import 'package:flutter/material.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/services/drill_runtime_adapter_v1.dart';
import 'package:poker_analyzer/ui_v2/screens/modern_table_screen_v1.dart';

class DebugDrillRuntimeAdapterV1Screen extends StatefulWidget {
  const DebugDrillRuntimeAdapterV1Screen({
    super.key,
    this.sessionId = 'w0.s01',
  });

  final String sessionId;

  static Route<void> route({String sessionId = 'w0.s01'}) {
    return MaterialPageRoute<void>(
      builder: (_) => DebugDrillRuntimeAdapterV1Screen(sessionId: sessionId),
    );
  }

  @override
  State<DebugDrillRuntimeAdapterV1Screen> createState() =>
      _DebugDrillRuntimeAdapterV1ScreenState();
}

class _DebugDrillRuntimeAdapterV1ScreenState
    extends State<DebugDrillRuntimeAdapterV1Screen> {
  final _adapter = const DrillRuntimeAdapterV1();
  final _evaluator = const DrillEvaluatorV1();

  List<SessionDrillItemV1> _drills = const [];
  bool _loading = true;
  String? _loadError;
  int _currentIndex = 0;
  bool? _lastPass;
  String? _lastErrorClass;
  String? _lastFailureDetail;

  SessionDrillItemV1? get _currentDrill =>
      _drills.isEmpty ? null : _drills[_currentIndex];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final drills = await _adapter.loadSessionDrills(widget.sessionId);
      if (!mounted) return;
      setState(() {
        _drills = drills;
        _loading = false;
        _loadError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadError = '$e';
      });
    }
  }

  void _handleEvent(DrillUserEventV1 event) {
    final current = _currentDrill;
    if (current == null) return;
    final result = _evaluator.evaluate(current.spec, event);
    if (result.isPass) {
      if (_currentIndex < _drills.length - 1) {
        setState(() {
          _currentIndex += 1;
          _lastPass = null;
          _lastErrorClass = null;
          _lastFailureDetail = null;
        });
      } else {
        setState(() {
          _lastPass = true;
          _lastErrorClass = null;
          _lastFailureDetail = null;
        });
      }
      return;
    }
    setState(() {
      _lastPass = false;
      _lastErrorClass = result.errorClass;
      _lastFailureDetail = _buildFailureDetail(current.spec, event);
    });
  }

  void _nextDrill() {
    if (_drills.isEmpty) return;
    setState(() {
      _currentIndex = (_currentIndex + 1).clamp(0, _drills.length - 1);
      _lastPass = null;
      _lastErrorClass = null;
      _lastFailureDetail = null;
    });
  }

  void _resetCurrent() {
    setState(() {
      _lastPass = null;
      _lastErrorClass = null;
      _lastFailureDetail = null;
    });
  }

  String _buildFailureDetail(DrillSpecV1 spec, DrillUserEventV1 event) {
    switch (spec.kind) {
      case DrillKindV1.seatTap:
        final expected = spec.expected.role != null
            ? 'role=${spec.expected.role}'
            : 'seatId=${spec.expected.seatId ?? '?'}';
        final got = event.role != null
            ? 'role=${event.role}'
            : 'seatId=${event.seatId ?? '?'}';
        return 'expected $expected, got $got';
      case DrillKindV1.actionChoice:
      case DrillKindV1.showdownWinnerChoice:
      case DrillKindV1.positionThinkingChoice:
      case DrillKindV1.initiativeAggressorChoice:
      case DrillKindV1.outsCountChoice:
        return 'expected actionId=${spec.expected.actionId ?? '?'}, got actionId=${event.actionId ?? '?'}';
      case DrillKindV1.betSizingChoice:
        return 'expected presetId=${spec.expected.presetId ?? '?'}, got presetId=${event.actionId ?? '?'}';
      case DrillKindV1.boardTextureClassifier:
      case DrillKindV1.rangeBucketClassifier:
      case DrillKindV1.handChain:
        return 'expected_action=${spec.expectedActionV1 ?? '?'}, got actionId=${event.actionId ?? '?'}';
      case DrillKindV1.boardTap:
        return 'expected boardSlot=${spec.expected.boardSlot ?? '?'}, got boardSlot=${event.boardSlot ?? '?'}';
      case DrillKindV1.holeCardsTap:
        final expectedCardSlot = spec.expected.cardSlot ?? '?';
        final gotCardSlot = event.cardSlot ?? '?';
        if (spec.expected.cardId != null) {
          return 'expected cardSlot=$expectedCardSlot cardId=${spec.expected.cardId}, got cardSlot=$gotCardSlot cardId=${event.cardId ?? '?'}';
        }
        return 'expected cardSlot=$expectedCardSlot, got cardSlot=$gotCardSlot';
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = _currentDrill;
    return Scaffold(
      appBar: AppBar(title: Text('Debug Drills ${widget.sessionId}')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _loadError != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _loadError!,
                  key: const Key('debug_drill_load_error'),
                ),
              ),
            )
          : current == null
          ? const Center(child: Text('No drills found'))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Drill ${_currentIndex + 1}/${_drills.length}: ${current.drillId} (${current.spec.kind.name})',
                        key: const Key('debug_drill_status_header'),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        current.spec.prompt,
                        key: const Key('debug_drill_prompt'),
                      ),
                      const SizedBox(height: 8),
                      if (_lastPass == null)
                        const Text('...', key: Key('debug_drill_result_idle'))
                      else if (_lastPass == true)
                        const Text('OK', key: Key('debug_drill_result_ok'))
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'FAIL (${_lastErrorClass ?? 'unknown'})',
                              key: const Key('debug_drill_result_fail'),
                            ),
                            if (_lastFailureDetail != null)
                              Text(
                                _lastFailureDetail!,
                                key: const Key(
                                  'debug_drill_result_fail_detail',
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: ModernTableScreenV1(
                    onSeatTapV1: (seatIndex) {
                      _handleEvent(
                        DrillUserEventV1.seatTap(
                          seatId: _adapter.seatIdForIndex(seatIndex),
                          role: _adapter.roleForSeat(
                            widget.sessionId,
                            seatIndex,
                          ),
                        ),
                      );
                    },
                    onActionTapV1: (actionId) {
                      _handleEvent(DrillUserEventV1.actionChoice(actionId));
                    },
                    onBoardSlotTapV1: (boardSlot) {
                      _handleEvent(DrillUserEventV1.boardTap(boardSlot));
                    },
                    onHoleCardTapDetailV1: (cardSlot, cardId) {
                      _handleEvent(
                        DrillUserEventV1.holeCardsTap(
                          cardSlot: cardSlot,
                          cardId: cardId,
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                  child: Row(
                    children: [
                      OutlinedButton(
                        onPressed: _resetCurrent,
                        child: const Text('Reset Result'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: _currentIndex < _drills.length - 1
                            ? _nextDrill
                            : null,
                        child: const Text('Next Drill'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
