# Pre-Human Campaign State v1

Status: ACTIVE campaign state — **first read** for any campaign session.

Compact machine-readable campaign state. **One screen only.** Full plan:
`docs/plan/PRE_HUMAN_AND_HUMAN_PROVEN_CAMPAIGN_v1.md`. Do not duplicate the plan
here; update only the fields below.

| Field | Value |
| --- | --- |
| Canonical HEAD | `31ac1addbb9094b1074f266d678845b9dd1e9d47` |
| Campaign version | v1 |
| Umbrella stage | **Pre-Human Node 5 — Canonical Contract and Test Authority Restoration** |
| Active sub-packet | **PHP-0 — Canonical-Adjacent Red-Guard Triage** |
| Status | **CLOSED_CLASSIFIED_PENDING_MERGE** |
| Latest admitted PR | **#53** |
| F-16 | **CLOSED** (independently reverified at head, 62/62) |
| F-17 | **CLASSIFIED** — 53 files: required 0; stale 2; active-nonblocking 5; archived 7; quarantined 29; unresolved-unique 10. Full ledger: `docs/_reviews/php0_canonical_adjacent_red_guard_triage_v1.md` |
| F-18 | **STALE_TEST** — exact pre-F-16-to-head trail disproves PR #51/#52 causation; owner is compact-decision test fixture / retired teaching-step assertion |
| Sharky owner decision | **SUPPLIED** — `SHARKY_VISUAL_LOCK_V1` (refined C) |
| Sharky production integration | **PENDING** (PHP-6) |
| Next authorized packet | **PENDING_OWNER_GATEWAY** — PHP-3 recommended for unresolved unique contracts |
| Following packet | **PENDING_OWNER_GATEWAY** — PHP-2 known-owner disposition |
| Autonomous window | **one packet / maximum one merged PR** |
| Human Proof | **NOT AUTHORIZED** |
| `PRE_HUMAN_READY` | **NOT MET** |
| `HUMAN_PROVEN_10_OF_10_CANDIDATE` | **NOT MET** |

## Open canonical severity counts (at `52034abb`)

| Severity | Count | IDs |
| --- | ---: | --- |
| P0 | **0** | — |
| P1 proven | **0** | (the known P1, F-16 #12, is closed and verified) |
| P2 contract-significance | **5** | F-15, W1W6-DLR-003, SHK-VIS-01, MOT-04, A11Y-01 (red-contract half) |
| P3 | **2** | F-01, F-02 |
| Unassignable until PHP-0 | **0** | — |
| `BLOCKED_OWNER_DECISION` | **1** | SHK-CREST-01 (crest vs approved no-crest package; blocks only crest-dependent asset production in PHP-6) |

Severity here is *contract significance*, not proven learner-visible impact.
Product severity resolves in PHP-0.

## Packet ledger

| Packet | Stage | Status |
| --- | --- | --- |
| PHP-0 Canonical-Adjacent Red-Guard Triage | Node 5 | **CLOSED_CLASSIFIED_PENDING_MERGE** |
| PHP-1 Confirmed Canonical Guard Repair | Node 5 | NOT_PREAUTHORIZED |
| PHP-2 Legacy Corpus Ownership Disposition | Node 5 | NOT_PREAUTHORIZED |
| PHP-3 Canonical Test Classification and Manifest | Node 5 | NOT_PREAUTHORIZED |
| PHP-4 Canonical Full-Lane CI Authority | Node 5 | NOT_PREAUTHORIZED |
| PHP-5 Premium Motion & Ceremony Completion | — | NOT_PREAUTHORIZED |
| PHP-6 Sharky Production Integration & Completeness Proof | — | NOT_PREAUTHORIZED |
| PHP-7 Screen-Role & Visual-Hierarchy Emphasis Proof | — | NOT_PREAUTHORIZED |
| PHP-8 Evidence & Accessibility Lane Completeness | — | NOT_PREAUTHORIZED |
| PHP-9 `PRE_HUMAN_READY` Admission | — | NOT_PREAUTHORIZED |

PR targets: Node 5 ≈ **4–7**; full machine horizon ≈ **8–12**; **16 is a hard
emergency ceiling, never a target.**

## Update rule

Each packet close updates only: canonical HEAD, latest admitted PR, the changed
finding statuses, the changed severity counts, the packet ledger row, and the
next-authorized/following-packet fields. Any packet may be **eliminated** if
triage proves it unnecessary — record `CLOSED_UNNECESSARY` with the proving
evidence rather than executing it for completeness.
