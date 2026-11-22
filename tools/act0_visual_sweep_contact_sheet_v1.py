#!/usr/bin/env python3
"""Build a browsable contact sheet from the Act0 V3 widget-host capture."""
import argparse
from collections import Counter
from html import escape
import json
from pathlib import Path
import re
import struct


def screenshot(folder, file_name, caption):
    if not re.fullmatch(r"[\w-]+\.png", file_name):
        raise ValueError(f"Invalid PNG file name: {file_name!r}")
    with (folder / file_name).open("rb") as image:
        header = image.read(24)
    if header[:8] != b"\x89PNG\r\n\x1a\n" or struct.unpack(">II", header[16:]) != (393, 852):
        raise ValueError(f"Invalid V3 screenshot: {file_name}")
    return (
        f'<figure><a href="{file_name}"><img loading="lazy" src="{file_name}" '
        f'width="393" height="852" alt="{caption}"></a><figcaption>{caption}</figcaption></figure>'
    )


def write_sheet(folder, source):
    frames = {"decision": "Решение", "feedback": "Разбор", "teach-0": "Теория"}
    rows = sorted(
        (json.loads(path.read_text()) for path in folder.glob("*-w*-*.json")),
        key=lambda row: (row["world"], row["route"], row["lesson"], row["task"]),
    )
    if not rows:
        raise ValueError(f"No widget capture records in {folder}")

    worlds = sorted({row["world"] for row in rows})
    counts = Counter(row["world"] for row in rows)
    numbers = {
        "tasks": len(rows),
        "frames": sum(row["checkedTableFrames"] for row in rows),
        "screenshots": sum(len(row["files"]) for row in rows),
        "flagged": sum(bool(row["issues"]) for row in rows),
        "day7": sum(row["route"] == "day7" for row in rows),
    }
    with (folder / "index.html").open("w", encoding="utf-8") as html:
        html.write("""<!doctype html>
<html lang="ru"><meta charset="utf-8"><meta name="viewport" content="width=device-width">
<title>Sharky · Столы Act0</title>
<style>
body{font:16px system-ui;background:#10161e;color:#e5edf5;max-width:1200px;margin:auto;padding:1.5rem}
a{color:#9cddff} nav{display:flex;gap:1rem;flex-wrap:wrap} code{overflow-wrap:anywhere}
section{margin-top:2.5rem} article{border-top:1px solid #475361;padding:1rem 0}
h3{margin:0} .frames{display:flex;gap:1rem;flex-wrap:wrap;margin-top:.8rem}
figure{margin:0;width:min(260px,100%)} img{display:block;width:100%;height:auto}
figcaption{padding:.3rem 0} summary{color:#ffd69a;cursor:pointer}
</style>
<h1>Sharky · Столы Act0</h1>
""")
        html.write(f"<p>Источник <code>{escape(source)}</code>. Flutter widget host, "
                   "393×852, English, Roboto. PNG при 1×. "
                   "Геометрия проверяется при 1× и 1,3×.</p>")
        html.write(f'<p>{numbers["tasks"]} заданий, включая {numbers["day7"]} Day 7. '
                   f'{numbers["screenshots"]} PNG. {numbers["frames"]} проверенных '
                   f'кадров со столом. {numbers["flagged"]} заданий с сигналами.</p>')
        html.write("<nav>" + " ".join(f'<a href="#w{world}">W{world} ({counts[world]})</a>'
                                      for world in worlds) + "</nav>")
        for world in worlds:
            html.write(f'<section id="w{world}"><h2>W{world}</h2>')
            for row in (row for row in rows if row["world"] == world):
                route = "Day 7" if row["route"] == "day7" else "Курс"
                issues = row["issues"]
                labels = [route, escape(row["lesson"]), escape(row["street"])]
                if row["boardCards"] == 5:
                    labels.append("пять карт")
                if row["bets"]:
                    labels.append(f'{row["bets"]} ставки')
                if row["trail"]:
                    labels.append(f'{row["trail"]} действий')
                if row["allIn"]:
                    labels.append("all-in")
                if row.get("sidePot"):
                    labels.append("side pot")
                html.write(f'<article id="{escape(row["route"] + "-" + row["task"])}">'
                           f'<h3>{escape(row["title"])}</h3>'
                           f'<code>{escape(row["task"])}</code><p>{" · ".join(labels)}</p>')
                if issues:
                    html.write("<details><summary>Геометрия и рендеринг</summary><ul>"
                               + "".join(f"<li>{escape(issue)}</li>" for issue in issues)
                               + "</ul></details>")
                html.write('<div class="frames">' + "".join(
                    screenshot(folder, file_name, frames[frame])
                    for frame, file_name in row["files"].items()
                ) + "</div></article>")
            html.write("</section>")
    print(json.dumps({"worlds": counts, **numbers}, sort_keys=True))


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("folder", type=Path)
    parser.add_argument("--source", required=True)
    args = parser.parse_args()
    write_sheet(args.folder, args.source)
