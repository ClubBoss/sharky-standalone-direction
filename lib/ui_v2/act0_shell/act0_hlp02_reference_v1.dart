import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Bounded Act0 HLP-02 content projection. This does not evaluate poker hands,
/// grade decisions, award XP, alter persistence, or replace the existing
/// first-use term contract or legacy GlossaryService.
class Act0Hlp02ReferenceCatalogV1 {
  Act0Hlp02ReferenceCatalogV1._({
    required this.rankings,
    required this.namedVariant,
    required this.terms,
    required this.contextByLesson,
  });

  static const assetPath = 'content/_meta/hlp02_reference_en_v1.json';
  static const schemaVersion = 'hlp02.act0-reference.en.v1';

  final List<Map<String, dynamic>> rankings;
  final Map<String, dynamic> namedVariant;
  final Map<String, Map<String, dynamic>> terms;
  final Map<String, Map<String, dynamic>> contextByLesson;

  static Future<Act0Hlp02ReferenceCatalogV1> load(AssetBundle bundle) async {
    final raw = await bundle.loadString(assetPath);
    return fromJson(raw);
  }

  static Act0Hlp02ReferenceCatalogV1 fromJson(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic> ||
        decoded['schema_version'] != schemaVersion) {
      throw const FormatException('Unsupported HLP-02 reference schema');
    }

    final rankData = decoded['rankings'];
    final termData = decoded['terms'];
    final contextData = decoded['context_by_lesson'];
    final namedVariant = decoded['named_variant'];
    if (rankData is! List ||
        rankData.length != 9 ||
        termData is! List ||
        contextData is! Map ||
        namedVariant is! Map) {
      throw const FormatException('Incomplete HLP-02 reference data');
    }
    final rankings = <Map<String, dynamic>>[
      for (final row in rankData) Map<String, dynamic>.from(row as Map),
    ];
    final ids = <String>{};
    for (var index = 0; index < rankings.length; index++) {
      final row = rankings[index];
      if (row['order_low_to_high'] != index + 1 ||
          !ids.add(row['id'] as String)) {
        throw const FormatException('Invalid or duplicate rank ID/order');
      }
    }

    final terms = <String, Map<String, dynamic>>{};
    for (final item in termData) {
      final term = Map<String, dynamic>.from(item as Map);
      final id = term['id'] as String;
      if (terms.containsKey(id)) {
        throw const FormatException('Duplicate glossary term ID');
      }
      terms[id] = term;
    }
    final contexts = <String, Map<String, dynamic>>{};
    for (final entry in contextData.entries) {
      final key = entry.key as String;
      final value = Map<String, dynamic>.from(entry.value as Map);
      final termIds = value['term_ids'] as List<dynamic>;
      if (termIds.any((id) => !terms.containsKey(id))) {
        throw const FormatException('Unknown term in lesson context');
      }
      contexts[key] = value;
    }
    return Act0Hlp02ReferenceCatalogV1._(
      rankings: List<Map<String, dynamic>>.unmodifiable(rankings),
      namedVariant: Map<String, dynamic>.unmodifiable(
        Map<String, dynamic>.from(namedVariant),
      ),
      terms: Map<String, Map<String, dynamic>>.unmodifiable(terms),
      contextByLesson: Map<String, Map<String, dynamic>>.unmodifiable(contexts),
    );
  }

  Map<String, dynamic>? contextFor(String lessonId, String taskId) {
    final context = contextByLesson[lessonId];
    return context != null && context['task_id'] == taskId ? context : null;
  }

  List<Map<String, dynamic>> definitionsFor(String lessonId, String taskId) {
    final context = contextFor(lessonId, taskId);
    if (context == null) return const <Map<String, dynamic>>[];
    final ids = (context['term_ids'] as List<dynamic>).cast<String>();
    return <Map<String, dynamic>>[for (final id in ids) terms[id]!];
  }
}

/// Exact source-owned Act0 lesson/task ID allowlist. The gate intentionally
/// excludes scored practice/recheck/review, pre-choice decision overlays,
/// placements, and any unconfirmed source-to-Act0 term promotion.
class Act0Hlp02ReferencePolicyV1 {
  Act0Hlp02ReferencePolicyV1._();

  static const Map<String, String> theoryTaskByLesson = <String, String>{
    'what_poker_is': 'what_poker_is_theory',
    'cards_ranks_suits': 'cards_ranks_suits_theory',
    'blinds_action_order': 'blinds_theory',
    'positions': 'positions_theory',
    'hand_rankings_table': 'hand_rankings_theory',
    'showdown_winning': 'showdown_theory',
    'call_price': 'w4_price_intro',
    'outs_improvement': 'w5_outs_intro',
    'range_combo_counts': 'w6_combo_counts_intro',
    'spr_and_commitment': 'w7_spr_intro',
    'exploit_guardrails': 'w10_guardrails_intro',
  };

  static bool canOpen({
    required String lessonId,
    required String taskId,
    required bool isTheory,
    required bool isLearnStep,
    required bool isSelectable,
    required bool isEnglish,
    required bool hasActiveScoredChoice,
  }) {
    return isEnglish &&
        isSelectable &&
        isTheory &&
        isLearnStep &&
        !hasActiveScoredChoice &&
        theoryTaskByLesson[lessonId] == taskId;
  }
}

/// A button on the unscored Learn page only; never on the decision table.
/// Tapping this does not provide an assessment hint or grade a choice.
/// Inline disclosure has no Navigator route to survive a task, tab or
/// assessment change. Its state is discarded on exit from the Learn subtree.
/// The disclosure never invokes onChoiceAssistance or changes grading.
class Act0Hlp02ReferenceButtonV1 extends StatefulWidget {
  const Act0Hlp02ReferenceButtonV1({
    super.key,
    required this.lessonId,
    required this.taskId,
    required this.isTheory,
    required this.isLearnStep,
    required this.isSelectable,
    required this.isEnglish,
    required this.hasActiveScoredChoice,
  });

  final String lessonId;
  final String taskId;
  final bool isTheory;
  final bool isLearnStep;
  final bool isSelectable;
  final bool isEnglish;
  final bool hasActiveScoredChoice;

  @override
  State<Act0Hlp02ReferenceButtonV1> createState() =>
      _Act0Hlp02ReferenceButtonV1State();
}

class _Act0Hlp02ReferenceButtonV1State
    extends State<Act0Hlp02ReferenceButtonV1> {
  bool _isExpanded = false;

  @override
  void didUpdateWidget(covariant Act0Hlp02ReferenceButtonV1 oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A same-position widget can represent a different source task. Do not
    // carry a previously opened answer-sensitive reference across that swap.
    if (oldWidget.lessonId != widget.lessonId ||
        oldWidget.taskId != widget.taskId ||
        oldWidget.isTheory != widget.isTheory ||
        oldWidget.isLearnStep != widget.isLearnStep ||
        oldWidget.isSelectable != widget.isSelectable ||
        oldWidget.isEnglish != widget.isEnglish ||
        oldWidget.hasActiveScoredChoice != widget.hasActiveScoredChoice) {
      _isExpanded = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!Act0Hlp02ReferencePolicyV1.canOpen(
      lessonId: widget.lessonId,
      taskId: widget.taskId,
      isTheory: widget.isTheory,
      isLearnStep: widget.isLearnStep,
      isSelectable: widget.isSelectable,
      isEnglish: widget.isEnglish,
      hasActiveScoredChoice: widget.hasActiveScoredChoice,
    )) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            key: const Key('act0_hlp02_open_theory_reference'),
            icon: Icon(
              _isExpanded ? Icons.close : Icons.menu_book_outlined,
              size: 18,
            ),
            label: Text(
              _isExpanded ? 'Close hand & term reference' :
                  'Hand & term reference',
            ),
            onPressed: () => setState(() => _isExpanded = !_isExpanded),
          ),
        ),
        if (_isExpanded)
          SizedBox(
            key: const Key('act0_hlp02_inline_reference_region'),
            height: 320,
            child: _Act0Hlp02ReferencePanelV1(
              key: ValueKey<String>(
                'hlp02_${widget.lessonId}_${widget.taskId}',
              ),
              lessonId: widget.lessonId,
              taskId: widget.taskId,
            ),
          ),
      ],
    );
  }
}

class _Act0Hlp02ReferencePanelV1 extends StatefulWidget {
  const _Act0Hlp02ReferencePanelV1({
    super.key,
    required this.lessonId,
    required this.taskId,
  });

  final String lessonId;
  final String taskId;

  @override
  State<_Act0Hlp02ReferencePanelV1> createState() =>
      _Act0Hlp02ReferencePanelV1State();
}

class _Act0Hlp02ReferencePanelV1State
    extends State<_Act0Hlp02ReferencePanelV1> {
  late final Future<Act0Hlp02ReferenceCatalogV1> _catalog;

  @override
  void initState() {
    super.initState();
    _catalog = Act0Hlp02ReferenceCatalogV1.load(rootBundle);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Act0Hlp02ReferenceCatalogV1>(
      future: _catalog,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Reference unavailable'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final catalog = snapshot.requireData;
        final lessonContext = catalog.contextFor(
          widget.lessonId,
          widget.taskId,
        );
        if (lessonContext == null) {
          return const Center(child: Text('Reference unavailable'));
        }
        final definitions = catalog.definitionsFor(
          widget.lessonId,
          widget.taskId,
        );
        final showRanks = lessonContext['show_ranks'] == true;
        return ListView(
          key: const Key('act0_hlp02_theory_reference_panel'),
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
          children: <Widget>[
            Text('Hand & term reference',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text('Study definitions only. The table decision stays yours.'),
            if (showRanks) ...<Widget>[
              const SizedBox(height: 16),
              Text('Hand rankings - lowest to highest',
                  style: Theme.of(context).textTheme.titleMedium),
              for (final rank in catalog.rankings)
                ExpansionTile(
                  key: Key('act0_hlp02_rank_${rank['id']}'),
                  title: Text('${rank['order_low_to_high']}. ${rank['name_en']}'),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  expandedCrossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(rank['definition_en'] as String),
                    const SizedBox(height: 6),
                    Semantics(
                      label: 'Example: ${_cardNames(
                        (rank['example_five_cards'] as List<dynamic>)
                            .cast<String>(),
                      )}',
                      child: ExcludeSemantics(
                        child: Text('Example: ${(rank['example_five_cards'] as List<dynamic>).join(' ')}'),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text('Compare: ${rank['compare_en']}'),
                    const SizedBox(height: 6),
                    Text('Common error: ${rank['common_mistake_en']}'),
                  ],
                ),
              const SizedBox(height: 6),
              Text('${catalog.namedVariant['name_en']}: '
                  '${catalog.namedVariant['definition_en']}'),
            ],
            if (definitions.isNotEmpty) ...<Widget>[
              const SizedBox(height: 16),
              Text('Terms in this lesson',
                  style: Theme.of(context).textTheme.titleMedium),
              for (final term in definitions)
                ListTile(
                  key: Key('act0_hlp02_term_${term['id']}'),
                  contentPadding: EdgeInsets.zero,
                  title: Text(term['name_en'] as String),
                  subtitle: Text(term['definition_en'] as String),
                ),
            ],
          ],
        );
      },
    );
  }
}

String _cardNames(List<String> cards) {
  const ranks = <String, String>{
    'A': 'Ace', 'K': 'King', 'Q': 'Queen', 'J': 'Jack', 'T': 'Ten',
    '9': 'Nine', '8': 'Eight', '7': 'Seven', '6': 'Six',
    '5': 'Five', '4': 'Four', '3': 'Three', '2': 'Two',
  };
  const suits = <String, String>{
    's': 'spades', 'h': 'hearts', 'd': 'diamonds', 'c': 'clubs',
  };
  return cards.map((code) {
    if (code.length != 2) return 'unknown card';
    return '${ranks[code[0]] ?? 'Unknown'} of '
        '${suits[code[1]] ?? 'unknown suit'}';
  }).join(', ');
}
