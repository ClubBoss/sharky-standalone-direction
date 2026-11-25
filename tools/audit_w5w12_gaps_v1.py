#!/usr/bin/env python3
"""B77: snapshot-only triage of non-repair W5–W12 course rows.

C5 membership comes from the checked-in atlas baseline, not a reimplementation
of the Dart guard: the snapshot joins teaching titles/bodies and feedback
titles/reasons. Semantic dispositions are reviewed rules for this snapshot,
not new guard exceptions. Unknown concepts/candidates remain visible.
"""
import argparse
from collections import Counter, defaultdict
from dataclasses import dataclass, field
import json
from pathlib import Path
import re

FIXTURES = Path(__file__).resolve().parents[1] / "test/fixtures"
WORLDS = range(5, 13)
FP = "FP-guard"
SELF = "SELF-SUPPLIED"
REAL = "REAL-EARLY"
REVIEW = "REVIEW"
TEACHING = {"TEACH", "CAPTION", "HINT"}
DECISION = {"Q", "OPTION"}
OPTION = re.compile(r"  ([+-]) \[(\w+)\] (.*?) —\s*(.*)$")


@dataclass
class Task:
    world: int
    id: str
    phase: str
    surfaces: list = field(default_factory=list)
    options: list = field(default_factory=list)


def read_tasks():
    tasks = {}
    world = None
    task = None
    for line in (FIXTURES / "act0_catalog_snapshot_v1.txt").read_text().splitlines():
        if line == "===== REPAIR-ONLY TASKS =====":
            break
        if match := re.match(r"===== WORLD (\d+) · LESSON ", line):
            world = int(match[1])
            task = None
        elif match := re.match(r"TASK (\S+) \[(\w+)\]", line):
            task = Task(world, match[1], match[2])
            if task.id in tasks:
                raise ValueError(f"Duplicate course task: {task.id}")
            tasks[task.id] = task
        elif task is not None:
            if line.startswith(("TEACH: ", "CAPTION: ", "Q: ")):
                task.surfaces.append(tuple(line.split(": ", 1)))
            elif match := re.match(r"HINT \[(\w+)\]: (.*)", line):
                if match[1] == "always" or (match[1] == "theoryOnly" and task.phase == "theory"):
                    task.surfaces.append(("HINT", match[2]))
            elif match := OPTION.fullmatch(line):
                sign, quality, label, feedback = match.groups()
                # The snapshot also carries seat and size tags on these labels.
                task.surfaces.extend([("OPTION", label), ("FEEDBACK", feedback)])
                task.options.append((sign, quality, label, feedback))
    return tasks


def read_patterns():
    source = json.loads((FIXTURES / "act0_c5_concepts_v1.json").read_text())
    patterns = dict(source["coverage_patterns"])
    for concept in source["owner_concepts"]:
        aliases = "|".join(map(re.escape, concept["aliases"]))
        patterns[str(concept["n"])] = rf"(?<![a-z0-9])(?:{aliases})(?![a-z0-9])"
    exceptions = json.loads((FIXTURES / "act0_c5_exceptions_v1.json").read_text())
    return {key: re.compile(value, re.I) for key, value in patterns.items() if key not in exceptions}


# Earlier or same-task instruction exists, including teaching by example and
# singular/plural/synonym misses. See report for the reviewed teaching anchors.
FP_CONCEPTS = set("""
139 141 14 check 43 two_pair starting_chart action_order 147 148 ip_oop
169 97 98 board_texture 93 paired_board connected_board 121 flush_draw
118 119 oesd gutshot backdoor range 495 528 427 cbet 359 fold_equity
393 192 isolation full_ring_6max 297 effective_stack 300 short_stack
309 spr 312 388 848 icm 385 845 889 bubble 687 691 692 player_types
bluff_catcher 131 334 multiway 842 ante gto mixed_strategy
""".split())
# Ordinary prose, explicit local example/assumption, or a descriptive term
# that need not be learned to make the choice. These are not guard deletions.
SELF_CONCEPTS = set("""
440 569 570 84 one_in_n winrate rake 26 table_talk deep_stack
137 138 152 156 296 mtt commitment push_fold outs
""".split())

# Core gaps: the decision options use commitment before a plain gloss; W9's
# recap introduces steals as a label before W10 teaches it. Earlier examples
# teach the underlying mechanisms, not these specific labels.
REAL_KEYS = {
    ("w7_low_spr_commit", "commitment"): "Define commitment before options: a bet may leave little stack for later decisions; not an automatic all-in.",
    ("w7_high_spr_room", "commitment"): "Use 'putting most of the stack in now' instead of 'immediate commitment', or use the prior gloss.",
    ("w7_spr4_middle", "commitment"): "Use plain wording about remaining chips in both options; reuse the low-SPR gloss.",
    ("w7_top_pair_spr2_transfer", "commitment"): "Replace 'commitment pressure' with 'a bet uses more of the remaining stack'.",
    ("w9_survival_recap", "steal"): "Replace 'skip sound steals' with 'skip good raises to win the blinds'.",
    ("w9_checkpoint_table_notice", "steal"): "Replace 'successful steals' with 'times everyone folds to your raise'.",
}

# Ante appears in an unrelated EV intro formula before its own teaching;
# bubble is recalled in that same lesson using the already shown payout case.
# Both are context, not prerequisite demands of the intervening choices.
SELF_KEYS = {
    ("w9_survival_intro", "ante"), ("w9_survival_intro", "842"),
    ("w9_survival_recap", "bubble"), ("w9_survival_recap", "889"),
}
FP_KEYS = {
    ("w7_spr_recap", "push_fold"),
    ("w7_top_pair_spr2_transfer", "push_fold"),
    ("w11_checkpoint_trigger_line", "push_fold"),
    # The broad deep-stack matcher also fires on a literal 200 BB.
    ("w7_effective_stack_intro", "deep_stack"),
    ("w7_effective_stack_30bb", "deep_stack"),
    ("w7_effective_stack_100bb", "deep_stack"),
}


def classify_c5(task, concept):
    pair = (task.id, concept)
    if pair in REAL_KEYS:
        return REAL
    if pair in SELF_KEYS:
        return SELF
    if pair in FP_KEYS:
        return FP
    if concept in FP_CONCEPTS:
        return FP
    if concept in SELF_CONCEPTS:
        return SELF
    return REVIEW


def c5_rows(tasks, patterns):
    baseline = json.loads((FIXTURES / "act0_catalog_quality_baseline_v1.json").read_text())
    for key in baseline["c5_concept_order_v1"]:
        world, task_id, concept = key.split("|")
        if int(world[1:]) not in WORLDS:
            continue
        task = tasks[task_id]
        if task.world != int(world[1:]):
            raise ValueError(f"World mismatch: {key}")
        matches = [(surface, copy) for surface, copy in task.surfaces if patterns[concept].search(copy)]
        # Baseline is authoritative, but never silently classify stale keys.
        category = classify_c5(task, concept) if matches else REVIEW
        yield task, concept, category


def reason_probe(feedback):
    """The export has no title/reason delimiter; a first sentence is a proxy."""
    return re.split(r"(?<=[.!?])\s+", feedback, maxsplit=1)[-1]


def normalize(copy):
    return " ".join(re.findall(r"\w+", copy.casefold()))


GENERIC = re.compile(
    r"^(?:not quite|look again|try again|incorrect|wrong|recheck|think again|"
    r"read the table again|that is not (?:right|correct|the best choice))\W*$", re.I
)

# These short bodies were inspected against the selected option. Each names
# a concrete rank, count, price, seat, action or contrast; brevity != generic.
SHORT_EXCLUSIONS = {
    ('flush_draws_w5_made_hand_vs_flush_draw_transfer', 'Current hand first. Your pair of aces already counts. Another heart could help an opponent later.'),
    ('straight_draws_w5_gap_board', 'Not quite. Straight pressure needs closer ranks.'),
    ('straight_draws_w5_gutshot_contrast_transfer', 'You still need a fifth rank. Your four ranks need a 5 or a ten to make a straight.'),
    ('outs_improvement_w5_flush_out', 'Not quite. The flush path is hearts, so hearts are the outs.'),
    ('outs_improvement_w5_straight_out', 'Not quite. A king does not connect this rank ladder.'),
    ('outs_improvement_w5_straight_out', 'Check the clue again. A ten skips the nine. You need five consecutive ranks for a straight.'),
    ('turn_river_changes_w5_river_misses', 'Not quite. No spade arrived on the turn or river. The flop draw never completed.'),
    ('turn_river_changes_w5_river_draw_story_transfer', 'The ace misses the draw. The river ace does not extend 4-5-6-7 to a straight.'),
    ('w6_combo_weight_compare', 'Not quite. Pocket pairs have only 6 combos. Broad non-pair families like A-K are denser.'),
    ('range_checkpoint_board_fit', 'Check for a matching rank. There are no equal ranks among your two cards and this flop.'),
    ('range_checkpoint_board_fit', 'Count five consecutive ranks. The cards do not form five consecutive ranks. Your hand is ace-high.'),
    ('range_checkpoint_combos', 'Count all suit combinations. Twelve counts only the offsuit hands. Four suited combinations are possible as well.'),
    ('w6_checkpoint_table_combo_weight', 'Count the off-suit combinations. CO opens all six pocket-nine combos here and all twelve A-K offsuit combos.'),
    ('w6_kicker_showdown_compare', 'Both hands miss this flop. Neither hand has a pair. They fold under the stated rule.'),
    ('range_checkpoint_review', 'Pot size does not remove a card. Look for information about which private cards are still physically available.'),
    ('visible_card_combo_density_transfer_check', 'Recheck the visible cards. Visible cards change available counts; they do not identify an exact hand.'),
    ('w7_count_winning_rivers', 'Check what can still win. Nine hearts make a winning flush. Three non-heart aces also win.'),
    ('w7_count_winning_rivers', 'Check what can still win. Count the three unseen aces as well as all nine unseen hearts.'),
    ('w8_guided_short_read', 'Look again. The draws fold. Counting them as callers overstates what the bet earns.'),
    ('w9_m_ratio_table_window_transfer', 'Look again. M is 12. A fold gives up a free flop after SB calls.'),
    ('w10_find_limper', 'Look again. SB posted 0.5 BB as a blind. That post was forced.'),
    ('w10_find_turn_raiser', 'Look again. CO made the first turn bet of 5 BB. BB made the raise.'),
    ('w10_find_turn_raiser', 'Look again. BTN folded before the flop and put no chips in on the turn.'),
    ('w11_bankroll_stake_choice', 'Look again. $340 covers 34 NL10 buy-ins. This is six below the course buffer.'),
    ('w11_first_in_seat', 'Look again. UTG folded. Counting that seat as the opener ignores HJ’s 2.5 BB raise.'),
    ('w12_checkpoint_review', 'Look again. Checking misses the 6 BB payments that weaker aces and nines would make.'),
}


def feedback_rows(tasks):
    for task in tasks.values():
        if task.world not in WORLDS:
            continue
        full = [normalize(option[3]) for option in task.options]
        body = [normalize(reason_probe(option[3])) for option in task.options]
        for index, (sign, quality, label, feedback) in enumerate(task.options):
            if sign != "-":
                continue
            if not full[index]:
                candidate = "empty"
            elif full.count(full[index]) > 1 or body.count(body[index]) > 1:
                candidate = "identical"
            elif GENERIC.fullmatch(feedback) or GENERIC.fullmatch(reason_probe(feedback)):
                candidate = "generic"
            elif len(reason_probe(feedback).split()) <= 13:
                candidate = "short/generic candidate"
            else:
                continue
            excluded = candidate == "short/generic candidate" and (task.id, feedback) in SHORT_EXCLUSIONS
            yield task, label, feedback, candidate, excluded


# Exact-alias absence is only a candidate: synonyms and earlier examples
# supply the concept. Each accepted exclusion names its pre-choice anchor.
# For "steal" the mechanism was taught, but the label is missing: keep the
# real C5 wording gap and do not count it as an absent underlying concept.
PREREQUISITE_EXCLUSIONS = {
    "119": ("straight_draws_w5_straight_intro", "An open-ended draw can finish at either end", "open-ended draw at either end"),
    "528": ("w6_combo_counts_intro", "A blocker is a known card", "singular blocker definition"),
    "312": ("w7_spr_intro", "SPR is the stack-to-pot ratio", "SPR ratio and low/high room"),
    "steal": ("w9_short_stack_survival", "an all-in can win the blinds", "first-in all-in can win blinds; term remains a C5 gap"),
    "gto": ("w9_survival_recap", "balances growth and survival", "ordinary-language balances, no GTO tested"),
    "mtt": ("w9_survival_intro", "Your run ends if you lose your stack", "chips versus prizes in tournament setting"),
    "296": ("w7_effective_stack_intro", "The smaller of two stacks", "stack amounts and smaller stack"),
    "131": ("w10_outs_and_turn_price", "A clean out makes you win", "singular clean out makes you win"),
}


def prerequisite_rows(tasks, patterns):
    seen = set()
    prior_ids = set()
    for task in tasks.values():
        for surface, copy in task.surfaces:
            if surface in TEACHING:
                seen.update(concept for concept, pattern in patterns.items() if pattern.search(copy))
        if task.world in WORLDS:
            for concept, pattern in patterns.items():
                if concept in seen:
                    continue
                if not any(pattern.search(copy) for surface, copy in task.surfaces if surface in DECISION):
                    continue
                anchor, fragment, why = PREREQUISITE_EXCLUSIONS.get(concept, ("", "", "unreviewed"))
                if concept == "gto" and anchor == task.id:
                    excluded = any(surface == "Q" and fragment in copy for surface, copy in task.surfaces)
                else:
                    excluded = anchor in prior_ids and any(
                        surface in TEACHING and fragment in copy for surface, copy in tasks[anchor].surfaces
                    )
                yield task, concept, excluded, why, anchor
        prior_ids.add(task.id)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--details", action="store_true", help="print every baseline entry and candidate disposition")
    args = parser.parse_args()
    tasks = read_tasks()
    patterns = read_patterns()
    c5 = list(c5_rows(tasks, patterns))
    feedback = list(feedback_rows(tasks))
    prerequisites = list(prerequisite_rows(tasks, patterns))
    counts = Counter((task.world, category) for task, concept, category in c5)
    world_counts = Counter(task.world for task in tasks.values())
    dropped_feedback = Counter(task.world for task, _, _, _, excluded in feedback if excluded)
    feedback_tasks = {(task.world, task.id) for task, _, _, _, excluded in feedback if not excluded}
    missing_pairs = {(task.world, concept) for task, concept, excluded, _, _ in prerequisites if not excluded}
    dropped_prereq = Counter(task.world for task, _, excluded, _, _ in prerequisites if excluded)
    columns = ["World", "Rows", FP, SELF, REAL, REVIEW, "Feedback tasks", "Feedback dropped", "Missing concepts", "Alias hits dropped"]
    print("| " + " | ".join(columns) + " |")
    print("| " + " | ".join(["---"] * len(columns)) + " |")
    totals = [0] * (len(columns) - 1)
    for world in WORLDS:
        values = [world_counts[world], *(counts[world, category] for category in (FP, SELF, REAL, REVIEW)),
                  sum(w == world for w, _ in feedback_tasks), dropped_feedback[world],
                  sum(w == world for w, _ in missing_pairs), dropped_prereq[world]]
        totals = [a + b for a, b in zip(totals, values)]
        print("| " + " | ".join(map(str, [f"W{world}", *values])) + " |")
    print("| " + " | ".join(map(str, ["Total", *totals])) + " |")
    print(f"Course rows W1–W12: {len(tasks)}; C5 pairs W5–W12: {len(c5)}.")
    print(f"Feedback candidates (options): {len(feedback)}; alias-absence candidates (task/concept): {len(prerequisites)}.")
    noncorrect = sum(sign == "-" for task in tasks.values() if task.world in WORLDS
                     for sign, _, _, _ in task.options)
    feedback_types = Counter(kind for _, _, _, kind, excluded in feedback if not excluded)
    print(f"Noncorrect options inspected: {noncorrect}; retained empty: {feedback_types['empty']}; "
          f"identical: {feedback_types['identical']}; generic/short: "
          f"{feedback_types['generic'] + feedback_types['short/generic candidate']}.")
    if args.details:
        for world in WORLDS:
            for category in (FP, SELF, REAL, REVIEW):
                grouped = defaultdict(list)
                for task, concept, classification in c5:
                    if task.world == world and classification == category:
                        grouped[task.id].append(concept)
                if grouped:
                    print(f"W{world} {category}: " + "; ".join(f"{task}: {', '.join(concepts)}" for task, concepts in sorted(grouped.items())))
        print("\nConfirmed C5 repair proposals:")
        for task, concept, category in c5:
            if category == REAL:
                print(f"W{task.world} {task.id}|{concept}: {REAL_KEYS[task.id, concept]}")
        print("\nFeedback candidates:")
        for task, label, feedback_copy, candidate, excluded in feedback:
            print(f"W{task.world} {task.id} | {label} | {candidate} | {'DROP' if excluded else 'KEEP'} | {feedback_copy}")
        print("\nAlias-absence candidates:")
        for task, concept, excluded, why, anchor in prerequisites:
            print(f"W{task.world} {task.id}|{concept} | {'DROP' if excluded else 'KEEP'} | {anchor}: {why}")


if __name__ == "__main__":
    main()
