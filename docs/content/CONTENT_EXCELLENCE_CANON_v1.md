# Content Excellence Canon v1

Status: active content quality canon
Last updated: 2026-05-02

Builds on:

- `docs/learning/UNIFIED_LEARNING_ARCHITECTURE_v4.4.md`
- `docs/content/CONTENT_SYSTEM_v2.1.md`
- `docs/plan/CURRICULUM_DENSITY_WORLD_VOLUME_CANON_v1.md`
- `docs/plan/WORLD_PROGRESSION_PACING_SSOT_v1.md`

Purpose:

- define what "great content" means for Sharky
- prevent shallow node fill that only looks complete
- keep lessons fun, useful, deterministic, and beginner-safe
- give agents and humans a shared bar before content becomes release-visible

## One-Sentence Standard

Great Sharky content makes the learner understand one poker idea at the table,
use it correctly, repair the common mistake, and feel a small earned win.

## The Content Unit

The release unit is a micro-session, not a text lesson.

Each micro-session must have:

1. One skill atom.
2. One table situation where the atom matters.
3. One correct behavior.
4. One common mistake.
5. One short reason.
6. One variation.
7. One repair path.
8. One mastery signal.

If a task cannot be shown on the table, it is probably too abstract for early
worlds.

## Skill Atom Test

A skill atom is valid only if all questions have clear answers:

| Question | Required answer |
| --- | --- |
| What does the learner notice? | A visible table/card/action cue. |
| What does the learner do? | Tap, classify, choose, compare, or recall. |
| Why is it correct? | One beginner-safe reason. |
| What mistake is likely? | One predictable wrong answer. |
| How is the mistake repaired? | One table-adjacent explanation or repeat. |

Bad atom:

- "Understand position."

Good atom:

- "When hero is BTN and everyone folds, identify that hero acts last postflop."

## Session Rhythm

Default rhythm:

1. Show the concept.
2. Ask one guided question.
3. Repeat with one variation.
4. Apply in a slightly more real spot.
5. Repair any mistake.
6. Recap with a lesson-learned takeaway.

Avoid:

- five passive explanations in a row
- five identical action buttons in a row
- asking before the visual cue was taught
- review that only repeats lesson titles

## Decision Count Guidance

For a real micro-session:

- minimum: 4 meaningful decisions
- target: 6-12 decisions
- maximum for beginner session: keep short enough for 3-7 minutes

The session can mix direct answers and table taps.

Examples:

- tap BTN
- choose Fold / Call / Raise
- classify board dry/wet
- compare pair versus two pair
- choose who acts first
- spot whether a bet is value or bluff

## Beginner Copy Rules

Copy should be:

- short
- concrete
- table-linked
- calm
- supportive

Use:

- "This bet sets a price."
- "BTN acts last after the flop."
- "Weak ace can be behind a better ace."

Avoid:

- "optimal"
- "GTO"
- "MDF"
- "range construction"
- "equity realization"
- "solver-approved"

Advanced terms can appear later only after the learner has the visible model.

## Feedback Rules

Correct feedback:

- names what was read correctly
- stays short
- reinforces the habit

Wrong feedback:

- never shames
- shows the selected mistake
- shows the better action or label
- gives one table reason
- either repairs immediately or sends the mistake to Review

Example:

- "Not quite. You chose Call. Better: Fold. The price is high and the hand is
  weak."

## Recap Rules

Recap is not a title repeat.

A recap must include:

1. What changed in the learner's model.
2. One rule of thumb.
3. One common trap to avoid.

Example:

- "Lesson learned: value means worse can call. Before betting, name which worse
  hands can pay. Do not bet just because your hand looks strong."

## Real-Play Transfer Rules

Every playable world should eventually include one transfer task.

Transfer tasks are short observation prompts, not new engines.

Examples:

- "Watch three hands. Point to BTN before the cards are dealt."
- "Pause a flop. Say dry or wet before anyone bets."
- "Spot one bet that wants a call and one bet that wants folds."

Transfer should start early, not only after advanced worlds.

## Anti-Boredom Rules

Content should vary after the base concept is stable.

Good variety:

- same atom, new cards
- same atom, new seat
- same atom, new street
- table tap instead of button choice
- mistake spotting
- quick replay

Bad variety:

- unrelated concept jump
- harder vocabulary instead of better practice
- random novelty that does not reinforce the atom

## Mastery Tiers

Every atom should be reusable across three tiers:

| Tier | Name | What changes |
| --- | --- | --- |
| 1 | Learn | hints allowed, clean examples, generous pace |
| 2 | Prove | fewer hints, tighter feedback, mixed recall |
| 3 | Speed | low guidance, faster decisions, mixed contexts |

Do not create infinite content.

Reuse curated atoms with changed guidance and tighter thresholds.

## Sharky Content Rules

Sharky should make content feel alive without becoming content.

Allowed Sharky lines:

- pre-session goal
- correct reaction
- wrong repair encouragement
- block completion identity line

Not allowed:

- extra lecture
- open chat affordance
- generic filler
- repeated interruption

Good:

- "Nice read. You spotted the price."
- "Small miss, easy repair. Look at who set the price."

Bad:

- "Ask me anything about poker."
- "You should study harder."

## World Release Checklist

A world is release-playable only when:

1. It has one clear cognitive shift.
2. It has a clear emotional win.
3. It has 5-10 meaningful micro-sessions or equivalent density.
4. It includes intro, practice, apply, and review.
5. It has common mistakes and repairs.
6. It has at least one transfer prompt or planned transfer seam.
7. It does not depend on a later world to teach its own basics.
8. Its copy avoids advanced jargon unless already taught.
9. It has deterministic correctness.
10. It has focused tests or content guards for the claims it makes.

## Human Review Checklist

Before calling a world release-grade, a reviewer should answer:

1. Would a total beginner know why the first question is being asked?
2. Does every lesson teach one thing, not three?
3. Is there enough repetition to stabilize the habit?
4. Are wrong answers useful?
5. Does the world feel less boring than a quiz list?
6. Does the world create a small real-play behavior?
7. Does Sharky help without talking too much?
8. Would this make someone want to return tomorrow?

## Stop Rules

Stop and redesign the content slice if:

- a question appears before its concept is shown
- a beginner needs outside poker knowledge to answer
- a lesson has multiple unrelated atoms
- feedback explains with jargon
- review only repeats task names
- the map looks full but the world has no real application layer
- the content is correct but boring
