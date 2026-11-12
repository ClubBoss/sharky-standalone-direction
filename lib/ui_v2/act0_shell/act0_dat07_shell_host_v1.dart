part of 'act0_shell_preview_screen_v1.dart';

// One process-wide lifetime gate for the one canonical progress key. Forced
// parent removal deliberately leaves it held: only a verified remount can
// release it; restarting the process is the safe escape from an abandoned UI.
final _act0Dat07SessionsV1 = <_Act0ShellPreviewScreenV1State>{};
_Act0Dat07BarrierV1? _act0Dat07BarrierV1;
// Dev reset includes prefs.clear() outside the canonical Store queue. Hold the
// entire destructive operation, not just its before/after continuation checks.
Completer<void>? _act0Dat07ResetInFlightV1;

class _Act0Dat07BarrierV1 {
  _Act0Dat07BarrierV1(this.owner);
  final _Act0Dat07ShellHostV1State owner;
  final released = Completer<void>();
}

class _Act0Dat07ScopeV1 extends InheritedWidget {
  const _Act0Dat07ScopeV1({
    super.key,
    required this.token,
    required super.child,
  });
  final Object token;
  @override
  bool updateShouldNotify(_Act0Dat07ScopeV1 oldWidget) =>
      !identical(token, oldWidget.token);
}

/// Owns canonical shell replacement for the native backup/restore route.
/// The existing shell and all its observation-only test APIs stay unchanged.
class Act0Dat07ShellHostV1 extends StatefulWidget {
  const Act0Dat07ShellHostV1({
    super.key,
    required this.shell,
    this.fileBridge = const Act0Dat07NativeFileBridgeV1(),
  });
  final Act0ShellPreviewScreenV1 shell;
  final Act0Dat07FileBridgeV1 fileBridge;

  @override
  State<Act0Dat07ShellHostV1> createState() => _Act0Dat07ShellHostV1State();
}

class _Act0Dat07ShellHostV1State extends State<Act0Dat07ShellHostV1> {
  Object _generationToken = Object();
  _Act0ShellPreviewScreenV1State? _session;
  Act0Dat07TransferV1? _transfer;
  Completer<bool>? _remountReady;
  bool _opening = false;
  bool _closing = false;
  String? _failure;
  Act0ShellPreviewScreenV1? _pinnedShell;

  bool _tokenMatches(_Act0ShellPreviewScreenV1State session) => identical(
    session.context.getInheritedWidgetOfExactType<_Act0Dat07ScopeV1>()?.token,
    _generationToken,
  );

  bool _admitsBoot(_Act0ShellPreviewScreenV1State session) =>
      mounted &&
      identical(_act0Dat07BarrierV1?.owner, this) &&
      _remountReady != null &&
      identical(session._dat07HostV1, this) &&
      _tokenMatches(session);

  void _sessionReady(_Act0ShellPreviewScreenV1State session) {
    if (!mounted || !_tokenMatches(session)) return;
    _session = session;
    final ready =
        session._progressRestoredV1 &&
        !session._progressLoadFailed &&
        session._bootSurfaceReady &&
        session._progressStore.isWriteLeaseCurrent;
    final pending = _remountReady;
    if (pending != null && !pending.isCompleted) pending.complete(ready);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && identical(_session, session)) setState(() {});
    });
  }

  Act0Dat07TransferV1 _controller(Act0ProgressStoreV1 store) =>
      Act0Dat07TransferV1(
        codec: const Act0Dat07CodecV1(
          isValidProgress: act0CanonicalProgressIsValidV1,
          supportedProgressSchema: act0CanonicalProgressSchemaV1,
        ),
        port: Act0Dat07CanonicalStorePortV1(
          store: store,
          supportedProgressSchema: act0CanonicalProgressSchemaV1,
        ),
      );

  void _open() {
    final session = _session;
    if (!mounted ||
        _act0Dat07BarrierV1 != null ||
        _act0Dat07ResetInFlightV1 != null ||
        session == null ||
        !session._usesPersistedProgress ||
        !session._progressRestoredV1 ||
        session._progressLoadFailed ||
        session._recoveryBusyV1 ||
        !session._progressStore.isWriteLeaseCurrent)
      return;
    _act0Dat07BarrierV1 = _Act0Dat07BarrierV1(this);
    _pinnedShell = widget.shell;
    // Before any await, invalidate microtask saves and all captured callbacks.
    final sessions = _act0Dat07SessionsV1
        .where((s) => s._usesPersistedProgress)
        .toList(growable: false);
    for (final old in sessions) {
      old._freezeForDat07V1();
    }
    setState(() {
      _opening = true;
      _failure = null;
    });
    unawaited(_drainAndOpen(session, sessions));
  }

  Future<void> _drainAndOpen(
    _Act0ShellPreviewScreenV1State session,
    List<_Act0ShellPreviewScreenV1State> sessions,
  ) async {
    try {
      for (final old in sessions) {
        await old._progressStore.flush();
      }
      if (!mounted || !identical(_act0Dat07BarrierV1?.owner, this)) return;
      // Canonical load may heal or complete a pending recovery. It is not a
      // synthetic fresh snapshot and a tombstone keeps its durable revision.
      await session._progressStore.readDurableSnapshot();
      if (!mounted) return;
      setState(() {
        _transfer = _controller(session._progressStore);
        _opening = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _opening = false;
        _failure =
            'Saved progress could not be read safely. Retry reload or '
            'restart Sharky. Navigation remains locked.';
      });
    }
  }

  Future<void> _reconcile() async {
    if (!mounted ||
        !identical(_act0Dat07BarrierV1?.owner, this) ||
        _remountReady != null)
      throw const Act0RecoveryHoldV1();
    final ready = Completer<bool>();
    setState(() {
      _remountReady = ready;
      _session = null;
      _generationToken = Object();
    });
    // This completes only after ordinary canonical bootstrap reports durable
    // success, including first-start preference reads. Failure is never ready.
    final verified = await ready.future;
    _remountReady = null;
    final fresh = _session;
    if (!mounted ||
        !verified ||
        fresh == null ||
        !fresh.mounted ||
        !_tokenMatches(fresh) ||
        !fresh._progressStore.isWriteLeaseCurrent) {
      throw const Act0RecoveryHoldV1();
    }
    setState(() {
      // The old restore port fenced itself at commit; never reuse that writer.
      _transfer = _controller(fresh._progressStore);
      _failure = null;
      _opening = false;
    });
  }

  Future<void> _close() async {
    if (_closing || _opening || _remountReady != null) return;
    setState(() => _closing = true);
    try {
      await _reconcile();
      if (!mounted) return;
      final fresh = _session!;
      final barrier = _act0Dat07BarrierV1!;
      // Only this new, canonical state may resume. Any other frozen old shell
      // stays suspended; releasing a global barrier must not revive old data.
      fresh._resumeAfterDat07V1();
      setState(() {
        _transfer = null;
        _closing = false;
        _failure = null;
        _pinnedShell = null;
        _act0Dat07BarrierV1 = null;
      });
      barrier.released.complete();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _closing = false;
        _failure =
            'Progress could not be safely reloaded. Retry reload or '
            'restart Sharky. Navigation remains locked.';
      });
    }
  }

  @override
  void dispose() {
    final pending = _remountReady;
    if (pending != null && !pending.isCompleted) pending.complete(false);
    // No unlock here: the ordinary dispose path must never revive stale state.
    super.dispose();
  }

  Act0ShellPreviewScreenV1 _buildSession() {
    final source = _pinnedShell ?? widget.shell;
    // The host owns session identity, including when a caller supplied a
    // GlobalKey. Reparenting that key would preserve precisely the stale State
    // that canonical reconciliation must discard.
    return Act0ShellPreviewScreenV1(
      key: ObjectKey(_generationToken),
      initialTab: source.initialTab,
      initialPhase: source.initialPhase,
      state: source.state,
      showPlacementOnStart: source.showPlacementOnStart,
      debugHarnessEntry: source.debugHarnessEntry,
      telemetrySink: source.telemetrySink,
      debugSessionDrillRecheckQueueItemsV1:
          source.debugSessionDrillRecheckQueueItemsV1,
      debugLoadSessionDrillRecheckQueueItemsV1:
          source.debugLoadSessionDrillRecheckQueueItemsV1,
      clock: source.clock,
      tableVisualVariant: source.tableVisualVariant,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ownsBarrier = identical(_act0Dat07BarrierV1?.owner, this);
    final session = _session;
    final firstStartRestore =
        !ownsBarrier &&
        session != null &&
        session._progressRestoredV1 &&
        session._dat07LoadedEmptyV1 &&
        (session._showPlacement || session._showWelcome);
    return PopScope(
      canPop: !ownsBarrier,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Offstage(
            offstage: ownsBarrier,
            child: ExcludeFocus(
              excluding: ownsBarrier,
              child: IgnorePointer(
                ignoring: ownsBarrier,
                child: _Act0Dat07ScopeV1(
                  key: ObjectKey(_generationToken),
                  token: _generationToken,
                  child: _buildSession(),
                ),
              ),
            ),
          ),
          if (firstStartRestore)
            Positioned(
              top: 0,
              right: 12,
              child: SafeArea(
                child: TextButton(
                  key: const Key('dat07_first_start_restore'),
                  onPressed: _open,
                  child: const Text('Restore backup'),
                ),
              ),
            ),
          if (_transfer != null)
            Act0Dat07TransferScreenV1(
              controller: _transfer!,
              fileBridge: widget.fileBridge,
              onBack: () => unawaited(_close()),
              onRestored: _reconcile,
              onReconcileRestore: _reconcile,
            ),
          if (_opening || _closing || _failure != null)
            Scaffold(
              body: SafeArea(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_failure == null) const CircularProgressIndicator(),
                      if (_failure != null) ...[
                        Text(_failure!, textAlign: TextAlign.center),
                        TextButton(
                          key: const Key('dat07_host_retry_reload'),
                          onPressed: _closing
                              ? null
                              : () => unawaited(_close()),
                          child: const Text('Retry safe reload'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
