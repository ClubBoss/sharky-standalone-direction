# Runout Reference Summary

Status: local competitive research summary. Do not use this as source copy.

## Source

- Local artifact: `external_competitors/runout/raw/runout_1.1.6_APKPure.xapk`
- Raw artifact is ignored by Git under `external_competitors/`.
- Analysis date: 2026-06-17
- Method: XAPK manifest JSON, APK archive inventory, dependency marker files, asset-name taxonomy, and minified bundle keyword/category inspection.
- Limitation: local `apkanalyzer` could not decode the binary APK manifest because Android build tools were incomplete. Package metadata comes from XAPK `manifest.json`.

## App Metadata

- App name: Runout
- Package: `com.gramercy.runout`
- Version: `1.1.6`
- Version code: `82`
- Min SDK: `24`
- Target SDK: `36`
- Split locales/configs observed: Arabic, German, English, Spanish, French, Hindi, Indonesian, Italian, Japanese, Korean, Burmese, Portuguese, Russian, Thai, Turkish, Vietnamese, Chinese, hdpi, armeabi-v7a.

## Tech Stack Signals

- React Native bundle present: `assets/index.android.bundle`.
- Native Android dependency markers include Compose UI/Material3, AndroidX, Kotlin coroutines, Firebase Analytics/Auth, Google Play Billing, Play Services Measurement, Sentry replay markers, Coil, Room, DataStore, WorkManager, gRPC/Firestore-related protobuf files.
- Permissions indicate internet, billing, notifications, install referrer, ad id/ad services, wake/boot/alarm/background-service support.

## Main Product Surfaces Observed

- Onboarding/calibration and "how it works" surfaces.
- Trainer / daily session flow.
- Skills library and mastery path.
- Analytics / report / tracker surfaces.
- Hand recording, sessions, history, and replayer surfaces.
- Paywall / discount / subscription surfaces with video support.
- Reference/library surfaces and poker concept lessons.

## Strongest Product Principles

- Clear premium packaging: custom typography, branded backgrounds, glass surfaces, chart imagery, and paywall video.
- Broad learning promise: trainer, skills, reports, hands, tracker, analytics, and references imply a complete poker improvement system.
- Retention scaffolding: daily-session, progress-chart, skill mastery, tracker, notifications, and profile/stat surfaces.
- Calibration feel: onboarding and recalibration token families suggest the app can make the user feel seen.
- Visual specificity: named assets for preflop/postflop/position/hand-reading/chart motifs make the app feel poker-native.

## Weakest Product Risks

- Heavy surface breadth can dilute first-session learning proof.
- Paywall/subscription infrastructure appears mature enough to risk arriving before trust if not carefully sequenced.
- Personalization may feel claimed rather than causally proven unless the UI shows how answers change the route.
- Analytics/tracker breadth can become dashboard work instead of table-first learning.
- Large content volume risks jargon density for true beginners.

## Sharky Strategic Response

- Do not compete by matching breadth first.
- Win the first session through deterministic proof: user answer -> visible table signal -> clear why -> next repair/transfer.
- Keep premium feel, but let the poker table be the proof engine.
- Use progress and retention surfaces only after first value is visible.
- Make personalization causal and auditable from existing Act0 placement and runner metadata.

## Do Not Copy

- Do not copy Runout assets, exact text, layouts, paywall composition, icons, videos, or code.
- Do not mimic their brand naming, tier labels, or proprietary visual surfaces.
- Do not import raw strings into Sharky docs or implementation prompts.
- Do not use private implementation clues for secrets, endpoints, auth, or paywall bypass.
- Treat this pack as product-principle evidence only.
