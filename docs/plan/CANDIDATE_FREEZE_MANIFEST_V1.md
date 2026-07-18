# Candidate Freeze Manifest v1

Status: IMMUTABLE ADMITTED CANDIDATE

## Freeze identity contract

- PRODUCT_SOURCE_BASELINE: 40babdeb97d1464c1977f2b5470c5aa05d042d80.
  This is the exact product source/content/test/runtime state validated by the
  deterministic packet. No product-relevant change is authorized after it
  inside this candidate wrapper.
- FREEZE_PUBLICATION_BASELINE: the corrected docs-only convergence publication
  commit made by this repair. Its exact SHA is immutably resolved and recorded
  by the tag below and the publication report.
- IMMUTABLE_AUDIT_BASELINE_TAG: act0-final-deterministic-candidate-v1.
- AUDIT_START_BASELINE: the exact commit resolved by
  refs/tags/act0-final-deterministic-candidate-v1. The clean-room auditor must
  checkout this tag target, not PRODUCT_SOURCE_BASELINE and not mutable main.
- canonical route: AppRoot to EntryGate to Act0ShellPreviewScreenV1.

The fully enumerated docs-only convergence wrapper between
PRODUCT_SOURCE_BASELINE and the immutable tagged audit baseline is authorized.
Any product code, tests, authored content, schemas, telemetry, persistence,
route, progression, build contract, or release-behavior change requires a new
product candidate. Any commit after the immutable tagged audit baseline
requires a new audit baseline before downstream audit. This tag must never move;
a future candidate must use a new versioned tag and refreshed manifest.

## Contract pins

| contract | pin |
| --- | --- |
| assessment | 291 rows; input SHA-256 2502f955068feeca0a26bd67ff02b81db6d0786f36bf78195c5911c6ceda6a6c; fingerprint 1318f99a5430f45fe18c9cf64dd3f583dc21a49b7dc98482ae167031d139e959 |
| error/repair | 20 ids; 466 incorrect options; 277 alternate targets; 14 intentional replays; zero gaps |
| discrimination | 121 binary rows; 121/165/5 option census; positions 112/115/62/2 |
| retention | schema 17; schema-16 migration; schema-17 round trip; 24h/72h/7d |
| W7 | four assessed outcomes, QJ5 unseen transfer, original-source recheck |
| original audit | 41 retained rows; 17 fixed, 3 verified, 1 false positive, 12 intentional, 8 Human-only source verification |

## Gate pins and downstream state

Selected canonical route gate and all 14 selected guards passed. Release gate,
analyzer, source validation, Graphify hook, and diff checks passed. Full-suite
policy was OFF by default. See FINAL_DETERMINISTIC_CONVERGENCE_PACKET_V1.md.
Final Deep Independent Audit remains the next Top-1 but is blocked until this
manifest correction is committed, pushed, and immutably tagged. Human Novice
Proof and AI Personalization remain downstream and unstarted.

## Human hypotheses

First-60-second aha, feedback comprehension, Profile clutter, future commerce
trust, W8/W9 jargon tolerance, recap value, full-shell VoiceOver, perceived
durable progress, binary guessability, and W7 transfer comprehension. These
map to later Human Novice Proof or release validation.

## Accepted risks

| risk | mitigation / validation | blocks freeze |
| --- | --- | --- |
| schema-17 older-binary rollback incompatibility | additive migration; release rollback rehearsal | no |
| concentrated Act0 owner | focused guards; bounded future refactor only | no |
| startup preference complexity | cold-start contracts and clean-install release validation | no |
| full-shell VoiceOver | Human accessibility journey | no |
| release identity/observability | release lane before store submission | no |
| English-first maintenance | localization planning and language review | no |

## Repository preservation

Tracked and staged diffs were empty at preflight. Pre-existing untracked
evidence was preserved; aggregate SHA-256:
6586d9e449c4fb820eda5faa7b582068ad1d83f0525da9ff92b0023ab52be8fb.

## Freeze-consistency terminal ledger

| items | disposition |
| --- | --- |
| CFS-01 through CFS-03 | repository, product baseline, and docs-only wrapper verified |
| CFS-04 through CFS-08 | active route, manifest, packet, crosswalk, closure, and invalidation contract corrected |
| CFS-09 through CFS-11 | immutable tag, tag target, and baseline-to-tag allowlist verified at publication |
| CFS-12 through CFS-14 | links, pins, stale-language scan, Graphify, and diff checks passed |
| CFS-15 through CFS-17 | commit, push, and untracked preservation verified at publication |
| CFS-18 through CFS-19 | repaired freeze admitted; next Top-1 is Final Deep Independent Audit |
