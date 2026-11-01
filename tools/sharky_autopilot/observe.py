#!/usr/bin/env python3
"""Read-only Sharky GitHub observer. No LLM, worker dispatch or scorecard writes.

Run in GitHub Actions or locally with an authenticated, read-only GitHub token.
"""
import argparse
import datetime as dt
import hashlib
import json
import os
from pathlib import Path
from urllib import error, parse, request

REPO = "ClubBoss/sharky-standalone-direction"
PR_NUMBER = 355
ISSUE_NUMBER = 356
API_BASE = "https://api.github.com"


def api_get(path: str, token: str, *, opener=request.urlopen) -> dict:
    if not path.startswith(f"/repos/{REPO}/"):
        raise ValueError("Observer request outside permitted Sharky repo")
    if not token:
        raise ValueError("GitHub token missing; no anonymous fallback")
    req = request.Request(
        API_BASE + path,
        headers={
            "Accept": "application/vnd.github+json",
            "Authorization": f"Bearer {token}",
            "X-GitHub-Api-Version": "2022-11-28",
            "User-Agent": "sharky-autopilot-observer-v0.1",
        },
        method="GET",
    )
    try:
        with opener(req, timeout=18) as response:
            return json.load(response)
    except (error.URLError, TimeoutError) as exc:
        # Never print auth headers or token.
        raise RuntimeError("GitHub observer GET failed") from exc


def normalize(pr: dict, actions: dict, issue: dict) -> dict:
    if pr.get("number") != PR_NUMBER:
        raise ValueError("Unexpected PR number")
    head = pr["head"]["sha"]
    if not isinstance(head, str) or len(head) != 40:
        raise ValueError("Missing exact PR HEAD")
    runs = [r for r in actions.get("workflow_runs", [])
            if r.get("head_sha") == head and r.get("event") == "pull_request"]
    runs.sort(key=lambda r: (str(r.get("name")), int(r.get("id", 0))))
    selected = [{
        "name": r.get("name"), "run_id": r.get("id"),
        "status": r.get("status"), "conclusion": r.get("conclusion"),
    } for r in runs]
    state = {
        "repo": REPO,
        "pr": PR_NUMBER,
        "head_sha": head,
        "draft": pr.get("draft") is True,
        "merged": pr.get("merged_at") is not None,
        "ci": selected,
        "autopilot_issue": {
            "number": ISSUE_NUMBER,
            "state": issue.get("state"),
            "updated_at": issue.get("updated_at"),
        },
    }
    raw = json.dumps(state, sort_keys=True, separators=(",", ":")).encode("utf-8")
    return {
        "schema": "sharky.autopilot.observation.v0.1",
        "event_id": hashlib.sha256(raw).hexdigest(),
        "observed_utc": dt.datetime.now(dt.timezone.utc).isoformat(timespec="seconds"),
        "state": state,
        "acceptance": "NEVER_INFERRED_FROM_GREEN_CI",
        "mutation_permitted": False,
        "model_dispatch_permitted": False,
        "scorecard_write_permitted": False,
    }


def observe(token: str, *, getter=api_get) -> dict:
    pr = getter(f"/repos/{REPO}/pulls/{PR_NUMBER}", token)
    sha = pr["head"]["sha"]
    # Restrict to the exact candidate SHA. No unrelated CI data is promoted.
    actions = getter(f"/repos/{REPO}/actions/runs?{parse.urlencode({'head_sha': sha, 'per_page': 40})}", token)
    issue = getter(f"/repos/{REPO}/issues/{ISSUE_NUMBER}", token)
    return normalize(pr, actions, issue)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--out", default="autopilot-observation.json")
    args = parser.parse_args()
    result = observe(os.environ.get("GITHUB_TOKEN", ""))
    out = Path(args.out)
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(result, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    # Never print auth, learner PII, full external payloads, or a purported DoD PASS.
    state = result["state"]
    print(f"OBSERVED PR#{state['pr']} HEAD={state['head_sha'][:12]} draft={state['draft']} "
          f"ci_runs={len(state['ci'])} event={result['event_id'][:12]} DoD=NOT_INFERRED")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
