# Feedback / Repair Verdict Card Premium Lift v1

## Scope

Visual hierarchy only in the existing `Act0FeedbackShellV1` feedback path.
This covers wrong and correct feedback plus the existing repair focus, repair
result, and session repair proof states inside that shell.

## Evidence

Used the accepted Feedback / Repair Verdict Card premium-lift brief, focused
feedback rhythm tests, live local visual QA, and the first-week and Day 2
compact review packets.

## Component change

`Act0FeedbackShellV1` remains the single shared feedback surface. The outer
container now carries the premium tone through a restrained dark gradient,
subtle border, and soft shadow. A private hairline divider replaces the prior
equal-weight bordered subcards for action contrast, repair focus, repair
result, and session repair.

## Hierarchy result

The order is now status and coach line, role eyebrow, hero action, table
signal and why, then a hairline before repair or proof. The existing Continue
action remains the only filled CTA. Repair and session language remains calm
proof rather than a reward ceremony.

## Refinement pass

The shared feedback shell now renders the action as a separate hero line, with
the action role reduced to an eyebrow. The table signal is inline rather than
a bordered subcard. Repair focus removes the duplicate missed-signal sentence
and keeps its deterministic next-hand reason plus next-decision focus as one
secondary line. Repair-result and session-proof outcomes use stronger proof
typography without adding a second CTA.

The Day 2 `open_repair_source` capture uses this same shared feedback shell,
so it receives the lifted verdict treatment. It is not a separate legacy
surface.

## Review and Profile

No Review data or route behavior changed. Active Review spacing remains a
single intentional repair-card presentation when no recovered-proof data is
available; no proof strip was fabricated. Profile did not show a proven
`Today 0/3` versus progress-bar state in the current deterministic capture, so
no Profile state or structure was changed.

## Rules applied

- one tonal outer container;
- internal typography and hairlines rather than nested bordered boxes;
- hero action before the inline clue and why;
- blue remains reserved for the existing filled Continue CTA;
- calm muted explanation copy and sparing status accents;
- no saturated error fills, new CTA, route, logic, or telemetry behavior.

## Checks

- focused feedback-shell and feedback-rhythm tests;
- `first_week` and `day2_return` compact screen-review packets;
- `flutter analyze`, formatter, diff, and status checks before commit.

## Intentionally not changed

No Modern Table, routes, repair rules, telemetry, content, glossary, Review
mapping, Profile structure, screenshot tooling, monetization, AI, or generated
artifacts.

## Remaining limitation

The deterministic fast renderer still repairs some button-label glyph output.
It is suitable for hierarchy acceptance, not final native typography proof.

## Recommended next step

Package this bounded verdict-card lift, then assess a separate Review/Profile
rhythm pass only if new evidence shows a concrete data-backed layout issue.
