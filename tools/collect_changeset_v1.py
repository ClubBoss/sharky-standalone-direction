"""Read-only changed-scope adapter. Never fetch, execute event text, or infer a PR base."""
import json
import os
import re
import subprocess
import sys
from pathlib import Path

class Unknown(ValueError):
    pass

def sha(value):
    if not isinstance(value, str) or not re.fullmatch(r"[0-9a-f]{40}", value) or value == "0"*40:
        raise Unknown("invalid SHA")
    return value

def mapping(value):
    if not isinstance(value, dict):
        raise Unknown("malformed object")
    return value

def context(env, candidate, parents):
    """Event files are trusted runtime inputs, not authority supplied by PR code."""
    if env.get("GITHUB_ACTIONS") == "true":
        event_name = env.get("GITHUB_EVENT_NAME")
        repository = env.get("GITHUB_REPOSITORY", "")
        ref = env.get("GITHUB_REF", "")
        if not re.fullmatch(r"[^/\s]+/[^/\s]+", repository):
            raise Unknown("repository missing")
        if sha(env.get("GITHUB_SHA")) != candidate:
            raise Unknown("runtime SHA differs from checkout")
        event = mapping(json.loads(Path(env["GITHUB_EVENT_PATH"]).read_text()))
        if mapping(event.get("repository")).get("full_name") != repository:
            raise Unknown("event repository mismatch")
        if event_name == "pull_request":
            if event.get("action") not in {"opened", "synchronize", "reopened"}:
                raise Unknown("unsupported PR action")
            number = event.get("number")
            if type(number) is not int or number <= 0 or ref not in {f"refs/pull/{number}/merge", f"refs/pull/{number}/head"}:
                raise Unknown("PR ref mismatch")
            pr = mapping(event.get("pull_request"))
            base_data, head_data = mapping(pr.get("base")), mapping(pr.get("head"))
            if mapping(base_data.get("repo")).get("full_name") != repository:
                raise Unknown("base repository mismatch")
            base, head = sha(base_data.get("sha")), sha(head_data.get("sha"))
            if candidate == head:
                return "pr", base, head
            if ref != f"refs/pull/{number}/merge" or parents != [base, head]:
                raise Unknown("synthetic parent mismatch")
            return "synthetic", base, head
        if event_name == "push":
            if not ref.startswith("refs/heads/") or event.get("ref") != ref or event.get("deleted") is not False:
                raise Unknown("push ref or deletion mismatch")
            if sha(event.get("after")) != candidate:
                raise Unknown("push after mismatch")
            if event.get("before") == "0"*40:
                return "full-scope", None, None
            return "push", sha(event.get("before")), candidate
        if event_name in {"workflow_dispatch", "schedule"}:
            if not ref.startswith("refs/heads/"):
                raise Unknown("unsupported non-PR ref")
            return "full-scope", None, None
        raise Unknown("unsupported event")
    # Explicit local authority remains caller-owned, never inferred from origin/main.
    mode = env.get("SHARKY_CHANGE_MODE", "")
    if not mode:
        return "full-scope", None, None
    if mode != "pr":
        raise Unknown("unsupported explicit mode")
    base, head, expected = [sha(env.get("SHARKY_CHANGE_"+k)) for k in ("BASE", "HEAD", "CANDIDATE")]
    if candidate != expected or candidate != head:
        raise Unknown("explicit checkout mismatch")
    return "pr", base, head

def collect(root, env):
    def git(*args):
        q = subprocess.run(["git", "-C", root, *args], stdout=subprocess.PIPE,
                           stderr=subprocess.PIPE, check=False)
        if q.returncode:
            raise Unknown("git query failed")
        return q.stdout
    candidate = sha(git("rev-parse", "--verify", "HEAD^{commit}").strip().decode())
    if git("ls-files", "--unmerged", "-z"):
        raise Unknown("unmerged index")
    parents = git("show", "-s", "--format=%P", candidate).strip().decode().split()
    mode, base, head = context(env, candidate, parents)
    queries = []
    if mode == "full-scope":
        # No ancestry claim. Consumers must explicitly select ALL declared families.
        queries += [("ls-tree", "-r", "--name-only", "-z", candidate), ("ls-files", "-z")]
    else:
        if git("rev-parse", "--is-shallow-repository").strip() != b"false":
            raise Unknown("bounded ancestry is shallow")
        for value in (base, head):
            if git("rev-parse", "--verify", value+"^{commit}").strip().decode() != value:
                raise Unknown("required object absent")
        if mode == "push":
            queries.append(("diff", "--no-renames", "--name-only", "-z", base, candidate, "--"))
        else:
            bases = git("merge-base", "--all", base, head).splitlines()
            if len(bases) != 1:
                raise Unknown("unique merge base unavailable")
            merge_base = sha(bases[0].decode())
            queries.append(("diff", "--no-renames", "--name-only", "-z", merge_base, head, "--"))
            if mode == "synthetic":
                queries.append(("diff", "--no-renames", "--name-only", "-z", base, candidate, "--"))
    queries += [
        ("diff", "--no-renames", "--name-only", "-z", "--cached", "HEAD", "--"),
        ("diff", "--no-renames", "--name-only", "-z", "--"),
        ("ls-files", "--others", "--exclude-standard", "-z"),
    ]
    paths = set()
    for args in queries:
        data = git(*args)
        if data and not data.endswith(b"\0"):
            raise Unknown("unterminated path stream")
        for raw in data.split(b"\0"):
            if not raw:
                continue
            path = raw.decode("utf-8")
            if "\n" in path or "\r" in path:
                raise Unknown("unrepresentable path")
            paths.add(path)
    if git("rev-parse", "HEAD").strip().decode() != candidate:
        raise Unknown("checkout changed during collection")
    return ("full-scope" if mode == "full-scope" else "bounded"), sorted(paths)

if __name__ == "__main__":
    try:
        scope, paths = collect(sys.argv[1], os.environ)
    except (ValueError, UnicodeError, OSError, IndexError, KeyError, TypeError):
        print("CHANGESET_UNKNOWN: event authority or git state invalid", file=sys.stderr)
        sys.exit(75)
    if "--with-scope" in sys.argv[2:]:
        print("SCOPE:" + scope)
    sys.stdout.write("".join(path+"\n" for path in paths))
