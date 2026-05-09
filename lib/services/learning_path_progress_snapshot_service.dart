import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/learning_path_progress_snapshot.dart';
import '../infra/telemetry.dart';
import 'atomic_write_v1.dart';

abstract class ProgressSnapshotStorage {
  Future<void> save(String key, String value);
  Future<String?> load(String key);
}

class PrefsProgressSnapshotStorage implements ProgressSnapshotStorage {
  @override
  Future<void> save(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  @override
  Future<String?> load(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }
}

class FileProgressSnapshotStorage implements ProgressSnapshotStorage {
  FileProgressSnapshotStorage({Directory? rootDir})
    : _rootDirFuture = rootDir != null
          ? Future.value(rootDir)
          : _resolveRootDir();

  final Future<Directory> _rootDirFuture;

  static Future<Directory> _resolveRootDir() async {
    try {
      return await getApplicationSupportDirectory();
    } catch (_) {
      return Directory.systemTemp.createTempSync('lp_snapshot_v1');
    }
  }

  Future<File> _fileFor(String key) async {
    final dir = await _rootDirFuture;
    final safeKey = key.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    return File('${dir.path}/$safeKey.json');
  }

  Future<File> _backupFor(String key) async {
    final file = await _fileFor(key);
    return File('${file.path}.bak');
  }

  Future<Directory> get rootDirectory async => await _rootDirFuture;

  @override
  Future<void> save(String key, String value) async {
    final file = await _fileFor(key);
    await AtomicWriteV1.writeString(file, value);
  }

  @override
  Future<String?> load(String key) async {
    final file = await _fileFor(key);
    return AtomicWriteV1.readString(file);
  }

  Future<String?> loadBackup(String key) async {
    final file = await _backupFor(key);
    return AtomicWriteV1.readString(file);
  }

  Future<void> recoverFromBackup(String key) async {
    final backup = await _backupFor(key);
    final raw = await AtomicWriteV1.readString(backup);
    if (raw == null) return;
    final file = await _fileFor(key);
    await AtomicWriteV1.writeString(file, raw);
  }
}

class LearningPathProgressSnapshotService {
  LearningPathProgressSnapshotService({ProgressSnapshotStorage? storage})
    : storage = storage ?? FileProgressSnapshotStorage();

  final ProgressSnapshotStorage storage;

  static final instance = LearningPathProgressSnapshotService();

  static const _prefix = 'lp_snapshot_';

  Future<void> deleteAllSnapshots() async {
    if (storage is FileProgressSnapshotStorage) {
      final fileStorage = storage as FileProgressSnapshotStorage;
      final dir = await fileStorage.rootDirectory;
      if (await dir.exists()) {
        for (final entry in dir.listSync()) {
          if (entry is File) {
            final name = entry.uri.pathSegments.last;
            if (name.startsWith(_prefix)) {
              try {
                await entry.delete();
              } catch (_) {
                // Best-effort cleanup
              }
            }
          }
        }
      }
    }

    final prefs = await SharedPreferences.getInstance();
    for (final key in prefs.getKeys().where((k) => k.startsWith(_prefix))) {
      await prefs.remove(key);
    }
  }

  Future<void> save(String pathId, LearningPathProgressSnapshot snap) async {
    final key = '$_prefix$pathId';
    await storage.save(key, jsonEncode(snap.toJson()));
  }

  Future<LearningPathProgressSnapshot?> load(String pathId) async {
    final key = '$_prefix$pathId';
    String? raw = await storage.load(key);
    if (raw == null && storage is FileProgressSnapshotStorage) {
      final prefsRaw = await PrefsProgressSnapshotStorage().load(key);
      if (prefsRaw != null) {
        raw = prefsRaw;
        await storage.save(key, prefsRaw);
      }
    }
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return LearningPathProgressSnapshot.fromJson(map);
    } catch (_) {
      if (storage is FileProgressSnapshotStorage) {
        final fileStorage = storage as FileProgressSnapshotStorage;
        final backupRaw = await fileStorage.loadBackup(key);
        if (backupRaw != null) {
          try {
            final map = jsonDecode(backupRaw) as Map<String, dynamic>;
            await fileStorage.recoverFromBackup(key);
            await Telemetry.logEvent('learning_path_snapshot_corrupt_v1', {
              'pathId': pathId,
              'storage': 'file',
              'recovered': true,
              'reason': 'json_decode',
            });
            return LearningPathProgressSnapshot.fromJson(map);
          } catch (_) {
            // Fall through to null.
          }
        }
      }
      await Telemetry.logEvent('learning_path_snapshot_corrupt_v1', {
        'pathId': pathId,
        'storage': storage is FileProgressSnapshotStorage ? 'file' : 'prefs',
        'recovered': false,
        'reason': 'json_decode',
      });
      return null;
    }
  }
}
