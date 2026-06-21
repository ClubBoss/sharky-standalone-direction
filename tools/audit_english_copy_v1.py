#!/usr/bin/env python3
"""Inventory and classify Sharky user-facing English copy."""

from __future__ import annotations

import json
import re
import shutil
from collections import Counter, defaultdict
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Iterable


ROOTS = ("lib", "assets", "content", "test", "docs")
OUTPUT_DIR = Path("output/copy_audit/current")
TEXT_EXTENSIONS = {".dart", ".json", ".jsonl", ".md", ".yaml", ".yml"}
EXCLUDED_PARTS = {
    "build",
    ".dart_tool",
    "output",
    "external_competitors",
    ".git",
    ".idea",
    ".vscode",
}
DOC_ALLOWED_PREFIXES = (
    "docs/plan/",
    "docs/content/",
    "docs/current/",
    "docs/product/",
    "docs/learning/",
    "docs/_reviews/",
)
ACTIVE_ACT0_FILES = {
    "act0_home_shell_v1.dart",
    "act0_learn_path_shell_v1.dart",
    "act0_play_shell_v1.dart",
    "act0_review_shell_v1.dart",
    "act0_profile_shell_v1.dart",
    "act0_shell_preview_screen_v1.dart",
    "act0_shell_chrome_v1.dart",
    "act0_content_copy_v1.dart",
    "act0_runtime_surface_copy_v1.dart",
    "act0_placement_shell_v1.dart",
    "act0_welcome_shell_v1.dart",
    "act0_lesson_runner_shell_v1.dart",
    "act0_shell_state_v1.dart",
}
FORBIDDEN_TERMS = (
    "AI",
    "adaptive",
    "GTO",
    "solver",
    "optimal",
    "guarantee",
    "win-rate",
    "premium",
    "paywall",
    "trial",
    "leak detected",
    "mastered forever",
)
POKER_TERMS = (
    "GTO",
    "EV",
    "ICM",
    "equity",
    "range",
    "ranges",
    "blocker",
    "blockers",
    "c-bet",
    "3-bet",
    "three-bet",
    "iso",
    "squeeze",
    "SPR",
    "pot odds",
    "fold equity",
    "exploit",
    "exploitative",
    "polar",
    "merged",
)
INTERNAL_TERMS = (
    "payload",
    "telemetry",
    "debug",
    "fixture",
    "taskId",
    "lessonId",
    "worldId",
    "sessionId",
    "act0_",
    "world_",
)


@dataclass
class InventoryItem:
    id: str
    text: str
    file_path: str
    line_number: int
    source_type: str
    likely_visibility: str
    confidence: str
    notes: str


@dataclass
class Finding:
    id: str
    item_id: str
    category: str
    severity: str
    confidence: str
    text: str
    file_path: str
    line_number: int
    likely_visibility: str
    notes: str


def main() -> int:
    if OUTPUT_DIR.exists():
        shutil.rmtree(OUTPUT_DIR)
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    items = _dedupe_items(_extract_inventory())
    findings = _build_findings(items)
    summary = _summary(items, findings)

    (OUTPUT_DIR / "english_copy_inventory.json").write_text(
        json.dumps(
            {
                "schema": "english_copy_inventory_v1",
                "items": [asdict(item) for item in items],
                "findings": [asdict(finding) for finding in findings],
                "summary": summary,
            },
            ensure_ascii=False,
            indent=2,
        )
        + "\n",
        encoding="utf-8",
    )
    (OUTPUT_DIR / "english_copy_summary.json").write_text(
        json.dumps(summary, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    (OUTPUT_DIR / "english_copy_inventory.md").write_text(
        _inventory_markdown(items, summary),
        encoding="utf-8",
    )
    (OUTPUT_DIR / "english_copy_findings.md").write_text(
        _findings_markdown(findings, summary),
        encoding="utf-8",
    )

    print(OUTPUT_DIR / "english_copy_inventory.md")
    print(OUTPUT_DIR / "english_copy_findings.md")
    print(OUTPUT_DIR / "english_copy_inventory.json")
    print(OUTPUT_DIR / "english_copy_summary.json")
    print(f"inventory_items={summary['total_inventory_strings']}")
    print(f"findings={summary['total_findings']}")
    return 0


def _extract_inventory() -> list[InventoryItem]:
    items: list[InventoryItem] = []
    next_id = 1
    for path in _iter_candidate_files():
        for text, line_number, source_type, notes in _extract_file(path):
            clean = _clean_text(text)
            if not _is_candidate_copy(clean):
                continue
            visibility, confidence, visibility_notes = _classify_visibility(
                path, clean, source_type
            )
            item = InventoryItem(
                id=f"copy_{next_id:06d}",
                text=clean,
                file_path=path.as_posix(),
                line_number=line_number,
                source_type=source_type,
                likely_visibility=visibility,
                confidence=confidence,
                notes="; ".join(part for part in (notes, visibility_notes) if part),
            )
            items.append(item)
            next_id += 1
    return items


def _iter_candidate_files() -> Iterable[Path]:
    for root in ROOTS:
        root_path = Path(root)
        if not root_path.exists():
            continue
        for path in root_path.rglob("*"):
            if not path.is_file() or path.suffix.lower() not in TEXT_EXTENSIONS:
                continue
            parts = set(path.parts)
            if EXCLUDED_PARTS.intersection(parts):
                continue
            posix = path.as_posix()
            if posix.startswith("docs/") and not posix.startswith(DOC_ALLOWED_PREFIXES):
                continue
            if "/archive/" in posix or "/history/" in posix:
                continue
            yield path


def _extract_file(path: Path) -> Iterable[tuple[str, int, str, str]]:
    suffix = path.suffix.lower()
    if suffix == ".dart":
        yield from _extract_dart_strings(path)
    elif suffix in {".json", ".jsonl"}:
        yield from _extract_json_content(path)
    elif suffix in {".yaml", ".yml"}:
        yield from _extract_yaml_content(path)
    elif suffix == ".md":
        yield from _extract_markdown_content(path)


def _extract_dart_strings(path: Path) -> Iterable[tuple[str, int, str, str]]:
    text = path.read_text(encoding="utf-8", errors="ignore")
    pattern = re.compile(
        r"""(?P<prefix>r)?(?P<quote>'''|\"\"\"|'|")(?P<body>.*?)(?P=quote)""",
        re.DOTALL,
    )
    line_offsets = _line_offsets(text)
    for match in pattern.finditer(text):
        body = match.group("body")
        quote = match.group("quote")
        if "\n" in body and quote in {"'", '"'}:
            continue
        line = _line_for_offset(line_offsets, match.start())
        line_text = text.splitlines()[line - 1] if line - 1 < len(text.splitlines()) else ""
        decoded = body if match.group("prefix") else _decode_dart_string(body)
        notes = ["dart literal"]
        if "ru:" in line_text or "localeIsRu" in line_text or "_copyV1" in line_text:
            notes.append("locale alternative")
        yield decoded, line, "test_preview" if path.as_posix().startswith("test/") else "dart_string", "; ".join(notes)


def _extract_json_content(path: Path) -> Iterable[tuple[str, int, str, str]]:
    if path.suffix.lower() == ".jsonl":
        for line_number, line in enumerate(path.read_text(encoding="utf-8", errors="ignore").splitlines(), 1):
            stripped = line.strip()
            if not stripped:
                continue
            try:
                value = json.loads(stripped)
            except json.JSONDecodeError:
                continue
            yield from _walk_json_value(value, line_number)
        return
    try:
        value = json.loads(path.read_text(encoding="utf-8", errors="ignore"))
    except json.JSONDecodeError:
        return
    yield from _walk_json_value(value, 1)


def _walk_json_value(value: object, line_number: int) -> Iterable[tuple[str, int, str, str]]:
    if isinstance(value, str):
        yield value, line_number, "json_content", "json value"
    elif isinstance(value, list):
        for item in value:
            yield from _walk_json_value(item, line_number)
    elif isinstance(value, dict):
        for key, item in value.items():
            if isinstance(key, str):
                yield key, line_number, "json_content", "json key"
            yield from _walk_json_value(item, line_number)


def _extract_yaml_content(path: Path) -> Iterable[tuple[str, int, str, str]]:
    for line_number, line in enumerate(path.read_text(encoding="utf-8", errors="ignore").splitlines(), 1):
        stripped = line.strip()
        if not stripped or stripped.startswith("#"):
            continue
        if stripped.startswith("- "):
            candidate = stripped[2:].strip()
        elif ":" in stripped:
            candidate = stripped.split(":", 1)[1].strip()
        else:
            candidate = stripped
        candidate = candidate.strip("'\"")
        yield candidate, line_number, "yaml_content", "yaml scalar heuristic"


def _extract_markdown_content(path: Path) -> Iterable[tuple[str, int, str, str]]:
    in_fence = False
    for line_number, line in enumerate(path.read_text(encoding="utf-8", errors="ignore").splitlines(), 1):
        stripped = line.strip()
        if stripped.startswith("```"):
            in_fence = not in_fence
            continue
        if in_fence or not stripped:
            continue
        candidate = re.sub(r"^#{1,6}\s*", "", stripped)
        candidate = re.sub(r"^[-*]\s+", "", candidate)
        candidate = re.sub(r"^\d+\.\s+", "", candidate)
        yield candidate, line_number, "markdown_content", "markdown prose"


def _dedupe_items(items: list[InventoryItem]) -> list[InventoryItem]:
    seen: set[tuple[str, str, int]] = set()
    unique: list[InventoryItem] = []
    for item in items:
        key = (item.file_path, item.text, item.line_number)
        if key in seen:
            continue
        seen.add(key)
        item.id = f"copy_{len(unique) + 1:06d}"
        unique.append(item)
    return unique


def _build_findings(items: list[InventoryItem]) -> list[Finding]:
    findings: list[Finding] = []
    for item in items:
        findings.extend(_item_findings(item))
    findings.extend(_duplicate_findings(items))
    for index, finding in enumerate(findings, 1):
        finding.id = f"finding_{index:06d}"
    return findings


def _item_findings(item: InventoryItem) -> list[Finding]:
    text = item.text
    lowered = text.lower()
    visibility = item.likely_visibility
    active = visibility in {
        "active_first_week_ui",
        "active_first_week_learning_content",
        "active_feedback_result",
    }
    result: list[Finding] = []

    if _has_cyrillic(text):
        if active:
            if "locale alternative" in item.notes:
                result.append(_finding(item, "cyrillic_in_active_english", "medium", "medium", "Russian/Cyrillic locale alternative exists in active source; verify it is not selected in English-first runtime."))
            else:
                result.append(_finding(item, "cyrillic_in_active_english", "high", "high", "Russian/Cyrillic copy appears in active English-target surface."))
        else:
            result.append(_finding(item, "dormant_copy_debt", "medium", "medium", "Cyrillic copy retained outside active first-week scope."))

    for term in FORBIDDEN_TERMS:
        if re.search(rf"\b{re.escape(term.lower())}\b", lowered):
            result.append(_finding(item, "forbidden_claim", "high" if active else "medium", "high" if active else "medium", f"Risky or deferred claim detected: {term}."))

    if any(term.lower() in lowered for term in INTERNAL_TERMS) and active:
        result.append(_finding(item, "visible_internal_jargon", "high", "medium", "Potential internal identifier/jargon may be visible."))

    if active and text in {"Start", "Continue", "Go", "Open", "Next"}:
        result.append(_finding(item, "cta_clarity", "medium", "medium", "Generic CTA may need contextual action text."))

    if active and len(text) > 118:
        result.append(_finding(item, "too_long_for_mobile", "medium", "high", "Long active UI string may be hard to scan on compact mobile."))
    elif item.likely_visibility == "active_first_week_learning_content" and len(text) > 180:
        result.append(_finding(item, "too_long_for_mobile", "medium", "medium", "Long learning content may be hard to scan on mobile."))

    if _awkward_english(text):
        result.append(_finding(item, "awkward_english", "medium" if active else "low", "medium", "Phrase reads awkwardly or mechanically."))

    if active and _surface_role_confusion(item.file_path, text):
        result.append(_finding(item, "role_boundary_confusion", "medium", "medium", "Copy may make this surface sound like another Act0 role."))

    if active and _term_inconsistency(text):
        result.append(_finding(item, "term_inconsistency", "medium", "medium", "Term may conflict with first-week English route language."))

    if item.likely_visibility == "active_first_week_learning_content":
        for term in POKER_TERMS:
            if re.search(rf"\b{re.escape(term)}\b", text, flags=re.IGNORECASE):
                result.append(_finding(item, "poker_term_unintroduced", "medium", "low", f"Potentially advanced term in beginner content: {term}."))
                break
        if _feedback_without_action(text):
            result.append(_finding(item, "feedback_not_actionable", "medium", "medium", "Feedback-like text may not clearly say what to do next."))
        if len(text.split()) > 22 and not re.search(r"\b(because|so|look|use|next|try|repair|means)\b", lowered):
            result.append(_finding(item, "learning_content_clarity", "medium", "low", "Learning copy may need clearer why/next-step framing."))

    if active and item.source_type == "dart_string" and item.file_path.endswith("act0_shell_preview_screen_v1.dart"):
        if len(text.split()) >= 2 and not _has_cyrillic(text):
            result.append(_finding(item, "copy_not_centralized", "low", "low", "Visible copy may be embedded in shell preview instead of a copy/content source."))

    return result


def _duplicate_findings(items: list[InventoryItem]) -> list[Finding]:
    by_normalized: dict[str, list[InventoryItem]] = defaultdict(list)
    for item in items:
        key = _normalize_duplicate_key(item.text)
        if key:
            by_normalized[key].append(item)
    findings: list[Finding] = []
    for group in by_normalized.values():
        active_group = [item for item in group if item.likely_visibility.startswith("active_")]
        if len(group) < 3 or not active_group:
            continue
        first = active_group[0]
        findings.append(
            _finding(
                first,
                "duplicate_or_near_duplicate",
                "low",
                "medium",
                f"Same or near-identical copy appears {len(group)} times; check whether it should be centralized.",
            )
        )
    return findings


def _finding(
    item: InventoryItem,
    category: str,
    severity: str,
    confidence: str,
    notes: str,
) -> Finding:
    return Finding(
        id="",
        item_id=item.id,
        category=category,
        severity=severity,
        confidence=confidence,
        text=item.text,
        file_path=item.file_path,
        line_number=item.line_number,
        likely_visibility=item.likely_visibility,
        notes=notes,
    )


def _summary(items: list[InventoryItem], findings: list[Finding]) -> dict[str, object]:
    return {
        "total_inventory_strings": len(items),
        "total_findings": len(findings),
        "counts_by_visibility": dict(Counter(item.likely_visibility for item in items)),
        "counts_by_source_type": dict(Counter(item.source_type for item in items)),
        "findings_by_category": dict(Counter(finding.category for finding in findings)),
        "findings_by_confidence": dict(Counter(finding.confidence for finding in findings)),
        "high_confidence_findings": sum(1 for finding in findings if finding.confidence == "high"),
    }


def _inventory_markdown(items: list[InventoryItem], summary: dict[str, object]) -> str:
    lines = [
        "# English Copy Inventory v1",
        "",
        f"- Total strings: {summary['total_inventory_strings']}",
        "",
        "## Counts by visibility",
        "",
    ]
    for key, value in sorted(summary["counts_by_visibility"].items()):  # type: ignore[index, union-attr]
        lines.append(f"- `{key}`: {value}")
    lines.extend(["", "## Inventory", ""])
    for item in items:
        lines.append(
            f"- `{item.id}` `{item.likely_visibility}` `{item.source_type}` "
            f"`{item.file_path}:{item.line_number}` — {item.text}"
        )
    return "\n".join(lines) + "\n"


def _findings_markdown(findings: list[Finding], summary: dict[str, object]) -> str:
    lines = [
        "# English Copy Findings v1",
        "",
        f"- Total findings: {summary['total_findings']}",
        "",
        "## Findings by category",
        "",
    ]
    for key, value in sorted(summary["findings_by_category"].items()):  # type: ignore[index, union-attr]
        lines.append(f"- `{key}`: {value}")
    lines.extend(["", "## High and medium confidence findings", ""])
    for finding in findings:
        if finding.confidence not in {"high", "medium"}:
            continue
        lines.append(
            f"- `{finding.category}` `{finding.severity}` `{finding.confidence}` "
            f"`{finding.file_path}:{finding.line_number}` — {finding.text} "
            f"({finding.notes})"
        )
    return "\n".join(lines) + "\n"


def _classify_visibility(path: Path, text: str, source_type: str) -> tuple[str, str, str]:
    posix = path.as_posix()
    name = path.name
    lower = posix.lower()
    if posix.startswith("test/"):
        if "act0_shell_preview" in lower or "preview" in lower:
            return "internal_dev_test", "medium", "test preview copy; may feed deterministic visible states"
        return "internal_dev_test", "high", "test-only copy"
    if "/archive/" in posix or "legacy" in lower:
        return "dormant_future_content", "high", "archive/legacy content"
    if posix.startswith("content/world1_act0") or "world1_act0" in lower:
        return "active_first_week_learning_content", "high", "world1 act0 content"
    if posix.startswith("assets/content/intro") or posix.startswith("assets/content/core"):
        return "active_first_week_learning_content", "medium", "intro/core content asset"
    if posix.startswith("assets/theory_lessons/level1"):
        return "active_first_week_learning_content", "medium", "level1 theory asset"
    if posix.startswith("lib/ui_v2/act0_shell/"):
        if name == "act0_lesson_runner_shell_v1.dart" or any(
            word in text.lower()
            for word in ("correct", "wrong", "repair", "receipt", "summary", "continue")
        ):
            return "active_feedback_result", "medium", "act0 runner/feedback surface"
        if name in ACTIVE_ACT0_FILES:
            return "active_first_week_ui", "high", "active act0 shell"
        return "active_first_week_ui", "medium", "act0 shell support"
    if posix.startswith("assets/") or posix.startswith("content/"):
        return "dormant_future_content", "medium", "content asset outside active first-week heuristic"
    if posix.startswith("docs/"):
        return "dormant_future_content", "low", "docs contract/reference inventory only"
    return "unknown", "low", "visibility unknown"


def _clean_text(text: str) -> str:
    text = text.encode("utf-8", "ignore").decode("utf-8", "ignore")
    text = text.replace("\\n", " ")
    text = re.sub(r"\s+", " ", text)
    return text.strip()


def _is_candidate_copy(text: str) -> bool:
    if len(text) < 3 or len(text) > 320:
        return False
    if not re.search(r"[A-Za-zА-Яа-я]", text):
        return False
    if re.fullmatch(r"[a-z0-9_./:-]+", text):
        return False
    if text.startswith(("package:", "asset:", "assets/", "lib/", "http://", "https://")):
        return False
    if re.fullmatch(r"[A-Z0-9_]+", text) and len(text) < 24:
        return False
    return True


def _decode_dart_string(body: str) -> str:
    return (
        body.replace(r"\n", " ")
        .replace(r"\r", " ")
        .replace(r"\t", " ")
        .replace(r"\'", "'")
        .replace(r'\"', '"')
        .replace(r"\\", "\\")
    )


def _line_offsets(text: str) -> list[int]:
    offsets = [0]
    for match in re.finditer("\n", text):
        offsets.append(match.end())
    return offsets


def _line_for_offset(offsets: list[int], offset: int) -> int:
    lo, hi = 0, len(offsets) - 1
    while lo <= hi:
        mid = (lo + hi) // 2
        if offsets[mid] <= offset:
            lo = mid + 1
        else:
            hi = mid - 1
    return hi + 1


def _has_cyrillic(text: str) -> bool:
    return bool(re.search(r"[А-Яа-яЁё]", text))


def _awkward_english(text: str) -> bool:
    lowered = text.lower()
    awkward_phrases = (
        "perfect opened",
        "mastered forever",
        "no old spots due",
        "fix this spot before it becomes a habit",
        "training today",
    )
    return any(phrase in lowered for phrase in awkward_phrases)


def _surface_role_confusion(file_path: str, text: str) -> bool:
    lowered = text.lower()
    if "act0_home" in file_path and any(term in lowered for term in ("repair coach", "mistake review", "profile growth")):
        return True
    if "act0_learn" in file_path and any(term in lowered for term in ("daily drill", "repair this clue", "review waiting")):
        return True
    if "act0_play" in file_path and any(term in lowered for term in ("learning path", "repair coach")):
        return True
    if "act0_review" in file_path and any(term in lowered for term in ("today's training", "learning path", "home")):
        return True
    if "act0_profile" in file_path and any(term in lowered for term in ("start daily set", "repair this clue")):
        return True
    return False


def _term_inconsistency(text: str) -> bool:
    lowered = text.lower()
    return "play" in lowered and "practice" not in lowered and any(
        word in lowered for word in ("tab", "surface", "entry", "route")
    )


def _feedback_without_action(text: str) -> bool:
    lowered = text.lower()
    if not any(word in lowered for word in ("correct", "wrong", "miss", "mistake", "good", "not quite")):
        return False
    return not any(word in lowered for word in ("because", "look", "use", "next", "try", "repair", "remember"))


def _normalize_duplicate_key(text: str) -> str:
    normalized = re.sub(r"[^a-z0-9а-я]+", " ", text.lower()).strip()
    if len(normalized) < 12:
        return ""
    return normalized


if __name__ == "__main__":
    raise SystemExit(main())
