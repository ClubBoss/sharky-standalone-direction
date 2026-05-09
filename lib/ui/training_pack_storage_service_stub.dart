import 'dart:io';

import 'package:poker_analyzer/models/training_pack.dart';

import 'flutter_stub_test.dart';

class TrainingPackStorageService extends ChangeNotifier {
  TrainingPackStorageService({Object? cloud});

  static Directory? _overrideDirectory;
  static Directory? _generatedDirectory;
  static final Map<String, List<Map<String, Object?>>> _store = {};

  static void setTestDirectory(Directory directory) {
    _overrideDirectory = directory;
  }

  static void clearTestDirectory() {
    _overrideDirectory = null;
  }

  static Directory _resolveDirectory() {
    final override = _overrideDirectory;
    if (override != null) return override;
    final existing = _generatedDirectory;
    if (existing != null) return existing;
    final created = Directory.systemTemp.createTempSync(
      'training_pack_storage_stub',
    );
    _generatedDirectory = created;
    return created;
  }

  final List<TrainingPack> _packs = [];

  List<TrainingPack> get packs => List.unmodifiable(_packs);

  Future<void> addPack(TrainingPack pack) async {
    _packs.add(pack);
    await _persist();
    notifyListeners();
  }

  Future<void> load() async {
    final stored = _store[_storageKey()];
    if (stored == null) return;
    _packs
      ..clear()
      ..addAll(
        stored.map(
          (e) => TrainingPack(
            id: e['id'] as String?,
            name: e['name'] as String? ?? '',
            description: e['description'] as String? ?? '',
            hands: const [],
          ),
        ),
      );
  }

  Future<void> clear() async {
    _packs.clear();
    _store.remove(_storageKey());
    notifyListeners();
  }

  Future<void> _persist() async {
    _store[_storageKey()] = [
      for (final pack in _packs)
        {'id': pack.id, 'name': pack.name, 'description': pack.description},
    ];
  }

  String _storageKey() {
    final dir = _resolveDirectory();
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    return dir.path;
  }
}
