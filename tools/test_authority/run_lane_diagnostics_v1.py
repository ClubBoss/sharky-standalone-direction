"""Safe, bounded diagnostics for the test-authority lane runner."""

from __future__ import annotations

import math
import os
import re
from pathlib import Path

TAIL_LIMIT = 4000

_SENSITIVE_ASSIGNMENT = re.compile(
    r"(?i)\b([a-z0-9_-]*(?:token|secret|password|passwd|credential|authorization|api[_-]?key)[a-z0-9_-]*)"
    r"(\s*[:=]\s*)([^\s,;]+)"
)
_BEARER = re.compile(r"(?i)\bBearer\s+[^\s,;]+")
_GITHUB_TOKEN = re.compile(r"\b(?:gh[pousr]_[A-Za-z0-9_]{12,}|github_pat_[A-Za-z0-9_]{12,})\b")
_AWS_ACCESS_KEY = re.compile(r"\bAKIA[0-9A-Z]{16}\b")
_JWT = re.compile(r"\beyJ[A-Za-z0-9_-]+\.eyJ[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\b")
_URL_CREDENTIALS = re.compile(r"(://)[^/@\s:]+:[^/@\s]+@")
_PRIVATE_KEY_BLOCK = re.compile(
    r"-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----.*?-----END (?:RSA |EC |OPENSSH )?PRIVATE KEY-----",
    re.DOTALL,
)


def sanitize_output(output: str) -> str:
    """Redact common credential forms and neutralize Actions workflow commands."""
    output = _URL_CREDENTIALS.sub(r"\1[REDACTED]@", output)
    output = _BEARER.sub("Bearer [REDACTED]", output)
    output = _PRIVATE_KEY_BLOCK.sub("[REDACTED_PRIVATE_KEY]", output)
    output = _GITHUB_TOKEN.sub("[REDACTED_GITHUB_TOKEN]", output)
    output = _AWS_ACCESS_KEY.sub("[REDACTED_AWS_ACCESS_KEY]", output)
    output = _JWT.sub("[REDACTED_JWT]", output)
    output = _SENSITIVE_ASSIGNMENT.sub(r"\1\2[REDACTED]", output)
    return re.sub(r"(?m)^(\s*)::", r"\1: :", output)


def tail(output: str, limit: int = TAIL_LIMIT) -> tuple[str, bool, int]:
    """Return a sanitized suffix and explicit truncation metadata."""
    sanitized = sanitize_output(output)
    return sanitized[-limit:], len(output) > limit, len(output)


def append_job_summary(summary: dict[str, object]) -> None:
    """Append only allowlisted metadata; never persist command text or output."""
    path = os.environ.get("GITHUB_STEP_SUMMARY")
    if not path:
        return
    lines = [
        "## Test authority diagnostics",
        "",
        "Command IDs are the 1-based execution order in the normal step log.",
        "",
        "| Command ID | Status | Exit code | Seconds | Log reference |",
        "|---|---|---:|---:|---|",
    ]
    statuses = {"pass", "fail", "timeout", "error", "cancelled", "skip"}
    for index, result in enumerate(summary.get("results", []), start=1):
        status = result.get("status")
        status = status if isinstance(status, str) and status in statuses else "unknown"
        code = result.get("exit_code")
        code = str(code) if type(code) is int else "unknown"
        duration = result.get("duration_seconds")
        seconds = (
            f"{duration:.3f}"
            if type(duration) in (int, float) and math.isfinite(duration) and duration >= 0
            else "unknown"
        )
        lines.append(
            f"| command-{index:03d} | {status} | {code} | {seconds} | Normal step log |"
        )
    with Path(path).open("a", encoding="utf-8") as stream:
        stream.write("\n".join(lines) + "\n")


def failure_log_lines(result: dict[str, object]) -> list[str]:
    """Format one failure for the normal step log, preserving truncation clues."""
    status = result.get("status")
    if status == "pass":
        return []
    name = sanitize_output(str(result.get("name", "unknown"))).replace("\r", " ").replace("\n", " ")
    output = str(result.get("output_tail") or "")
    lines = [
        f"::group::Test authority {status}: {name}",
        f"status={status} exit_code={result.get('exit_code')} "
        f"duration_seconds={result.get('duration_seconds')}",
    ]
    if result.get("output_truncated"):
        lines.append(
            f"[output truncated: showing final {len(output)} of "
            f"{result.get('output_chars')} characters]"
        )
    elif not output:
        lines.append("[no command output captured]")
    lines.extend([sanitize_output(output), "::endgroup::"])
    return lines
