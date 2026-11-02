# Sharky Autopilot M1 — GitHub read-only observer

Issue: [#356](https://github.com/ClubBoss/sharky-standalone-direction/issues/356).

**Scope:** PR #355 exact HEAD and its GitHub PR-triggered workflows, plus the tracker #356. All operations use read-only HTTP GET. The emitted JSON includes a deterministic event fingerprint but DOES NOT deduplicate across workflow runs: event persistence/leases are deferred to M2. Never infer acceptance from green CI.

**Cost and security:** standard GitHub-hosted runner in a public repository; no paid APIs, model inference, subscriptions, third-party credentials, scorecard edits or worker dispatch. Explicit minimal GitHub token permissions. GitHub artifact expires in 3 days. Workflow is scheduled hourly only after merge to the default branch; schedules are best-effort and can be delayed/dropped. A PR run tests the observer but does not activate scheduled monitoring.

**Local test:** `python3 -m unittest discover -s tools/sharky_autopilot -p 'test_*.py' -v`.

**Live use:** `GITHUB_TOKEN=<read-only-token> python3 tools/sharky_autopilot/observe.py --out observation.json`; no requirement to place tokens in files. Never share tokens in logs. The observer hard-fails on unexpected PR or repo identifiers and cannot modify GitHub.

**Status:** M1 candidate, NOT 24/7 deployed; M2 durable queue, event dedup, producer/consumer separation and quotas still needed before automatic model execution. Owner decisions remain explicit.

macOS Python.org TLS note: If local urllib reports an absent CA bundle (without a GitHub API failure), use the OS-provided trust file with SSL_CERT_FILE=/etc/ssl/cert.pem. Never bypass TLS certificate verification or hardcode authentication tokens.

Security gate: This workflow deliberately has NO pull_request trigger. Only default-branch scheduled/manual runs read GitHub with an observer token. PR source changes require local/independent review plus existing canonical CI prior to merging; PR-provided code never runs in the observer with credentials.

## M2A local-only preparation (NOT deployed)

Pure `journal_projection.py` computes a material event identity from the
exact-source PR and CI state while intentionally excluding the infrastructure
Issue's updated_at and the observer capture timestamp. Its
`plan_append()` only returns PREPARE_ONLY, NOOP or STOP; it has no GitHub write
transport, subscription usage or executor dispatch. 12 deterministic tests
cover feedback-loop prevention, replay dedup, falsified bot receipts and
fail-closed behavior. The GitHub-hosted M1 observer remains read-only until
separate M2B admission.

## M2B local candidate (disabled; independent review required)

`journal_issue_gateway.py` is a narrow Issue #356 journal transport and bounded
write-policy candidate. It is **NOT** committed to `main` or deployed. Its diagnostic CLI has no
write option and invokes `run_once()` with `admit_post=False`. An explicitly
separate `.github/workflows/sharky-autopilot-journal.yml` is included as a
trusted-main-only candidate; it is inert until separately accepted and merged.
M1 remains read-only on its established schedule. No provider, learner data, protected PR or score is touched.

Before any real posting, an independent reviewer must ACCEPT the exact new
default-branch-only workflow and the owner must admit deployment. The job
serializes *all* journal writers in a single
concurrency group, supply only the normal job token, have exact scoped
`issues: write` and supporting read permissions, and explicitly call
`run_once(..., admit_post=True)` after satisfying both the owner-admission
environment marker and trusted-main provenance guard. No `pull_request` or
`pull_request_target` triggers, self-hosted runner, model inference, private
credentials, or dynamic task code. Merge does not itself imply owner admission.

The gateway reads Issue's exact `comments` count twice, fetches every page
of at most 100 records, rejects changed/incomplete history, checks for the
authenticated GitHub Actions bot's deterministic marker, and rechecks count
immediately before a potential append. A successful POST requires authenticated
readback. Token/header/error values are never printed. Body contains only
source-public PR/CI identities and explicit `NOT INFERRED` acceptance.

**Concurrency limitation:** GitHub Issue comments have no transactional
compare-and-swap. The workflow serialization plus dedup/replay prevents ordinary
duplicate deliveries, but cannot guarantee exactly-once against an unrelated
writer bypassing the workflow or a race between final check and POST. In doubt
STOP and review, never infer stage PASS. GitHub comments are editable/deletable;
this is a durable operational log, not an immutable cryptographic ledger.

Local tests:
`python3 -m unittest discover -s tools/sharky_autopilot -p 'test_*.py' -v`.
Expected current isolated total: 40 tests. **No deployed journal/queue/lease/worker as of this draft.**


## M2C isolated local queue pilot — NOT deployed (2026-11-02)

M1 observer and M2B Issue #356 journal are **deployed on main** and have
verified successful real scheduled GitHub-hosted runs. This paragraph supersedes
the historical M1/M2A/M2B "candidate" labels above; those preserve their original
pre-merge provenance.

`durable_queue.py` now proves an isolated, **local-only** SQLite queue for
explicitly owner-admitted `AUTOPILOT_INFRA_TEST_ONLY` tasks. It requires an
explicit database initialization, stable task identity and source event hash,
an infra/autopilot-* branch, a 40-hex exact source SHA and zero incremental
spend. `provider=NONE` and `execution_permitted=False` are hard-coded: it
never calls Codex, Claude, a shell, a paid API or GitHub mutation. There are no
credentials, daemon, Actions triggers or production worker.

Atomic `BEGIN IMMEDIATE` lease reservation and a unique active-resource
index prevent duplicate reservations across separate SQLite connections;
reopening the DB preserves active leases and append-only operational events.
Old/stale leases are diagnostic ONLY and never automatically reclaimed.
`acknowledge_stopped` **requires a separately supplied trusted verifier** of
worker exit (not implemented); the default always STOPs, even if a plausible
receipt is provided. Unit tests may use a fake verifier solely to exercise state
transitions. Only owner re-admission can retry a verified-stopped task, limited
to two attempts. Missing/incompatible storage STOPs rather than silently
recreating a database.

**Current gaps:** no actual process-identity/exit verifier, no machine daemon,
no queue replication to GitHub, no provider quota probe, no trusted
source-to-task admission service, no native simulator readiness and no
owner-approved live Codex/Claude worker. SQLite is one-host storage, not a
distributed lease service. Never equate these simulation tests with M2 full PASS
or M3 dispatch permission. Product DoD and SHARKY_100 remain unchanged.

M2C focused tests:
`python3 -m unittest discover -s tools/sharky_autopilot -p 'test_*.py' -q`.


## M2D real local process-stop proof — isolated pilot (2026-11-02)

`process_pilot.py` launches exactly one fixed offline Python child using
`subprocess.Popen` (no shell, no inherited user environment, no secrets, no
Codex/Claude/provider calls). It acquires the M2C SQLite lease first, waits for
the child to be reaped and its private process group to disappear, then supplies
a SHA-256 stop receipt and a tightly scoped in-process OS observation callback
to `acknowledge_stopped`. The child may not be relaunched after task STOP;
the second invocation yields NOOP. An existing ACTIVE lease blocks it.

The process proof deliberately uses `provider=NONE`, zero model tokens and
`execution_permitted=False` as *model dispatch* permission: the only allowed
action is the pre-approved fixed offline child. It is **not a generic worker**,
a supported Codex CLI launcher or an unattended macOS daemon. Stop verification
does not yet survive caller crash with an ACTIVE lease, does not prove malicious
process-tree isolation, and cannot be reused as M3 permission. No automatic
lease reclamation on timeout/error; operator intervention is necessary.
Do not schedule or merge with product workflows without an independent review.


## M3A one-shot subscription Codex READ-ONLY pilot (2026-11-02)

This is **not** general autonomous dispatch and not a production worker. The
only permitted model task is a fixed, manually owner-admitted one-line marker
response via the existing ChatGPT-authenticated Codex CLI on the authorized Mac.
No GitHub Actions, daemon, cron, app code, agent-to-agent queue bridge, or
headless Work/ordinary ChatGPT session is involved. No paid API.

The M2C SQLite schema advances to v2 with only two recognized providers:
`NONE` (legacy M2C/M2D, no model permission) and
`CODEX_SUBSCRIPTION_READONLY_ONESHOT`. A v1 database is **rejected** rather
than migrated or reinitialized. Only `admit_codex_readonly_once()` can create
the latter task, bound to fixed ID, exact source base SHA, infra-only branch,
one attempt, $0 budget and a separate owner-admission value. A leased Codex
task still sets generic `execution_permitted=False`; the dedicated M3A
adapter requires `codex_readonly_probe_permitted=True`, never grants writes
or accepts a model/prompt/command from the task or user.

`codex_readonly_pilot.py` requires verified, clean local source branch and
reviewed main ancestry. The CLI has no command/model/task/database overrides
and uses only the single fixed local queue path
`~/Sharky_Autopilot_Pilot/m3a_state/codex-readonly-once.sqlite3`.
A real launch requires the explicit flag `--owner-admit-readonly-once` and
initial `--initialize`; missing admission or DB STOPs. The explicit invocation
is one-shot: identical replay is NOOP without re-running the model. The state
path is a cooperative safety gate against accidental repeated launch, **not**
an anti-tamper guarantee against someone who can deliberately delete files.

The fixed Codex command uses `gpt-5.6-luna`, LOW reasoning,
`--sandbox read-only`, `--ephemeral`, `--ignore-user-config`, temporary
empty working directory, bounded 70-second timeout, exact marker output, and
no inherited provider/GitHub API tokens. Standard output/error are discarded;
only a bounded receipt hash and status are emitted. On any failure, no
provider fallback, no automatic retry and no paid API; a model run counts as
the single attempt. Once the child is reaped and its process group has ended,
a scoped verifier can close its lease even on model failure. If exit/stop is
uncertain, the active lease remains and a human must inspect it.

**Owner/QA gates:** independent review BEFORE the first actual gated model
launch; exact branch/HEAD and relevant CI BEFORE merge; independent evidence
after launch. The amount of available subscription quota cannot be proven by
`codex login status` or the installed model list. One-off access proof is not
a guaranteed 24/7 free allowance. This is a bounded test using existing
included quota only, with **incremental paid spend zero**.

**No M3 continuous scheduler is deployed.** Flutter, PR #355, protected PR
#224, SHARKY_100 and genuine learner/DoD proof remain untouched. M2B GitHub
Issue journal and M1 observer are unchanged.
