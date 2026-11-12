import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

/// DAT-07 file envelope only. The Act0 shell remains the sole authority for
/// payload validation, awards, grading, and migration.
const act0Dat07FileFormatV1 = 'sharky.act0.progress';
const act0Dat07FormatRevisionV1 = 1;
const act0Dat07MaxFileBytesV1 = 8 * 1024 * 1024;

enum Act0Dat07ErrorCodeV1 {
  noProgress,
  tooLarge,
  invalidFile,
  invalidDigest,
  unsupportedFormat,
  unsupportedSchema,
  invalidProgress,
  changed,
  unverified,
}

class Act0Dat07ErrorV1 implements Exception {
  const Act0Dat07ErrorV1(this.code);
  final Act0Dat07ErrorCodeV1 code;

  String get userMessage => switch (code) {
    Act0Dat07ErrorCodeV1.noProgress => 'There is no saved progress to export.',
    Act0Dat07ErrorCodeV1.tooLarge => 'This backup file is too large.',
    Act0Dat07ErrorCodeV1.invalidFile => 'This is not a complete Sharky backup.',
    Act0Dat07ErrorCodeV1.invalidDigest =>
      'This backup failed its integrity check. Nothing was changed.',
    Act0Dat07ErrorCodeV1.unsupportedFormat =>
      'This backup format is not supported by this app version.',
    Act0Dat07ErrorCodeV1.unsupportedSchema =>
      'This progress version is not supported. Update Sharky before restoring.',
    Act0Dat07ErrorCodeV1.invalidProgress =>
      'The backup contains invalid progress. Nothing was changed.',
    Act0Dat07ErrorCodeV1.changed =>
      'Progress changed after preview. Select the file again.',
    Act0Dat07ErrorCodeV1.unverified =>
      'Restore could not be verified. Restart Sharky and check your progress.',
  };

  @override
  String toString() => userMessage;
}

class Act0Dat07BackupV1 {
  const Act0Dat07BackupV1({
    required this.payload,
    required this.sha256,
    required this.schemaVersion,
    this.exportedAtUtc,
    required this.earnedXp,
    required this.completedTasks,
    required this.completedLessons,
    required this.includesEvidence,
  });

  /// Original serialized bytes are kept unchanged. No records are projected
  /// back into a reconstructed learner state or regraded during transfer.
  final String payload;
  final String sha256;
  final int schemaVersion;
  final DateTime? exportedAtUtc;
  final int earnedXp;
  final int completedTasks;
  final int completedLessons;
  final bool includesEvidence;
}

class Act0Dat07CodecV1 {
  const Act0Dat07CodecV1({
    required this.isValidProgress,
    required this.supportedProgressSchema,
  });

  /// Inject the exact accepted Act0 shell payload validator, not a new store.
  final bool Function(String payload) isValidProgress;
  final int supportedProgressSchema;

  static String digest(String source) =>
      sha256.convert(utf8.encode(source)).toString();

  Act0Dat07BackupV1 _validatePayload(
    String payload, {
    DateTime? exportedAtUtc,
  }) {
    Map<String, dynamic> value;
    try {
      final parsed = jsonDecode(payload);
      if (parsed is! Map<String, dynamic>) {
        throw const Act0Dat07ErrorV1(Act0Dat07ErrorCodeV1.invalidProgress);
      }
      value = parsed;
    } on Act0Dat07ErrorV1 {
      rethrow;
    } catch (_) {
      throw const Act0Dat07ErrorV1(Act0Dat07ErrorCodeV1.invalidProgress);
    }

    if (value['schemaVersion'] != supportedProgressSchema) {
      throw const Act0Dat07ErrorV1(Act0Dat07ErrorCodeV1.unsupportedSchema);
    }

    // These fields are necessary to distinguish a complete progress snapshot
    // from a truncated but otherwise parseable map. The shell validator must
    // also approve the COMPLETE, source-owned payload before any write.
    bool strings(Object? source) =>
        source is List &&
        source.every((item) => item is String && item.isNotEmpty);
    final xp = value['earnedXp'];
    final tasks = value['completedTaskIds'];
    final lessons = value['completedLessonIds'];
    final evidence = value['learningEvidenceHistory'];
    if (xp is! int ||
        xp < 0 ||
        !strings(tasks) ||
        !strings(lessons) ||
        (evidence is! List && evidence is! Map)) {
      throw const Act0Dat07ErrorV1(Act0Dat07ErrorCodeV1.invalidProgress);
    }
    try {
      if (!isValidProgress(payload)) {
        throw const Act0Dat07ErrorV1(Act0Dat07ErrorCodeV1.invalidProgress);
      }
    } on Act0Dat07ErrorV1 {
      rethrow;
    } catch (_) {
      throw const Act0Dat07ErrorV1(Act0Dat07ErrorCodeV1.invalidProgress);
    }
    return Act0Dat07BackupV1(
      payload: payload,
      sha256: digest(payload),
      schemaVersion: supportedProgressSchema,
      exportedAtUtc: exportedAtUtc,
      earnedXp: xp,
      completedTasks: (tasks as List).length,
      completedLessons: (lessons as List).length,
      includesEvidence: evidence is List
          ? evidence.isNotEmpty
          : (evidence as Map).isNotEmpty,
    );
  }

  Uint8List exportPayload(String payload, {required DateTime exportedAtUtc}) {
    final backup = _validatePayload(payload);
    if (utf8.encode(payload).length > act0Dat07MaxFileBytesV1 ~/ 2) {
      throw const Act0Dat07ErrorV1(Act0Dat07ErrorCodeV1.tooLarge);
    }
    final file = jsonEncode(<String, Object>{
      'format': act0Dat07FileFormatV1,
      'formatRevision': act0Dat07FormatRevisionV1,
      'progressSchemaVersion': backup.schemaVersion,
      'createdAtUtc': exportedAtUtc.toUtc().toIso8601String(),
      'payloadLength': utf8.encode(payload).length,
      'payloadSha256': backup.sha256,
      'payload': payload,
    });
    final bytes = Uint8List.fromList(utf8.encode(file));
    if (bytes.length > act0Dat07MaxFileBytesV1) {
      throw const Act0Dat07ErrorV1(Act0Dat07ErrorCodeV1.tooLarge);
    }
    return bytes;
  }

  Act0Dat07BackupV1 inspectBytes(Uint8List bytes) {
    if (bytes.isEmpty) {
      throw const Act0Dat07ErrorV1(Act0Dat07ErrorCodeV1.invalidFile);
    }
    if (bytes.length > act0Dat07MaxFileBytesV1) {
      throw const Act0Dat07ErrorV1(Act0Dat07ErrorCodeV1.tooLarge);
    }
    Map<String, dynamic> envelope;
    try {
      final decoded = jsonDecode(utf8.decode(bytes, allowMalformed: false));
      if (decoded is! Map<String, dynamic>) {
        throw const Act0Dat07ErrorV1(Act0Dat07ErrorCodeV1.invalidFile);
      }
      envelope = decoded;
    } on Act0Dat07ErrorV1 {
      rethrow;
    } catch (_) {
      throw const Act0Dat07ErrorV1(Act0Dat07ErrorCodeV1.invalidFile);
    }
    if (envelope['format'] != act0Dat07FileFormatV1 ||
        envelope['formatRevision'] != act0Dat07FormatRevisionV1) {
      throw const Act0Dat07ErrorV1(Act0Dat07ErrorCodeV1.unsupportedFormat);
    }
    if (envelope.length != 7 ||
        envelope['createdAtUtc'] is! String ||
        envelope['progressSchemaVersion'] is! int ||
        envelope['payloadLength'] is! int ||
        envelope['payloadSha256'] is! String ||
        envelope['payload'] is! String) {
      throw const Act0Dat07ErrorV1(Act0Dat07ErrorCodeV1.invalidFile);
    }
    final createdAt = DateTime.tryParse(envelope['createdAtUtc'] as String);
    if (createdAt == null || !createdAt.isUtc) {
      throw const Act0Dat07ErrorV1(Act0Dat07ErrorCodeV1.invalidFile);
    }
    final raw = envelope['payload'] as String;
    if (utf8.encode(raw).length != envelope['payloadLength'] ||
        digest(raw) != envelope['payloadSha256']) {
      throw const Act0Dat07ErrorV1(Act0Dat07ErrorCodeV1.invalidDigest);
    }
    if (envelope['progressSchemaVersion'] != supportedProgressSchema) {
      throw const Act0Dat07ErrorV1(Act0Dat07ErrorCodeV1.unsupportedSchema);
    }
    final backup = _validatePayload(raw, exportedAtUtc: createdAt);
    if (backup.schemaVersion != envelope['progressSchemaVersion']) {
      throw const Act0Dat07ErrorV1(Act0Dat07ErrorCodeV1.invalidProgress);
    }
    return backup;
  }
}

/// The existing canonical store must implement compare-and-swap under its ONE
/// serialization queue, with its current atomic checkpoint/verification path.
/// In particular, a read-then-save pair is NOT a safe implementation.
/// Revision is a destination-local checkpoint generation, not a source
/// progress schema or a timestamp. Revision must come from the canonical
/// store's resolver; never synthesize it from XP or the current payload.
typedef Act0Dat07DurableStateV1 = ({int revision, String? payload});

abstract class Act0Dat07ProgressPortV1 {
  Future<Act0Dat07DurableStateV1> readDurableSnapshot();

  /// Compare the exact revision AND payload inside the current store queue.
  /// Even A -> B -> A or reset -> empty must invalidate an old preview.
  Future<Act0Dat07WriteResultV1> restoreIfUnchanged({
    required Act0Dat07DurableStateV1 expected,
    required String incomingPayload,
  });
}

/// changed guarantees no restore commit was attempted. unverified (including
/// a thrown port call) may have committed and requires shell reconciliation.
enum Act0Dat07WriteResultV1 { committed, changed, unverified }

enum Act0Dat07RestoreOutcomeV1 {
  restored,
  alreadyPresent,
  conflict,
  notVerified,
}

class Act0Dat07PreviewV1 {
  const Act0Dat07PreviewV1._(this.backup, this._originalState);
  final Act0Dat07BackupV1 backup;
  final Act0Dat07DurableStateV1 _originalState;

  bool get alreadyPresent => _originalState.payload == backup.payload;
  bool get conflict => _originalState.payload != null && !alreadyPresent;
  bool get mayRestore => _originalState.payload == null && !alreadyPresent;
}

/// Import is replacement of one opaque, validated source snapshot, never a
/// sum of XP or union of attempts. Existing different progress is a conflict.
class Act0Dat07TransferV1 {
  const Act0Dat07TransferV1({required this.codec, required this.port});

  final Act0Dat07CodecV1 codec;
  final Act0Dat07ProgressPortV1 port;

  Future<Uint8List> export({required DateTime exportedAtUtc}) async {
    final current = await port.readDurableSnapshot();
    if (current.payload == null) {
      throw const Act0Dat07ErrorV1(Act0Dat07ErrorCodeV1.noProgress);
    }
    return codec.exportPayload(current.payload!, exportedAtUtc: exportedAtUtc);
  }

  Future<Act0Dat07PreviewV1> inspect(Uint8List file) async {
    final backup = codec.inspectBytes(file);
    final current = await port.readDurableSnapshot();
    return Act0Dat07PreviewV1._(backup, current);
  }

  Future<Act0Dat07RestoreOutcomeV1> confirm(Act0Dat07PreviewV1 preview) async {
    // The port must enforce this once more AT THE DURABLE WRITE, not merely
    // here. An old progress state cannot be overwritten by a stale preview.
    final current = await port.readDurableSnapshot();
    if (current != preview._originalState) {
      return Act0Dat07RestoreOutcomeV1.conflict;
    }
    if (current.payload == preview.backup.payload) {
      return Act0Dat07RestoreOutcomeV1.alreadyPresent;
    }
    if (current.payload != null) {
      return Act0Dat07RestoreOutcomeV1.conflict;
    }
    Act0Dat07WriteResultV1 written;
    try {
      written = await port.restoreIfUnchanged(
        expected: current,
        incomingPayload: preview.backup.payload,
      );
    } catch (_) {
      // A thrown write may have landed. Never classify it as a conflict.
      return Act0Dat07RestoreOutcomeV1.notVerified;
    }
    if (written == Act0Dat07WriteResultV1.changed) {
      return Act0Dat07RestoreOutcomeV1.conflict;
    }
    // Failure/exception must never be reinterpreted as rollback: a committed
    // checkpoint may be revealed on the next verified load.
    if (written != Act0Dat07WriteResultV1.committed) {
      return Act0Dat07RestoreOutcomeV1.notVerified;
    }
    try {
      final durable = await port.readDurableSnapshot();
      return durable.revision > current.revision &&
              durable.payload == preview.backup.payload
          ? Act0Dat07RestoreOutcomeV1.restored
          : Act0Dat07RestoreOutcomeV1.notVerified;
    } catch (_) {
      return Act0Dat07RestoreOutcomeV1.notVerified;
    }
  }
}
