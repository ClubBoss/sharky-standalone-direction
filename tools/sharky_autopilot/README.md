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
