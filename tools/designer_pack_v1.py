#!/usr/bin/env python3
"""Render the local Act0 capture outputs and designer component inventory."""

import argparse
import html
import json
import os
from pathlib import Path
import subprocess
from urllib.parse import quote

ROOT = Path(__file__).resolve().parents[1]
COMPACT_SURFACES = ("home", "learn", "practice", "review", "profile")
# B100's per-world minimum, independent of row.json so a truncated row cannot
# silently remove an expected screen. Other variants come from the row itself.
V9_REQUIRED = ("lesson_start", "wrong_feedback", "repair", "result", "final_result")
PNG_SIGNATURE = b"\x89PNG\r\n\x1a\n"


def esc(value):
    return html.escape(str(value))


def inventory_path():
    for base in (ROOT / "docs", ROOT / "reasoning/design_brief",
                 ROOT.parent / "l0-audit/reasoning/design_brief"):
        matches = sorted(base.rglob("COMPONENT_INVENTORY*.md"))
        if matches:
            return matches[0]
    return None


def read_json(path, issues):
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
        if not isinstance(data, dict):
            raise ValueError("expected JSON object")
        return data
    except (OSError, ValueError) as error:
        issues.append(f"Missing or invalid capture manifest: {path} ({error})")
        return {}


def png_names(value, source, issues):
    """Only accept filenames, never arbitrary paths from a capture manifest."""
    if not isinstance(value, list):
        issues.append(f"Invalid screen list: {source}")
        return set()
    names = set()
    for name in value:
        if (not isinstance(name, str) or Path(name).name != name
                or not name.endswith(".png")):
            issues.append(f"Invalid PNG name in {source}: {name}")
        else:
            names.add(name)
    return names


def valid_png(path):
    try:
        with path.open("rb") as stream:
            return stream.read(8) == PNG_SIGNATURE and path.stat().st_size > 8
    except OSError:
        return False


def state_label(name):
    stem = Path(name).stem
    if stem.startswith("compact."):
        return stem.removeprefix("compact.").replace("_", " ").title() + " — compact tab"
    if stem == "welcome":
        return "Welcome — W1 start chooser (not full demo)"
    return stem.replace("_", " ").title()


def capture_grid(folder, required, declared, output, issues):
    # Include on-disk variants even when a capture stopped before saving its row.
    actual = {path.name for path in folder.glob("*.png")}
    cards = []
    for name in sorted(required | declared | actual):
        path = folder / name
        label = state_label(name)
        if not valid_png(path):
            issues.append(f"Missing or invalid screen: {path}")
            body = '<div class="missing">MISSING / INVALID PNG</div>'
        else:
            relative = quote(os.path.relpath(path, output).replace(os.sep, "/"))
            body = (f'<a href="{esc(relative)}"><img loading="lazy" '
                    f'src="{esc(relative)}" alt="{esc(label)}"></a>')
            if name not in declared:
                issues.append(f"Screen not listed in capture manifest: {path}")
                body += '<p class="warning">Unlisted capture — provenance unverified</p>'
        cards.append(f'<article><h3>{esc(label)}</h3><code>{esc(name)}</code>{body}</article>')
    return '<div class="grid">' + "\n".join(cards) + '</div>'


def markdown_tables(path):
    """Read pipe tables grouped by the source's headings, preserving all cells."""
    heading = path.stem
    rows = []
    for line in path.read_text(encoding="utf-8").splitlines() + [""]:
        if line.strip().startswith("|") and line.strip().endswith("|"):
            cells = [cell.strip() for cell in line.strip().strip("|").split("|")]
            if not all(cell and set(cell) <= set("-: ") for cell in cells):
                rows.append(cells)
        else:
            if rows:
                yield heading, rows
                rows = []
            if line.startswith("## "):
                heading = line[3:].strip()


def render_tables(tables):
    sections = []
    for heading, rows in tables:
        table = ['<table><thead><tr>' + ''.join(f'<th>{esc(cell)}</th>' for cell in rows[0]) + '</tr></thead><tbody>']
        table.extend('<tr>' + ''.join(f'<td>{esc(cell)}</td>' for cell in row) + '</tr>' for row in rows[1:])
        sections.append(f'<h3>{esc(heading)}</h3>' + ''.join(table) + '</tbody></table>')
    return '\n'.join(sections)


def render(compact_dir, v9_dir, inventory, output, last_world=12, screen_logic=None,
           checkout_commit=None):
    issues = []
    compact = read_json(compact_dir / "manifest.json", issues)
    if checkout_commit and compact and compact.get("git_commit") != checkout_commit:
        issues.append(f"Compact capture commit {compact.get('git_commit', 'unknown')} "
                      f"does not match checkout {checkout_commit}; refresh captures.")
    # Compact manifests use repo-relative paths; only their basenames belong to
    # this capture directory. The five tabs are always expected for a full pack.
    files = compact.get("output_files", [])
    if not isinstance(files, list) or not all(isinstance(name, str) for name in files):
        issues.append("Invalid compact output_files list")
        files = []
    compact_names = png_names([Path(name).name for name in files], compact_dir, issues)
    compact_grid = capture_grid(compact_dir, {f"compact.{s}.png" for s in COMPACT_SURFACES},
                                compact_names, output, issues)
    provenance = "; ".join(f"{key}: {compact.get(key, 'unknown')}" for key in
                           ("git_commit", "git_status", "captured_at", "device", "simulator"))
    worlds = []
    for world in range(1, last_world + 1):
        folder = v9_dir / f"w{world:02d}"
        row_path = folder / "row.json"
        row = read_json(row_path, issues)
        declared = png_names(row.get("screens", []), row_path, issues)
        if row and (row.get("world") != world or row.get("wrong_answer_repair") != "ok"
                    or row.get("overflow_errors") != [] or row.get("exceptions") != []):
            issues.append(f"Incomplete or failed walkthrough: {row_path}")
        grid = capture_grid(folder, {f"{s}.png" for s in V9_REQUIRED}, declared, output, issues)
        worlds.append(f'<h3>W{world:02d} · widget walkthrough</h3>{grid}')

    try:
        tables = list(markdown_tables(inventory)) if inventory else []
        if not any(rows[0][0].lower() == "component" and len(rows) > 1 for _, rows in tables):
            raise ValueError("no Component table with data rows found")
        legend = next((line for line in inventory.read_text(encoding="utf-8").splitlines()
                       if line.startswith("Screens:")), "")
        components = (f'<p>Source: {esc(inventory)}</p><p>{esc(legend)}</p>'
                      + render_tables(tables))
    except (OSError, ValueError) as error:
        issues.append(f"Missing or invalid COMPONENT_INVENTORY: {inventory} ({error})")
        components = '<p class="missing">Component inventory unavailable.</p>'

    known_states = ''
    if screen_logic and screen_logic.is_file():
        states = [(heading, rows) for heading, rows in markdown_tables(screen_logic)
                  if rows[0][0] in ("State", "Vision state")]
        known_states = (f'<p>Source: {esc(screen_logic)}. These are documented state contracts, '
                        'not screenshot coverage claims.</p>' + render_tables(states))
    summary = ('<ul>' + ''.join(f'<li>{esc(issue)}</li>' for issue in issues) + '</ul>'
               if issues else '<p>All expected and manifest-listed PNGs found.</p>')
    output.mkdir(parents=True, exist_ok=True)
    (output / "index.html").write_text(f'''<!doctype html>
<html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Sharky designer pack v1</title><style>
*{{box-sizing:border-box}}body{{font:16px system-ui,sans-serif;max-width:1500px;margin:auto;padding:24px;color:#20252b;background:#f5f6f8}}
.grid{{display:grid;grid-template-columns:repeat(auto-fill,minmax(210px,1fr));gap:16px}}
article{{background:white;border:1px solid #d9dde3;padding:12px;border-radius:8px;overflow-wrap:anywhere}}article h3{{font-size:16px;margin:0 0 6px}}img{{width:100%;height:auto;display:block;margin-top:8px}}code{{font-size:12px}}
.missing,.warning{{color:#9b251c;background:#fff0ed;padding:12px;margin-top:8px}}table{{width:100%;border-collapse:collapse;background:white;margin-bottom:20px}}td,th{{border:1px solid #d9dde3;padding:8px;text-align:left;vertical-align:top}}th{{background:#e6e9ee}}li{{overflow-wrap:anywhere}}
</style></head><body><h1>Sharky designer pack v1</h1>
<p>Local captures only. Refresh both capture lanes against the target checkout before generating. B100 widget rows do not record a commit SHA; freshness is not certified.</p>
<p>Checkout commit: {esc(checkout_commit or 'unknown')}</p>
<nav><a href="#issues">Missing captures</a> · <a href="#tabs">Tabs</a> · <a href="#walkthrough">Walkthrough</a> · <a href="#states">State contracts</a> · <a href="#components">Components</a></nav>
<h2 id="issues">Capture issues ({len(issues)})</h2>{summary}
<h2 id="tabs">Compact tab screenshots</h2><p>{esc(provenance)}</p>{compact_grid}
<h2 id="walkthrough">W1–W{last_world} learner walkthrough</h2>
<p>Widget-rendered sample per observed state/family, W2+ seeded prerequisites. Not device acceptance.</p>{''.join(worlds)}
<h2 id="states">State contracts and coverage gaps</h2>
<p>B100 and compact capture do not guarantee every learner state. Uncaptured or unproven variants include full Welcome demo, Placement, Settings, Archive / Replay, Own hands, recovery/error, empty/locked/done tab variants, Help, sheets, component interaction states and accessibility/platform variants. A missing manifest or PNG is flagged above; absence from the manifest does not prove a state is unreachable.</p>{known_states}
<h2 id="components">Component inventory (designer contract, not runtime proof)</h2>{components}
</body></html>\n''', encoding="utf-8")
    return not issues


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--compact-dir", type=Path, default=ROOT / "output/screen_review/current")
    parser.add_argument("--v9-dir", type=Path, default=ROOT / "build/v9")
    parser.add_argument("--inventory", type=Path, default=None)
    parser.add_argument("--output-dir", type=Path, default=ROOT / "build/designer_pack")
    parser.add_argument("--last-world", type=int, choices=range(1, 13), default=12,
                        help="Only for an explicitly scoped walkthrough (default: all 12 worlds).")
    args = parser.parse_args()
    try:
        checkout_commit = subprocess.check_output(
            ["git", "rev-parse", "HEAD"], cwd=ROOT, stderr=subprocess.DEVNULL,
            text=True).strip()
    except (OSError, subprocess.CalledProcessError):
        checkout_commit = None
    passed = render(args.compact_dir, args.v9_dir, args.inventory or inventory_path(),
                    args.output_dir, args.last_world, ROOT / "docs/plan/SCREEN_LOGIC_INVENTORY_v1.md",
                    checkout_commit)
    print(f"{args.output_dir / 'index.html'} — {'capture inputs present' if passed else 'capture issues; see HTML'}")
    return 0 if passed else 1


if __name__ == "__main__":
    raise SystemExit(main())
