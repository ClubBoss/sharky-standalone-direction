#!/usr/bin/env python3
"""Rebuild the dashboard at the top of docs/PLAN.md from the plan's own tables.

Run after changing a block's status or estimate:
    python3 tools/plan_dashboard_v1.py          # rewrite the dashboard
    python3 tools/plan_dashboard_v1.py --check  # exit 1 if it is stale (CI)

Inputs, all in docs/PLAN.md:
- The block table ("| Блок | Результат (DoD) | Roadmap | Кто | Оценка | Статус |").
  A block is done when its status starts with ✅. The estimate cell is one of:
  "—" (nothing left), "отложено" (not counted), "2д" (agent days),
  "влад. 1д" (owner days), optionally followed by "← V2, O5" (blocks it waits for).
- The post-beta table ("| Этап | Результат | ID из Roadmap 2.0 | Оценка |") with
  rough estimates "~5д", or "в бете" / "—" for nothing left.
"""
import pathlib
import re
import sys

PLAN = pathlib.Path(__file__).resolve().parents[1] / "docs/PLAN.md"
AGENTS = 2  # agents working in parallel; change when the team changes
START = "<!-- plan-dashboard:start · генерирует tools/plan_dashboard_v1.py, руками не править -->"
END = "<!-- plan-dashboard:end -->"
EST = re.compile(r"^(влад\.\s*)?~?(\d+(?:[.,]\d+)?)\s*д(?:\s*←\s*(.+))?$")
BETA = "Бета"


def cells(line):
    return [c.strip() for c in line.strip().strip("|").split("|")]


def table(lines, header_prefix):
    rows, inside = [], False
    for line in lines:
        if line.startswith(header_prefix):
            inside = True
            continue
        if inside:
            if not line.startswith("|"):
                break
            if not line.startswith("|---"):
                rows.append(cells(line))
    if not inside:
        sys.exit(f"table not found: {header_prefix}")
    return rows


def name(cell):
    return cell.replace("*", "").strip()


def days(x):
    s = f"{x:.1f}".replace(".", ",")
    return s[:-2] if s.endswith(",0") else s


def blocks(lines):
    out = {}
    for c in table(lines, "| Блок | Результат (DoD) | Roadmap | Кто | Оценка | Статус |"):
        if len(c) != 6 or not c[1]:
            continue  # section heading row
        block, _, _, who, est, status = c
        b = {"id": name(block), "done": status.startswith("✅"), "owner": False,
             "days": 0.0, "deps": [], "skip": est == "отложено"}
        m = EST.match(est)
        if m:
            b["owner"] = bool(m.group(1))
            b["days"] = float(m.group(2).replace(",", "."))
            b["deps"] = [d.strip() for d in (m.group(3) or "").split(",") if d.strip()]
        elif not b["done"] and est not in ("—", "отложено"):
            sys.exit(f"{b['id']}: unreadable estimate {est!r}")
        out[b["id"]] = b
    return out


def chain(bs, target):
    memo = {}

    def walk(i):
        if i not in memo:
            b = bs.get(i)
            if b is None or b["done"] or b["skip"]:
                memo[i] = (0.0, [])
            else:
                best = max((walk(d) for d in b["deps"]), default=(0.0, []), key=lambda t: t[0])
                memo[i] = (best[0] + b["days"], best[1] + [i])
        return memo[i]

    return walk(target)


def render(lines):
    bs = blocks(lines)
    open_ = [b for b in bs.values() if not b["done"] and not b["skip"]]
    agent = sum(b["days"] for b in open_ if not b["owner"])
    owner = [b for b in open_ if b["owner"]]
    length, path = chain(bs, BETA)
    beta_cal = max(length, agent / AGENTS)
    rows = [
        "| До вехи | Осталось | Работа агентов | Ждёт владельца | Срок, рабочих дней |",
        "|---|---|---|---|---|",
        f"| **Бета** | открыто {len(open_)} из {len(bs)} | {days(agent)} дн. | "
        f"{', '.join(b['id'] for b in owner) or '—'} (~{days(sum(b['days'] for b in owner))} дн.) | "
        f"**≈ {days(beta_cal)}** · цепочка {' → '.join(path)} = {days(length)} дн. |",
    ]
    total_agent, cal = agent, beta_cal
    for c in table(lines, "| Этап | Результат | ID из Roadmap 2.0 | Оценка |"):
        if len(c) != 4:
            continue
        m = EST.match(c[3])
        d = float(m.group(2).replace(",", ".")) if m else 0.0
        total_agent += d
        cal += d / AGENTS
        left = f"~{days(d)} дн." if d else c[3]
        rows.append(f"| **{name(c[0])}** | {left} | {days(total_agent)} дн. с начала | — | **≈ {days(cal)}** |")
    note = (f"Оценки — дни работы агента (блок ≈ 1 день), точность ±50 %. Срок = большее из двух: "
            f"самая длинная цепочка зависимостей или вся работа ÷ {AGENTS} агента. "
            "После беты — грубо, по этапам; порядок 1.1–1.9 пересматривается по данным беты.")
    return [START, "## Панель", "", *rows, "", note, END]


def main():
    text = PLAN.read_text()
    lines = text.splitlines()
    fresh = render(lines)
    if START in text:
        a = next(i for i, l in enumerate(lines) if l.startswith("<!-- plan-dashboard:start"))
        b = lines.index(END)
        new = lines[:a] + fresh + lines[b + 1:]
    else:
        at = next(i for i, l in enumerate(lines) if l.startswith("## Сейчас"))
        new = lines[:at] + fresh + [""] + lines[at:]
    out = "\n".join(new) + "\n"
    if "--check" in sys.argv:
        if out != text:
            print("docs/PLAN.md dashboard is stale: run python3 tools/plan_dashboard_v1.py")
            return 1
        print("plan dashboard is current")
        return 0
    PLAN.write_text(out)
    print("\n".join(fresh[3:-3]))
    return 0


if __name__ == "__main__":
    sys.exit(main())
