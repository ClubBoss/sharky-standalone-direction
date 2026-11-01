# Sharky Autopilot M1 — GitHub read-only observer

Issue: [#356](https://github.com/ClubBoss/sharky-standalone-direction/issues/356).

**Scope:** PR #355 exact HEAD and its GitHub PR-triggered workflows, plus the tracker #356. All operations use read-only HTTP GET. The emitted JSON includes a deterministic event fingerprint but DOES NOT deduplicate across workflow runs: event persistence/leases are deferred to M2. Never infer acceptance from green CI.

**Cost and security:** standard GitHub-hosted runner in a public repository; no paid APIs, model inference, subscriptions, third-party credentials, scorecard edits or worker dispatch. Explicit minimal GitHub token permissions. GitHub artifact expires in 3 days. Workflow is scheduled hourly only after merge to the default branch; schedules are best-effort and can be delayed/dropped. A PR run tests the observer but does not activate scheduled monitoring.

**Local test:** `python3 -m unittest discover -s tools/sharky_autopilot -p 'test_*.py' -v`.

**Live use:** `GITHUB_TOKEN=<read-only-token> python3 tools/sharky_autopilot/observe.py --out observation.json`; no requirement to place tokens in files. Never share tokens in logs. The observer hard-fails on unexpected PR or repo identifiers and cannot modify GitHub.

**Status:** M1 candidate, NOT 24/7 deployed; M2 durable queue, event dedup, producer/consumer separation and quotas still needed before automatic model execution. Owner decisions remain explicit.

macOS Python.org TLS note: If local urllib reports an absent CA bundle (without a GitHub API failure), use the OS-provided trust file with SSL_CERT_FILE=/etc/ssl/cert.pem. Never bypass TLS certificate verification or hardcode authentication tokens.
