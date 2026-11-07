import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';

/// A single accessible action, with the same callback as the visible control.
/// Decorative letters/icons and nested gesture semantics must not create a
/// second label or a second action. No answer correctness belongs in this API.
class Act0SemanticActionV1 extends StatelessWidget {
  const Act0SemanticActionV1({
    super.key,
    required this.label,
    required this.onTap,
    required this.child,
    this.value,
    this.selected,
    this.sortKey,
  });

  final String label;
  final String? value;
  final bool? selected;
  final SemanticsSortKey? sortKey;
  final VoidCallback? onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    button: true,
    enabled: onTap != null,
    selected: selected,
    label: label,
    value: value,
    sortKey: sortKey,
    onTap: onTap,
    excludeSemantics: true,
    child: child,
  );
}

/// English V1 speech for a visible card. This does not infer a hand's strength,
/// mark the answer-bearing card, or expose cards that the renderer hides.
String act0SpokenCardV1(String rank, String suit) {
  final spokenRank = switch (rank.trim().toUpperCase()) {
    'A' => 'Ace',
    'K' => 'King',
    'Q' => 'Queen',
    'J' => 'Jack',
    'T' || '10' => '10',
    _ => rank.trim(),
  };
  final spokenSuit = switch (suit.trim().toLowerCase()) {
    's' || 'spade' || 'spades' || '♠' => 'spades',
    'h' || 'heart' || 'hearts' || '♥' => 'hearts',
    'd' || 'diamond' || 'diamonds' || '♦' => 'diamonds',
    'c' || 'club' || 'clubs' || '♣' => 'clubs',
    _ => suit.trim(),
  };
  return spokenSuit.isEmpty ? spokenRank : '$spokenRank of $spokenSuit';
}

class Act0CardSemanticsV1 extends StatelessWidget {
  const Act0CardSemanticsV1({
    super.key,
    required this.rank,
    required this.suit,
    required this.child,
    this.position,
    this.onTap,
  });

  final String rank;
  final String suit;
  final String? position;
  final VoidCallback? onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    label: [
      if (position != null) position!,
      act0SpokenCardV1(rank, suit),
    ].join(', '),
    button: onTap != null,
    onTap: onTap,
    excludeSemantics: true,
    child: child,
  );
}

/// A live result is added only by the post-choice feedback surface. Flutter's
/// platform accessibility bridge owns delivery; rebuilding identical content
/// does not manually enqueue another announcement. Retain child actions/text
/// as explicit nodes so the learner can explore the explanation and continue.
class Act0ChoiceResultSemanticsV1 extends StatelessWidget {
  const Act0ChoiceResultSemanticsV1({
    super.key,
    required this.title,
    required this.selectedLabel,
    required this.reason,
    required this.assisted,
    required this.child,
  });

  final String title;
  final String selectedLabel;
  final String reason;
  final bool assisted;
  final Widget child;

  @override
  Widget build(BuildContext context) => Semantics(
    key: const Key('act0_accessibility_choice_result'),
    container: true,
    explicitChildNodes: true,
    liveRegion: true,
    label: [
      title,
      if (selectedLabel.trim().isNotEmpty) 'Selected: $selectedLabel',
      if (assisted) 'With help',
      reason,
    ].where((line) => line.trim().isNotEmpty).join('. '),
    child: child,
  );
}
