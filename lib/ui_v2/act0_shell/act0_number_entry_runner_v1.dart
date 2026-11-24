import 'act0_number_entry_v1.dart';
import 'act0_shell_state_v1.dart';

class Act0NumberEntryRunnerV1 {
  const Act0NumberEntryRunnerV1._(this.spec, this.pot, this.price);

  final Act0NumberEntryV1 spec;
  final double pot;
  final double price;

  static Act0NumberEntryRunnerV1? fromTask(
    String taskId,
    Act0TableStateV1 table,
  ) {
    final spec = act0W4NumberEntriesV1[taskId];
    final source = table.handContributions;
    if (spec == null || source == null) return null;
    final amounts = source.amounts(
      actorSeatId: table.decisionActorSeatId,
      seatIds: {
        for (final seat in table.seats)
          if (seat.isOccupied) seat.seatId,
      },
    );
    final price = amounts.toCallBb;
    if (price == null || price <= 0 || amounts.potBb <= 0) return null;
    final entry = Act0NumberEntryRunnerV1._(spec, amounts.potBb, price);
    final derived = spec.isPrice ? price : entry.threshold;
    return (spec.answer - derived).abs() < 1e-8 ? entry : null;
  }

  double get threshold => price / (pot + price) * 100;

  static String _number(double amount) =>
      amount.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '');

  String get answerLabel =>
      spec.isPrice ? '${_number(price)} BB' : '${_number(threshold)}%';

  List<String> get steps => [
    'Pot before your call: ${_number(pot)} BB.',
    'Call price: ${_number(price)} BB.',
    'Pot after your call: ${_number(pot)} + ${_number(price)} = '
        '${_number(pot + price)} BB.',
    'Break-even chance: ${_number(price)} ÷ ${_number(pot + price)} = '
        '${_number(threshold)}%.',
  ];

  String get _answerInput => _number(spec.isPrice ? price : threshold);

  Act0RunnerOptionV1 get expected => option(_answerInput, spec.forms.first)!;

  Act0RunnerOptionV1? option(String input, Act0NumberFormV1 form) {
    final value = spec.parse(input, form);
    if (value == null) return null;
    final quality = switch (spec.grade(value)) {
      Act0NumberGradeV1.correct => Act0FeedbackQualityV1.correct,
      Act0NumberGradeV1.acceptable => Act0FeedbackQualityV1.acceptable,
      Act0NumberGradeV1.mistake => Act0FeedbackQualityV1.wrong,
    };
    final label = spec.formatInput(input, form);
    return Act0RunnerOptionV1(
      id: 'number_entry:${form.name}:$input',
      label: label,
      isCorrect: quality.passes,
      preferredLabel: answerLabel,
      quality: quality,
      feedbackTitle: switch (quality) {
        Act0FeedbackQualityV1.correct => 'Correct read',
        Act0FeedbackQualityV1.acceptable => 'Within range',
        _ => 'Check the number',
      },
      feedbackReason: 'You entered $label. The answer is $answerLabel.',
    );
  }

  Act0RunnerOptionV1? restore(String? id) {
    if (id == null || !act0IsNumberEntryChoiceV1(id)) return null;
    final parts = id.split(':');
    if (parts.length != 3) return null;
    final form = spec.forms.where((form) => form.name == parts[1]).firstOrNull;
    return form == null ? null : option(parts[2], form);
  }
}

Act0RunnerOptionV1? act0RestoredNumberOptionV1(
  Act0LessonTaskV1 task,
  String? id,
) {
  if (id == null || !act0IsNumberEntryChoiceV1(id)) return null;
  return Act0NumberEntryRunnerV1.fromTask(
    task.taskId,
    task.runner.table,
  )?.restore(id);
}
