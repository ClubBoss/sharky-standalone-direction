# Sharky Implementation And Skill Growth Policy v1

Status: ACTIVE
Last updated: 2026-05-07

## Purpose

Lock the product direction for Sharky, feedback, skill growth, and future
leveling so the app gains warmth and retention without drifting into mascot
noise, fake gamification, or table-second UX.

This is the active implementation guardrail.

Use this document when deciding:

- how Sharky should appear and speak
- what the feedback card should prioritize
- how skill growth should surface after tasks
- what "levels" may mean later
- what ideas from exploratory mascot notes are acceptable versus rejected

This file does not replace the visual upgrade packet.
It constrains how that packet should be implemented.

## Product Verdict

Sharky should become a real product character, but not the center of the
product.

The app remains:

1. table first
2. decision first
3. learning truth first
4. Sharky second

Best product shape:

- Sharky is the primary emotional frame
- the product remains the primary instructional voice

Short version:

Sharky is a compact premium coach, not a mascot-first chat companion.

## What We Are Building

We are intentionally building:

- a premium table-first trainer
- with a compact emotional layer
- with visible skill growth
- with honest rewards tied to real learning evidence

We are not trying to build:

- a Duolingo-style mascot-first product
- an open-ended AI coach
- a noisy gamification shell
- a dashboard-heavy progression system

## Accepted Direction

The following directions are approved:

1. Real Sharky image integration using curated mood states.
2. Sharky inside the feedback hierarchy, not floating as unrelated chrome.
3. One short pre-session line, one short post-answer reaction, one short
   progress-linked reinforcement.
4. Skill gain visibility at the moment of earning.
5. Progress by real skill family, not only by generic level.
6. Brief celebration for real milestones: stable skill family, repaired weak
   spot, completed checkpoint, completed world block.
7. A cleaner wrong-answer layout where the signal is easier to parse than it is
   today.
8. Sharky warmth that reduces frustration and improves return motivation.

## Rejected Direction

The following directions are explicitly rejected:

1. Open-ended Sharky chat.
2. "Sharky says..." as a default prefix everywhere.
3. Mascot-first layout where Sharky visually competes with the table.
4. Reward systems based on taps, session count alone, or generic exposure.
5. Loud RPG framing before the learner feels real competence.
6. Emotional theater that makes the app feel childish or noisy.
7. Progress systems that hide the real skill family behind one vanity number.
8. Any implementation that makes wrong-answer states more crowded instead of
   clearer.

## Feedback Hierarchy Truth

Feedback must stay deterministic and table-adjacent.

On any answer, the learner should understand in this order:

1. what happened
2. what was true
3. what to notice next

Sharky improves the tone of that loop.
Sharky does not replace the loop.

### Correct Answer Feedback

Correct states should prioritize:

1. short positive reaction
2. one clear explanation sentence
3. optional compact skill gain row
4. optional collapsed context for "why"

### Wrong Answer Feedback

Wrong states should prioritize:

1. calm repair reaction
2. one clear correction sentence
3. one next cue
4. optional collapsed context

Wrong states should be calmer and clearer than they are today, not denser.

### Feedback Closure Requirements

Before the early route can be called externally strong:

1. learner-visible feedback on the active route must be scenario-first,
   specific, and calm
2. a weak-feedback heatmap must exist for the active learner path
3. a generic-copy residue audit must be run and tracked to closure

Not acceptable as closure:

- short generic praise with no table-specific reason
- wrong-answer copy that could fit almost any spot
- system-shaped template residue that sounds detached from the hand

## Sharky Visual Role

Real Sharky art is approved and strongly preferred over coded icon-only mascot
surfaces.

However:

- Sharky should stay small-to-medium in footprint
- Sharky should support the card hierarchy, not dominate it
- Sharky should feel premium, not toy-like
- Sharky should map to useful emotional states only

Approved early states:

- neutral
- happy
- celebrate
- thinking
- repair

Optional later idle state:

- sleeping

## Sharky Copy Rules

Sharky copy must stay:

- short
- curated
- emotionally useful
- free of solver jargon
- free of open-ended companion behavior

Preferred shape:

- 2 to 6 word reaction headline
- 1 short supporting sentence

Avoid:

- paragraphs
- motivational fluff
- therapist tone
- repeated mascot catchphrases

## Skill Growth Truth

Skill growth should be visible, but it must remain grounded in real learning
truth.

Allowed growth sources:

1. correct authored scenario performance
2. repeated stability inside one skill family
3. checkpoint or capstone completion
4. linked scenario-chain performance
5. recovery after earlier weakness

Do not treat these as meaningful growth by themselves:

- taps
- time spent
- session count alone
- streak alone
- one lucky correct answer

## Skill Family First, Levels Second

The app should first show growth by real learning family.

Examples:

- table sense
- board reading
- hand reading
- betting decisions
- position play
- blind play

This is the primary truth layer.

Later "levels" may exist, but only as a summary layer above real skill-family
evidence.

That means:

1. levels must derive from skill-family evidence
2. levels must not replace skill-family readability
3. levels must never be the only progress surface

## Leveling Policy

Future levels are allowed only if they obey all of these rules:

1. They summarize repeated learning evidence, not raw activity.
2. They remain secondary to real skill-family movement.
3. They celebrate real improvement rather than fabricate momentum.
4. They do not turn the product into a generic XP grinder.
5. They preserve the table-first identity of the app.

Good future level meaning:

- a compact summary of broad learner growth
- a milestone surface for identity and return motivation

Bad future level meaning:

- a replacement for real poker understanding
- a vanity number farmed through repetition without learning

## Visibility Policy

Skill growth should become visible in this order:

1. at the moment of earning inside post-answer feedback
2. in compact block/checkpoint recaps
3. in the profile as a stable summary
4. later, in deeper identity/level surfaces

This order matters.
The learner should feel improvement before they are asked to interpret a
dashboard.

## Implementation Order

The approved rollout order is:

1. real Sharky image integration
2. feedback card hierarchy redesign
3. in-the-moment skill gain surfacing
4. better skill-family mapping coverage
5. compact profile/progress summaries
6. later level/meta layer only after the above is strong

Do not skip directly to deep level systems before the feedback loop is strong.

## Relationship To Existing Docs

This file works with, not against, the existing stack:

1. `MASTER_PLAN_v3.0.md`
   Product route and top-level product quality bar.
2. `SHARKY_PROGRESSION_RETENTION_LAYER_v1.md`
   High-level role of Sharky and retention sequencing.
3. `CONTENT_SYSTEM_v2.1.md`
   Compact curated Sharky behavior and content-system limits.
4. `PROGRESS_SIGNAL_DERIVATION_v1.md`
   Ground truth for what may count as meaningful progress.
5. `SHARKY_VISUAL_SKILL_UPGRADE_PLAN_v1.md`
   Implementation packet for the visual and feedback upgrade.

Interpretation rule:

- this file = direction and guardrails
- visual upgrade plan = implementation packet
- exploratory notes = non-SSOT unless merged here or into the active stack

## Anti-Pattern Check

If a Sharky/progression proposal does any of the following, reject it:

1. makes the table feel secondary
2. increases cognitive load on wrong states
3. adds mascot chatter without learning value
4. rewards generic activity instead of evidence
5. hides real skill-family truth behind vague gamification
6. makes the app feel childish instead of premium

## Decision Rule

If a proposed Sharky/progression change cannot explain:

1. how it improves learning confidence
2. how it preserves table-first UX
3. which real skill signal it derives from
4. why it is emotionally useful without becoming noisy

then it is not ready to ship.
