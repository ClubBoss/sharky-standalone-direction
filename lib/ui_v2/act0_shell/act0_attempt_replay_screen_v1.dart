import 'dart:async';

import 'package:flutter/material.dart';

import 'act0_academy_reading_style_v1.dart';
import 'act0_attempt_archive_v1.dart';
import 'act0_shell_tokens_v1.dart';

class Act0AttemptReplayScreenV1 extends StatefulWidget {
  const Act0AttemptReplayScreenV1({
    super.key,
    required this.attempt,
    required this.onClose,
  });

  final Act0ArchivedAttemptV1 attempt;
  final VoidCallback onClose;

  @override
  State<Act0AttemptReplayScreenV1> createState() =>
      _Act0AttemptReplayScreenV1State();
}

class _Act0AttemptReplayScreenV1State extends State<Act0AttemptReplayScreenV1> {
  late var _replay = Act0AttemptReplayV1(widget.attempt);
  Timer? _timer;

  void _update(Act0AttemptReplayV1 replay) {
    setState(() => _replay = replay);
    if (!replay.isPlaying) {
      _timer?.cancel();
      _timer = null;
    }
  }

  void _togglePlayback() {
    if (_replay.isPlaying) {
      _update(_replay.pause());
    } else {
      _update(_replay.play());
      if (_replay.isPlaying) {
        _timer = Timer.periodic(
          const Duration(seconds: 1),
          (_) => _update(_replay.tick()),
        );
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final attempt = widget.attempt;
    final total = attempt.events.length;
    final pagePadding = Act0ShellTokensV1.pageHorizontalPaddingFor(context);
    final history = _replay.textAlternative;
    return ListView(
      key: const Key('act0_attempt_replay_screen'),
      padding: EdgeInsets.fromLTRB(
        pagePadding,
        Act0ShellTokensV1.gapMd,
        pagePadding,
        Act0ShellTokensV1.gapXl,
      ),
      children: [
        Act0ShellTokensV1.centeredContent(
          context,
          tabletMaxWidth: 860,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton(
                key: const Key('act0_attempt_replay_back_to_archive'),
                onPressed: widget.onClose,
                child: const Text('Back to attempt archive'),
              ),
              Text(
                attempt.taskLabel ?? attempt.evidence.taskId,
                style: Act0AcademyReadingStyleV1.sectionTitle,
              ),
              const SizedBox(height: Act0ShellTokensV1.gapMd),
              if (total == 0)
                const Text(
                  'No event history was saved for this attempt.',
                  style: Act0AcademyReadingStyleV1.muted,
                )
              else ...[
                Semantics(
                  liveRegion: true,
                  child: Text(
                    'Step ${_replay.position} of $total',
                    style: Act0AcademyReadingStyleV1.muted,
                  ),
                ),
                Wrap(
                  spacing: Act0ShellTokensV1.gapXs,
                  children: [
                    TextButton(
                      key: const Key('act0_attempt_replay_previous'),
                      onPressed: _replay.position == 0
                          ? null
                          : () => _update(_replay.back()),
                      child: const Text('Previous'),
                    ),
                    TextButton(
                      key: const Key('act0_attempt_replay_next'),
                      onPressed: _replay.atEnd
                          ? null
                          : () => _update(_replay.pause().forward()),
                      child: const Text('Next'),
                    ),
                    TextButton(
                      key: const Key('act0_attempt_replay_play_pause'),
                      onPressed: _replay.atEnd ? null : _togglePlayback,
                      child: Text(_replay.isPlaying ? 'Pause' : 'Play'),
                    ),
                    TextButton(
                      key: const Key('act0_attempt_replay_reset'),
                      onPressed: _replay.position == 0 && !_replay.isPlaying
                          ? null
                          : () => _update(_replay.reset()),
                      child: const Text('Reset'),
                    ),
                  ],
                ),
                if (history.isNotEmpty) ...[
                  Text(
                    history.last,
                    key: const Key('act0_attempt_replay_current_event'),
                    style: Act0AcademyReadingStyleV1.body,
                  ),
                  if (history.length > 1)
                    ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      title: const Text('Earlier steps'),
                      collapsedTextColor: Act0AcademyReadingStyleV1.text,
                      textColor: Act0AcademyReadingStyleV1.text,
                      children: [
                        for (final event in history.take(history.length - 1))
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              event,
                              style: Act0AcademyReadingStyleV1.body,
                            ),
                          ),
                      ],
                    ),
                ],
              ],
            ],
          ),
        ),
      ],
    );
  }
}
