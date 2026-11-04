# Academy Premium Leaves Packet V1 (2026-11-04)

Status: DRAFT / RUNNER B / PRESENTATION LEAVES ONLY / NOT INTEGRATED / SCORE DELTA 0.

Authority: Master Plan v5, `PRE_HUMAN_CAMPAIGN_STATE_v1.md`, Issue #364 A-J
register (comment 6628239374, "Dark Academy" line: selectively adapt
presentation leaf code to current LDR/#372; old shared-shell callbacks unsafe;
no new design exploration). This file is a traceability and adapter record, not
a second SSOT.

Baseline: `main` = `fee12ba70e2a8d70001b64ba7b1b0c5065636795` (merged #372).

## 1. What exists

New, isolated files only. No existing file was modified.

| File | Role |
|---|---|
| `lib/ui_v2/act0_shell/academy_leaves/act0_academy_leaf_style_v1.dart` | Palette, inline SVG glyph family, surface, optional backdrop, EN locale gate |
| `lib/ui_v2/act0_shell/academy_leaves/act0_academy_home_leaf_v1.dart` | Premium Home leaf |
| `lib/ui_v2/act0_shell/academy_leaves/act0_academy_practice_leaf_v1.dart` | Premium Practice leaf |
| `lib/ui_v2/act0_shell/academy_leaves/act0_academy_review_leaf_v1.dart` | Premium Review leaf |
| `lib/ui_v2/act0_shell/academy_leaves/act0_academy_you_leaf_v1.dart` | Premium You leaf |
| `lib/ui_v2/act0_shell/academy_leaves/act0_academy_settings_leaf_v1.dart` | Premium Settings body leaf |
| `assets/design/sharky/home/poker_lounge_reference_v2.png` | Restored #308 backdrop (sha256 `7d97dd8e...8c5500`), NOT declared in pubspec |
| `test/ui_v2/academy_leaves/*.dart` | Component-local widget tests |

No leaf has a `bool.fromEnvironment` flag, route, telemetry, persistence or
store access. Each takes one immutable `...InputV1` object and plain callbacks.

## 2. Reuse audit (B1)

| Donor | Component | Class | Exact coupling found | Adaptation |
|---|---|---|---|---|
| #308 | `act0_home_north_star_preview_v1.dart` | PORTABLE_WITH_LOCAL_ADAPTER | `Act0ShellStateV1` (only `streakDays`), `Act0SharkyCueV1.preSessionMood`, `AssetImage` on undeclared asset, `Act0AcademyGlyphV1` asset SVGs | Input model with `streakDays` + `mood`; optional `ImageProvider? backdrop` with gradient fallback; SVG inlined; `nextAction` nullable (no invented CTA) |
| #308 | `act0_academy_iconography_v1.dart` + 8 SVG | PORTABLE_WITH_LOCAL_ADAPTER | needs `pubspec.yaml` asset dir | Inlined as `SvgPicture.string` (existing `flutter_svg` dep) |
| #308 | `act0_home_shell_v1.dart` / `act0_shell_preview_screen_v1.dart` edits, `pubspec.yaml` asset lines | SHARED_RUNTIME_DEPENDENCY | Runner A owned | Not touched; see section 5 |
| #311 | `act0_practice_hybrid_v1.dart` | PORTABLE_WITH_LOCAL_ADAPTER | `Act0PracticeGroupV1`; DROPS the accepted Practice repair queue; string-matched `'complete'` subtitle swap | Restored repair-queue section from `Act0PracticeRepairQueueConsumerV1` with the shell's exact launchability rule; subtitle always source-provided; existing EN/RU atoms reused |
| #311 | `act0_play_shell_v1.dart` / preview screen edits | SHARED_RUNTIME_DEPENDENCY | Runner A owned | Not touched |
| #312 | `act0_review_v4.dart` | PORTABLE_WITH_LOCAL_ADAPTER | `SessionDrillRecheckLaunchQueueItemV1` (legacy launcher service, REUSE-01 R-01), `Act0ReviewStateV1` | Local `Act0AcademyReviewSavedCheckV1(checkId)`; open/past/due passed as separate lists; ASCII copy |
| #314 | `act0_you_v23.dart` (`part of act0_profile_shell_v1.dart`) | PORTABLE_WITH_LOCAL_ADAPTER | private profile-shell access, private sheets, settings flag | Rewritten as public leaf over plain values; Learning-details sheets deferred |
| #322 | You earned-moment truth (consumer `excludedSeedIds`) | PORTABLE_WITH_LOCAL_ADAPTER | modifies accepted `act0_achievement_seed_consumer_v1.dart` | Not modified: `act0AcademyYouEarnedMomentsV1` pre-filters the projection, then reuses the accepted consumer (exclusion before the 3-moment cap) |
| #315 | `act0_settings_quiet_control_v1.dart` | PORTABLE_WITH_LOCAL_ADAPTER | `AppSettingsService` direct, `Navigator` push, `lib/main.dart` boot load, `privacy_terms.dart` edits | Body leaf with injected values/callbacks; rows hidden unless wired (no fake toggles) |
| #315 | `lib/main.dart` boot `AppSettingsService.load()` | SHARED_RUNTIME_DEPENDENCY | protected | Not touched |
| #309 | `act0_learn_cinematic_path_a_v1.dart` (`part of act0_learn_path_shell_v1.dart`) | SHARED_RUNTIME_DEPENDENCY | private `_LearnMissionFirstBodyV5` model in ASM-04 file (#374) | Spec only (section 6) |
| #310 | `act0_worlds_b_v1.dart` (`part of act0_learn_path_shell_v1.dart`) | SHARED_RUNTIME_DEPENDENCY | same | Spec only |
| #318/#320/#321 | `act0_pw_c3_facade_v1.dart`, placement/welcome shell edits, table PNG + pubspec | SHARED_RUNTIME_DEPENDENCY (shell edits) / PORTABLE_WITH_LOCAL_ADAPTER (facade) | placement/welcome runtime, pubspec | Spec only |
| #327 | Placement repair-card persistence | SUPERSEDED_OR_UNSAFE for this lane | persistence / repair ledger (Runner A) | Not used |

## 3. Truth rules enforced by the leaves (and tested)

- Home: no CTA when `nextAction == null`; no stage highlighted when `phase == null`;
  no percent or "x of y" unless `0 <= earned <= total, total > 0`; streak chip only for `streakDays > 0`.
- Practice: start forwards the identical `Act0PracticeGroupV1` object (assistance flags untouched);
  locked recommendation never launches (Learn or nothing); unresolved recommendation id launches nothing;
  launchable active repair leads and forwards the identical launch request; non-launchable debt stays visible without CTA;
  no "fixed"/"mastered" copy.
- Review: open repair and due review are separate sections; every open mistake listed; "All caught up" only
  with no open, due or saved work; no due card without a due item; gateway title never echoes the keyed answer.
- You: open-mistake seeds never shown as earned (filtered before cap and again defensively); earned moments kept;
  fresh learner shows no XP/tasks/debt.
- Settings: toggles only when wired to the persisted setting; load failure shows Retry, never stale toggles;
  legal/learning rows only with a real destination.

## 4. Validation (this branch, Linux cloud, Flutter 3.35.0 / Dart 3.9.0)

- `dart format`: clean. `flutter analyze` (whole repo): no issues.
- `flutter test test/ui_v2/academy_leaves`: 40/40 pass.
- Negative controls (temporary mutations, reverted): progress guard, recommendation lock, repair target-type gate,
  You open-seed filter (both sites), Review caught-up rule. Each mutation produced at least one failure.
- Existing regression (unchanged source): achievement seed consumer/projection, play shell, practice repair queue
  consumer/projection, review shell, Sharky presence: 83/83 pass.
- NOT done: native iOS, real-device, screenshot, RU, compact-device runs. No claim of on-binary presence.

## 5. Minimal integration adapters (owner: Runner A / integration lane, after #374)

All gated behind one new `bool.fromEnvironment` per surface AND
`act0AcademyLeafSupportsLocaleV1(Localizations.localeOf(context))`, otherwise
the existing surface renders unchanged.

1. Asset: add `- assets/design/sharky/home/` to `pubspec.yaml`, then pass
   `const AssetImage(act0AcademyLeafLoungeBackdropAssetV1)` as `backdrop`.
2. Home (`act0_shell_preview_screen_v1.dart`, Home tab branch): build
   `Act0AcademyHomeLeafInputV1(courseTitle: <current courseTitle>, streakDays: state.streakDays,
   mood: sharky.preSessionMood, earnedLessonCount: <#308 _lessonCompleteWithTaskIds count, 0 when world locked>,
   courseLessonCount: selectedWorld.lessons.length, phase: <#308 _homeTrainingPhaseForRouteV1 mapped to
   Act0AcademyHomePhaseV1>, nextAction: Act0AcademyHomeNextActionV1(title, subtitle/hint, ctaLabel, onPressed: onContinue)
   or null when no launchable step, onOpenDevMenu)`; hide top bar and theme bottom nav as in #308.
3. Practice: in the `Act0PlayShellV1(...)` branch pass the same `practiceGroups`,
   `practiceSurfaceRecommendation.{groupId,title,subtitle,reasonLabel}`, the same
   `Act0PracticeRepairQueueConsumerV1.fromProjection(...)`, `onStartGroup` and
   `onLaunchRepairQueueTarget` closures, completion title/body, plus Review/Learn tab switches.
4. Review: `openMistakes: reviewState.mistakes`, `pastRepairs: reviewState.fixedMistakes`,
   `dueItems: <same list as Act0ReviewShellV1.dueReviewItems>`, `savedChecks: items.map((i) => Act0AcademyReviewSavedCheckV1(checkId: i.jobId))`,
   `onStartSavedCheck: (c) => onStartSessionDrillRecheck(items.firstWhere((i) => i.jobId == c.checkId))`,
   existing `onFixMistake` / `onReplayFixedMistake` / `onStartDueReview` / `onOpenLearn`.
5. You: `earnedMoments: act0AcademyYouEarnedMomentsV1(<achievement seed projection>)`, profile
   `playerName/level/xpLine/streakDays/completedTaskCount`, cross-session proof
   `totalBankedFixCount/reinforcedFixCount`, `openRepairCount: reviewState.mistakes.length`,
   `dueReviewCount: dueItems.length`, existing Review/Learn/Settings callbacks.
6. Settings: host route owns `AppSettingsService.instance` (`load()` before first interaction per #315,
   which touches protected `lib/main.dart`), maps `changes` snapshot to `soundEnabled/hapticsEnabled`,
   wires `setHapticsEnabled`; wire `onSoundChanged` only if sound cues are confirmed audible on the target build;
   `onOpenPrivacy/onOpenTerms` push existing `PrivacyScreen`/`TermsScreen`; Welcome/Placement pop then call
   existing `onReplayWelcome`/`onRetakePlacement`.

Key mapping: leaves use `act0_academy_*_leaf_*` keys. Existing shell keys
(`act0_shell_main_cta`, `act0_shell_play_screen`, `act0_shell_review_screen`, `act0_shell_profile_screen`)
stay on the legacy surfaces; flag-on tests must use the leaf keys.

## 6. Deferred, with exact blockers

| Surface | Blocker | Smallest next step |
|---|---|---|
| Learn (#309) | `part of act0_learn_path_shell_v1.dart`, reads private `_LearnMissionFirstBodyV5`; that file is in active ASM-04 #374 | After #374 merges, Runner A exposes a public read-only Learn view model; then port `_CinematicLearnBodyV1` as a leaf over it |
| Worlds (#310) | same file/part; overlay state | Same public view model (world list, lock state, progress) |
| Placement / Welcome (#318/#320/#321) | edits to placement/welcome shells; ASM-04 J3 Placement hint leak overlaps; #320 adds table PNG + pubspec | After #374, port `Act0PwC3PageV1/PanelV1/ChoiceV1` as leaves; keep canonical Runner; F7 table asset decision is Chat I's |
| You learning-details sheets | private `_show*Sheet` helpers in `act0_profile_shell_v1.dart` | Keep on legacy surface or expose as callbacks |

## 7. Runner A files untouched

`lib/main.dart`, `act0_shell_preview_screen_v1.dart`, `act0_lesson_runner_shell_v1.dart`,
`act0_learn_path_shell_v1.dart`, `act0_shell_state_v1.dart`, `act0_progress_store_v1.dart`,
`pubspec.yaml`, all existing tests, task/choice IDs, grading, assistance, evidence/repair ledgers,
navigation callbacks. The leaves only import existing public types read-only.

## 8. Native verification required after activation

EN iPhone 14 Pro 393x852 exact-binary: each flag on/off parity; Home CTA routes to the same target as legacy;
Practice repair CTA launches the same repair and debt `1 -> 0` only after independent correct;
Review due vs repair separation with a naturally due item; You shows no open-mistake seed as earned after
cold restart; Settings haptics persists across restart; reduced motion; VoiceOver labels; backdrop asset load.

## 9. Rollback

Not integrated, so no runtime rollback is needed. To remove: delete
`lib/ui_v2/act0_shell/academy_leaves/`, `test/ui_v2/academy_leaves/`,
`assets/design/sharky/home/poker_lounge_reference_v2.png` and this file, or revert the branch commits.
