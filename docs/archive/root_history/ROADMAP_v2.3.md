# Poker Analyzer — Master Roadmap v2.3
> Authority note:
> This file is historical/reference material and is not the active SSOT chain.
> Current planning authority starts at `docs/README_SSOT.md`.

*(Updated Nov 2025)*

## ✅ Stage 0–9 — Core Restoration & Foundation
| Stage | Goal | Result | Duration | EV | Status |
|-------|------|--------|----------|----|--------|
| 0 | Restore compilation | Analyzer runs clean | 4 days | 9 | ✅ |
| 1 | Reconnect asset pipeline | Legacy packs compile and load | 3 days | 8 | ✅ |
| 2 | Rebuild analyzer CI gate | Analyzer + formatter wired into CI | 2 days | 8 | ✅ |
| 3 | Stabilize dependency graph | Shimmed breaking packages and updated lockfile | 5 days | 7 | ✅ |
| 4 | Repair training data ingest | Pack YAML hydration unblocked and validated | 6 days | 7 | ✅ |
| 5 | Reinstate baseline tests | Core smoke tests pass locally and in CI | 4 days | 8 | ✅ |
| 6 | Recover content libraries | L1–L3 library indexes regenerated reliably | 5 days | 7 | ✅ |
| 7 | Restore UI scaffolding | Core navigation flows render without crashes | 3 days | 6 | ✅ |
| 8 | Harden sync services | Offline sync + path registry stable under load | 4 days | 7 | ✅ |
| 9 | Lock CI guardrails | Analyzer, tests, and export gates block regressions | 2 days | 9 | ✅ |

## ✅ Stage 10–14 — Training Engine V2 & SDK Sync
| Stage | Goal | Result | Duration | EV | Status |
|-------|------|--------|----------|----|--------|
| 10 | Launch Training Engine V2 | Session player rewired with deterministic core loops | 7 days | 9 | ✅ |
| 11 | Author V2 content schema | Pack templates normalized with migration tooling | 6 days | 8 | ✅ |
| 12 | Automate spot validation | Guard suite enforced via SpotKind + pack audits | 5 days | 8 | ✅ |
| 13 | Sync mobile SDKs | Dart/Flutter SDK parity achieved with CI smoke tests | 4 days | 7 | ✅ |
| 14 | Wire export services | CSV + bundle exporters verified against QA fixtures | 4 days | 7 | ✅ |

## ✅ Stage 15 — Telemetry & UX Automation
| Stage | Goal | Result | Duration | EV | Status |
|-------|------|--------|----------|----|--------|
| 15 | Capture navigation & UX metrics | Telemetry observer + UX QA bots feed CI dashboards | 6 days | 8 | ✅ |

## ✅ Stage 16 — UI V2 Brand & Telemetry Expansion
| Stage | Goal | Result | Duration | EV | Status |
|-------|------|--------|----------|----|--------|
| 16 | Launch UI V2 brand system | Theme V2, assets, and golden diff coverage stabilized | 8 days | 8 | ✅ |

## 🟡 Stage 17 — CI & QA Automation (Active Cluster)
| Stage | Goal | Result | Duration | EV | Status |
|-------|------|--------|----------|----|--------|
| 17A | Harden CI pipeline | Pipeline split into analyzer, test, content, export gates | 3 days | 8 | ✅ |
| 17B | Reduce legacy compile debt | Legacy build errors cut to single-digit backlog | 4 days | 7 | 🟡 |
| 17C | Integrate golden snapshots | UI V2 golden suite batched with baseline diffs | 3 days | 7 | 🟡 |
| 17D | Automate QA score engine | Weighted scoring model emits run-level health | 5 days | 8 | 🟡 |
| 17E | Expand smoke coverage | Added telemetry + session player smoke packs | 3 days | 7 | ✅ |
| 17F | Validate content regression bots | Training content validator wired into CI gate | 2 days | 7 | ✅ |
| 17G | Launch dashboard history | CI history tracked for trends and alerts | 2 days | 6 | ✅ |
| 17H | Ship doc autopublishing | Docs export wired into dashboard artifacts | 2 days | 6 | ✅ |
| 17N | QA score engine rollout | Final calibration + alert thresholds awaiting sign-off | 2 days | 9 | 🟡 |

## 🔜 Stage 18 — UX Integration & Player Layer (Next)
| Stage | Goal | Result | Duration | EV | Status |
|-------|------|--------|----------|----|--------|
| 18 | Merge player-facing flows | Integrate recap, streak, and roadmap UX into V2 shell | 6 days | 9 | 🔜 |

## 📈 Stage 19 — Adaptive Learning & Analytics (Planned)
| Stage | Goal | Result | Duration | EV | Status |
|-------|------|--------|----------|----|--------|
| 19 | Adaptive learning launch | Personalized booster engine + mastery analytics | 8 days | 9 | ⏳ |

## 🚀 Stage 20 — Public Launch & Monetization Pilot (Final)
| Stage | Goal | Result | Duration | EV | Status |
|-------|------|--------|----------|----|--------|
| 20 | Pilot public launch | Monetization pilot + beta cohort activation | 10 days | 10 | 🎯 |

### Timeline
- Current Stage → 17N (QA Score Engine) ≈ 96% complete.
- Stage 18 start → within 2–3 days.
- Core V2 ready → end of Dec 2025.
- Public Beta → Jan–Feb 2026.

*(Maintained automatically via Health Dashboard exporter.)*
