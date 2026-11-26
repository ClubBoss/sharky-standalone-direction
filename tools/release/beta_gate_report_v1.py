#!/usr/bin/env python3
"""Generate the owner beta gate from PLAN's pre-beta block table.

Run from the repository root: python3 tools/release/beta_gate_report_v1.py
Exit 1 means an active agent-class block needs attention, not a build failure.
"""
import argparse
from dataclasses import dataclass
import os
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "tools"))
from plan_dashboard_v1 import PLAN, blocks, name, table

HEADER = "| Блок | Результат (DoD) | Roadmap | Кто | Оценка | Статус |"
OUT = ROOT / "docs/release/BETA_GATE_v1.md"
DAY = "docs/release/OWNER_DEVICE_DAY_v1.md"
RELEASE = "docs/RELEASE.md"
V9 = "docs/release/V9_CHECKLIST_v1.md"
QUIET = "docs/release/quiet_test/OWNER_RUN_v1.md"


@dataclass(frozen=True)
class Prep:
    owner: str
    blocker: str
    docs: tuple = ()
    command: str = ""
    # Documented minute estimates only; each expression selects an individual
    # prep step, not the overlapping overall owner-day budget.
    timings: tuple = ()
    timing_note: str = ""


# (file, regex with one or two minute groups, multiplier, time window).
# No inference from PLAN's day estimates or a performance target.
def timing(doc, pattern, count=(1, 1), *, window=False):
    return doc, pattern, count, window


PREP = {
    "A8": Prep("owner", "Подписанный RC после O4; замеры и переустановка на iPhone",
               (DAY, "docs/release/SIGNING_CHECKLIST_v1.md", RELEASE),
               "tools/release/ios_release_dryrun_v1.sh && python3 tools/release/owner_day_preflight_v1.py",
               (timing(DAY, r"Before signing \(~(\d+)–(\d+) min\)"),
                timing(DAY, r"1\. Sign · (\d+)–(\d+) min")),
               "dry run + подпись"),
    "L0": Prep("agent", "Сверить незакрытый статус карты L0 и B76",
               ("docs/_reviews/b76_l01_c5_w1w4_exceptions_v1.md",)),
    "Q3": Prep("iPhone", "F1: замер запуска и первого вопроса на устройстве",
               (RELEASE,), "python3 tools/measure_w1_startup_v1.py <device-id>"),
    "Q14": Prep("agent", "Сверить статус Q14 в PLAN: запись о закрытии внутри строки не закрывает блок",
                ("docs/_reviews/b77_q142_w1w12_gap_audit_v1.md",)),
    "V6": Prep("visual", "Финальный скин, проверка экранов и нативная читаемость",
               ("docs/release/DESIGNER_PACK_v1.md", "docs/plan/SKIN_LAYER_v1.md"),
               "./tools/capture_act0_screens_v1.sh all compact; "
               "./tools/capture_act0_screens_v1.sh v9 walkthrough; python3 tools/designer_pack_v1.py"),
    "V7": Prep("visual", "Арт, права, иконка, launch screen, подключение и нативная проверка",
               ("assets/skin_v1/README.md",),
               "flutter test test/ui_v2/act0_skin_asset_slots_v1_test.dart"),
    "V9": Prep("iPhone", "Полный захват и проверка финального скина на физическом iPhone",
               (V9, DAY), "./tools/capture_act0_screens_v1.sh v9 walkthrough",
               (timing(V9, r"final build \(~(\d+) minutes\)"),), "на телефоне"),
    "O1": Prep("owner", "Установить подписанную сборку и лично пройти W1",
               (DAY, RELEASE), "open ios/Runner.xcworkspace",
               (timing(DAY, r"2\. Install · (\d+)–(\d+) min"),), "только установка"),
    "O2": Prep("owner", "Тихий тест и F1M после разрешения владельца",
               (QUIET, DAY),
               "python3 tools/f1m_report_v1.py --observations <private-observations.csv>",
               (timing(DAY, r"(\d+) min setup"),
                timing(QUIET, r"(\d+)–(\d+) minutes each", (3, 5))),
               "setup + 3–5 участников"),
    "O4": Prep("owner", "Решение о переустановке, Apple Developer и доступы",
               ("docs/release/SIGNING_CHECKLIST_v1.md", RELEASE), "open ios/Runner.xcworkspace"),
    "Бета": Prep("owner", "Внешний TestFlight: метаданные, upload и Beta App Review после ворот и O4",
                 (RELEASE, "docs/release/drafts/APP_STORE_TEXT_v1.md",
                  "docs/release/drafts/PRIVACY_POLICY_DRAFT_v1.md",
                  "docs/release/drafts/SUPPORT_PAGE_DRAFT_v1.md",
                  "docs/release/drafts/REVIEW_NOTES_v1.md",
                  "docs/release/drafts/HALT_ROLLBACK_RUNBOOK_v1.md"),
                 "open build/ios/archive/Runner.xcarchive",
                 (timing(RELEASE, r"5\. \*\*ждёт O4\*\* · (\d+)–(\d+) мин", window=True),
                  timing(RELEASE, r"7\. \*\*ждёт O4\*\* · (\d+)–(\d+) мин", window=True)),
                 "метаданные + upload; не ожидание Apple"),
}


def minutes(prep):
    if not prep.timings:
        return None
    low = high = 0
    for doc, pattern, (n_low, n_high), window in prep.timings:
        path = ROOT / doc
        if not path.is_file():
            return None
        match = re.search(pattern, path.read_text(encoding="utf-8"))
        if not match:
            return None
        start = int(match[1])
        end = int(match[2]) if len(match.groups()) == 2 else start
        if window:
            start = end = end - start
        low += start * n_low
        high += end * n_high
    return low, high


def interval(value):
    if value is None:
        return "—"
    lo, hi = value
    return str(lo) if lo == hi else f"{lo}–{hi}"


def cell(value):
    return value.replace("|", r"\|").replace("\n", " ")


def link(doc, out):
    return f"[{Path(doc).name}]({os.path.relpath(ROOT / doc, out.parent)})"


def render(lines, out):
    # The dashboard defines which table is pre-beta, which statuses count as
    # done (leading ✅), and which estimates are deferred. Use it unchanged.
    parsed = blocks(lines)
    statuses = {name(c[0]): c[5] for c in table(lines, HEADER) if len(c) == 6 and c[1]}
    rows = []
    deferred = []
    agent = []
    missing = 0
    total_low = total_high = 0
    for item, block in parsed.items():
        if block["done"]:
            continue
        prep = PREP.get(item, Prep("agent", statuses[item] or "Статус не указан"))
        estimate = minutes(prep)
        status = "отложено" if block["skip"] else "открыто"
        blocker = f"{prep.owner} · {status}: {prep.blocker}"
        command = f"`{prep.command}`" if prep.command else "no prep yet"
        if prep.docs:
            command += "<br>" + " · ".join(link(doc, out) for doc in prep.docs)
        duration = interval(estimate)
        if estimate and prep.timing_note:
            duration += f" ({prep.timing_note})"
        row = "| " + " | ".join(map(cell, (item, blocker, command, duration))) + " |"
        if block["skip"]:
            deferred.append(row)
            continue
        rows.append(row)
        if prep.owner == "agent":
            agent.append(item)
        if estimate is None:
            missing += 1
        else:
            total_low += estimate[0]
            total_high += estimate[1]

    header = ["| Пункт | Блокер / кто | Подготовка / команда | Оценка, мин |",
              "|---|---|---|---|"]
    report = [
        "# Beta gate · остаток к бете", "",
        "Пересчитать из PLAN: `python3 tools/release/beta_gate_report_v1.py`.",
        "Команды — из корня репозитория; замените параметры в `<...>` своими значениями. Отчёт ничего не запускает и не закрывает.",
        f"Открыто: **{len(rows)}** · agent: **{len(agent)}** · отложено: **{len(deferred)}**.",
        "", *header, *rows,
        f"| **Итого (известное время)** | {missing} без оценки | "
        f"Без ожиданий Apple, дизайна и неоценённых проверок | **{interval((total_low, total_high)) if len(rows) > missing else '—'}** |",
        "",
        "Оценки — только указанные в подготовительных документах этапы, не полный срок до беты. "
        "Подписание и установка считаются отдельно; общий бюджет owner day не прибавляется повторно.",
    ]
    if deferred:
        report += ["", "## Отложено владельцем (не входит в итог)", "", *header, *deferred]
    report += [
        "", "## Перед днём на устройстве", "",
        f"Единый порядок: {link(DAY, out)}. Дополнительный GRO-прогон: "
        f"{link('docs/release/GRO_PHONE_CHECKLIST_v1.md', out)} "
        "(B113, 1.5, не отдельный блок беты; в итог не включён).",
        "", "Agent: " + (", ".join(agent) + " — требуется сверка/работа агента (exit 1)."
                        if agent else "открытых блоков нет (exit 0)."),
        "",
    ]
    return "\n".join(report), bool(agent)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--plan", type=Path, default=PLAN)
    parser.add_argument("--out", type=Path, default=OUT)
    args = parser.parse_args()
    report, has_agent = render(args.plan.read_text(encoding="utf-8").splitlines(), args.out.resolve())
    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text(report, encoding="utf-8")
    print(f"Wrote {args.out}")
    return int(has_agent)


if __name__ == "__main__":
    raise SystemExit(main())
