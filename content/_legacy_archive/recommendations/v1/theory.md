# Recommendation Overview

Persona-aware recommendations turn the SR queues into a live coaching feed. The layer scans fresh, priority, and decay items, builds a score from recent misses and difficulty tiers, and then asks which domain deserves the spotlight for the current learner. Each suggestion spells out the key action (call, fold, jam, check, raise_x) and why it is timely so the coaching voice feels deliberate rather than random noise.

## Why Adaptive Recommendations Matter

Static study plans collect dust once the player changes pace. An adaptive engine notices when Cash L3 ranges slip, when bubble ICM calls wobble, or when mixed-pattern instincts fade. Instead of repeating the same list, the system leans into these signals and the persona profile: risk-avoidant learners see more ICM drills, pattern seekers get Mixed and Recap nudges, and flow-focused learners receive quick micro-quizzes. This keeps practice efficient and prevents burnout from overdrilling mastered items.

## Inputs (SR queues, recent misses, difficulty tiers)

The scoring layer begins with three queues plus annotations. Fresh queue entries are easy hits (difficulty level 1 or unseen) and keep the learner warm. Priority queue entries are flagged by difficulty>=2 or tags such as pressure, premium, or stack, so they start with higher weight. Decay queue entries tend to be difficulty=3 or tagged with risk or decay; they are only surfaced when the persona can handle the strain. Recent misses receive a hot flag that temporarily multiplies their score so the next recommendation arrives quickly.

## Persona Signals (traits, insights, Tier-B summaries)

Persona signals translate telemetry into tuning knobs. Traits such as risk-avoidant, pattern seeker, or flow seeker come from Tier-B summaries and Phi-series insights. A risk-avoidant persona increases the score on ICM items that protect chips, while shaving points from heavy Cash L3 sessions. Pattern seekers get a boost on Mixed checkpoints and Recaps because they thrive on cross-skill echoes. Flow personas prefer shorter sets, so the model weights micro-quizzes and fewer items while trimming the load from difficult drills. When a persona trait shifts, the scoring stage recalculates the weights before ranking the queues.

## Cross-Skill Mapping (Cash L3, ICM L4, MTT, Mixed, Recaps, Micro)

Each SR item tags the domain it supports. Cash L3 items reinforce range and sizing awareness, ICM L4 items revisit risk premium and ladder pressure, MTT items emphasize stage dynamics, Mixed checkpoints weave contexts together, Recaps restate core heuristics, and Micro-Quizzes sharpen recall. The ranking step keeps all six channels visible so it can trigger a Mixed checkpoint after a Cash blunder or a micro-quiz after a Recap lull. This mapping prevents any single domain from monopolizing attention while honoring persona and queue cues.

## Decision Loop (Score -> Rank -> Suggest)

1. **Score**: Assign each item a numeric value using queue status, difficulty tier, persona weight, recent-miss boost, and tag alignment. Priority and decay queue entries already start above zero; persona-aligned tags such as pressure, premium, or stage cues add multipliers.
2. **Rank**: Sort scored items so higher values rise. Remove duplicates so a single concept appears once, and limit the slice to what the persona can handle.
3. **Suggest**: Output the top entries with a short explanation plus the action verb. If the persona is low on bandwidth, the list shrinks to micro-quizzes; if the persona craves depth, it can include Mixed or ICM drills with cross-skill callouts.

## Common Pitfalls

- **Treating every persona the same**: Ignoring trait weights creates generic recommendations that feel irrelevant.
- **Overloading with difficulty 3 hits**: Hard spots are important, but too many in a row fatigue focus.
- **Skipping recent misses**: The hot flag exists because mistakes need swift follow-up; ignoring them leaves gaps.
- **Dropping cross-skill context**: Each suggestion should reference the domain it strengthens so the learner understands why it matters.

[[IMAGE:rec_flow]]
