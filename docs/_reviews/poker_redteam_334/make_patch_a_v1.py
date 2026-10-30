# Generates the #334 content patch A against act0_shell_state_v1.dart @ c1f69e1d.
import sys
src=open(sys.argv[1]).read(); out=sys.argv[2]
lines=src.split('\n')
def off(line): return sum(len(l)+1 for l in lines[:line-1])
edits=[]
def E(anchor, old, new, window=4000, ledger=''):
    edits.append((anchor, old, new, window, ledger))
SUB="quality: Act0FeedbackQualityV1.suboptimal"; WR="quality: Act0FeedbackQualityV1.wrong"
# L1 + L9 w6_board_pair_strength_compare
E(18744,"id: 'hero_aj',",None,ledger='anchor')
E(18744,SUB,WR,400,'L9')
E(18744,"K-8 uses the paired board to make trips. Trips beat two pair.","K-8 uses the paired board to make a full house, eights full of twos. A full house beats two pair.",ledger='L1')
E(18744,"The extra 8 turns Villain into trips, and trips outrank Hero two pair.","The extra 8 gives Villain 8-8-8-2-2, a full house, which outranks Hero two pair.",ledger='L1')
E(18744,"because one player may jump to trips while the other stays on two pair.","because one player may fill up to a full house while the other stays on two pair.",ledger='L1')
E(18744,"focusLabels: <String>['Paired board', 'Trips', 'Two pair', 'Best five'],","focusLabels: <String>['Paired board', 'Full house', 'Two pair', 'Best five'],",ledger='L1')
# L2 w6_value_wet_board
E(17785,"// 8-7-6 two-tone: hero has 9-8 (two pair) → value range","// 8-7-6 two-tone: hero has 9-8 (top pair + open-ended draw) → value range",ledger='L2')
E(17785,"hint: '9-8 flopped two pair on a connected board.',","hint: '9-8 flopped top pair plus an open-ended straight draw.',",ledger='L2')
E(17785,"'9-8 flopped two pair. Two pair is a strong value hand on any texture.',","'9-8 flopped top pair with an open-ended straight draw: a 5 or a T makes a straight. That is a strong value hand on this board.',",ledger='L2')
E(17785,"'Two pair is a strong made hand. Missed hands have no pair and no useful draw.',","'Top pair with an open-ended draw is a strong hand. Missed hands have no pair and no useful draw.',",ledger='L2')
# L3 w6_bluff_candidate (+ range_checkpoint_pressure inherits)
E(17958,"// K-7-2: hero has A-Q (overcards, no pair)","// K-7-2: hero has A-Q (ace overcard, no pair)",ledger='L3')
E(17958,"hint: 'Two overcards, no pair. Some fold equity exists.',","hint: 'One overcard (the ace), no pair. Some fold equity exists.',",ledger='L3')
E(17958,"'A-Q has two overcards and ace-blocker. It can represent pressure '","'A-Q has one overcard, the ace, plus the ace blocker. It can represent pressure '",ledger='L3')
# L4 outs wording
E(16780,"feedbackReason: 'With 5-6-7-8 on board, any 9 completes the straight.',","feedbackReason: 'Your 6-5 plus the 8-7 on board make four in a row, so any 9 completes the straight.',",ledger='L4')
# L5 w4_bad_bluff
E(15159,"caption: 'Villain called big already. Fold pressure is low.',","caption: 'This BB calls almost every flop bet. Fold pressure is low.',",ledger='L5')
E(15159,"'A pot-size bluff is too ambitious when fold pressure is unclear.',","'A pot-size bluff is too ambitious against a player who rarely folds.',",ledger='L5')
E(15159,"Act0ActionTrailItemV1(label: 'Flop: BB calls 3 BB'),","Act0ActionTrailItemV1(label: 'BB checks'),",ledger='L5')
# L6 pot-odds wording
E(15440,"'Pot 8 BB is not enough to justify risking 7 BB with a weak pair. The hand is too thin for that price.',","'Risking 7 BB to win 15 BB (the 8 BB pot plus the 7 BB bet) needs about 32% equity. A weak pair is too thin for that price.',",ledger='L6')
E(15440,"'Calling spends 7 BB to win a pot that is only 8 BB, and a weak pair is not a strong enough reason.',","'Calling risks 7 BB to win 15 BB (the 8 BB pot plus the 7 BB bet), so it needs about 32% equity. A weak pair is not a strong enough reason.',",ledger='L6')
E(15555,"'Top pair sounds good, but Pot 9 BB is not enough to justify risking 6 BB with a weak kicker.',","'Top pair sounds good, but risking 6 BB to win 15 BB (the 9 BB pot plus the 6 BB bet) needs about 29% equity, a lot to ask of a weak kicker against this bet.',",ledger='L6')
# L7 W9 M-ratio + preflop to-call
E(20160,"at 12 BB in yellow zone.',","at 18 BB in yellow zone.',",ledger='L7')
E(20160,"toCallLabel: 'To call 0 BB',","toCallLabel: 'To call 1 BB',",ledger='L7')
E(20160,"centerLabel: 'BTN, 12 BB, yellow zone',","centerLabel: 'BTN, 18 BB, yellow zone',",ledger='L7')
E(20160,"focusLabels: <String>['Yellow zone', '12 BB', 'Urgency', 'Plan early'],","focusLabels: <String>['Yellow zone', '18 BB', 'Urgency', 'Plan early'],",ledger='L7')
# L8 blinds_theory key
E(9255,"  question: 'Which blind posts 1 BB?',\n","""  question: 'Which blind posts 1 BB?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'sb',
      label: 'SB',
      seatId: 'sb',
      isCorrect: false,
      preferredLabel: 'BB',
      betterAnswerLabel: 'BB',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason: 'SB posts the small blind, 0.5 BB. BB posts the full 1 BB.',
    ),
    Act0RunnerOptionV1(
      id: 'bb',
      label: 'BB',
      seatId: 'bb',
      isCorrect: true,
      preferredLabel: 'BB',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'BB posts 1 BB.',
      feedbackReason: 'The big blind posts the full 1 BB. The small blind posts half.',
    ),
    Act0RunnerOptionV1(
      id: 'btn',
      label: 'BTN (your seat)',
      seatId: 'btn',
      isCorrect: false,
      preferredLabel: 'BB',
      betterAnswerLabel: 'BB',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason: 'BTN posts no blind. Only SB and BB post before the cards.',
    ),
  ],
""",ledger='L8')
# L9 deterministic tiers (anchors = option id line in base)
for line,oid in [(10548,'hero_cards_only'),(18253,'twelve'),(18295,'twelve'),(18337,'same_weight'),(18412,'same_weight'),(18464,'same_weight'),(18649,'tie'),(18892,'villain_wins')]:
    E(line-2,f"id: '{oid}',",None,ledger='anchor')
    E(line,SUB,WR,500,'L9')
E(18515,"id: 'pair_nines',",None,ledger='anchor')
E(18515,SUB,WR,600,'L9')
# L10 decision-time highlights that light only the winner
E(10205,"""    highlightedCardIds: const <String>[
      'hero_0',
      'hero_1',
      'board_0',
      'board_1',
      'board_2',
    ],
    centerLabel: 'Hero full house beats CO flush',""","""    highlightedCardIds: const <String>[],
    centerLabel: 'River showdown',""",ledger='L10+L12')
E(10280,"""    highlightedCardIds: const <String>[
      'hero_0',
      'hero_1',
      'board_0',
      'board_1',
      'board_2',
    ],
    centerLabel: 'Hero quads beat CO full house',""","""    highlightedCardIds: const <String>[],
    centerLabel: 'River showdown',""",ledger='L10+L12')
E(10350,"""    highlightedCardIds: const <String>[
      'board_0',
      'board_1',
      'board_2',
      'hero_0',
      'hero_1',
    ],
    centerLabel: 'Hero royal flush beats CO ace-high flush',""","""    highlightedCardIds: const <String>[],
    centerLabel: 'River showdown',""",ledger='L10+L12')
E(18560,"highlightedCardIds: const <String>['hero_0', 'hero_1', 'board_0'],","highlightedCardIds: const <String>[],",ledger='L10')
E(18800,"""    highlightedCardIds: const <String>[
      'board_0',
      'board_1',
      'board_2',
      'board_3',
      'board_4',
    ],
    highlightedSeatIds: const <String>['co', 'btn'],""","""    highlightedCardIds: const <String>[],
    highlightedSeatIds: const <String>['co', 'btn'],""",ledger='L10')
# L12 center labels that state the answer
for old,new in [("centerLabel: 'Five board cards'","centerLabel: 'Board count'"),("centerLabel: 'Best five: A A 7 7 J'","centerLabel: 'Showdown count'"),("centerLabel: 'Hero A-K beats CO A-Q by kicker'","centerLabel: 'Same pair of aces'"),("centerLabel: 'Wet board'","centerLabel: 'Board texture'"),("centerLabel: 'Disconnected'","centerLabel: 'Board ranks'"),("centerLabel: 'Draw missed'","centerLabel: 'River card'"),("centerLabel: 'Hero cannot win side pot'","centerLabel: 'Main pot and side pot'")]:
    i=src.index(old); E(src[:i].count('\n')+1,old,new,ledger='L12')
# apply: resolve every edit against the original text, then apply descending
spans=[]; anchor_pos={}
for anchor,old,new,window,ledger in edits:
    base=max(0,off(anchor)-300)
    if new is None:
        j=src.find(old,base); assert j>=0 and j-base<window, (anchor,old); anchor_pos[anchor]=j; continue
    start=anchor_pos.get(anchor,base) if ledger=='L9' else base
    j=src.find(old,start)
    assert j>=0 and j-start<=window+300, (anchor,old[:70],None if j<0 else j-start)
    spans.append((j,j+len(old),new,ledger))
spans.sort()
for a,b in zip(spans,spans[1:]): assert a[1]<=b[0], ('overlap',a[3],b[3])
s=src
for j,k,new,ledger in reversed(spans): s=s[:j]+new+s[k:]
open(out,'w').write(s)
import collections; print('edits applied',len(spans),collections.Counter(x[3] for x in spans))
