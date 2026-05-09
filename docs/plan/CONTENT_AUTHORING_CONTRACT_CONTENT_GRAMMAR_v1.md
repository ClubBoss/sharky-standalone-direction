# Content Authoring Contract / Content Grammar v1
Status: SSOT-lite
Purpose: Record the minimum authoring contract and slice grammar that future content fill should follow so authored slices stay coherent, deterministic, and product-clean.
Last updated: 2026-03-09

## Use

This document sits alongside:

- `docs/content/CONTENT_SYSTEM_v2.1.md`
- `docs/plan/MODE_FAMILY_STRATEGY_v1.md`
- `docs/plan/SKILL_COVERAGE_MATRIX_v1.md`
- `docs/plan/WORLD_NODE_MODE_MATRIX_v1.md`
- `docs/plan/PROGRESSION_PREREQUISITE_MATRIX_v1.md`

It does not replace runtime contracts.
It defines the authoring discipline that should shape future content slices before broader fill continues.

Core rule:

- content should feel like one system
- not like many unrelated packets written in different voices and structures

## Core Authoring Roles

### Intro

Purpose:

- tell the learner what this slice is about before the reps start
- set focus without a lecture

Good usage:

- one short framing card or prelude
- names the skill and what to watch

Low-EV usage:

- long theory page
- abstract motivational copy
- restating the entire course plan

### Practice

Purpose:

- build recognition and repetition on the target skill

Good usage:

- compact deterministic reps
- one main decision or recognition job at a time

Low-EV usage:

- many concepts mixed too early
- unclear prompt + unclear success condition

### Apply

Purpose:

- make the learner use the skill in a slightly more decision-like context

Good usage:

- same skill under a slightly richer spot
- still bounded and deterministic

Low-EV usage:

- abrupt jump into multi-concept reasoning
- hiding the real target skill behind unrelated complexity

### Review

Purpose:

- revisit a recent mistake or fragile skill with low friction

Good usage:

- short resurfacing
- same core signal, cleaner correction

Low-EV usage:

- full reteach of the world
- random old content with no reason to reappear

### Recap

Purpose:

- consolidate the pattern after a bounded cluster

Good usage:

- one short summary of what the learner should leave with

Low-EV usage:

- repeating every prompt in long form
- a second lesson disguised as recap

## Canonical Authored Slice Elements

These are the practical slice elements already used or clearly implied in current modernized paths and pilots.

### Setup / Concept Framing

What it is for:

- tell the learner what the concept is in plain terms

Good usage:

- one clear sentence
- names the pattern, not just the task

Bad usage:

- internal scaffolding language
- vague filler like “this is important”
- duplicating the prompt without adding concept

Required or optional:

- required for intros and modernized smart-learning micro-slices
- optional for pure review reps if the pattern is already established

### Why it matters

What it is for:

- explain why the learner should care about the correct pattern

Good usage:

- causal
- practical
- short

Bad usage:

- restating the prompt
- generic “because it matters”
- solver-heavy jargon

Required or optional:

- strongly preferred for intro/practice bridge slices
- optional for ultra-short review if reinforcement already covers the same value

### Notice / Focus

What it is for:

- point the learner at the key visual or structural cue

Good usage:

- tells the learner what to look at on the table or in the spot

Bad usage:

- too broad
- hidden second lesson
- duplicated `Why it matters`

Required or optional:

- preferred where visual anchoring is central
- optional when the prompt itself already isolates the cue cleanly

### Expected Answer

What it is for:

- define the best deterministic answer for the rep

Good usage:

- one clear expected result
- machine-checkable

Bad usage:

- fuzzy “best depends”
- hidden author intent not encoded in content

Required or optional:

- required for deterministic evaluated slices

### Acceptable Answer(s)

What it is for:

- allow a legal-but-weaker answer without pretending it is the best answer

Good usage:

- limited use
- explicit “acceptable but worse” semantics

Bad usage:

- adding many acceptable answers to avoid hard decisions
- blurring correct vs merely legal

Required or optional:

- optional
- only use when the instructional goal truly benefits from soft-pass handling

### Mismatch / Correction Copy

What it is for:

- tell the learner what was wrong in a compact factual way

Good usage:

- specific
- short
- points back to the target pattern

Bad usage:

- shame language
- long essay
- cryptic failure labels exposed as user copy

Required or optional:

- required for evaluated reps

### Reinforce / Recap

What it is for:

- restate the stable takeaway after success or cluster completion

Good usage:

- one compact line or short grouped block

Bad usage:

- duplicate of setup/why/notice all at once
- long summary that overwhelms the learner

Required or optional:

- preferred after bounded clusters
- optional after single tiny reps if recap already exists at cluster end

## Good Slice Shape

A minimally healthy authored slice usually does this:

1. tells the learner what the rep is about
2. gives one clear target
3. keeps the evaluation deterministic
4. gives one short why or notice signal
5. reinforces the right pattern without overexplaining

Practical implication:

- not every slice needs every field
- but every slice should have a clear instructional job

## Bad Slice Patterns To Avoid

- placeholder-like copy that feels internal or unfinished
- three fields that all say the same thing
- prompt and correction that disagree about what the task is
- “acceptable” answers used as a hedge against unclear authoring
- intro text that becomes a hidden lesson wall
- recap text that is longer than the practice itself

## Answer Semantics

### Expected vs Acceptable

`expected` means:

- the best answer the slice is teaching
- the answer the learner should internalize as the target pattern

`acceptable` means:

- not the preferred answer
- still legally or strategically defensible enough for a soft pass

Practical rule:

- acceptable should never erase the identity of the expected answer
- the learner must still know what the best answer was

### When Acceptable Is Appropriate

Use acceptable answers when:

- the learning target is “best vs legal-but-weaker”
- the product benefits from soft-pass correction instead of hard fail

Do not use acceptable answers when:

- the slice is a clean foundational rep
- ambiguity would weaken the core pattern
- the rep should teach exact recognition or exact order

### Deterministic Evaluation Rule

- one rep should still have clear evaluation semantics
- avoid “both are kind of right” authoring unless the slice explicitly teaches that distinction
- if a slice needs open interpretation, it likely belongs to a later family, not a foundational deterministic rep

## Authoring Quality Rules

- keep it short and calm
- no wall of text
- no solver-heavy jargon
- no placeholder-like user-facing copy
- no duplicated fields that say the same thing
- preserve table-first / product-first clarity
- if wording is too dense, compress before adding more structure
- prefer one strong sentence over three weak ones

## Optional vs Required By Slice Type

### Intro slice

Usually needs:

- setup / concept framing
- why it matters
- notice / focus

### Practice slice

Usually needs:

- prompt
- expected answer
- mismatch/correction
- optional why or notice

### Apply slice

Usually needs:

- prompt
- expected answer
- stronger why or reinforce

### Review slice

Usually needs:

- compact prompt
- expected answer
- compact correction

### Recap slice

Usually needs:

- reinforce / recap only

## Near-Term Implication

Future content fill should use this contract to keep:

- early smart-learning slices coherent
- session-drill pilots structurally consistent
- answer semantics deterministic
- intro/practice/apply/review roles distinct

Future content QA and future guards should eventually use this grammar to catch:

- missing target pattern framing
- duplicate low-value copy
- incorrect acceptable-answer usage
- mismatch between prompt, evaluation, and correction

Future mode contracts can build on this grammar rather than inventing one-off authoring rules for every new slice.
