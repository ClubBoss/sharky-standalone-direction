part of 'act0_lesson_runner_shell_v1.dart';

extension _NumberEntryInteractionV1 on _Act0LessonRunnerShellV1State {
  Future<void> _openNumberEntryV1() async {
    final entry = widget.numberEntry!;
    final identity = _compositionTaskIdentity(widget);
    final interaction = _interactionKey(widget.runner);
    final option = await showAct0ClubSheetV1<Act0RunnerOptionV1>(
      context: context,
      builder: (_) => _NumberEntrySheetV1(
        entry: entry,
        onReveal: () =>
            _exposeDecisionAssistanceV1(Act0DecisionAssistanceV1.quickHint),
      ),
    );
    if (option != null &&
        mounted &&
        identity == _compositionTaskIdentity(widget) &&
        interaction == _interactionKey(widget.runner)) {
      _handleChooseOptionTelemetry(option);
    }
  }
}

class _NumberEntryPromptV1 extends StatelessWidget {
  const _NumberEntryPromptV1({required this.question, required this.onOpen});

  final String question;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(12),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(question, style: Act0ClubNightTokensV1.body),
        Act0ClubButtonsV1.primary(
          key: const Key('act0_number_entry_open'),
          label: 'Enter answer',
          onPressed: onOpen,
        ),
      ],
    ),
  );
}

class _NumberEntrySheetV1 extends StatefulWidget {
  const _NumberEntrySheetV1({required this.entry, required this.onReveal});

  final Act0NumberEntryRunnerV1 entry;
  final Future<bool> Function() onReveal;

  @override
  State<_NumberEntrySheetV1> createState() => _NumberEntrySheetV1State();
}

class _NumberEntrySheetV1State extends State<_NumberEntrySheetV1> {
  late var _form = widget.entry.spec.forms.first;
  String _input = '';
  bool _revealing = false;
  bool _revealed = false;

  Future<void> _reveal() async {
    setState(() => _revealing = true);
    final shown = await widget.onReveal();
    if (!mounted) return;
    setState(() {
      _revealing = false;
      _revealed = shown;
    });
  }

  Widget _key(String symbol, String label, VoidCallback action) => Expanded(
    child: Padding(
      padding: const EdgeInsets.all(2),
      child: Semantics(
        label: switch (label) {
          '.' => 'Decimal point',
          '/' => 'Fraction slash',
          _ => null,
        },
        child: Act0ClubButtonsV1.secondary(
          key: ValueKey('act0_number_key_$symbol'),
          label: label,
          onPressed: _revealing ? null : action,
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    final spec = entry.spec;
    final option = entry.option(_input, _form);
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(spec.question, style: Act0ClubNightTokensV1.body),
          if (spec.forms.length > 1)
            Wrap(
              children: [
                for (final form in spec.forms)
                  Semantics(
                    selected: form == _form,
                    label: form.spokenLabel,
                    child: Act0ClubButtonsV1.link(
                      label: form.label,
                      onPressed: _revealing
                          ? null
                          : () => setState(() {
                              if (_form == form) return;
                              _form = form;
                              _input = '';
                            }),
                    ),
                  ),
              ],
            ),
          Semantics(
            container: true,
            liveRegion: true,
            label: 'Answer in ${_form.spokenLabel}',
            value: _input.isEmpty ? 'Empty' : _input,
            child: ExcludeSemantics(
              child: Text(
                spec.formatInput(_input.isEmpty ? '—' : _input, _form),
                style: Act0ClubNightTokensV1.body,
              ),
            ),
          ),
          Semantics(
            container: true,
            explicitChildNodes: true,
            label: 'Numeric keypad',
            child: Column(
              children: [
                for (final row in ['123', '456', '789', '._0'])
                  Row(
                    children: [
                      for (final symbol in row.split(''))
                        if (symbol == '_')
                          _key(symbol, 'Delete', () {
                            if (_input.isEmpty) return;
                            setState(
                              () => _input = _input.substring(
                                0,
                                _input.length - 1,
                              ),
                            );
                          })
                        else
                          _key(
                            symbol,
                            symbol == '.'
                                ? (_form == Act0NumberFormV1.fraction
                                      ? '/'
                                      : '.')
                                : symbol,
                            () {
                              if (_input.length >= 12) return;
                              final digit =
                                  symbol == '.' &&
                                      _form == Act0NumberFormV1.fraction
                                  ? '/'
                                  : symbol;
                              setState(() => _input += digit);
                            },
                          ),
                    ],
                  ),
              ],
            ),
          ),
          Act0ClubButtonsV1.primary(
            key: const Key('act0_number_entry_submit'),
            label: 'Submit answer',
            onPressed: option == null || _revealing
                ? null
                : () => Navigator.of(context).pop(option),
          ),
          if (_revealed)
            for (final step in entry.steps)
              Text(step, style: Act0ClubNightTokensV1.body)
          else
            Act0ClubButtonsV1.link(
              label: 'Show the math',
              onPressed: _revealing ? null : _reveal,
            ),
        ],
      ),
    );
  }
}
