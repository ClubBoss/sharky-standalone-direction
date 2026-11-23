# Sharky · Screen vision v1 (2026-11-23)

Wireframe-level spec for every learner screen. **No visual style here**: layout, colour, type and motion belong to the designer. This file is the designer's DoD and the agents' mechanism list. Content order inside each screen follows `value_index_v1.md`. Personas: P1 regular, P2 beginner, P3 returner, P4 live/MTT (`personas_v1.md`).

B23 status: the screen-logic inventory (`docs/plan/SCREEN_LOGIC_INVENTORY_v1.md`) is **not in main yet** (B23 not started at 23:00). When it lands, its per-screen state tables replace the «Where logic sits» column below; this file stays the target.

## Global rules (all screens)
- **States vocabulary**: first run · empty · loading · in progress · done · error · offline. The app is local-first, so «offline» must equal «online» everywhere except sharing, store review and (later) sync. Every screen lists the states it must draw.
- **Honesty**: no fake progress, XP, streak or mastery claims (ENG-02, HST-01.a). Assisted answers never look like independent success.
- **Not anywhere before an owner decision**: paywall, price, lock icons, XP shop/economy, AI chat, bots, RU switch.
- **Accessibility minimum** (already merged in T3): every action reachable by VoiceOver with a label; text scales; Reduce Motion respected. Polish beyond that is after beta.
- **One primary action per screen.** Secondary actions are visually quieter.
- **Designer DoD common part**: draws every listed state; uses only data that exists in the listed view model; safe-area correct on iPhone SE → Pro Max (VIS-04.b); no text truncation of task text or answer options at the largest standard Dynamic Type size; passes the W1–W12 screenshot run (V9).

---

## 1. Welcome
| | |
|---|---|
| **Job** | P2: «show me this is for beginners and start now». P1/P3: «let me skip basics». P4: «does it cover live/9-handed?» |
| **Must-have (by index)** | 1) One primary «Start with the basics» (F1: first decision ≤ 3 min, VI-07). 2) «I know the rules → quick check» (placement J1). 3) One line of promise (repair mistakes fast). 4) Restore notice if progress exists. |
| **States** | first run · returning with progress (resume card replaces start) · error reading storage (start fresh offer, never silent wipe; DAT-06) |
| **Actions / nav** | Start → Lesson intro W1 L1. Check → Placement. Resume → last lesson. |
| **NOT here** | Sign-up, account, paywall, goal survey longer than one tap, feature tour, more than ~40 words. |
| **Designer DoD** | First tap reachable without scroll; ≤ 2 choices above the fold; resume variant drawn. |
| **Mechanisms first** | `act0_welcome_shell_v1.dart`: welcome view model with `{hasProgress, resumeTarget, storageError}`; telemetry exists (do not add). Optional NEW VI-40 goal tag (owner scope) would add one field `goal`. |

## 2. Placement (rules check / J1)
| | |
|---|---|
| **Job** | P1/P3: prove basics in < 2 min and land in the right world. P2: honest «not yet» without shame. |
| **Must-have** | 1) Short question set with progress «n of N». 2) Result with landing world and why. 3) «Start from W1 anyway» escape. |
| **States** | in progress · passed (→ W2 or later) · not passed (→ W1) · interrupted (resume same question; DAT-03) · skipped (disposition saved, no fake completion) |
| **Actions / nav** | Answer · Skip · Back to Welcome. Result → Lesson intro of landing lesson. |
| **NOT here** | Scores as grades, XP, leaderboard, timer pressure. |
| **Designer DoD** | Draws passed / not passed / skipped results; question view reuses lesson option component. |
| **Mechanisms first** | `act0_placement_shell_v1.dart` + `act0_shell_preview_placement_v1.dart`: placement state class `{index, total, answers, outcome, landingWorld}`. Returner refresher (NEW VI-39) extends outcome with «refresh list». |

## 3. Home
| | |
|---|---|
| **Job** | All: «what do I do now?» in one glance. P1: today's practice. P3: where I stopped. |
| **Must-have (by index)** | 1) Continue card: next lesson or due review, one primary button. 2) Due Day 2/Day 7 repeats count (retention, CMP PokerPath advantage). 3) Daily Practice entry (DAY-01). 4) Weekly honest summary (ENG-06). 5) Entry to Review. |
| **States** | first run (after first lesson only; before that Welcome owns) · in progress · nothing due («all caught up» + optional practice) · course done W1–W12 (next: practice / W13+ when flag on) · storage error |
| **Actions / nav** | Continue → Lesson intro / task. Review → Review. Map → Map. You → Profile. |
| **NOT here** | Feed, news, multiple competing CTAs, streak flames, XP totals as the hero, locked premium tiles. |
| **Designer DoD** | Exactly one primary CTA in each state; «nothing due» drawn; course-done state drawn. |
| **Mechanisms first** | `act0_home_shell_v1.dart`, `act0_shell_preview_home_v1.dart`: home view model `{primaryAction, dueCount, practiceAvailable, weeklySummary, courseState}` (B23 seam). |

## 4. Map (learn path / worlds)
| | |
|---|---|
| **Job** | P2: see the road and that it is short steps. P1/P3: jump to a world/skill. P4: find live/MTT worlds. |
| **Must-have** | 1) Worlds W1–W12 with lesson status (done / current / next / locked-by-order). 2) Current position marker. 3) Per-world skill list (skill map exists). 4) W13+ section only when the catalog flag is on. |
| **States** | first run · in progress · world done · all done · flag-on extended catalog · 9-max tasks hidden until table visual (B15 gate) |
| **Actions / nav** | Tap lesson → Lesson intro. Tap world → world menu. Back → Home. |
| **NOT here** | Paywall locks, star ratings, decorative map art that hides status, worlds the learner cannot open without a reason shown. |
| **Designer DoD** | Draws all lesson statuses; 36 worlds scale (scroll/sections) without redesign; locked reason readable. |
| **Mechanisms first** | `act0_learn_path_*` files: path view model `{worlds[{id,status,lessons[{id,status}]}], current, catalogFlag}`; spot search (NEW VI-43) would add an index. |

## 5. Lesson intro
| | |
|---|---|
| **Job** | P2: one idea, ≤ ~60 words before the first tap (checklist F2). P1: skip to tasks. |
| **Must-have** | 1) Lesson title + one-line goal. 2) The one new concept, short. 3) Start. 4) «I know this → go to tasks» for repeat visits. |
| **States** | first visit · repeat visit · mid-lesson resume (go straight to the task) |
| **Actions / nav** | Start → first task. Back → Map/Home. |
| **NOT here** | Long theory, more than 2 steps of text (Q3), quizzes, video. |
| **Designer DoD** | Word budget respected at largest Dynamic Type without scrolling past the CTA on iPhone 14 Pro. |
| **Mechanisms first** | Intro copy already in catalog; view model `{title, goal, concept, steps, resumeTask}`. |

## 6. Lesson / table task (incl. hand-history summary)
| | |
|---|---|
| **Job** | All: make a decision, understand why, repair. P1/P4: know the line before turn/river (hand history). |
| **Must-have (by index)** | 1) Table with hero cards, board, pot, price (Modern Table — do not change). 2) **Hand-history summary** (H1/H2, VI-12/13): one row per earlier street, board on that street, action chips, pot after the street; always visible on turn/river tasks; tap opens replayer (HH decision M2). 3) Question + 2–4 options. 4) Feedback: grade, neutral start, concrete reason, «Try same clue» / «Continue» (repair loop). 5) Help (glossary, numeric tools HLP-02). 6) Confidence + mistake reason input (LRN-01.a, VI-16) after a wrong answer — place chosen by designer. |
| **States** | loading task · deciding · answered correct · answered wrong (repair offered) · repair in progress · assisted (help used, marked) · task with earlier streets (summary) · preflop task (no summary) · resume after kill · error (bad task data → skip with report, never crash) |
| **Actions / nav** | Choose option · Help · Open replayer · Continue · Try same clue · Exit to Home (progress saved). |
| **NOT here** | Timer pressure (unless timed-drill type, VI-26), chat, ads, bot opponents, XP pop-ups that hide the reason, solver frequencies. |
| **Designer DoD** | Summary readable for 4 streets × 6 seats and 9 seats; long options never truncated; feedback reason scrolls separately from the button (V2-lite); correct/wrong distinguished by icon + word + colour. |
| **Mechanisms first** | B20 typed timeline record (`Act0ActionTrailItemV1` → per-street typed events, engine-checked pot); H2 summary view model `{streets[{name, board, actions[], potAfter}]}`; B21 fills the gaps in ~1,300 trails; T2 replay controls (#764); F2 for 9 seats. LRN-01.a data model in B23. |

## 7. Result / Session summary
| | |
|---|---|
| **Job** | All: «what did I learn, what is next». P1: what to repair. |
| **Must-have** | 1) Honest outcome: independent vs assisted vs repaired. 2) Skills touched. 3) One useful next step (ENG-03). 4) «Try this question again» for exact repeats. 5) Share preview (GRO-01, optional, quiet). |
| **States** | lesson done clean · done with repairs · world done (store review prompt possible, GRO-02, max once per 180 days) · partial (left mid-lesson) |
| **Actions / nav** | Next → next lesson / Home. Retry → task. Share → iOS sheet after preview. |
| **NOT here** | Confetti that hides the next step, fake mastery, comparison with other users, paywall. |
| **Designer DoD** | Draws all 4 states; next step is the primary CTA; share is secondary. |
| **Mechanisms first** | `act0_learning_run_payoff_v1.dart`, `act0_learning_receipt_v1.dart`: summary view model `{outcome, skills, nextAction, retryTargets, shareText}`. |

## 8. Review
| | |
|---|---|
| **Job** | P1/P3: repeat what I got wrong until it sticks. P2: gentle second chance. |
| **Must-have (by index)** | 1) Due repeats (Day 2 / Day 7) with count. 2) Recurring mistake patterns → targeted practice (HST-05). 3) Entry to Attempt archive and Own hands. 4) Leak dashboard (NEW VI-34, later: accuracy by position/street/skill). |
| **States** | empty (no mistakes yet: explain how review fills) · due items · nothing due · patterns found · storage error |
| **Actions / nav** | Start review → task. Pattern → practice. Archive → Archive. Own hands → Own hands. |
| **NOT here** | Raw stats without a next action, solver charts, paywall. |
| **Designer DoD** | Empty state drawn with a reason; due vs not-due clear; pattern rows lead to an action. |
| **Mechanisms first** | `act0_review_shell_v1.dart`, `act0_review_mistake_history_*`, `act0_review_pattern_coaching_v1.dart`: review view model `{due[], patterns[], archiveCount, ownHandsCount}`; leak aggregates (VI-34) from attempt archive + skill map. |

## 9. Archive / Replay
| | |
|---|---|
| **Job** | P1/P4: find a past attempt, step through it, see the line. |
| **Must-have** | 1) Search/filter by world, skill, outcome (HST-02). 2) Replay: step, play/pause, street jump (HST-03, T2). 3) Same hand-history summary as the task. 4) Delete one / all (HST-02.b). |
| **States** | empty · list · filtered-empty · replay playing · replay paused · replay at end · deleted (undo window if available) |
| **Actions / nav** | Open attempt → Replay. Replay → «Practise this spot» (HST-06.c link). Back → Review. |
| **NOT here** | Editing past attempts, sharing raw hands publicly, analytics. |
| **Designer DoD** | Replay controls reachable one-handed; summary identical to task summary component. |
| **Mechanisms first** | `act0_attempt_archive_*`, `act0_attempt_replay_screen_v1.dart`, `act0_street_replay_contract_v1.dart`; B20 record shared with task; H4 controls later. |

## 10. Own hands
| | |
|---|---|
| **Job** | P1: bring my real hands, see the line, practise the matching spot. P4: enter a live hand by hand. |
| **Must-have** | 1) Import (PokerStars USD NLHE cash today; more formats VI-18 later). 2) Manual entry step by step with validation (HST-06.a). 3) List with replay. 4) Link to the matching drill (HST-06.c). 5) Delete. |
| **States** | empty (how to import) · importing · import error with reason (illegal state named) · list · manual entry in progress · saved |
| **Actions / nav** | Import · Enter manually · Open → Replay · Practise spot · Delete. |
| **NOT here** | Cloud upload, HUD stats, opponent tracking, network calls. |
| **Designer DoD** | Error states name the line/field; manual entry works at 9 seats once F2 lands. |
| **Mechanisms first** | `act0_imported_hand_*`, `act0_manual_hand_screen_v1.dart` (T1 merged); B14 adds widget scenario; leak finder (VI-35) later. |

## 11. Profile / You
| | |
|---|---|
| **Job** | All: «am I getting better?» honestly. P3: what I already know. |
| **Must-have** | 1) Course progress by world and by skill (1.1 target: skill map, not only worlds). 2) Repair evidence (fixed independently vs assisted). 3) Weekly summary. 4) Settings entry. |
| **States** | first run (almost empty, explains what fills it) · in progress · course done · storage error |
| **Actions / nav** | Skill → practice. Settings → Settings. |
| **NOT here** | Leaderboards, level badges as economy, social feed, paywall/plan card (until owner decision). |
| **Designer DoD** | Empty and full states drawn; numbers match `act0_profile_evidence_projection_v1.dart`. |
| **Mechanisms first** | `act0_profile_shell_v1.dart`, `act0_profile_evidence_*`, `act0_academy_runtime_adapter_v1.dart`: profile view model `{worlds[], skills[], repairs, weekly}`. |

## 12. Settings
| | |
|---|---|
| **Job** | All: control reminders, data and support. |
| **Must-have** | 1) Opt-in return reminders and time (RET-01). 2) Delete learner data (resets GRO-02 interval). 3) Version/build + support/beta feedback copy (REL-02.b, Q2). 4) Privacy text link. |
| **States** | default · reminders denied by iOS (explain + open iOS settings) · delete confirm · deleted |
| **Actions / nav** | Toggle reminders · Delete data (confirm) · Copy beta summary · Back. |
| **NOT here** | Language switch (RU is after 1.0), account/login, purchase restore (until monetization decision), debug surfaces in release. |
| **Designer DoD** | Destructive action separated and confirmed; denied-permission state drawn. |
| **Mechanisms first** | Settings view model `{reminders, permission, version, build}`; `act0_shell_preview_debug_surfaces_v1.dart` must stay out of release. |

---

## Mechanism checklist before the designer's drop (ordered by index)
| # | Mechanism | Screens | Value item | Package |
|---:|---|---|---|---|
| 1 | View models + state classes for Welcome, Home, Review, Profile (≤4 per package) | 1,3,8,11 | VI-01 | B23 |
| 2 | Typed hand timeline record | 6,9,10 | VI-12 | B20 |
| 3 | H2 street summary view model | 6,9 | VI-13 | B24 (new) |
| 4 | LRN-01.a confidence/mistake-reason data | 6,8 | VI-16 | B23 step 3 |
| 5 | View models for Placement, Map, Lesson intro, Result, Settings | 2,4,5,7,12 | VI-01 | B25 (B23 follow-up) |
| 6 | Trail gap fixes + migration | 6 | VI-14 | B21 |
| 7 | Leak aggregates (data only) | 8 | VI-34 | after owner scope |
