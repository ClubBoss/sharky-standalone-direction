#!/usr/bin/env python3
"""Run with python3 -I tools/prepush_affected_tests_v1_selftest.py."""

from pathlib import Path
import subprocess
import sys
from tempfile import TemporaryDirectory


SCRIPT = Path(__file__).resolve().with_name("prepush_affected_tests_v1.py")


def main():
    with TemporaryDirectory(prefix="prepush-selftest-", dir=SCRIPT.parent.parent) as directory:
        repo = Path(directory)

        def git(*args):
            subprocess.run(
                ["git", "-c", "core.hooksPath=/dev/null", "-c", "commit.gpgsign=false",
                 "-c", "user.name=Self-test", "-c", "user.email=selftest@example.invalid", *args],
                cwd=repo, check=True, capture_output=True,
            )

        source = repo / "lib" / "sample.dart"
        asset = repo / "assets" / "keys.json"
        tests = repo / "test"
        for path in (source.parent, asset.parent, tests):
            path.mkdir()
        source.write_text("class OldCounter {}\n", encoding="utf-8")
        asset.write_text('{"old.asset_key": true}\n', encoding="utf-8")
        (tests / "symbols_test.dart").write_text("void main() { NewCounter(); }\n", encoding="utf-8")
        (tests / "removed_test.dart").write_text("void main() { OldCounter(); }\n", encoding="utf-8")
        (tests / "keys_test.dart").write_text("const key = 'old.asset_key';\n", encoding="utf-8")
        (tests / "unrelated_test.dart").write_text("// Tiny\nvoid main() {}\n", encoding="utf-8")
        git("init", "-q")
        git("add", ".")
        git("commit", "-qm", "base")
        git("update-ref", "refs/remotes/origin/main", "HEAD")

        committed = "class NewCounter {}\nclass Tiny {}\n"
        source.write_text(committed, encoding="utf-8")
        git("add", str(source))
        git("commit", "-qm", "rename counter")
        staged = committed + "enum StagedState { active }\n"
        source.write_text(staged, encoding="utf-8")
        (tests / "directly changed_test.dart").write_text("void main() {}\n", encoding="utf-8")
        git("add", ".")
        source.write_text(staged + "int localCount() => 1;\n", encoding="utf-8")
        asset.write_text('{"new.asset_key": true}\n', encoding="utf-8")

        output = subprocess.check_output([sys.executable, "-I", str(SCRIPT)], cwd=tests, text=True)
        assert "Symbols: NewCounter, OldCounter, StagedState, localCount\n" in output, output
        assert "Keys: new.asset_key, old.asset_key\n" in output, output
        assert "Matched test files: 4 (4 selected)\n" in output, output
        assert "unrelated_test.dart" not in output, output
        assert "dart format --output=none --set-exit-if-changed lib/sample.dart" in output, output
        assert (
            "flutter test --no-pub 'test/directly changed_test.dart' test/keys_test.dart "
            "test/removed_test.dart test/symbols_test.dart"
        ) in output, output
    print("prepush affected tests self-test passed")


if __name__ == "__main__":
    main()
