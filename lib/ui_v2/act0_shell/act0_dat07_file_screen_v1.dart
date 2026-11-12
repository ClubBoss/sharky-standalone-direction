import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'act0_dat07_transfer_v1.dart';

/// Native, user-chosen Files path. The OS owns document selection and the
/// share/save destination; no account, background sync or blanket file access.
abstract class Act0Dat07FileBridgeV1 {
  Future<Uint8List?> selectBackup();
  Future<void> shareBackup(Uint8List bytes);
}

class Act0Dat07NativeFileBridgeV1 implements Act0Dat07FileBridgeV1 {
  const Act0Dat07NativeFileBridgeV1();

  @override
  Future<Uint8List?> selectBackup() async {
    final selected = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['json'],
      allowMultiple: false,
      withData: false,
    );
    if (selected == null) return null; // User cancelled; no storage mutation.
    if (selected.files.length != 1) {
      throw const Act0Dat07ErrorV1(Act0Dat07ErrorCodeV1.invalidFile);
    }
    final picked = selected.files.single;
    if (picked.size > act0Dat07MaxFileBytesV1) {
      throw const Act0Dat07ErrorV1(Act0Dat07ErrorCodeV1.tooLarge);
    }
    if (picked.bytes != null) return picked.bytes;
    if (picked.path == null) {
      throw const Act0Dat07ErrorV1(Act0Dat07ErrorCodeV1.invalidFile);
    }
    final file = File(picked.path!);
    if (await file.length() > act0Dat07MaxFileBytesV1) {
      throw const Act0Dat07ErrorV1(Act0Dat07ErrorCodeV1.tooLarge);
    }
    return file.readAsBytes();
  }

  @override
  Future<void> shareBackup(Uint8List bytes) async {
    if (bytes.isEmpty || bytes.length > act0Dat07MaxFileBytesV1) {
      throw const Act0Dat07ErrorV1(Act0Dat07ErrorCodeV1.tooLarge);
    }
    final dir = await getTemporaryDirectory();
    final timestamp = DateTime.now().toUtc().millisecondsSinceEpoch;
    final file = File('${dir.path}/sharky-progress-$timestamp.json');
    try {
      await file.writeAsBytes(bytes, flush: true);
      if (await file.length() != bytes.length) {
        throw const Act0Dat07ErrorV1(Act0Dat07ErrorCodeV1.unverified);
      }
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/json')],
        subject: 'Sharky progress backup',
        text: 'Save this private progress file to Files for later restoration.',
      );
    } finally {
      try {
        if (await file.exists()) await file.delete();
      } catch (_) {
        // Temporary share cleanup is best-effort; it is never the sole backup.
      }
    }
  }
}

/// Standalone English/iPhone 14 Pro backup and preview surface. The shell must
/// route to it and supply the *canonical* progress port before it is reachable.
/// Both completion callbacks must fence/dispose old state and remount from a
/// verified canonical load before returning. The owner must also prevent shell
/// replacement/navigation and new writers while this route is locked.
class Act0Dat07TransferScreenV1 extends StatefulWidget {
  const Act0Dat07TransferScreenV1({
    super.key,
    required this.controller,
    required this.fileBridge,
    this.onBack,
    required this.onRestored,
    required this.onReconcileRestore,
  });

  final Act0Dat07TransferV1 controller;
  final Act0Dat07FileBridgeV1 fileBridge;
  final VoidCallback? onBack;

  /// This callback must complete a canonical durable remount/fence.
  /// A fire-and-forget restart would leave the old shell able to write.
  final Future<void> Function() onRestored;

  /// Required after an unverified attempt or failed success callback. A normal
  /// canonical startup/read must decide durable truth; never reapply the file.
  /// Complete only when old writers are fenced and the shell is safely rebuilt.
  /// Throw if unresolved: this screen stays locked and offers reconciliation
  /// retry only. This callback must be idempotent and must not import again.
  final Future<void> Function() onReconcileRestore;

  @override
  State<Act0Dat07TransferScreenV1> createState() =>
      _Act0Dat07TransferScreenV1State();
}

class _Act0Dat07TransferScreenV1State extends State<Act0Dat07TransferScreenV1> {
  bool _busy = false;
  bool _requiresReconciliation = false;
  bool get _locked => _busy || _requiresReconciliation;
  Act0Dat07PreviewV1? _preview;
  String? _message;

  void _back() {
    if (!mounted || _locked) return;
    widget.onBack?.call();
  }

  void _cancelPreview() {
    if (!mounted || _locked) return;
    setState(() {
      _preview = null;
      _message = 'Import cancelled. Progress was not changed.';
    });
  }

  Future<void> _backup() async {
    if (_locked) return;
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final bytes = await widget.controller.export(
        exportedAtUtc: DateTime.now().toUtc(),
      );
      await widget.fileBridge.shareBackup(bytes);
      if (!mounted) return;
      setState(() {
        _message =
            'Share sheet closed. Check that you saved the JSON file '
            'to Files or another private destination.';
      });
    } on Act0Dat07ErrorV1 catch (error) {
      if (mounted) setState(() => _message = error.userMessage);
    } catch (_) {
      if (mounted) {
        setState(() => _message = 'Could not open the backup share sheet.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _choose() async {
    if (_locked) return;
    setState(() {
      _busy = true;
      _preview = null;
      _message = null;
    });
    try {
      final bytes = await widget.fileBridge.selectBackup();
      if (!mounted || bytes == null) return;
      final proposal = await widget.controller.inspect(bytes);
      if (mounted) setState(() => _preview = proposal);
    } on Act0Dat07ErrorV1 catch (error) {
      if (mounted) setState(() => _message = error.userMessage);
    } catch (_) {
      if (mounted) {
        setState(() => _message = 'Could not read the selected file.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _restore() async {
    final proposal = _preview;
    if (_locked || proposal == null || !proposal.mayRestore) return;
    setState(() {
      _busy = true;
      _message = null;
    });
    // Lock before entering the controller: even an exception is not rollback.
    _requiresReconciliation = true;
    try {
      final outcome = await widget.controller.confirm(proposal);
      if (!mounted) return;
      switch (outcome) {
        case Act0Dat07RestoreOutcomeV1.restored:
          await _reconcile(restored: true);
        case Act0Dat07RestoreOutcomeV1.alreadyPresent:
          setState(() {
            _requiresReconciliation = false;
            _preview = null;
            _message = 'This progress is already saved. No XP was added.';
          });
        case Act0Dat07RestoreOutcomeV1.conflict:
          setState(() {
            _requiresReconciliation = false;
            _preview = null;
            _message =
                'Your local progress changed or conflicts with this '
                'backup. Nothing was overwritten. Select the file again.';
          });
        case Act0Dat07RestoreOutcomeV1.notVerified:
          await _reconcile(restored: false);
      }
    } catch (_) {
      // Conservative even for a pre-write read failure. A port exception never
      // permits stale shell state to resume or an automatic import retry.
      if (mounted) await _reconcile(restored: false);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _reconcile({required bool restored}) async {
    try {
      if (restored) {
        await widget.onRestored();
      } else {
        await widget.onReconcileRestore();
      }
      if (!mounted) return;
      setState(() {
        _requiresReconciliation = false;
        _preview = null;
        _message = restored
            ? 'Saved progress restored and reloaded.'
            : 'Saved progress reloaded. The restore outcome was uncertain. '
                  'Check your progress before choosing another backup.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _requiresReconciliation = true;
        _preview = null;
        _message =
            'Progress could not be safely reloaded. '
            'Restore and navigation remain locked. Retry reload or '
            'restart Sharky before continuing.';
      });
    }
  }

  Future<void> _retryReconciliation() async {
    if (_busy || !_requiresReconciliation) return;
    setState(() => _busy = true);
    try {
      await _reconcile(restored: false);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final proposal = _preview;
    return PopScope(
      canPop: !_locked,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Back up & restore'),
          leading: widget.onBack == null
              ? null
              : IconButton(
                  key: const Key('dat07_back'),
                  onPressed: _locked ? null : _back,
                  icon: const Icon(Icons.arrow_back),
                ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Keep your learning progress',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text(
              'Save a private backup to Files. On a new device or '
              'after reinstalling, choose that file to preview the saved '
              'progress before restoring. No account is required.',
            ),
            const SizedBox(height: 16),
            FilledButton(
              key: const Key('dat07_export'),
              onPressed: _locked ? null : _backup,
              child: const Text('Back up to a file'),
            ),
            OutlinedButton(
              key: const Key('dat07_select_file'),
              onPressed: _locked ? null : _choose,
              child: const Text('Choose a backup file'),
            ),
            if (_busy)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(14),
                  child: CircularProgressIndicator(),
                ),
              ),
            if (_message != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(_message!, key: const Key('dat07_status')),
              ),
            if (_requiresReconciliation && !_busy)
              FilledButton(
                key: const Key('dat07_retry_reload'),
                onPressed: _retryReconciliation,
                child: const Text('Retry safe reload'),
              ),
            if (proposal != null) ...[
              const Divider(height: 32),
              const Text(
                'Backup preview',
                key: Key('dat07_preview_title'),
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text('File format: v1'),
              Text('Data schema: ${proposal.backup.schemaVersion}'),
              Text(
                'Backup created (UTC): '
                '${proposal.backup.exportedAtUtc?.toIso8601String() ?? 'unknown'}',
              ),
              Text('Earned XP: ${proposal.backup.earnedXp}'),
              Text('Completed tasks: ${proposal.backup.completedTasks}'),
              Text('Completed lessons: ${proposal.backup.completedLessons}'),
              Text(
                'Learning history: '
                '${proposal.backup.includesEvidence ? 'included' : 'empty'}',
              ),
              Text(
                'Integrity SHA-256: '
                '${proposal.backup.sha256.substring(0, 16)}...',
              ),
              const SizedBox(height: 12),
              if (proposal.conflict)
                const Text(
                  'This device already contains different progress. '
                  'For safety, this version does not merge or replace it. '
                  'Export your current progress before choosing a recovery plan.',
                  key: Key('dat07_conflict'),
                )
              else if (proposal.alreadyPresent)
                const Text(
                  'This exact snapshot is already present. '
                  'Importing it again cannot award more XP.',
                  key: Key('dat07_already_present'),
                )
              else
                const Text(
                  'Restore this snapshot? This will use the existing '
                  'atomic progress store. No attempts or XP are added. '
                  'After confirming, restore cannot be cancelled.',
                  key: Key('dat07_confirm_warning'),
                ),
              const SizedBox(height: 12),
              FilledButton(
                key: const Key('dat07_confirm'),
                onPressed: _locked || !proposal.mayRestore ? null : _restore,
                child: const Text('Confirm restore'),
              ),
              TextButton(
                key: const Key('dat07_cancel'),
                onPressed: _locked ? null : _cancelPreview,
                child: const Text('Cancel'),
              ),
            ],
            const SizedBox(height: 16),
            const Text(
              'The JSON backup is not encrypted. Keep it private. '
              'A checksum detects accidental damage, not deliberate tampering.',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
