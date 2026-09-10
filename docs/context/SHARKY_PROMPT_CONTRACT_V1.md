# Sharky Prompt Contract v1

Status: ACTIVE
Purpose: delta-only agent dispatch with stable reusable invariants.

This contract reduces repeated prompt history. It is a routing and output contract,
not a replacement for live source, tests, current campaign state, or explicit owner
instructions.

## 1. Dispatch rule

A new bounded implementation prompt should carry only:

```text
SHARKY_PACKET <packet-id>

BASE
HEAD=<exact live sha>
BRANCH=<branch>

AUTHORITY
STATE=docs/context/PRE_HUMAN_CAMPAIGN_STATE_v1.md
CONTRACT=SHARKY_PROMPT_CONTRACT_V1
TASK_AUTHORITY=<minimum task-specific source>

DELTA
<the change requested now>

FROZEN
<contract IDs or exact invariants that must not move>

ALLOWED
<bounded mutable owners>

FORBIDDEN
<explicitly excluded owners/surfaces>

VALIDATE
<targeted deterministic gates>
<runtime evidence when user-facing>

RETURN
SHARKY_PACKET_REPORT_V1
```

Do not replay unchanged project history when a stable authority or contract ID already
carries it. Expand an invariant inline only when the current task changes, challenges,
or depends on its exact value.

## 2. Minimum orientation

Before mutation:

1. Re-resolve live `origin/main`.
2. Run `tools/sharky_context_capsule_v2.sh`.
3. Read the current campaign state only as needed to verify the capsule.
4. Read only the minimum task-specific authority that can change owner, scope, order,
   severity, evidence, or admission.
5. Escalate to broader SSOT only on a real unresolved question or conflict.

The capsule is not authority. If capsule output conflicts with live source or an
authority document, live evidence wins and the conflict must be reported.

## 3. Context budget rules

- Never stream a broad test, analyzer, build, or CI log into the agent transcript.
- Use `tools/sharky_compact_evidence_v1.sh` for noisy commands.
- Preserve the raw log and return the compact summary.
- Read diffs by `--name-only` or `--numstat` first; inspect only changed hunks required
  for adjudication.
- Prefer identifier-targeted grep/read over whole-file reads.
- Do not read archive/donor trees unless the task explicitly requires history.
- Do not spawn a fresh subagent when it would have to repay the same orientation cost.

Token economy never overrides correctness. Spend saved context on execution evidence,
not on additional speculative reading.

## 4. Model routing

Route by decision content:

- TOP: adjudication, causation, architecture, shared-owner redesign, severity,
  admission, conflicting evidence.
- MID: bounded implementation or repair when owner and DoD are already known.
- LOWEST_SAFE: deterministic formatting, lane wiring, publication, mechanical batch
  work with no remaining judgement call.

If the worker must decide whether the contract itself should change, it is not a
mechanical packet.

## 5. Raw evidence contract

Raw evidence is immutable for the run. Compression is a view, never the only copy.

Required relationship:

```text
raw command output -> ignored *.raw.log
                   -> compact deterministic summary -> agent context
```

On ambiguous failure, inspect only the bounded raw section needed to resolve it.
Do not summarize away exact values, SHAs, dimensions, test names, file paths, or
contract identifiers that determine admission.

## 6. Return schema

Implementation workers return this exact field set unless the task requires an
additional evidence field:

```text
SHARKY_PACKET_REPORT_V1
PRE_HEAD=<sha>
POST_HEAD=<sha>
BRANCH=<branch>
FILES_CHANGED=<comma-separated paths>
CONTRACTS_PRESERVED=<YES|NO>
TESTS=<compact result>
RUNTIME_375=<PASS|FAIL|NOT_REQUIRED>
RUNTIME_402=<PASS|FAIL|NOT_REQUIRED>
RUNTIME_430=<PASS|FAIL|NOT_REQUIRED>
EVIDENCE=<paths or artifact refs>
REGRESSIONS=<NONE or bounded list>
VERDICT=<PASS|FAIL|BLOCKED>
BLOCKER=<NONE or exact blocker>
END_SHARKY_PACKET_REPORT_V1
```

No narrative completion essay is required. Reasoning depth is preserved internally;
the external report is state plus evidence.

## 7. Automatic application and Astra profile

This contract is the default for Sharky repository work. A user does not need to say
"use context economy", invoke a skill, run the capsule, or choose a model tier.
Agents perform those steps automatically when their client exposes the required
capability.

For GPT-6 Astra and other high-cost long-context models:

- keep the stable instruction/authority prefix unchanged across turns where possible;
- place volatile packet delta after the stable prefix;
- prefer client-native prompt caching and conversation compaction when exposed;
- when the client supports an in-conversation reasoning configuration update, change
  effort through that mechanism rather than rewriting the stable prompt prefix;
- compact only completed/stable history; preserve active assumptions, exact IDs,
  tool outcomes, unresolved blockers, and the next concrete goal;
- do not request manual cache, compaction, or reasoning management from the user.

These are capability-gated behaviors. Repository tooling must still work correctly
when a client exposes none of them.

## 8. Mutation safety

- Smallest sufficient intervention.
- No unrelated cleanup.
- No hidden write/apply side effects in context tooling.
- Existing enums remain append-only.
- Existing frozen contracts remain frozen unless the owner explicitly opens them.
- CI failure blocks merge; rollback or repair remains bounded to the admitted owner.
- Third-party token compressors or shell interceptors are optional experiments only.
  They must not become a required production dependency without an evidence-backed
  comparison against the native Sharky tooling.
