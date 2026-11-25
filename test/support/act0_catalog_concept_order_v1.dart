import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

import 'act0_catalog_snapshot_v1.dart';

typedef CatalogConceptV1 = ({String id, RegExp mention});

final _raiseAmount = RegExp(
  r'\b(?:raise to \d|3-bet to)',
  caseSensitive: false,
);
final _minimumSizeQuestion = RegExp(
  r'\b(?:legal|minimum|smallest|at least|must|increment)\b',
  caseSensitive: false,
);
final _sentence = RegExp(r'(?<=[.!?])\s+');
final _explanation = RegExp(
  r'\b(means?|refers to|is when|are when|is an?|are the|'
  r'consists? of|stands? for|completes?|makes?|calculate|divide|'
  r'because|lets you|allows? you|gives? you|is called|are called)\b',
  caseSensitive: false,
);

// A few common teaching forms are more precise than the generic definition
// verbs below. Match the actual relationship, not merely a heading or example
// containing the term. A worked chart must contain its rows, for instance.
final _explicitDefinitions = <String, String>{
  '141': r'\bBTN (?:is|means|marks) (?:the )?Button\b',
  '139': r'\bHJ (?:is|means) Hijack\b',
  '140': r'\bCO (?:is|means) Cutoff\b',
  'button': r'\bBTN (?:is|means|marks) (?:the )?Button\b',
  'blinds': r'\bblinds are forced contributions\b',
  '14': r'\bblinds are forced contributions: the small blind puts in 0\.5 BB\b',
  '15':
      r'\bblinds are forced contributions: the small blind puts in 0\.5 BB and the big blind puts in 1 BB\b',
  '31': r'\bflop has three (?:shared |board )?cards\b',
  '32': r'\bturn is the fourth(?: board card)?\b',
  'rules_hand_flow':
      r'\bflop has three shared cards\. The turn is the fourth\b',
  'action_order': r'\bUTG acts first, right after the big blind\b',
  '39':
      r'\bFrom the flop on, [^.]+ acts first\. If the Button can still act, it goes after all the others on the first pass\b',
  'check':
      r'\bcheck (?:passes|keeps playing) for free\b|\bcheck means passing without betting when no bet is facing you\b',
  'starting_chart':
      r'\bstarting chart\.[\s\S]*?Premium:\s*[A-Z0-9]{2}[\s\S]*?Strong:\s*[A-Z0-9]{2}[\s\S]*?Medium:\s*[A-Z0-9]{2}[\s\S]*?Weak:\s*\w',
  '41': r'\bhigh card means no matching ranks or stronger combination\b',
  '42': r'\ba pair means two cards of one rank\b',
  '44':
      r'\bthree of a kind means three cards of one rank\b|\bthree of a kind[^.]*\.+\s*Three cards of one rank\b',
  '43': r'\btwo pair (?:uses two ranks|means two separate pairs)\b',
  'two_pair': r'\btwo pair (?:uses two ranks|means two separate pairs)\b',
  '47': r'\bfull house has three of one rank and two of another\b',
  '48': r'\bfour of a kind uses all four of one rank\b',
  '49': r'\bstraight flush is five ranks in a row in one suit\b',
  'one_in_n': r'\bone win returns \d+ BB, so you break even at one in five\b',
  'min_bet_raise_sizes':
      r'\ba full raise must add at least the size of the last bet or full raise\b',
  'min_raise':
      r'\ba full raise must add at least the size of the last bet or full raise\b',
  '23': r'\ba tie means the pot is split\b',
  '13': r'\bBTN marks the Button\.+\s*The dealer button shows the late seat\b',
  'wheel': r'\bA-2-3-4-5 is the five-high straight, called the wheel\b',
  '57': r'\bA-2-3-4-5 is the five-high straight, called the wheel\b',
  'pot_odds':
      r'\bTo call X into a pot of Y after the bet, you need to win at least X ÷ \(X \+ Y\) of the time\b|\bA \d+(?:\.\d+)? BB call for \d+(?:\.\d+)? BB needs about \d+%',
  'split_pot': r'\ba tie means the pot is split\b',
  'hand_rankings':
      r'\branking ladder\.+\s*Learn the first four ranks in order:',
  'kicker': r'\ba kicker is a side card that can break a tie\b',
  'showdown':
      r'\bshowdown is when players compare their best five after revealing their cards\b',
  '11':
      r'\bshowdown is when players compare their best five after revealing their cards\b',
  '34':
      r'\bshowdown is when players compare their best five after revealing their cards\b',
  '21': r'\ba side pot is extra chips matched after someone goes all-in\b',
  'side_pot':
      r'\ba side pot is extra chips matched after someone goes all-in\b',
  '147': r'\bin position when you act after the other player\b',
  'ip_oop': r'\bin position when you act after the other player\b',
  '169': r'\bJJ and TT, which are pocket pairs\b',
  'pocket_pair': r'\bJJ and TT, which are pocket pairs\b',
  '71':
      r'\btop pair means a private card matches the highest rank on the board\b',
  'top_pair':
      r'\btop pair means a private card matches the highest rank on the board\b',
  '59':
      r'\bboard plays\.+\s*You and [A-Z]+ both use the same [A-Z-]+ straight from the board here, so private cards do not improve either player\b',
  '33': r'\briver (?:adds the fifth|completes the board)',
  '152': r'\bUTG acts first, right after the big blind\b',
  'broadway':
      r'\bbroadway ranks are (?:ten, jack, queen, king, and ace|T, J, Q, K, and A)\b',
  'starting_hand_groups':
      r'\bstarting chart\.[\s\S]*?Premium:\s*[A-Z0-9]{2}[\s\S]*?Strong:\s*[A-Z0-9]{2}[\s\S]*?Medium:\s*[A-Z0-9]{2}[\s\S]*?Weak:\s*\w',
  'position_information':
      r'\bacting later lets you see more moves before you decide\b',
  'protection': r'\bprotection makes the next card cost chips\b',
  'set_trips':
      r'\ba set (?:is|means) three of a kind made (?:from|with) a pair\b',
  '423': r'\bprotection bets make the next card cost something\b',
}.map((id, pattern) => MapEntry(id, RegExp(pattern, caseSensitive: false)));

/// A lexical guard. A use does not teach a term by itself. The definition
/// signal has to share a sentence with the term, unless the teaching surface
/// supplies one of the explicit relationships above (including its heading).
Map<String, String> catalogConceptOrderFindingsV1(
  Iterable<CatalogTask> route,
  List<CatalogConceptV1> concepts,
) {
  final taught = <String>{};
  final findings = <String, String>{};
  for (final row in route) {
    final task = row.task;
    final runner = task.runner;
    final asksMinimumSize = _minimumSizeQuestion.hasMatch(
      catalogQuestion(task),
    );
    void inspect(String surface, String text, {bool teaching = false}) {
      if (teaching) {
        for (final concept in concepts) {
          if (_explicitDefinitions[concept.id]?.hasMatch(text) ?? false) {
            taught.add(concept.id);
          }
        }
      }
      for (final sentence in text.split(_sentence)) {
        final canExplain = teaching && _explanation.hasMatch(sentence);
        for (final concept in concepts) {
          final mentions =
              concept.mention.hasMatch(sentence) ||
              (concept.id == 'min_bet_raise_sizes' &&
                  surface == 'OPTION' &&
                  asksMinimumSize &&
                  _raiseAmount.hasMatch(sentence));
          if (taught.contains(concept.id) || !mentions) {
            continue;
          }
          if (canExplain) {
            taught.add(concept.id);
          } else {
            findings.putIfAbsent(
              'W${row.world.worldNumber}|${task.taskId}|${concept.id}',
              () => '$surface: $sentence',
            );
          }
        }
      }
    }

    for (final step in runner.teachingSteps) {
      inspect('TEACH', '${step.title}. ${step.body}', teaching: true);
    }
    inspect('CAPTION', runner.caption, teaching: true);
    if (runner.hintPolicy == Act0HintPolicyV1.always ||
        (runner.hintPolicy == Act0HintPolicyV1.theoryOnly &&
            task.phase == Act0LessonPhaseV1.theory)) {
      inspect('HINT', runner.hint, teaching: true);
    }
    inspect('Q', catalogQuestion(task));
    for (final option in runner.options) {
      inspect('OPTION', option.label);
      inspect('FEEDBACK', option.feedbackReason);
    }
  }
  return findings;
}
