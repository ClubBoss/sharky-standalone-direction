# Repo State Reconciliation v1

Purpose:

- reconcile the accepted mainline architecture closeouts with the later World 2 validator backfill
- state whether any previously closed block is actually reopened
- name one canonical current roadmap cursor

## Closed Mainline Blocks Still Valid

| Block | Status after reconciliation | Why |
| --- | --- | --- |
| World 2 truth / validation | remains closed | later showdown validator work is bounded post-closeout hardening inside an already-closed family, not evidence that the block closeout was wrong |
| topology / entry / progression consumer normalization | remains closed | no later repo state contradicts the centralized topology/progression seams |
| route-to-surface entry mapping | remains closed | later repo state does not reintroduce any in-scope mapping residue |
| auxiliary entry seam cleanup | remains closed | later repo state does not add a new in-scope production auxiliary launch seam |
| pack-target / host-surface mapping | remains closed | later repo state does not add another bounded shared host-choice seam |

## Accepted Late Backfill

| Backfill | Repo state | Reopens closed block? | Why |
| --- | --- | --- | --- |
| R298 board-plays / split-pot wording hardening | accepted | no | extends `world2_showdown_truth_validator_v1.dart` inside the bounded visible-showdown pilot without changing the closure decision for the larger World 2 truth/validation block |
| R299 explicit generic two-pair wording hardening | accepted | no | same bounded validator family, same pilot corpus, same post-closeout hardening pattern |

## Doc / Status Mismatch Check

| Item | Result | Note |
| --- | --- | --- |
| `world2_truth_validation_closeout_v1.md` next-block text | needs compact reconciliation note | its original next-block recommendation is historical now that the repo later accepted R298 / R299 and the active cursor moved back to the architecture mainline |
| mainline architecture closeout docs | valid as-is | their closure decisions still match repo truth |
| showdown coverage matrix | valid as-is | it correctly reflects the late accepted validator hardening |

## Canonical Current Roadmap Cursor

- current active block:
  - start / continue target -> map shell routing
- why this is canonical now:
  - it is the last explicitly started later-mainline block in repo docs
  - `docs/audit/investigations/map_shell_routing_audit_v1.md` shows one bounded seam already centralized
  - there is no corresponding closeout doc yet
  - R298 / R299 do not outrank or replace that architecture cursor; they are accepted backfill patches on a previously closed World 2 block

## Reconciliation Decision

- accepted repo truth:
  - keep all previously closed mainline blocks closed
  - accept R298 / R299 as late World 2 validator hardening
  - do not reopen World 2 truth / validation
  - continue from the later architecture mainline at the map shell routing block
