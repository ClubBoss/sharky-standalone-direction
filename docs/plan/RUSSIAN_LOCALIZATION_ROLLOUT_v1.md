# RUSSIAN LOCALIZATION ROLLOUT v1

Status: ACTIVE  
Depends on:

- `docs/plan/MASTER_PLAN_v3.0.md`
- `docs/l10n/RU_POKER_TERMS_CANON_v1.md`
- `docs/plan/ACT0_CONTENT_LOCALIZATION_SCALING_v1.md`
- `docs/plan/ACT0_EXECUTION_SNAPSHOT_2026_05_11_v1.md`

## Goal

Ship Russian as a real launch language for the active Act0 product route.

This rollout is not a broad repo-wide translation sweep.

It is a launch-path quality program.

## Principles

1. Human quality beats coverage percentage.
2. Active launch surfaces first.
3. Product truth first, support surfaces second.
4. Rewrite awkward English-shaped Russian instead of polishing it.
5. Do not mix localization with new feature expansion.

## Wave order

### Wave 1. RU foundation

- create the Russian tone canon
- lock runtime language truth
- clean obviously broken Russian in current shared l10n
- inventory active Act0 shell English strings

### Wave 2. Active shell primary pass

- `Placement`
- `Home`
- `Learn`
- `Review`
- `Play`
- `You`

Goal:
- all top-level learner-facing shell surfaces become launch-quality Russian

### Wave 3. Core loop pass

- `Table`
- `Feedback`
- `Result`

Goal:
- the teaching loop reads naturally in Russian

### Wave 4. Deeper launch-path content pass

- task titles on the active launch path
- task summaries on the active launch path
- runner prompt/support text that is visible on the launch route
- deeper `Review` / `Play` / `You` visible detail copy

Goal:
- move Russian from shell-quality to route-quality without mass-translating
  inactive content

### Wave 5. Premium and support pass

- premium preview
- settings language UI
- legal / support strings touched by launch

Goal:
- no launch-path value/support surface falls back to English

### Wave 6. Final editorial pass

- repetition cleanup
- tone alignment
- button consistency
- small-screen readability
- final Russian QA on the real launch path

## Stop rules

- do not translate archive or donor surfaces
- do not translate deep legacy modules unless they appear on the active launch path
- do not mass-convert every string in the repo just for coverage optics
- do not ship machine-shaped Russian

## Launch proof

Russian is launch-ready when:

1. the app opens in Russian by default on first run
2. the active Act0 route is fully readable in Russian
3. Sharky voice sounds natural in Russian
4. premium and settings surfaces do not fall back to English in the launch path
5. no critical CTA or continuation meaning is lost on small screens
