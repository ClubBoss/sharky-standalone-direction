# First Week + Commercial Product Readiness Audit v1

Date: 2026-06-18
Mode: Audit-only macro recalibration
Scope: Act0 first session, first return, first-week loop, core product surfaces, premium perception, learning proof, and commercial readiness.

## 1. Purpose

Evaluate whether current Sharky is moving toward commercial-release quality across the first five minutes, first return, first week, premium perception, trainer identity, learning depth, and Runout-style benchmark expectations.

This audit does not implement code, tests, copy, routes, telemetry, UI, screenshots, Playwright tooling, table geometry, content, monetization, paywall, or entitlement changes. It uses existing review artifacts, code owners, tests, and known screenshot artifacts only.

Primary verdict:

Sharky now has a strong first-value learning engine and a safer commerce foundation, but it is not yet a 10/10 commercial trainer because the first week still feels more like a set of good local loops than a packaged trainer journey. Commerce should remain parked. The highest-EV next product move is a bounded First Week Progression Loop implementation wave, not paywall work, screenshot tooling, or local table polish.

## 2. Current Readiness Snapshot

| Dimension | Score | Current proof | Main gap | Release interpretation |
| --- | ---: | --- | --- | --- |
| First impression | 8.2 | Placement and Act0 entry copy now frame a useful first hand and table-first learning. | Still depends heavily on text hierarchy rather than a strong branded trainer moment. | Good enough for product iteration; not final-store premium. |
| First value | 9.1 | First correct feedback proves `Table read improved`, `No bet yet`, and same-signal next action. | Needs broader repeated proof beyond the first table clue. | Strong competitive advantage. |
| Return reason | 8.4 | Home reason line, first-value carry persistence, daily rep launch, and repair queue exist. | Day 2 reason is coherent, but not yet a packaged week arc. | Solid, with first-week opportunity. |
| First-week progression | 6.7 | Daily count, streak/progress, Review repaired proof, Profile progress, Learn path surfaces exist. | No clear Day 1 to Day 7 trainer plan or visible weekly payoff. | Biggest non-commerce blocker. |
| Visual premium feel | 7.5 | First-correct screenshot proof is strong; Home/Review code/tests show calmer hierarchy. | Home/Review/Profile/Learn lack current compact visual proof after recent changes; packaging still less polished than Runout-style products. | Needs targeted product-surface pass, not broad redesign. |
| Trainer identity | 7.0 | `act0_sharky_presence_v1.dart` exists and copy is calmer. | Sharky is not yet a consistent visible coach across first week. | Medium-high opportunity. |
| Learning proof | 9.0 | Deterministic signal proof, table highlights, feedback copy, same-signal reps, repair proof. | Needs repeated transfer across several days. | Strongest pillar. |
| Repair/progress proof | 8.6 | Deterministic repair queue, repaired proof, Review fixed state, lifecycle telemetry. | Repair is credible, but first-week packaging does not yet make it feel like a guided growth system. | Strong but under-packaged. |
| Copy density | 7.6 | Recent hierarchy passes reduced system-like labels. | Some surfaces still risk card/list density and operational language. | Manageable, not a blocker. |
| Commercial trust | 7.8 | Premium claims tightened; ledger code exists; paywall remains forbidden; Premium Hub hidden/deferred. | Receipt verification, expiry, refunds, revocation, grace period, production restore remain deferred. | Park commerce for now; do not expose paywall. |
| Implementation readiness | 8.2 | Act0 owners are clear and focused lanes have been stable. | Broad preview test drift and stale screenshot artifacts still limit confidence for macro visual claims. | Product work can continue with focused proof lanes. |

Overall direction score: 8.2 / 10.

## 3. Surface-by-Surface Audit

| Surface/state | Owner/file if known | User job | Current proof source | Readiness score 1-10 | Biggest issue | Severity | Implementation risk | Recommended action | Rationale |
| --- | --- | --- | --- | ---: | --- | --- | --- | --- | --- |
| Act0 entry / welcome | `lib/ui_v2/act0_shell/act0_welcome_shell_v1.dart`, `act0_shell_preview_screen_v1.dart` | Understand the app will teach one useful poker spot quickly. | Code evidence and prior first-value audits. | 8.0 | Trainer identity is calm but not highly branded. | Medium | Low | Fold into first-week progression packaging. | The first promise is clear enough; extra local polish would have less EV than week-level framing. |
| Placement start / quick check | `lib/ui_v2/act0_shell/act0_placement_shell_v1.dart` | Feel safe starting without an exam mindset. | Placement result and direct-handoff tests from accepted waves. | 8.4 | Still slightly procedural. | Low | Low | Keep; avoid expanding question count. | Placement has become a useful induction, not the current bottleneck. |
| Placement result / first hand ready | `lib/ui_v2/act0_shell/act0_placement_shell_v1.dart` | Believe the first hand is selected for a learning reason. | Closeout audit notes route proof and direct start. | 8.6 | Result proof is strong for Day 1, not a longer plan. | Low | Low | Keep current behavior; reuse proof language in week arc. | This surface already explains why the next hand matters. |
| First runner hand | `lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart` | Answer a poker-native table spot without UI friction. | Focused Act0 tests and accepted action-rhythm waves. | 8.7 | Premium feel depends on table/feedback continuity rather than motion. | Low | Medium | Do not reopen table geometry. | Runner is stable and table-first enough; first-week depth matters more. |
| First correct feedback | `lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart` | See "I noticed a table clue and read better." | Current compact screenshot proof and tests for exact No-bet copy. | 9.1 | Proof is excellent but local to first clue. | Low | Low | Preserve as pattern for week loop. | This is Sharky's strongest competitive proof surface. |
| Wrong/repair feedback | `lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart`, `act0_review_shell_v1.dart` | Know the missed signal and repair it without shame. | Repair queue MVP, signal metadata, Review repaired proof tests. | 8.6 | Repair feels credible, but not yet part of an obvious weekly coaching rhythm. | Medium | Low | Surface repair as one week-loop step. | Current mechanics are strong enough; product packaging is the gap. |
| Home first-value carry | `lib/ui_v2/act0_shell/act0_home_shell_v1.dart`, `act0_shell_preview_screen_v1.dart` | Return to the next useful same-signal rep. | First-return persistence context and focused tests. | 8.5 | Current compact screenshot proof is stale for Home after hierarchy changes. | Medium | Low | Include Home in first-week loop; defer fresh screenshot packet. | Code/test proof is adequate for product work, but launch proof needs later visuals. |
| Home daily loop | `lib/ui_v2/act0_shell/act0_home_shell_v1.dart` | Know what to do today in one glance. | Daily completion and Home reason-line waves. | 7.8 | Daily loop is useful but not yet week-shaped. | High | Medium | Make Home show the next first-week beat without new dashboard. | This is the main retention surface. |
| Review open repair | `lib/ui_v2/act0_shell/act0_review_shell_v1.dart` | Fix the next weak signal. | Review repaired-proof drift fix and targeted visual packet code/test evidence. | 8.0 | Fresh compact visual proof is missing; comparison copy may still feel operational. | Medium | Low | Keep mechanics; integrate one repair item into weekly rhythm. | Review is functional; its issue is packaging and proof freshness. |
| Review repaired proof | `lib/ui_v2/act0_shell/act0_review_shell_v1.dart` | See that a repair worked and replay if desired. | Focused repaired-proof tests. | 8.2 | No current compact screenshot proof for repaired state. | Medium | Low | Defer visual proof; do not redesign Review. | Stable enough to support first-week progression. |
| Learn path | `lib/ui_v2/act0_shell/act0_learn_path_shell_v1.dart` | Understand where training is going. | Existing Learn screenshot artifacts and owner file. | 7.2 | Learn can imply breadth, but first-week path payoff is not clearly tied to daily practice. | Medium | Medium | Bounded Learn/Home week coherence pass after first-week loop. | Do not expand content; clarify journey packaging first. |
| Profile/progress | `lib/ui_v2/act0_shell/act0_profile_shell_v1.dart` | See progress, consistency, and skill gains. | Profile owner contains progress proof, consistency, recent gains, and milestone cards. | 7.6 | Rich but may feel dense and downstream rather than a simple first-week receipt. | Medium | Medium | Use Profile as proof endpoint, not main next arc. | Profile supports retention but should not become a broad dashboard fix. |
| Premium preview | `lib/ui_v2/act0_shell/act0_premium_preview_v1.dart` | Understand premium is optional later, without pressure. | Commerce/trust audits and bounded preview cleanup context. | 7.8 | Safe but not a commercial growth engine yet. | Low | Medium | Keep parked and informational. | Paywall should not outrun first-week proof or receipt truth. |
| Entitlement/commerce foundation | `lib/services/entitlement_ledger_v1.dart`, `entitlement_ssot_v1.dart`, `release_premium_access_action_v1.dart` | Avoid false entitlement or payment claims. | Commerce audit, ledger design, code evidence of ledger service. | 7.4 | Production receipt verification and lifecycle truth remain deferred. | High for public paywall; Low for current hidden state | High | Park commerce unless public purchase becomes in-scope. | Current product phase should not spend more on commerce before stronger week retention. |

## 4. First-Week Loop Audit

| Day/session | Expected user job | Current behavior/proof | Gap | Retention value score 1-10 | Learning value score 1-10 | Risk | Recommended action |
| --- | --- | --- | --- | ---: | ---: | --- | --- |
| Session 1: placement to first hand | Start safely and get a useful hand. | Placement result direct-starts the recommended runner; first hand teaches one table clue. | Good local induction, no week framing. | 8.6 | 8.9 | Low | Keep. |
| Session 1: first correct feedback | Feel the first aha: table clue -> action. | `Table read improved`; `You noticed No bet yet before choosing an action.`; same-signal next rep. | Strong but isolated. | 8.8 | 9.3 | Low | Preserve as canonical first-week pattern. |
| Session 1: first wrong/repair path | Miss safely and get a repair rep. | Repair queue and corrected repair proof exist. | Needs calmer week-level framing so repair feels like training, not remediation. | 8.0 | 8.8 | Medium | Include repair as a normal weekly beat. |
| Same-day Home after first value | Know exactly what to do next. | Home carry and same-signal launch exist; daily checklist exists. | Home is useful but not yet "your first week starts here." | 8.3 | 8.5 | Medium | Add first-week progression state in a bounded Home/Review/Learn pass. |
| Same-day daily completion | Feel a small finish and reason to return. | Daily completion copy aligned; done state avoids confusing `Today 0/3`. | Completion payoff is still mostly daily, not week-building. | 7.9 | 7.8 | Medium | Tie completion to next session's table clue. |
| First return / Day 2 | Resume with a reason. | First-return reason and persistence are now stronger; durable state exists for carry/progress. | The explicit Day 2 promise is not yet visually packaged as part of a week. | 8.0 | 8.1 | Medium | Make Day 2 the second beat in the week loop. |
| Day 3-4 | See a different but related table clue and repair if needed. | Existing daily/repair mechanics can support this. | No visible plan for variety, transfer, or first-week arc. | 6.4 | 7.2 | High | Highest-EV first-week progression loop. |
| Day 5-7 | Believe Sharky is a trainer worth keeping. | Profile/Learn/Review can show progress, but proof is distributed. | No compact week receipt, milestone, or "you now read X clues" payoff. | 5.9 | 6.8 | High | Add a bounded first-week receipt/progression layer, not a full dashboard. |

## 5. Visual/Premium Perception Audit

Current visual proof is uneven:

- Strong current proof: first correct feedback compact screenshot shows the table as the hero, a visible table signal, a short why sentence, a next action, and a visible Continue CTA.
- Current code/test proof but stale screenshot proof: Home and Review after the calm hierarchy pass.
- Missing current compact proof: Review repaired proof, post-Day 2 Home, and first-week progression state.
- Existing Learn screenshots show repeated premium work, but Learn is not yet the main retention bottleneck.

Premium perception diagnosis:

Sharky's current advantage is not cinematic packaging. It is deterministic proof that a learner's choice maps to a visible table signal and the next useful rep. The product feels commercially promising when that proof is visible. It feels less commercial when surfaces become lists, receipts, or dense progress cards without a simple trainer story.

Runout-style products are still likely ahead in perceived packaging: motion, polished onboarding, charts, App Store positioning, and broad subscription infrastructure. Sharky should not copy that shape. The sharper path is to make the first week feel like a calm poker trainer that repeatedly proves: table signal -> decision -> repair/transfer -> progress.

## 6. Functional/Learning Depth Audit

Current depth strengths:

- First value before monetization is real.
- Signal proof is deterministic rather than fake AI.
- Same-signal reps and repair targets exist across action, board, price, starting-hand, and position families.
- Repair lifecycle is understandable: mistake -> repair item -> Fix -> repaired proof.
- Persistence is materially stronger than earlier waves: first-return and carry behavior are no longer purely in-memory for the core loop.
- Telemetry seams exist for the learning proof and repair loop.

Current depth gaps:

- First-week sequencing is not yet a product object. The app can train daily, but the learner does not see a compelling seven-day arc.
- Learn/Profile/Review are individually useful but do not yet combine into one obvious "this trainer is building me" story.
- Content breadth after Day 1 is enough for local reps, but not packaged as increasing table-reading capability.
- Repair is strong functionally, but a new learner may not yet understand how repairs accumulate into progress over a week.
- Commercial trust is safe because claims are bounded, but not yet store-ready because production receipt and subscription lifecycle truth remain deferred.

## 7. Benchmark Comparison vs Runout-Style Expectations

| Category | Sharky current | Runout-style benchmark | Gap | Winning principle for Sharky |
| --- | --- | --- | --- | --- |
| First promise | Clear and beginner-safe. | Polished and market-ready. | Sharky needs more premium confidence in the first viewport. | Keep beginner-safe table-first framing. |
| First value | Stronger: real table-signal proof before paywall. | Polished, but benchmark is weaker on visible causal learning proof. | Sharky must preserve and repeat this proof. | Prove value before monetization. |
| Onboarding | Short and useful. | More packaged and animated. | Sharky can feel less cinematic. | Do not add friction; package the payoff. |
| Table training | Deterministic signal -> why -> next rep. | Visually premium, poker-native, likely more advanced/GTO-oriented. | Sharky should remain beginner-safe and proof-first. | Visible table clue beats abstract analytics. |
| Retention loop | Daily/repair/carry exist. | Competitor likely feels broader and more subscription-ready. | Sharky lacks a first-week journey. | Turn local loops into a week trainer arc. |
| Progress proof | Profile, Review, repaired proof, daily done. | Charts/analytics likely feel richer. | Sharky progress is real but distributed. | Compact receipts before dashboards. |
| Commercial trust | Low-pressure and safer after preview cleanup and ledger work. | Public subscription system likely more mature. | Sharky should not expose paywall yet. | Earn monetization after first-week proof. |
| Premium feel | Improving but uneven. | Stronger packaging and asset polish. | Home/Review/Learn need fresh proof and calmer first-week hierarchy. | Premium through clarity, not decoration. |

## 8. Commercial Release Blocker Table

| Blocker | Category | Severity | EV if fixed | Risk | Recommended timing | Rationale |
| --- | --- | --- | --- | --- | --- | --- |
| First week is not yet a visible trainer journey | Retention | High | Blocker | Medium | Next wave | Biggest non-commerce gap; improves Home, Review, Learn, Profile, and return reason without paywall dependency. |
| Home/Review current hierarchy lacks fresh compact visual proof | Tooling | Medium | Medium | Low | After first-week implementation | Product can continue from code/test proof; launch confidence needs current screenshots later. |
| Trainer identity is present but not consistently felt | UX | Medium | High | Medium | Wave 2 or 3 | A calm Sharky coach presence can make existing proof feel commercial without fake AI. |
| Learn/Profile progress story is distributed | Learning | Medium | High | Medium | After first-week loop | These surfaces should reinforce the week arc, not become a broad dashboard. |
| Some surfaces remain card/list dense | Visual | Medium | Medium | Medium | After week loop evidence | Text density is not the primary bottleneck but can undermine premium perception. |
| Production receipt verification is deferred | Commerce | High for paywall; Low for current phase | High if paywall is next | High | Deferred until monetization phase | Public paywall remains forbidden, so this should not block the next product arc. |
| Subscription expiry/refund/revocation/grace truth is deferred | Commerce | High for public commerce; Low now | High later | High | Deferred | Important before release monetization, not before first-week product proof. |
| Broad preview test drift / stale visual artifacts | Tooling | Medium | Medium | Medium | Bounded proof packet later | Focused lanes are enough for product work; full cleanup should not consume this macro wave. |
| No App Store narrative packet tied to first-week proof | Trust | Medium | Medium | Low | After first-week loop | Narrative should follow the product truth, not lead it. |

## 9. Recommended Next 3-5 Implementation Waves

1. First Week Progression Loop v1
   - EV: Blocker
   - Risk: Medium
   - Scope: Home, Review, Learn/Profile touchpoints only where needed to make Day 1, Day 2, and next sessions feel like one trainer journey.
   - Product target: "This week you are learning to read table clues: no bet, price, board, position, repair."
   - Constraints: no dashboard, no Skill Map, no new content family, no paywall, no table geometry.
   - Why first: it addresses the biggest commercial gap across retention, premium perception, trainer identity, and learning depth.

2. Sharky Coach Presence + Trainer Voice Pass v1
   - EV: High
   - Risk: Medium
   - Scope: bounded coach presence and copy hierarchy across Home, first-week receipt, Review repair, and daily completion.
   - Product target: a calm poker coach, not a task tracker or metadata receipt.
   - Why second: it makes existing deterministic proof feel proprietary and premium without fake AI claims.

3. Product Surface Premium Implementation Pack v1
   - EV: High
   - Risk: Medium
   - Scope: reduce operational density and improve hierarchy for Home, Review, Learn, and Profile based on the first-week loop.
   - Product target: table-first, proof-first, less list-like.
   - Why third: visual polish should follow the chosen week structure so work is not local micro-polish.

4. First-Week Progress Proof Packet v1
   - EV: Medium-high
   - Risk: Low
   - Scope: quota-bounded screenshot/manual proof after implementation for first-correct feedback, Home Day 2, Review open repair, Review repaired proof, Learn/Profile week receipt.
   - Product target: know which surfaces are launch-proof and which remain stale.
   - Why fourth: visual evidence should verify the product pass, not substitute for it.

5. App Store / Product Packaging Narrative Audit v1
   - EV: Medium
   - Risk: Low
   - Scope: translate proven first-week truth into store-safe positioning and screenshots roadmap.
   - Product target: premium commercial framing without unsupported claims.
   - Why fifth: only useful once the first-week trainer promise is real.

## 10. Deferred List

- Public paywall, pricing, subscription package, purchase UI, and Premium Hub exposure.
- Receipt verification, refund, revocation, expiry, grace period, and production restore semantics.
- Broad dashboard, Skill Map, or Leak Profile.
- New lesson families or broad content expansion.
- More local W3 micro-reps unless a first-week gap specifically requires one existing-task mapping.
- ModernTable/table geometry changes.
- Screenshot tooling rewrite or full preview-lane cleanup.
- GTO, solver, optimal, frequency, AI, or adaptive claims.
- App Store claim expansion before first-week proof is current.

## 11. Stop Rules

- Stop any next wave if it becomes paywall or purchase work.
- Stop if the proposed solution requires a broad dashboard, Skill Map, or Leak Profile as the immediate fix.
- Stop if table geometry, answer dock geometry, or ModernTable becomes the main work.
- Stop if first-week progression requires new lesson families rather than packaging existing daily, repair, and same-signal capabilities.
- Stop if screenshot tooling becomes the implementation path instead of product work.
- Stop if copy claims imply AI/adaptive/GTO/solver behavior not currently proven.
- Stop if commerce is reopened before a product need proves it is the bottleneck.

## 12. Direction Score

Current direction: 8.2 / 10.

Sharky is directionally strong because the core learning proof is now real: first useful hand, visible table signal, compact why, same-signal next rep, repair queue, repaired proof, daily carry, and safer commercial claims. That is a better foundation than a polished but generic onboarding funnel.

The missing points are mostly commercial packaging and first-week retention:

- +0.6 if first-week progression becomes a visible trainer journey.
- +0.4 if Sharky coach presence becomes consistent without fake AI.
- +0.3 if Home/Review/Learn/Profile get current compact visual proof.
- +0.3 if Product Surface Premium hierarchy reduces operational density.
- +0.2 later when commerce receipt/restore truth becomes public-release safe.

Runout-style competitors remain ahead on perceived packaging, motion, commercial polish, and mature subscription infrastructure. Sharky's path to beating them is not to copy those surfaces. It is to make the first week repeatedly prove learning value on the table before asking for money.

## 13. Recommended Next Arc

Recommended next arc: First Week Progression Loop v1.

Proposed implementation prompt:

Wave: First Week Progression Loop v1

Mode: Implement bounded product loop. Do not add paywall, dashboard, Skill Map, new lesson families, table geometry changes, screenshot tooling, or broad content expansion.

Goal: Make the current Act0 first-value, daily, same-signal, repair, Learn, and Profile surfaces feel like one first-week trainer journey.

Primary target: after the learner completes first value and returns, Home should communicate the next first-week beat, Review should make repair feel like normal training, and Learn/Profile should show a compact week-level payoff using existing progress and task state.

Allowed:

- bounded copy/hierarchy changes in Act0 Home, Review, Learn, Profile, and shell state if needed;
- reuse existing daily count, first-value carry, repair memory, completed task ids, skill receipt, and same-signal mapping;
- focused tests for Day 1, first return, open repair, repaired proof, and no paywall;
- no new content families.

Acceptance:

- Day 1 first value still shows exact table-signal proof;
- Home after first value and first return shows a clear next week beat;
- wrong/repair path still launches deterministic repair;
- repaired proof still appears;
- Learn/Profile reinforce the first-week journey without becoming dashboards;
- commerce remains parked;
- focused Act0 lanes and fast loop remain green.

This is the best next product arc because it improves first-week retention, premium perception, trainer identity, learning depth, and commercial readiness without reopening commerce or visual micro-polish.
