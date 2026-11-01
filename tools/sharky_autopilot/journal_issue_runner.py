#!/usr/bin/env python3
"""Trusted-main-only M2B Issue journal writer. No AI, product, or PR mutations."""
import os

from journal_issue_gateway import IssueClient, run_once
from observe import observe


def main():
    # This transport is never used by the public read-only M1 workflow.
    # The immutable workflow trusted-main admission is verified by run_once.
    if os.environ.get("GITHUB_REPOSITORY") != "ClubBoss/sharky-standalone-direction":
        raise SystemExit("STOP: non-target repo")
    result = run_once(
        observe(os.environ.get("GITHUB_TOKEN", "")),
        IssueClient(os.environ.get("GITHUB_TOKEN", "")),
        admit_post=True,
    )
    if result["action"] not in ("NOOP", "POSTED_READBACK"):
        raise SystemExit("STOP: journal writer not admitted or history incomplete")
    print(f"M2B {result['action']} event={result['event_id'][:12]} DoD=NOT_INFERRED")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
