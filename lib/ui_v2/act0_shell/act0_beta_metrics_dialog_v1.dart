import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'act0_beta_metrics_v1.dart';
import 'act0_practice_reminder_v1.dart';

class Act0BetaMetricsDialogV1 extends StatefulWidget {
  const Act0BetaMetricsDialogV1({
    super.key,
    required this.learning,
    required this.nowUtc,
  });

  final Act0BetaLearningMetricsV1 learning;
  final DateTime Function() nowUtc;

  @override
  State<Act0BetaMetricsDialogV1> createState() =>
      _Act0BetaMetricsDialogStateV1();
}

class _Act0BetaMetricsDialogStateV1 extends State<Act0BetaMetricsDialogV1> {
  late Future<Act0BetaActivityV1?> _activity = Act0BetaMetricsStoreV1.read();
  bool _saving = false;

  Future<void> _answer(int question, Act0BetaSurveyAnswerV1? value) async {
    setState(() => _saving = true);
    try {
      await Act0BetaMetricsStoreV1.setAnswer(question, value);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Your answer could not be saved.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
          _activity = Act0BetaMetricsStoreV1.read();
        });
      }
    }
  }

  String _returnLabel(Act0BetaReturnV1? value) => switch (value) {
    Act0BetaReturnV1.returned => 'Returned',
    Act0BetaReturnV1.missed => 'No return in this window',
    Act0BetaReturnV1.pending => 'Still open',
    null => 'Unavailable',
  };

  String _scoreLabel(({int correct, int total}) attempts) => attempts.total == 0
      ? 'No answers yet'
      : '${attempts.correct}/${attempts.total} correct';

  Future<void> _copySummary(Act0BetaActivityV1 activity) async {
    final summary = widget.learning.summary(
      activity,
      widget.nowUtc(),
      reminderEnabled: Act0PracticeReminderV1.isSupported
          ? Act0PracticeReminderV1.enabled.value
          : null,
    );
    String message;
    try {
      await Clipboard.setData(ClipboardData(text: summary.clipboard));
      message = 'Summary copied.';
    } catch (_) {
      message = 'Summary could not be copied.';
    }
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final learning = widget.learning;
    return FutureBuilder<Act0BetaActivityV1?>(
      future: _activity,
      builder: (context, snapshot) {
        final activity = snapshot.data;
        final now = widget.nowUtc();
        final decisions = activity == null
            ? null
            : learning.decisionsSince(activity.firstVisitUtc);
        return AlertDialog(
          title: const Text('Beta activity'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                const Text('Saved on this device.'),
                const SizedBox(height: 12),
                Text(
                  'First lesson: ${learning.firstLessonCompleted ? 'Complete' : 'Incomplete'}',
                ),
                Text(
                  'World 1: ${learning.worldOneCompleted ? 'Complete' : 'Incomplete'}',
                ),
                Text('Corrected mistakes: ${learning.correctedMistakes}'),
                if (snapshot.connectionState == ConnectionState.waiting &&
                    activity == null)
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else ...[
                  Text('Day 2: ${_returnLabel(activity?.day2At(now))}'),
                  Text('Day 7: ${_returnLabel(activity?.day7At(now))}'),
                  if (decisions != null) ...[
                    const SizedBox(height: 12),
                    const Text('Day 1 first lesson · first answer per spot'),
                    Text('On your own: ${_scoreLabel(decisions.onYourOwn)}'),
                    Text('With help: ${_scoreLabel(decisions.withHelp)}'),
                    const SizedBox(height: 12),
                    Text(
                      'Day 7 new review, on your own: ${_scoreLabel(decisions.day7NewReview)}',
                    ),
                    const SizedBox(height: 12),
                    ValueListenableBuilder<bool>(
                      valueListenable: Act0PracticeReminderV1.enabled,
                      builder: (_, enabled, _) {
                        final summary = learning.summary(
                          activity!,
                          now,
                          reminderEnabled: Act0PracticeReminderV1.isSupported
                              ? enabled
                              : null,
                        );
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (final line in summary.progress) Text(line),
                          ],
                        );
                      },
                    ),
                  ],
                ],
                if (activity != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Optional feedback',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  for (final (question, label)
                      in act0BetaSurveyQuestionsV1.indexed) ...[
                    const SizedBox(height: 12),
                    Text(label),
                    Wrap(
                      spacing: 8,
                      children: [
                        for (final answer in Act0BetaSurveyAnswerV1.values)
                          ChoiceChip(
                            label: Text(switch (answer) {
                              Act0BetaSurveyAnswerV1.yes => 'Yes',
                              Act0BetaSurveyAnswerV1.no => 'No',
                              Act0BetaSurveyAnswerV1.unsure => 'Unsure',
                            }),
                            selected: activity.answers[question] == answer,
                            onSelected: _saving
                                ? null
                                : (selected) => _answer(
                                    question,
                                    selected ? answer : null,
                                  ),
                          ),
                      ],
                    ),
                  ],
                ],
              ],
            ),
          ),
          actions: [
            if (activity != null)
              TextButton(
                onPressed: _saving ? null : () => _copySummary(activity),
                child: const Text('Copy summary'),
              ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
