#!/usr/bin/env python3
"""Check the B89 unsigned iPhone release profile of a built Runner.app."""

import argparse
import base64
from pathlib import Path
import plistlib
import sys
from xml.parsers.expat import ExpatError

ROOT = Path(__file__).resolve().parents[2]
PORTRAIT = ["UIInterfaceOrientationPortrait"]
PLACEHOLDER = "com.example.pokerAnalyzer"
# Flutter 3.35 injects these version metadata defines even without CLI defines.
SDK_DEFINES = {
    "FLUTTER_VERSION", "FLUTTER_CHANNEL", "FLUTTER_GIT_URL",
    "FLUTTER_FRAMEWORK_REVISION", "FLUTTER_ENGINE_REVISION", "FLUTTER_DART_VERSION",
}
B89_FLAGS = {
    "goalRouteV1", "numberEntryV1", "warmupV1", "opponentStylesV1", "actionReasonV1", "liveRoomV1",
    "SHARKY_LEAK_DASHBOARD_V1", "SHARKY_STREET_SUMMARY_PREVIEW",
    "SHARKY_W13_PLUS_PILOT",
}


def default_defines(xcconfig):
    """Reject custom Dart defines; plist metadata alone cannot prove them."""
    for line in xcconfig.read_text().splitlines():
        key, _, value = line.partition("=")
        if key.strip() != "DART_DEFINES":
            continue
        for encoded in filter(None, value.strip().split(",")):
            define = base64.b64decode(encoded, validate=True).decode("utf-8")
            name, separator, _ = define.partition("=")
            if not separator or name not in SDK_DEFINES:
                return False
    return True


def checks(plist, xcconfig=None, version=None):
    identity = plist.get("CFBundleIdentifier") == PLACEHOLDER
    if version is not None:
        name, number = version.split("+", 1)
        identity = identity and (
            plist.get("CFBundleShortVersionString") == name
            and plist.get("CFBundleVersion") == number
        )
    # Flutter's Xcode backend adds the VM service Bonjour entry and local
    # network prompt in debug/profile only. Neither belongs in this app.
    debug_keys = B89_FLAGS | {
        "NSBonjourServices", "NSLocalNetworkUsageDescription", "DART_DEFINES",
    }
    native_debug_clear = not debug_keys.intersection(plist)
    defines_clear = xcconfig is None or default_defines(xcconfig)
    return [
        ("Portrait only (#867)", plist.get("UISupportedInterfaceOrientations") == PORTRAIT
         and plist.get("UISupportedInterfaceOrientations~iphone", PORTRAIT) == PORTRAIT),
        ("Placeholder bundle ID" + (" and pubspec version" if version else ""), identity),
        ("iPhone device family", plist.get("UIDeviceFamily") == [1]),
        ("English only", plist.get("CFBundleDevelopmentRegion") == "en"
         and plist.get("CFBundleLocalizations") == ["en"]),
        ("No debug plist flags" + (" or custom Dart defines" if xcconfig else
                                  " (Dart defines not inspected)"),
         native_debug_clear and defines_clear),
    ]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("plist", type=Path, nargs="?",
                        default=ROOT / "build/ios/iphoneos/Runner.app/Info.plist")
    parser.add_argument("--xcconfig", type=Path, help="Generated.xcconfig from the same build")
    parser.add_argument("--version", help="Expected pubspec version (x.y.z+build)")
    args = parser.parse_args()
    try:
        with args.plist.open("rb") as handle:
            plist = plistlib.load(handle)
        if not isinstance(plist, dict):
            raise ValueError("Info.plist must contain a dictionary")
        results = checks(plist, args.xcconfig, args.version)
    except (OSError, ValueError, ExpatError) as error:
        print(f"Release profile check failed: {error}", file=sys.stderr)
        return 1
    for label, passed in results:
        print(f"{'PASS' if passed else 'FAIL'}: {label}")
    return 0 if all(passed for _, passed in results) else 1


if __name__ == "__main__":
    raise SystemExit(main())
