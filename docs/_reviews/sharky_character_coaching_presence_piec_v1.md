# Sharky Character & Coaching Presence PIEC v1

## Scope

Audit only on local `main` at `acd4acb27de4792005d689a7d4eea8a209218d01`.
No product, copy, UI, test, asset, animation, or screenshot changes.

## Inspected files

- `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md`
- `docs/plan/MASTER_PLAN_v3.0.md`
- `lib/ui_v2/act0_shell/act0_sharky_presence_v1.dart`
- `lib/ui_v2/act0_shell/act0_shell_state_v1.dart`
- `lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart`
- `lib/ui_v2/act0_shell/act0_home_shell_v1.dart`
- `lib/ui_v2/act0_shell/act0_learn_path_shell_v1.dart`
- `lib/ui_v2/act0_shell/act0_play_shell_v1.dart`
- `lib/ui_v2/act0_shell/act0_review_shell_v1.dart`
- `lib/ui_v2/act0_shell/act0_profile_shell_v1.dart`
- `lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart`
- `lib/ui_v2/act0_shell/act0_welcome_shell_v1.dart`

## Current Sharky inventory

| Surface | Current presence | Learner job | Assessment |
| --- | --- | --- | --- |
| Welcome | Compact `Act0SharkyGuideCardV1` on each welcome beat. | Explain the starting route. | Positive if it names the current learning purpose; verify density before any change. |
| Placement | Result state owns a Sharky coach title/line and route recommendation. | Explain the recommended starting point. | Positive when tied to diagnostic evidence; no implementation change admitted. |
| Home | Identity row, mission support line, and state-driven `sharkyOverride`. | Orient the next useful hand and calm return. | State-driven repair/daily lines are positive; static "one clean read ready" language is generic and can duplicate the route card. |
| Learn | Sharky guide title/line/detail for the current mission. | Explain why the current lesson matters. | Positive only as secondary route context; it must not make Learn look like Practice. |
| Practice / Play | No standalone Sharky card in the Play hub; repair recommendation owns the handoff. | Reinforce one useful rep. | Correct role boundary. Do not add mascot presence merely for coverage. |
| Review | Repair coach and pattern card are learner-facing, but not Sharky-branded. | Repair a clue or repeated pattern. | Correct: causal repair copy matters more than a character wrapper. |
| Runner theory/decision | Mascot cue/learning rail and authored pre-session prompts. | Focus the next table read before acting. | Positive when prompt-specific; generic fallback encouragement is lower EV. |
| Feedback / repair result | Mascot, signal proof, Repair focus, Repair result, and Session repair. | Connect answer to signal, repair, and outcome. | Highest learning-EV Sharky seam because it is adjacent to real evidence. |
| Session/block summary | `Act0SharkyPresenceBubbleV1` can accompany concrete result/next-action proof. | Close a session and orient the next move. | Positive if it summarizes actual progress; avoid repeating celebratory filler. |
| Profile | Mascot image/identity only; progress mirror owns the substantive proof. | Reflect growth. | Mostly decorative today; do not add a second coach layer over Profile proof. |

## Learning-EV assessment

The landed loop is supported most credibly in runner feedback and summary:

`mistake -> repair focus -> repair result -> session repair -> return reason -> review pattern -> profile proof`

Sharky adds value when it introduces, reinforces, or closes one of those
evidence-backed moments. It is not needed in Review or Profile simply to make
the character ubiquitous.

High-EV: prompt-specific pre-session guidance, signal-specific wrong feedback,
repair-result support, and outcome/next-action summaries.

Low-EV or risk: static Home assurances, generic default reactions such as
`Sharp read.` / `Good spot to fix.`, and any extra character card that repeats
an existing route, repair, or Profile message.

## Claude review signal classification

| Signal | Classification | Evidence-based interpretation |
| --- | --- | --- |
| Learn and Practice look redundant. | Needs evidence; useful now as an audit question. | Code assigns Learn the route/mission guide and Play the recommended rep, but `Continue lesson` and similar handoffs can blur the distinction in a partial artifact. Do not merge surfaces. |
| Home appears to have competing primary actions. | Useful now. | Home has mission, return, and daily/repair seams; audit hierarchy before adding character presence. |
| Packet lacked an actual decision/answer-choice screen. | Useful later. | Current review evidence should add a real decision/feedback capture state before external visual claims. No capture tooling work in this audit. |
| Generic `Continue` may be overused. | Useful now. | Runner, Learn, and Play retain multiple `Continue` labels; classify by ownership and action meaning in a focused CTA audit. |
| Coach-tip card helps only when it supports learning. | Useful now. | Existing evidence supports that rule: repair/feedback moments are strong; static Home/Profile mascot repetition is not. |
| Profile metrics mismatch beginner Learn content. | Needs evidence. | Profile has a compact real-progress mirror, but this needs an end-to-end beginner-state review, not a metric redesign. |
| Full onboarding, Result, Premium, and latest repair states were absent. | Stale/invalid as a product verdict; useful as capture-gap evidence. | The artifact was incomplete, so it cannot override active-shell truth. |

## Recommendation

Do not implement Sharky Character & Coaching Presence next. The character
already has broad surface coverage, while the highest current risk is surface
role and CTA ambiguity. Recommended next wave: **Surface Role / CTA Coherence
Audit v1**.

Candidate scope requiring separate approval: audit Home, Learn, Practice/Play,
and runner CTA ownership; verify that character lines are only retained where
they add a concrete table-signal, repair, or session-transition job. It must
not become a nav redesign, Learn/Practice merge, or copy sweep.

Fallback after that audit, if first-start evidence is the actual blocker:
**Welcome / Placement Micro-Aha Alignment**.

## Not now

- No new mascot assets, animation, or decorative character cards.
- No chat, AI/persona system, or broad copy rewrite.
- No Modern Table work.
- No Learn/Practice merge or navigation redesign.
- No Profile metric redesign, monetization, dashboard, XP, or notification work.
- No screenshot rerun or tooling change in this wave.

## Proposed next prompt title

`Surface Role / CTA Coherence Audit v1 — Local Only`
