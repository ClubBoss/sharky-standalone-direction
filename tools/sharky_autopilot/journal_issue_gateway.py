"""M2B candidate: narrowly gated Issue #356 append-only observation journal.

Local code only: no Actions writer workflow is installed and CLI has no --write.
A future independently reviewed trusted-main workflow must explicitly call
run_once(..., admit_post=True) with the GitHub job context. Do not infer DoD PASS.
"""
from __future__ import annotations

import json
import os
from urllib import error, request

from journal_projection import BOT, ISSUE_NUMBER, REPO, canonical_state, marker, plan_append

API = "https://api.github.com"
ISSUE = f"/repos/{REPO}/issues/{ISSUE_NUMBER}"
COMMENTS = ISSUE + "/comments"
PAGE_SIZE = 100
MAX_COMMENTS = 2000
EXPECTED_WORKFLOW_REF = (
    f"{REPO}/.github/workflows/sharky-autopilot-journal.yml@refs/heads/main"
)


class JournalStop(RuntimeError):
    """A hard, non-retry-with-write gate; never silently bypass."""


class IssueClient:
    def __init__(self, token: str, *, opener=request.urlopen):
        if not token:
            raise JournalStop("missing read/write GitHub job token")
        self._token = token
        self._opener = opener

    def _request(self, method: str, path: str, payload: dict | None = None):
        allowed_get = (
            path == ISSUE
            or path.startswith(COMMENTS + "?per_page=100&page=")
            and path[len(COMMENTS + "?per_page=100&page="):].isdigit()
        )
        allowed_post = path == COMMENTS and payload is not None
        if not ((method == "GET" and allowed_get and payload is None)
                or (method == "POST" and allowed_post)):
            raise JournalStop("GitHub API request outside fixed Issue #356 scope")
        headers = {
            "Accept": "application/vnd.github+json",
            "Authorization": f"Bearer {self._token}",
            "X-GitHub-Api-Version": "2022-11-28",
            "User-Agent": "sharky-autopilot-journal-m2b",
        }
        data = None
        if payload is not None:
            data = json.dumps(payload, separators=(",", ":")).encode("utf-8")
            headers["Content-Type"] = "application/json"
        req = request.Request(API + path, headers=headers, data=data, method=method)
        try:
            with self._opener(req, timeout=18) as response:
                return json.load(response)
        except (error.URLError, TimeoutError, OSError, ValueError) as exc:
            # Do not expose HTTP headers, tokens, or any sensitive response.
            raise JournalStop("GitHub Issue journal request failed") from exc

    def issue_comments_count(self) -> int:
        issue = self._request("GET", ISSUE)
        if not isinstance(issue, dict) or issue.get("number") != ISSUE_NUMBER:
            raise JournalStop("wrong Issue response")
        if issue.get("state") != "open":
            raise JournalStop("journal Issue not open")
        count = issue.get("comments")
        if type(count) is not int or not 0 <= count <= MAX_COMMENTS:
            raise JournalStop("missing/oversize Issue comments count")
        return count

    def comments_page(self, page: int) -> list[dict]:
        if type(page) is not int or not 1 <= page <= 1 + MAX_COMMENTS // PAGE_SIZE:
            raise JournalStop("invalid Issue comments page")
        data = self._request("GET", f"{COMMENTS}?per_page={PAGE_SIZE}&page={page}")
        if not isinstance(data, list):
            raise JournalStop("malformed comment list")
        return data

    def post_comment(self, body: str) -> dict:
        if not isinstance(body, str) or len(body) > 2400:
            raise JournalStop("invalid bounded journal body")
        result = self._request("POST", COMMENTS, {"body": body})
        if not isinstance(result, dict):
            raise JournalStop("malformed comment write receipt")
        return result


def read_stable_history(client) -> list[dict]:
    """Count-checked full pagination; on any race, reject rather than truncate."""
    count = client.issue_comments_count()
    if type(count) is not int or count < 0 or count > MAX_COMMENTS:
        raise JournalStop("journal history size not trustworthy")
    comments: list[dict] = []
    seen: set[int] = set()
    pages = (count + PAGE_SIZE - 1) // PAGE_SIZE
    for page in range(1, pages + 1):
        batch = client.comments_page(page)
        if not isinstance(batch, list) or len(batch) > PAGE_SIZE:
            raise JournalStop("malformed or truncated comment page")
        for item in batch:
            if not isinstance(item, dict) or type(item.get("id")) is not int or item["id"] <= 0:
                raise JournalStop("missing comment identity")
            if item["id"] in seen:
                raise JournalStop("duplicated comment across pages")
            if not isinstance(item.get("user"), dict) or not isinstance(item["user"].get("login"), str):
                raise JournalStop("missing comment author identity")
            if not isinstance(item.get("body"), str):
                raise JournalStop("missing comment body")
            seen.add(item["id"])
            comments.append(item)
    if len(comments) != count or client.issue_comments_count() != count:
        raise JournalStop("journal changed or incomplete while reading")
    return comments


def render_receipt(observation: dict, event_id: str) -> str:
    state = canonical_state(observation)
    counts = {"success": 0, "failure": 0, "skipped": 0, "other": 0}
    for run in state["ci"]:
        conclusion = run["conclusion"]
        counts[conclusion if conclusion in counts else "other"] += 1
    return (
        f"{marker(event_id)}\n"
        "**Sharky Autopilot M2 observation (machine-only; NOT acceptance)**\n\n"
        f"- Source: PR #{state['pr']} at exact HEAD `{state['head_sha']}`\n"
        f"- Draft: `{str(state['draft']).lower()}`; merged: `{str(state['merged']).lower()}`\n"
        f"- PR-triggered CI: success={counts['success']}, failure={counts['failure']}, "
        f"skipped={counts['skipped']}, other={counts['other']}\n"
        "- Owner admission: **UNCHANGED**; source/native DoD: **NOT INFERRED**\n"
        "- Autonomous AI dispatch: **OFF**; paid spend: **$0**; SHARKY_100: **UNCHANGED**\n"
        f"- Deterministic event: `{event_id}`\n"
    )


def trusted_main_gate(env: dict) -> bool:
    """Explicit double gate; no admission follows merely from a green PR CI."""
    return (
        env.get("SHARKY_M2_POST_OWNER_ADMITTED") == "YES_AFTER_INDEPENDENT_REVIEW"
        and env.get("GITHUB_REPOSITORY") == REPO
        and env.get("GITHUB_REF") == "refs/heads/main"
        and env.get("GITHUB_EVENT_NAME") in ("schedule", "workflow_dispatch")
        and env.get("GITHUB_WORKFLOW_REF") == EXPECTED_WORKFLOW_REF
    )


def run_once(observation: dict, client, *, admit_post: bool = False, env=None) -> dict:
    """Idempotent replay with a separate out-of-band owner/workflow admission.

    Not exactly-once: GitHub comments have no compare-and-swap. The future
    trusted-main workflow MUST serialize all writes using one concurrency group.
    """
    history = read_stable_history(client)
    plan = plan_append(observation, history, complete_history=True)
    if plan["action"] != "PREPARE_ONLY":
        return plan
    if not admit_post or not trusted_main_gate(dict(os.environ) if env is None else env):
        return {**plan, "reason": "owner-admission-not-enabled"}
    # One last inexpensive race check, still not an atomic CAS operation.
    if client.issue_comments_count() != len(history):
        raise JournalStop("Issue comments changed before append")
    body = render_receipt(observation, plan["event_id"])
    posted = client.post_comment(body)
    if (type(posted.get("id")) is not int or posted["id"] <= 0
            or posted.get("user", {}).get("login") != BOT
            or posted.get("body") != body):
        raise JournalStop("write acknowledgement untrusted; inspect before retry")
    after = read_stable_history(client)
    actual = [c for c in after if c["id"] == posted["id"] and
              c["user"]["login"] == BOT and marker(plan["event_id"]) in c["body"]]
    if len(actual) != 1:
        raise JournalStop("written event not confirmed in readback")
    return {"action": "POSTED_READBACK", "event_id": plan["event_id"],
            "comment_id": posted["id"], "acceptance": "NEVER_INFERRED"}


def main() -> int:
    """Read-only diagnostic CLI; no --write argument or worker execution."""
    import argparse
    from pathlib import Path
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--observation", required=True)
    args = parser.parse_args()
    observation = json.loads(Path(args.observation).read_text(encoding="utf-8"))
    client = IssueClient(os.environ.get("GITHUB_TOKEN", ""))
    result = run_once(observation, client)  # Hard-coded dry run.
    print(json.dumps(result, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
