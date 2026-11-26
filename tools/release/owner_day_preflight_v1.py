#!/usr/bin/env python3
"""Check owner-day file prerequisites and the fresh unsigned B89 build."""

from pathlib import Path
import re
import subprocess
import sys


ROOT = Path(__file__).resolve().parents[2]
SHEET = Path("docs/release/OWNER_DEVICE_DAY_v1.md")
CHECKER = Path("tools/release/check_release_profile_v1.py")
PLIST = Path("build/ios/iphoneos/Runner.app/Info.plist")
XCCONFIG = Path("ios/Flutter/Generated.xcconfig")
# The owner sheet uses inline, relative Markdown file links (no reference links).
LINK = re.compile(r"\[[^\]\n]+\]\(([^)\s]+)\)")


def report(label, passed):
    print(f"{'READY' if passed else 'NOT READY'}: {label}")
    return passed


def check_links():
    sheet = ROOT / SHEET
    try:
        links = LINK.findall(sheet.read_text(encoding="utf-8"))
    except (OSError, UnicodeError) as error:
        return report(f"{SHEET}: {error}", False)
    ready = report(f"{SHEET} (linked files)", bool(links))
    for link in dict.fromkeys(links):
        target = (sheet.parent / link.split("#", 1)[0]).resolve()
        if not target.is_relative_to(ROOT):
            ready = report(f"{link} (not a repository file)", False) and ready
            continue
        ready = report(target.relative_to(ROOT), target.is_file()) and ready
    return ready


def check_profile():
    # Match the B105 dry run: check the version and generated Dart defines,
    # not just the Info.plist defaults. Never build or sign from preflight.
    try:
        pubspec = (ROOT / "pubspec.yaml").read_text(encoding="utf-8")
        version = re.search(r"^version:[ \t]*(\d+\.\d+\.\d+\+\d+)[ \t]*$", pubspec, re.M)
        if version is None:
            raise ValueError("expected version: x.y.z+build in pubspec.yaml")
        result = subprocess.run(
            [sys.executable, str(ROOT / CHECKER), str(ROOT / PLIST),
             "--xcconfig", str(ROOT / XCCONFIG), "--version", version.group(1)],
            cwd=ROOT, capture_output=True, text=True,
        )
    except (OSError, ValueError) as error:
        return report(f"unsigned release profile: {error}", False)
    for line in (result.stdout + result.stderr).splitlines():
        print(f"  {line}")
    return report("unsigned release profile", result.returncode == 0)


def main():
    links_ready = check_links()
    profile_ready = check_profile()
    ready = report("owner device day prerequisites", links_ready and profile_ready)
    return 0 if ready else 1


if __name__ == "__main__":
    raise SystemExit(main())
