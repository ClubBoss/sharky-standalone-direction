# SHARKY — S11.R Full-Route Reuse-First / Build-vs-Buy Radar

**Owner decisions:** 2026-10-15, initial S11.R checkpoint **expanded on the same date to cover EVERY remaining S12–S24 stage through App Store release and post-launch**.  
**Status:** `OWNER_APPROVED_PREPARATORY_RESEARCH / NO_IMPLEMENTATION_ADMISSION`; document is subordinate until reviewed and merged from docs Draft PR #284.  
**Placement:** after lawful **S11 exact-binary acceptance/integration**, before **S12.V**. This is a short operating checkpoint **within** accepted S01–S24; do not create a competing S11 production/QA writer or promote research to a stage PASS.  
**Authority:** [Master Plan v5 §10A](../plan/MASTER_PLAN_v5.0_TOP1_BULLDOZER_SSOT.md); [campaign dispatch](../context/PRE_HUMAN_CAMPAIGN_STATE_v1.md) and live HEAD/owner decisions override stale snapshots.

## 1. Owner's product and execution correction

**Do not hand-build commoditized engineering, QA, release, distribution, validation or operational processes when mature, documented, lawfully reusable solutions are clearly cheaper over their full lifecycle.** Apply `REUSE -> ADAPT -> BUILD` **at every remaining admitted stage**. Use real successful products to understand the *job/pattern*, open maintained repositories to learn implementation and official vendors/platform documentation to verify support, security, licensing and release mechanics. Keep the distinction between a commercial app's observed UX, a repository's public source, and independently proven product outcomes.

Preserve Sharky's differentiation: source-owned poker decisions and stable IDs; correct/error taxonomy; independent vs hint-assisted provenance; genuine independent recheck vs unseen transfer vs real elapsed retention; earned vs Placement-skipped completion; accurate XP, session/run, persisted due/repair, telemetry and consent. Existing compatible code can be superior to a fashionable package. `DO_NOTHING` is a fully valid answer.

**No new experimental platform or broad rewrite** is authorized. Never copy a third-party APK's proprietary source, assets, characters or expressive screens. APK analysis may support lawful *observation* only; a Flutter release APK is not a reusable source repository. Verify license and rights to redistribute for each candidate and asset.

## 2. Two-speed process — comprehensive coverage without a months-long detour

**A. One cross-roadmap radar after S11 (2–4h total, read-only):** cover **all S12–S24 stages**, one compact row each: job, current Sharky solution, mature external candidate(s), verified source/production reference, possible saving, adoption risk, and `KEEP / EVALUATE_AT_STAGE / DEFER / DO_NOTHING`. Deep-read **at most three** promising current bottlenecks; prefer test-tool reliability and near-term S12.V/Human readiness. The radar is *not* a claim that all vendor versions, licenses and production integrations have been audited.

**B. Just-in-time Reuse-First mini-check before each newly admitted downstream stage:** typically **30–90 minutes** for the chosen stage's concrete deliverable, only where a credible reuse option exists. Verify the current library/version/license/platform/privacy/support and benchmark against the repo's existing implementation. A high-risk purchase/privacy/signing choice may merit a separately bounded review. Then carry on that **same** stage. Do **not** hold S12.V waiting for exhaustive research into S20–S24.

**C. Only on demonstrated material EV:** one bounded reversible proof-of-concept with a precise source/CI/native DoD, owner admission, single writer, independent source review when required, rollback and decision. No code/pilot is authorized by this radar alone.

**Priority order:** immediate user/learner-trust blocker > proven automation/CI waste > exact-near-term stage support > distant release/tool ideas. Stop research on sufficient evidence rather than chasing another 20 links.

## 3. S12–S24 stage-by-stage opportunity map — research candidates, NOT integrations

The roadmap stage IDs, gates and their evidence authority remain unchanged.

| Roadmap | Existing job and potential reuse | Candidate(s) / where to learn | Admission-specific warning |
| --- | --- | --- | --- |
| **S12.V** visual trust | Real native compact/standard screenshots, semantics, touch/accessibility, regression; avoid bespoke testing infra | Flutter built-in Accessibility Guideline API + Xcode Accessibility Inspector; [Maestro](https://github.com/mobile-dev-inc/maestro) vs [Patrol](https://github.com/leancodepl/patrol); [Flutter samples](https://github.com/flutter/samples) for UI/reference | Screen parity, table/seat semantics and real persistence stay Sharky-specific; no Modern Table reconstruction without owner gate |
| **S12 P02 entry** | Human-admission checklist and beta provisioning | Current nine accepted P02 gates; [Apple TestFlight](https://developer.apple.com/testflight/), [App Store Connect API](https://developer.apple.com/documentation/appstoreconnectapi/) | Tools manage testers/builds; they **cannot** grant research ethics, eligible novices or P02 admission |
| **S13 Human novice study** | Consent, recruiting, observation, evidence logging and recontact | TestFlight tester groups/feedback, existing Human protocol and consented structured observation; optional research-note or interview software **only if** a real logistics bottleneck | Do not substitute simulated AI users, analytics events or tool-generated results for observed beginners |
| **S14 Human-found repair** | Turn confirmed Human findings into minimal source/native reproof | Existing fixed evidence ledger, focused Flutter/widget/native tests; evaluate a test harness only if test cost is established | Fix proven failure only; no speculative redesign or broad old suite |
| **S15 learning efficacy/return** | Event ingestion, cohort observation, real D2/D7, unseen transfer, elapsed due | Existing owned event contracts; [PostHog Flutter SDK](https://github.com/PostHog/posthog-flutter) as **optional** privacy-reviewed transport/analysis | Analytics cannot redefine `assistance`, `mastery`, genuine calendar elapsed time or establish causal learning effect without valid study |
| **S16 curriculum W1–W12** | Content QA, schema validation, replayable grading and cross-world audit | Reuse current authored schemas/tests/YAML/JSON; reusable validators; independent, licensed poker rules oracle only if matching variant | Never import someone else's preflop strategy/ranges blindly or grow W13+; semantic source/choice IDs remain canonical |
| **S17 brand/table/cast** | Remaining licensed art, 3D/support pipeline, rendering asset provenance | Existing stored design/asset artifacts; public Flutter/sample render recipes, licensed design resources when needed | Material table choices should already have S12.V disposition; protect #224, no duplicate V4 rebuild |
| **S18 competitive excellence** | Comparable current product job/flow benchmark and truthful deltas | Reuse S03 researched competitor dossier, same-job checklists, manual authorized app observation; public sample/repo architecture for reference | Competitor marketing claims and GitHub stars do **not** prove Sharky is Top-1; don't clone proprietary screenshots/assets |
| **S19 demand, value, WTP** | Recruiting, interview/questionnaire data, research traceability | Existing market protocol + basic consented survey/spreadsheet tools; optional SaaS questionnaire tool only if it materially saves operations | Clicks/survey interest/AI judgments are not paid conversion; separate actual WTP evidence and sample bias |
| **S20 commerce — conditional** | IAP entitlement, restore, subscriptions, price/trial clarity | **Already present:** Flutter `in_app_purchase` dependency; Apple StoreKit sandbox; evaluate [RevenueCat Flutter](https://github.com/RevenueCat/purchases-flutter) only versus genuine receipts/entitlement infrastructure cost | Paid SDK adds service dependency, privacy and potential fees; optional S20 N/A for honest free beta; require real purchase+restore sandbox/device |
| **S21 Store/legal/support** | Localized metadata, screenshots, policy/help URLs, age ratings and App Privacy responses | [fastlane deliver](https://docs.fastlane.tools/actions/deliver/) and [App Store Connect API](https://developer.apple.com/documentation/appstoreconnectapi/); [Apple privacy](https://developer.apple.com/help/app-store-connect/manage-app-information/manage-app-privacy/) and [age-rating definitions](https://developer.apple.com/help/app-store-connect/reference/app-information/age-ratings-values-and-definitions/) | Poker learning vs simulated gambling classification, regional law/age and truthful marketing need specific legal/platform review; no tool gives legal clearance |
| **S22 release candidate / TestFlight** | Signing, repeatable IPA, build provenance, distribution, rollback and feedback | Existing GitHub Actions/Xcode; [Flutter iOS release guide](https://docs.flutter.dev/deployment/ios); [fastlane pilot](https://docs.fastlane.tools/actions/pilot/), [Apple TestFlight](https://developer.apple.com/testflight/) | Preserve signed exact build/source/binary, credentials, approval chain and real-device smoke; don't create duplicate CD pipeline |
| **S23 owner App Store launch gate** | Decision packet, submission metadata, authorized release and rollout | [fastlane deliver](https://docs.fastlane.tools/actions/deliver/), [Apple App Store Connect API](https://developer.apple.com/documentation/appstoreconnectapi/) with explicit human authorization | **Owner GO/CONDITIONAL_BETA/HOLD is never automated**; an upload is not App Review approval or public release |
| **S24 post-launch** | Crash triage, learner feedback, release metrics and scoped next evidence-based priorities | **Already present:** `sentry_flutter`; optional [PostHog Flutter](https://github.com/PostHog/posthog-flutter); App Store Connect crash/metrics and review API | Consent, opt-out, data minimization, accurate analytics semantics and privacy disclosure must precede new collection |

**Existing repository dependency baseline (checked 2026-10-15 against PR #282 `pubspec.yaml`):** `provider`, `shared_preferences`, `hive`, `in_app_purchase`, `sentry_flutter`, `lottie`, `flutter_svg`, `poker_solver` and others. A tool named above may *already* have an overlapping capability; always inspect source and real app usage, not just dependency presence. No new dependency is presumed installed.

## 4. Verified reference classes (initial source scan; adoption not evaluated)

**Official platform/tool evidence, checked in public documentation on 2026-10-15:**
- [Flutter accessibility testing](https://docs.flutter.dev/ui/accessibility/accessibility-testing) offers native-inspector and framework guideline checks; [Flutter integration testing](https://docs.flutter.dev/cookbook/testing/integration/introduction) documents Patrol as a third-party option. **This does not show Patrol will fix Sharky's simctl flakiness.**
- [Maestro repository](https://github.com/mobile-dev-inc/maestro): accessible automation on iOS/Android, published Apache-2.0 license; [Patrol repository](https://github.com/leancodepl/patrol): Flutter-first framework with native automation (confirm current release/license/dependency details before pilot).
- [Flutter samples](https://github.com/flutter/samples) publishes official runnable source examples; samples demonstrate conventions but are **not evidence of independently successful released apps**.
- [Apple TestFlight](https://developer.apple.com/testflight/) and [App Store Connect API](https://developer.apple.com/documentation/appstoreconnectapi/) provide native beta distribution and administration. External beta may require review and qualified testers.
- [fastlane pilot](https://docs.fastlane.tools/actions/pilot/) and [deliver](https://docs.fastlane.tools/actions/deliver/) document distribution and metadata automation; [fastlane source](https://github.com/fastlane/fastlane) indicates MIT license.
- [RevenueCat Flutter](https://www.revenuecat.com/docs/getting-started/installation/flutter) documents receipt/entitlement tooling; [PostHog Flutter](https://github.com/PostHog/posthog-flutter) provides event instrumentation; [Sentry Flutter](https://pub.dev/packages/sentry_flutter) provides crash/error monitoring. These are evaluated as **products/services with operational/privacy costs**, not free drop-in proofs.
- [Apple App Privacy](https://developer.apple.com/help/app-store-connect/manage-app-information/manage-app-privacy/) requires disclosure including relevant third-party SDK collection; [Apple age rating](https://developer.apple.com/help/app-store-connect/reference/app-information/age-ratings-values-and-definitions/) distinguishes gambling and simulated gambling; [App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/) remain binding for product-specific compliance and availability.

**Evidence labels required at future sourcing:** `OFFICIAL_DOC`, `OPEN_SOURCE_REPO`, `PRODUCTION_CASE_STUDY`, `DIRECTLY_INSPECTED_PRODUCT`, `VENDOR_CLAIM`, `UNVERIFIED`. Do not call a public repository “used by successful apps” merely because it has stars; verify the named production example and exact mechanism before claiming this.

## 5. Candidate choice and engineering economics

At each stage, first ask: **what exactly would we otherwise build, what do we already own, and which part is genuinely generic?**

For each active candidate record: `job / source URL + version/date / verified evidence class / ownership + license and redistribution / SDK & iOS support / price+ops+maintenance / security+privacy / exact Sharky contract impact / initial adoption effort / long-term savings / rollback / decision`.

Compare `KEEP_CURRENT` with `REUSE`, `ADAPT`, `BUILD`. The winning option minimizes **total integration + migration + proof + operating cost** and maximizes *accepted learner outcome per hour*, not the number of packages installed. Cap detailed alternatives to **three** at any active stage. License scanner / dependency review can use mature tooling (e.g. [Very Good CLI license check](https://github.com/VeryGoodOpenSource/very_good_cli)) only if it improves on existing scanning; verify exact release before applying.

Use only `PILOT / ADOPT_LATER / DEFER / DO_NOTHING` for candidate outcomes. A `PILOT` decision requests **separate owner authority**; it does not start itself. Carry negative answers as reusable knowledge so later agents don't repeat research.

## 6. DoD, sequencing, stop condition

1. **S11 keeps sole production/QA ownership** until genuine native terminal adjudication. S11.R has **zero** runtime/QA/CI writes and no parallel tool migration.
2. After accepted S11, publish **one S12–S24 stage-to-tool radar**, one-page prioritized `S11R_REUSE_FIRST_DECISION` with only **up to three high-EV deep evaluations** and a single next action (or `DO_NOTHING`), within **2–4 hours**. Do not delay S12.V waiting for fully audited downstream tools.
3. At every later owner-admitted stage run one short just-in-time reuse check **only where needed**, referencing this radar. No permanent new committee, process layer, product engine or extra gate.
4. If an implementation pilot is later separately admitted: one branch/writer, explicit model/reasoning/mode/scope/DoD/constraints/quota, real RED/GREEN where material, exact affected native proof, independent review where required, rollback. No blanket acceptance of green CI.
5. **S12.V remains mandatory after the bounded radar**; if material visual trust HOLD, one explicit owner bounded visual wave and affected reproof. Then original nine S12 P02 gates, only then owner Human P02 admission. S13–S24 remain evidence- and owner-gated, not automatically “bulldozed”.
6. Stop research at saturation or timebox. Store deferred opportunities with trigger and owner; no speculative feature/content expansion, broad migration or reliance on APK-derived proprietary code.

**Terminal truth:** `S11R_CATALOGED` is a research inventory, **not** production readiness, App Store approval, legal sign-off or proof that a component is a Sharky-compatible solution.
