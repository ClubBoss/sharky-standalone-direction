import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:poker_analyzer/theme/app_colors.dart';
import 'package:poker_analyzer/theme/app_spacing.dart';
import 'package:poker_analyzer/theme/app_typography.dart';
import 'package:poker_analyzer/ui_v2/home/direct_loader.dart';
import 'package:poker_analyzer/sharky/design_tokens_v1.dart';
import 'package:poker_analyzer/ui_v2/map/progress_map_world1_determinism.dart';
import 'package:poker_analyzer/ui_v2/runner/canonical_launcher_api_v1.dart';
import 'package:poker_analyzer/ui_v2/screens/table_first_navigation.dart';
import 'package:poker_analyzer/ui_v2/screens/world1_foundations_microtask_runner_screen.dart';
import 'package:poker_analyzer/ui_v2/audio/ui_sound_v1.dart';
import 'package:poker_analyzer/ui_v2/table/table_surface.dart';
import 'package:poker_analyzer/ui_v2/widgets/next_action_strip_v1.dart';

class TheorySessionScreen extends StatefulWidget {
  final String moduleId;
  final String moduleTitle;
  @visibleForTesting
  final String? debugTheoryMarkdownOverrideV1;

  const TheorySessionScreen({
    super.key,
    required this.moduleId,
    required this.moduleTitle,
    this.debugTheoryMarkdownOverrideV1,
  });

  @override
  State createState() => _TheorySessionScreenState();
}

class _TheorySessionScreenState extends State<TheorySessionScreen> {
  late Future<String> _theoryFuture;
  String? _cachedTheoryMarkdownV1;
  bool get _isWorld1Context =>
      kWorld1CanonicalModuleOrder.contains(widget.moduleId);

  Future<void> _handleStartPracticeV1() async {
    UiSoundV1.fire(UiSoundEventV1.tap);
    await pushCanonicalPracticeLaunchV1(
      context,
      moduleId: widget.moduleId,
      moduleTitle: widget.moduleTitle,
      world1ModeV1: kWorld1RunnerModeTablePractice,
      world1InstructionSourceV1: _TheoryRunnerInstructionSourceV1.fromMarkdown(
        moduleId: widget.moduleId,
        moduleTitle: widget.moduleTitle,
        markdown: _cachedTheoryMarkdownV1,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    final debugMarkdown = widget.debugTheoryMarkdownOverrideV1;
    if (debugMarkdown != null) {
      _cachedTheoryMarkdownV1 = debugMarkdown;
      _theoryFuture = Future<String>.value(debugMarkdown);
      return;
    }
    _theoryFuture = DirectLoader.loadContentFile(widget.moduleId, 'theory.md')
        .then((value) {
          _cachedTheoryMarkdownV1 = value;
          return value;
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: SharkyTokensV1.slate600.withOpacity(0.55),
          ),
        ),
        centerTitle: false,
        titleTextStyle: AppTypography.h3.copyWith(
          color: SharkyTokensV1.textPrimary,
        ),
        iconTheme: IconThemeData(color: SharkyTokensV1.textSecondary),
        title: Text(widget.moduleTitle),
      ),
      body: FutureBuilder<String>(
        future: _theoryFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: _buildTheoryLoadingSurfaceV1());
          }

          if (snapshot.hasError) {
            return Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: SharkyTokensV1.surfaceCard.withOpacity(0.75),
                  borderRadius: BorderRadius.circular(SharkyTokensV1.radiusMd),
                  border: Border.all(
                    color: SharkyTokensV1.semanticLoss.withOpacity(0.55),
                  ),
                ),
                child: Text(
                  'Theory is unavailable right now',
                  textAlign: TextAlign.center,
                  style: AppTypography.body.copyWith(
                    color: SharkyTokensV1.textSecondary,
                  ),
                ),
              ),
            );
          }

          final bottomInset =
              AppSpacing.xl +
              AppSpacing.md +
              MediaQuery.of(context).viewPadding.bottom;
          final topBridgeCard = Container(
            key: const Key('theory_bridge_surface_v1'),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: SharkyTokensV1.surfaceCard.withOpacity(0.78),
              borderRadius: BorderRadius.circular(SharkyTokensV1.radiusMd),
              border: Border.all(
                color: SharkyTokensV1.slate600.withOpacity(0.58),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_isWorld1Context) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: SharkyTokensV1.surfaceElevated.withOpacity(0.84),
                      borderRadius: BorderRadius.circular(
                        SharkyTokensV1.radiusMd,
                      ),
                      border: Border.all(
                        color: SharkyTokensV1.slate600.withOpacity(0.62),
                      ),
                    ),
                    child: Text(
                      'Table-first context',
                      style: AppTypography.caption.copyWith(
                        color: SharkyTokensV1.textSecondary,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  NextActionStripV1(
                    key: const Key('theory_next_action_strip'),
                    title: 'Next action',
                    value: 'Start practice',
                    borderColor: SharkyTokensV1.semanticWin.withOpacity(0.72),
                    semanticsLabel: 'Theory next action',
                    semanticsValue: 'Start practice',
                    semanticsHint: 'double tap start practice to continue',
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
                Text(
                  widget.moduleTitle,
                  style: AppTypography.h1.copyWith(
                    color: SharkyTokensV1.textPrimary,
                    fontSize: 28,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  height: 52,
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    key: const Key('theory_start_practice_cta'),
                    style: _primaryCtaStyle(),
                    onPressed: _handleStartPracticeV1,
                    icon: const Icon(Icons.arrow_forward),
                    label: Text(
                      'START PRACTICE',
                      style: AppTypography.label.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
          final content = Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              bottomInset,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.xs),
                topBridgeCard,
                const SizedBox(height: AppSpacing.md),
                Expanded(
                  child: Container(
                    key: _isWorld1Context
                        ? const Key('table_first_theory_overlay')
                        : null,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: SharkyTokensV1.surfaceCard.withOpacity(0.75),
                      borderRadius: BorderRadius.circular(
                        SharkyTokensV1.radiusMd,
                      ),
                      border: Border.all(
                        color: SharkyTokensV1.slate600.withOpacity(0.55),
                      ),
                    ),
                    child: Markdown(
                      data: snapshot.data ?? '# Error loading theory',
                      physics: const BouncingScrollPhysics(),
                      styleSheet:
                          MarkdownStyleSheet.fromTheme(
                            Theme.of(context),
                          ).copyWith(
                            p: AppTypography.body.copyWith(
                              color: SharkyTokensV1.textSecondary,
                              height: 1.5,
                              fontSize: 16,
                            ),
                            h1: AppTypography.h1.copyWith(
                              color: SharkyTokensV1.textPrimary,
                            ),
                            h2: AppTypography.h3.copyWith(
                              color: SharkyTokensV1.textPrimary,
                              fontSize: 20,
                            ),
                            h3: AppTypography.h3.copyWith(
                              color: SharkyTokensV1.textPrimary,
                              fontSize: 18,
                            ),
                            listBullet: AppTypography.body.copyWith(
                              color: SharkyTokensV1.textPrimary,
                            ),
                          ),
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.lg),
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    color: SharkyTokensV1.slate600.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(
                      SharkyTokensV1.radiusSm,
                    ),
                  ),
                ),
              ],
            ),
          );
          if (!_isWorld1Context) {
            return content;
          }
          return KeyedSubtree(
            key: const Key('table_first_theory_shell'),
            child: TableSurface(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: <Color>[
                            SharkyTokensV1.surfaceCard.withOpacity(0.58),
                            SharkyTokensV1.surfaceApp.withOpacity(0.9),
                          ],
                        ),
                      ),
                    ),
                  ),
                  content,
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTheoryLoadingSurfaceV1() {
    return Container(
      key: const Key('theory_loading_surface_v1'),
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: SharkyTokensV1.surfaceCard.withOpacity(0.82),
        borderRadius: BorderRadius.circular(SharkyTokensV1.radiusMd),
        border: Border.all(color: SharkyTokensV1.slate600.withOpacity(0.58)),
        boxShadow: SharkyTokensV1.elevation2,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: SharkyTokensV1.brandPrimary.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(SharkyTokensV1.radiusSm),
                ),
                child: Icon(
                  Icons.menu_book_rounded,
                  color: SharkyTokensV1.brandPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Loading theory',
                      style: AppTypography.h3.copyWith(
                        color: SharkyTokensV1.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Preparing the lesson before practice starts.',
                      style: AppTypography.body.copyWith(
                        color: SharkyTokensV1.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(SharkyTokensV1.radiusFull),
            child: LinearProgressIndicator(
              minHeight: 6,
              backgroundColor: SharkyTokensV1.slate600.withOpacity(0.45),
              color: SharkyTokensV1.brandPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _TheoryRunnerInstructionSourceV1 implements RunnerInstructionSourceV1 {
  const _TheoryRunnerInstructionSourceV1({
    required this.moduleId,
    required this.moduleTitle,
    required this.introBlock,
    required this.stepBlock,
    required this.outcomeBlock,
  });

  factory _TheoryRunnerInstructionSourceV1.fromMarkdown({
    required String moduleId,
    required String moduleTitle,
    required String? markdown,
  }) {
    final parsed = _parseInstructionBlocksV1(markdown);
    return _TheoryRunnerInstructionSourceV1(
      moduleId: moduleId,
      moduleTitle: moduleTitle,
      introBlock: parsed.intro,
      stepBlock: parsed.step,
      outcomeBlock: parsed.outcome,
    );
  }

  final String moduleId;
  final String moduleTitle;
  final String? introBlock;
  final String? stepBlock;
  final String? outcomeBlock;

  static ({String? intro, String? step, String? outcome})?
  _parseDirectiveInstructionBlocksV1(String? markdown) {
    if (markdown == null || markdown.trim().isEmpty) return null;
    final lines = markdown.split('\n');
    final runnerValues = <String, String>{};
    var sawDirective = false;
    for (final rawLine in lines) {
      final line = rawLine.trim();
      if (line.isEmpty) {
        if (sawDirective) continue;
        continue;
      }
      if (!line.startsWith('@')) {
        break;
      }
      sawDirective = true;
      final space = line.indexOf(' ');
      final directive =
          (space == -1 ? line.substring(1) : line.substring(1, space))
              .trim()
              .toLowerCase();
      final payload = space == -1 ? '' : line.substring(space + 1).trim();
      final tokens = _parseDirectiveKvTokensV1(payload);
      if (tokens == null) return null;
      if (directive == 'runner') {
        for (final entry in tokens.entries) {
          if (runnerValues.containsKey(entry.key)) continue;
          runnerValues[entry.key] = entry.value;
        }
      }
    }
    if (!sawDirective || runnerValues.isEmpty) return null;
    String? clip(String? input, {int max = 72}) {
      if (input == null) return null;
      final text = input.replaceAll(RegExp(r'\s+'), ' ').trim();
      if (text.isEmpty) return null;
      return text.length <= max ? text : '${text.substring(0, max - 3)}...';
    }

    return (
      intro: clip(runnerValues['intro']),
      step: clip(runnerValues['step']),
      outcome: clip(runnerValues['outcome']),
    );
  }

  static Map<String, String>? _parseDirectiveKvTokensV1(String input) {
    final result = <String, String>{};
    var i = 0;
    while (i < input.length) {
      while (i < input.length && input.codeUnitAt(i) == 32) {
        i++;
      }
      if (i >= input.length) break;
      final keyStart = i;
      while (i < input.length && input.codeUnitAt(i) != 61) {
        if (input.codeUnitAt(i) == 32) return null;
        i++;
      }
      if (i >= input.length) return null;
      final key = input.substring(keyStart, i).trim();
      if (!RegExp(r'^[a-z0-9_]+$').hasMatch(key)) return null;
      i++; // skip '='
      if (i >= input.length) return null;

      String value;
      if (input.codeUnitAt(i) == 34) {
        i++; // skip opening quote
        final buffer = StringBuffer();
        var closed = false;
        while (i < input.length) {
          final ch = input.codeUnitAt(i);
          if (ch == 92) {
            if (i + 1 >= input.length) return null;
            final next = input.codeUnitAt(i + 1);
            if (next == 34 || next == 92) {
              buffer.writeCharCode(next);
              i += 2;
              continue;
            }
            return null;
          }
          if (ch == 34) {
            i++;
            closed = true;
            break;
          }
          buffer.writeCharCode(ch);
          i++;
        }
        if (!closed) return null;
        value = buffer.toString();
      } else {
        final valueStart = i;
        while (i < input.length && input.codeUnitAt(i) != 32) {
          i++;
        }
        value = input.substring(valueStart, i).trim();
      }

      if (!result.containsKey(key)) {
        result[key] = value;
      }
    }
    return result;
  }

  static ({String? intro, String? step, String? outcome})
  _parseInstructionBlocksV1(String? markdown) {
    if (markdown == null) {
      return (intro: null, step: null, outcome: null);
    }
    final directiveParsed = _parseDirectiveInstructionBlocksV1(markdown);
    if (directiveParsed != null &&
        (directiveParsed.intro != null ||
            directiveParsed.step != null ||
            directiveParsed.outcome != null)) {
      return directiveParsed;
    }
    final rawLines = markdown.split('\n');
    final lines = rawLines
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList(growable: false);
    if (lines.isEmpty) {
      return (intro: null, step: null, outcome: null);
    }

    String? clip(String? input, {int max = 72}) {
      if (input == null) return null;
      final text = input.replaceAll(RegExp(r'\s+'), ' ').trim();
      if (text.isEmpty) return null;
      return text.length <= max ? text : '${text.substring(0, max - 3)}...';
    }

    String? _stripPrefixLabel(String value, Set<String> labels) {
      final trimmed = value.trim();
      final colon = trimmed.indexOf(':');
      if (colon <= 0) return trimmed;
      final prefix = trimmed.substring(0, colon).trim().toLowerCase();
      if (!labels.contains(prefix)) return trimmed;
      return trimmed.substring(colon + 1).trim();
    }

    String? normalizeBullet(String line) {
      final trimmed = line.trim();
      String value = trimmed;
      if (value.startsWith('- ')) value = value.substring(2).trim();
      if (value.startsWith('* ')) value = value.substring(2).trim();
      final numbered = RegExp(r'^\d+\.\s+').firstMatch(trimmed);
      if (numbered != null) {
        value = trimmed.substring(numbered.end).trim();
      }
      value = value
          .replaceAll('**', '')
          .replaceAll('__', '')
          .replaceAll('`', '')
          .trim();
      return value;
    }

    String? firstContentLine() {
      for (final line in lines) {
        if (line.startsWith('#')) continue;
        return normalizeBullet(line);
      }
      return null;
    }

    String? firstLineAfterHeading(Set<String> headingHints) {
      for (var i = 0; i < rawLines.length; i++) {
        final line = rawLines[i].trim();
        if (!line.startsWith('#')) continue;
        final heading = line.replaceFirst(RegExp(r'^#+\s*'), '').toLowerCase();
        final matchesHint = headingHints.any(heading.contains);
        if (!matchesHint) continue;
        for (var j = i + 1; j < rawLines.length; j++) {
          final candidate = rawLines[j].trim();
          if (candidate.isEmpty) continue;
          if (candidate.startsWith('#')) break;
          return normalizeBullet(candidate);
        }
      }
      return null;
    }

    String? firstFeedbackishLine() {
      for (final line in lines) {
        if (line.startsWith('#')) continue;
        final lower = line.toLowerCase();
        if (lower.startsWith('feedback:') ||
            lower.startsWith('check:') ||
            lower.startsWith('remember:') ||
            lower.startsWith('key point:')) {
          final parts = line.split(':');
          final value = parts.length > 1
              ? parts.sublist(1).join(':').trim()
              : line;
          return normalizeBullet(value);
        }
      }
      return null;
    }

    final intro = clip(firstContentLine());
    final step = clip(
      _stripPrefixLabel(
        firstLineAfterHeading(<String>{'practice', 'drill'}) ?? '',
        <String>{'step', 'practice', 'drill'},
      ),
    );
    final outcome = clip(
      _stripPrefixLabel(
        firstLineAfterHeading(<String>{'feedback', 'review'}) ??
            firstFeedbackishLine() ??
            '',
        <String>{'feedback', 'check', 'remember', 'key point', 'review'},
      ),
    );
    return (intro: intro, step: step, outcome: outcome);
  }

  @override
  RunnerInstructionContentV1? getIntroInstruction({
    required String moduleId,
    required String moduleTitle,
    required int railIndex,
    required int railTotal,
    required RunnerInstructionContentV1 fallback,
  }) {
    if (moduleId != this.moduleId) return null;
    if (introBlock == null || introBlock!.isEmpty) return null;
    if (railIndex > 0) return null;
    return RunnerInstructionContentV1(
      title: fallback.title,
      subtitle: introBlock!,
    );
  }

  @override
  RunnerInstructionContentV1? getOutcomeInstruction({
    required String moduleId,
    required bool handLoopMode,
    required bool isCorrect,
    required RunnerInstructionContentV1 fallback,
  }) {
    if (moduleId != this.moduleId) return null;
    if (outcomeBlock == null || outcomeBlock!.isEmpty) return null;
    return RunnerInstructionContentV1(
      title: outcomeBlock!,
      subtitle: fallback.subtitle,
    );
  }

  @override
  RunnerInstructionContentV1? getStepInstruction({
    required String moduleId,
    required bool handLoopMode,
    required RunnerInstructionContentV1 fallback,
  }) {
    if (moduleId != this.moduleId) return null;
    if (stepBlock == null || stepBlock!.isEmpty) return null;
    return RunnerInstructionContentV1(
      title: handLoopMode ? stepBlock! : fallback.title,
      subtitle: handLoopMode ? fallback.subtitle : stepBlock!,
    );
  }
}

ButtonStyle _primaryCtaStyle() {
  return ButtonStyle(
    shape: MaterialStateProperty.all(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SharkyTokensV1.radiusMd),
      ),
    ),
    side: MaterialStateProperty.all(
      BorderSide(
        color: SharkyTokensV1.brandPrimary.withOpacity(0.84),
        width: 1.2,
      ),
    ),
    overlayColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.pressed)) {
        return Colors.white.withOpacity(0.14);
      }
      if (states.contains(MaterialState.hovered)) {
        return Colors.white.withOpacity(0.08);
      }
      if (states.contains(MaterialState.focused)) {
        return Colors.white.withOpacity(0.1);
      }
      return null;
    }),
    backgroundColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.disabled)) {
        return SharkyTokensV1.semanticWin.withOpacity(
          SharkyTokensV1.opacityDisabled,
        );
      }
      return SharkyTokensV1.brandPrimary;
    }),
    foregroundColor: MaterialStateProperty.all(Colors.white),
  );
}
