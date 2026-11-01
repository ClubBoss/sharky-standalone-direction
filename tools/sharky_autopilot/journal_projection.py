"""M2 preparation: pure zero-billing GitHub observation-to-journal projection.

No network, no credentials, no write API, no autonomous agent dispatch.
"""
from __future__ import annotations

import hashlib
import json
import re

REPO = "ClubBoss/sharky-standalone-direction"
PR_NUMBER = 355
ISSUE_NUMBER = 356
BOT = "github-actions[bot]"
FLAG_NAMES = ("mutation_permitted", "model_dispatch_permitted", "scorecard_write_permitted")
_SHA = re.compile(r"[a-f0-9]{40}\Z")
_EVENT = re.compile(r"[a-f0-9]{64}\Z")


def canonical_state(observation: dict) -> dict:
    """Drops timestamps on observer issue to avoid self-generated event loops."""
    if any(observation.get(flag) is not False for flag in FLAG_NAMES):
        raise ValueError("observer must explicitly deny mutation/dispatch/scorecard")
    state = observation["state"]
    if state.get("repo") != REPO or state.get("pr") != PR_NUMBER:
        raise ValueError("wrong source repository or PR")
    sha = state.get("head_sha")
    if not isinstance(sha, str) or not _SHA.fullmatch(sha):
        raise ValueError("invalid exact HEAD")
    issue = state.get("autopilot_issue")
    if not isinstance(issue, dict) or issue.get("number") != ISSUE_NUMBER:
        raise ValueError("wrong journal issue")
    if issue.get("state") not in ("open", "closed"):
        raise ValueError("unknown issue state")
    runs = state.get("ci")
    if not isinstance(runs, list):
        raise ValueError("missing CI observations")
    normalized = []
    seen = set()
    for r in runs:
        if not isinstance(r, dict) or not isinstance(r.get("run_id"), int) or r["run_id"] <= 0:
            raise ValueError("invalid CI run")
        if r["run_id"] in seen:
            raise ValueError("duplicate CI run")
        seen.add(r["run_id"])
        if r.get("status") not in ("queued", "requested", "waiting", "pending", "in_progress", "completed"):
            raise ValueError("unknown CI status")
        if r.get("conclusion") not in (None,"success", "failure", "cancelled", "skipped", "timed_out", "action_required", "neutral", "stale"):
            raise ValueError("unknown CI conclusion")
        normalized.append({k: r.get(k) for k in ("name", "run_id", "status", "conclusion")})
    normalized.sort(key=lambda r: (str(r["name"]), r["run_id"]))
    return {"schema": "sharky.autopilot.state.v0.2", "repo": REPO,
            "pr": PR_NUMBER, "head_sha": sha, "draft": state.get("draft") is True,
            "merged": state.get("merged") is True, "ci": normalized,
            "journal_issue_state": issue["state"]}


def fingerprint(observation: dict) -> str:
    payload = json.dumps(canonical_state(observation), sort_keys=True, separators=(",", ":")).encode()
    return hashlib.sha256(payload).hexdigest()


def marker(event_id: str) -> str:
    if not _EVENT.fullmatch(event_id):
        raise ValueError("invalid event ID")
    return f"<!-- SHARKY_AUTOPILOT_V2_EVENT:{event_id} -->"


def plan_append(observation: dict, comments: list[dict], *, complete_history: bool) -> dict:
    """Pure decision only. Caller MUST NOT post without separate owner/CI admission."""
    event_id = fingerprint(observation)
    if not complete_history:
        return {"action": "STOP", "reason": "journal-history-incomplete", "event_id": event_id}
    target = marker(event_id)
    for comment in comments:
        if not isinstance(comment, dict):
            raise ValueError("invalid journal comment")
        if comment.get("user", {}).get("login") == BOT and target in (comment.get("body") or ""):
            return {"action": "NOOP", "reason": "deduped", "event_id": event_id}
    return {"action": "PREPARE_ONLY", "reason": "new-material-state", "event_id": event_id,
            "marker": target, "mutation_permitted": False, "model_dispatch_permitted": False}
