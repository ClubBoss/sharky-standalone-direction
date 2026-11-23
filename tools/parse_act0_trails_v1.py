#!/usr/bin/env python3
"""Read-only syntax dry run. Text matches do not establish hand completeness."""

import argparse
from collections import Counter
from pathlib import Path
import re

SOURCE = Path(__file__).resolve().parents[1] / "lib/ui_v2/act0_shell"
COURSE = (
    *(f"act0_shell_runners_part{n}_v1.dart" for n in range(1, 5)),
    *(f"act0_shell_lessons_w{span}_v1.dart" for span in ("1_w4", "5_w8", "9_w12")),
    "act0_shell_state_v1.dart",
    "act0_y5d_lesson_tasks_v1.dart",
)
DAY7 = ("act0_shell_day7_content_v1.dart", "act0_shell_day7_review_v1.dart",
        "act0_shell_review_tasks_v1.dart")

# Match consecutive Dart string tokens, including multiline argument wrapping.
TOKEN = r"""(?:r?'(?:[^'\\\n]|\\.)*'|r?"(?:[^"\\\n]|\\.)*")"""
CALL = re.compile(
    rf"\bAct0ActionTrailItemV1(?P<note>\.note)?\(\s*label:\s*"
    rf"(?P<label>(?:{TOKEN}\s*)+)?"
)
STREET = r"preflop|flop|turn|river"
SEAT = r"UTG(?:\+[12])?|LJ|HJ|CO|BTN|SB|BB|MP|Hero"
CHIPS = r"(?P<amount>\d+(?:\.\d+)?) BB"
POST = re.compile(rf"(?P<seat>SB|BB) (?P<verb>blind|posts(?: (?:small|big) blind)?) {CHIPS}", re.I)
PASSIVE = re.compile(rf"(?P<seat>{SEAT}) (?P<verb>folds?|checks?)", re.I)
WAGER = re.compile(
    rf"(?P<seat>{SEAT}) (?P<verb>calls?|bets?|raises?|opens?|all[- ]in|jams?|shoves?)"
    rf"(?P<to> to)? {CHIPS}(?P<suffix> more| total)?", re.I
)
DEAL = re.compile(rf"(?P<street>{STREET}) (?:is )?dealt", re.I)
ACTOR = re.compile(rf"(?P<seat>{SEAT}) acts", re.I)
ANTE = re.compile(rf"(?P<seat>{SEAT}) (?:posts )?ante {CHIPS}", re.I)


def parse_label(label, hero_seat=None):
    """Parse street/seat/verb and amount meaning, keeping ambiguous amounts out."""
    label = label.strip()
    if deal := DEAL.fullmatch(label):
        return {"street": deal["street"].lower(), "verb": "deal"}, None
    prefix = re.match(rf"^({STREET}):\s*", label, re.I)
    street = prefix[1].lower() if prefix else None
    if prefix:
        label = label[prefix.end():]
    if re.match(r"^Hero\b", label, re.I):
        if hero_seat is None:
            return None, "Hero alias needs seat context"
        label = re.sub(r"^Hero\b", hero_seat, label, flags=re.I)
    if match := ACTOR.fullmatch(label):
        return {"street": street, "seat": match["seat"].lower(), "verb": "decision"}, None
    if match := ANTE.fullmatch(label):
        return {
            "street": street, "seat": match["seat"].lower(), "verb": "ante",
            "amount": match["amount"], "amount_kind": "added",
        }, None
    if match := POST.fullmatch(label):
        return {
            "street": street, "seat": match["seat"].lower(), "verb": "blind",
            "amount": match["amount"], "amount_kind": "added",
        }, None
    if match := PASSIVE.fullmatch(label):
        return {
            "street": street, "seat": match["seat"].lower(),
            "verb": match["verb"].lower().rstrip("s"),
        }, None
    if match := WAGER.fullmatch(re.sub(r"(calls?), ", r"\1 ", label, flags=re.I)):
        verb = match["verb"].lower().rstrip("s")
        verb = {"open": "raise", "jam": "all-in", "shove": "all-in",
                "all in": "all-in"}.get(verb, verb)
        suffix = match["suffix"]
        if suffix and suffix.lower() == " more":
            if verb != "call" or match["to"]:
                return None, "ambiguous incremental amount"
            amount_kind = "added"
        else:
            # Source call labels use a street total unless explicitly "more".
            amount_kind = "street_total"
        return {
            "street": street, "seat": match["seat"].lower(), "verb": verb,
            "amount": match["amount"], "amount_kind": amount_kind,
        }, None
    if re.search(r"\bside(?: pot)?\b|\bcontributes\b|, then |\bpost is included\b", label, re.I):
        return None, "compound action or pot annotation"
    if re.search(r"\bante\b", label, re.I):
        return None, "ante or forced-post note"
    if re.search(r"\bacts?\b|\b(?:decision|action) (?:is|returns)\b", label, re.I):
        return None, "actor/decision cue"
    if re.search(r"\braises? by\b", label, re.I):
        return None, "unsupported incremental wording"
    if re.search(r"\bdealt\b|\b(?:flop|turn|river)\b.*\b(?:comes|shows)\b", label, re.I):
        return None, "unsupported deal wording"
    return None, "other prose or unsupported action"


def scan(paths, verbose):
    parsed = Counter()
    failures = Counter()
    dynamic = notes = 0
    examples = {}
    for name in paths:
        text = (SOURCE / name).read_text()
        for match in CALL.finditer(text):
            raw = match["label"]
            if raw is None or (not raw.startswith("r") and re.search(r"(?<!\\)\$", raw)):
                dynamic += 1
                continue
            label = "".join(
                re.sub(r"""\\(['"\\])""", r"\1", token.lstrip("r")[1:-1])
                for token in re.findall(TOKEN, raw)
            )
            notes += bool(match["note"])
            event, reason = parse_label(label)
            if event is not None:
                parsed[event["verb"]] += 1
                continue
            failures[reason] += 1
            line = text.count("\n", 0, match.start()) + 1
            location = f"{name}:{line} {label}"
            examples.setdefault(reason, location)
            if verbose:
                print(f"  {reason}: {location}")
    good = sum(parsed.values())
    total = good + sum(failures.values())
    print(f"{good}/{total} static labels parsed ({100 * good / total:.1f}%), "
          f"{notes} note literals, {dynamic} dynamic calls excluded")
    print("  parsed:", ", ".join(f"{name} {n}" for name, n in parsed.most_common()))
    for reason, count in failures.most_common():
        print(f"  {count} {reason} — {examples[reason]}")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--verbose", action="store_true", help="list every unparsed literal")
    args = parser.parse_args()
    for name, paths in (("W1–W12", COURSE), ("Day 7", DAY7)):
        print(name)
        scan(paths, args.verbose)


if __name__ == "__main__":
    main()
