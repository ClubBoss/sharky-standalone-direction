# Runout ContentGraph Report v1

## Executive summary

This local static pass extracted a conservative content graph from the provided XAPK/APK without network calls, login, API access, paywall bypass, or Sharky repo edits. The strongest evidence is the XAPK manifest, APK resource inventory, Hermes bundle location/type, exact screenshot-seeded category and chapter labels, bundled lesson path references, and visual-key families.

The static graph contains 243 nodes and 258 edges. It should be treated as a curriculum map candidate, not a full app clone or definitive lesson catalog.

## Extraction method

- Copied the local XAPK into this isolated lab workspace.
- Unzipped the XAPK into `extracted_xapk/`.
- Unzipped the base APK into `extracted_base_apk/`.
- Generated raw inventories under `raw/`.
- Ran printable-string extraction on `assets/index.android.bundle`.
- Built CSVs from screenshot seeds, bundle string candidates, and APK resource filenames.

## Framework / bundle findings

- Package: `com.gramercy.runout`
- Version: `1.1.6` / code `82`
- Framework: React Native / Expo-style app with Hermes bytecode
- Main bundle: `assets/index.android.bundle`
- Bundle type: Hermes JavaScript bytecode v96
- Split configs: config.my, config.ru, config.armeabi_v7a, config.fr, config.ja, config.ko, config.th, config.zh, config.de, config.en, config.es, config.hi, config.tr, config.vi, config.ar, config.hdpi, config.in, config.it, config.pt
- APK file inventory count: 1486
- Asset file inventory count: 22

## What was confidently extracted

- Top-level package/version metadata from the XAPK manifest.
- A React Native / Expo-like runtime surface with Hermes bytecode.
- Main bundle path: `extracted_base_apk/assets/index.android.bundle`.
- Visible category, skill, and Preflop Hand Selection chapter seeds supplied in the prompt, with exact title hits in the bundle for most seeds.
- Paywall, onboarding, skills, mastery, daily-session, progress, trainer, reference, tier/rank, and chart/visual resources from bundled asset names.
- 22 bundled lesson path references under `../data/lessons/es/*.json`.
- 147 `lessons.visuals.*` visual-key families.

## What remains candidate / uncertain

- Exact parentage for most bundled lesson path refs is unresolved because this pass did not disassemble Hermes bytecode into structured JS objects.
- Exact full skill/chapter catalog beyond screenshot seeds is not fully static-resolved.
- Drill density and item counts outside visible Preflop Hand Selection remain candidate.
- Monetization timing and unlock rules are visible only as static strings/assets, not confirmed runtime behavior.

## Static bundled content vs server-side suspicion

Partial server-side content is suspected. The bundle contains static lesson path refs, UI strings, paywall strings, and some lesson/prose fragments. It also includes Firestore/Firebase, RevenueCat, user progress sync, cached poker questions, session review, and training persistence strings.

That points to a hybrid model: some educational/reference material is bundled, while progress, purchases, personalization/reviews, and possibly question/session data may be server-backed or locally cached after sync.

## Category map

- Preflop
- Betting & Aggression
- Defense & Response
- Math & Theory
- Hand Analysis & Decision Making
- Positional & Situational
- Tournament Strategy

## Skill map

High-confidence screenshot-seeded Preflop skills:

- Preflop Hand Selection
- 3-Betting
- Facing a 3-Bet
- 4-Betting
- Blind Defense

Medium-confidence bundled lesson topics include:

- Bet Sizing, Blind Defense
- Blockers
- Bluff Catching
- Bluffing
- C-Betting
- Check Raising
- Drawing Hand Strategy
- Facing 3-Bet
- Facing Cbet
- Facing Check Raise
- Hand Reading
- In Position Play
- Multiway Pots
- Out Of Position Play
- Pot Control
- Pot Odds
- Preflop Hand Selection
- Reverse Implied Odds
- SPR
- 3-Betting
- Value Betting

## Chapter map

The Preflop Hand Selection chapter map is written to `runout_skill_chapter_map_v1.csv`. It includes 11 screenshot-seeded chapters with beginner/intermediate/advanced labels and visible item counts.

## Visual explanation system

The bundle exposes many `lessons.visuals.*` key families. The names suggest reusable visual explainers for blockers, ranges, bet sizing, c-betting, draw equity, SPR/stack depth, street progression, action diagrams, and value/bluff structure. Full visual copy and rendering behavior were not reproduced.

## Trainer/adaptive/review signals

Static strings and assets reference skill drills, daily session, session review, recalibration, mastery/radar, ratings, ranks/tiers, saved tips, and progress/streak surfaces. The extraction found `adaptive`/`repair` as weaker direct signals than drills/review/recalibration.

## Onboarding and paywall signals

The APK bundles onboarding welcome/question/how-it-works imagery, first-session assets, paywall background/card/video assets, RevenueCat/paywall strings, Google Billing permission, subscription/trial terms, and purchase/restore flows.

## Screenshot validation needed

- Validate all non-Preflop categories and skills in-app or via screenshots.
- Validate whether the 22 Spanish lesson refs correspond to the full current catalog or only localized/static fallback content.
- Validate drills per chapter and whether quiz/trainer questions are bundled or fetched.
- Validate paywall timing and unlock surfaces through screenshots only, without bypassing auth/paywalls.

## Sharky comparison questions

- Does Sharky cover the same first-week Preflop foundations before asking for trust?
- Does Sharky visibly prove correction/repair more clearly than Runout's drill/review/recalibration surfaces?
- Does Sharky need visual explainers for blockers, ranges, SPR, MDF/pot odds, bet sizing, and street plans?
- Does Sharky's free-to-paid boundary preserve trust better than Runout's paywall ceremony?
- Does Sharky have enough drill density and review loops in the first week?

## Recommended next extraction pass

Use screenshots or a non-authenticated local app run to validate screen hierarchy and counts. If a Hermes bytecode disassembler becomes available locally, rerun only structural extraction for keys/objects, still excluding long lesson bodies and secrets.
