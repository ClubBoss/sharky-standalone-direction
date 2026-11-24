"""Flag direct semantics disposal in Dart addTearDown callbacks."""

from pathlib import Path
import re


ROOT = Path(__file__).resolve().parents[2]
ALLOW_LIST = "tools/test_lint/semantics_dispose_allow_v1.txt"
IDENTIFIER = r"[A-Za-z_$][\w$]*"
NON_CODE = re.compile(
    r"//[^\n]*|/\*.*?\*/"
    r"|r?(?P<quote>'''|\"\"\"|'|\")(?:\\.|(?!(?P=quote)).)*(?P=quote)",
    re.DOTALL,
)
HANDLE_ASSIGNMENT = re.compile(
    rf"(?<![\w$])({IDENTIFIER})\s*=\s*"
    rf"(?:{IDENTIFIER}\s*\.\s*)*ensureSemantics\s*\(\s*\)\s*;"
)
TEARDOWN = re.compile(r"(?<![\w$])addTearDown\s*\(")
DISPOSE = re.compile(rf"(?<![\w$])({IDENTIFIER})\s*\.\s*dispose(?![\w$])")
PARENTHESIS = re.compile(r"[()]")


def violation_lines(source):
    # Mask comments and strings so offsets still refer to the original lines.
    code = NON_CODE.sub(lambda match: re.sub(r"[^\n]", " ", match[0]), source)
    handles = set(HANDLE_ASSIGNMENT.findall(code))
    if not handles:
        return

    for teardown in TEARDOWN.finditer(code):
        depth = 1
        for paren in PARENTHESIS.finditer(code, teardown.end()):
            depth += 1 if paren[0] == "(" else -1
            if depth == 0:
                argument = code[teardown.end():paren.start()]
                if handles.intersection(DISPOSE.findall(argument)):
                    yield code.count("\n", 0, teardown.start()) + 1
                break


def main():
    allowed = {
        line.partition("#")[0].strip()
        for line in (ROOT / ALLOW_LIST).read_text(encoding="utf-8").splitlines()
    }
    failed = False
    for path in sorted((ROOT / "test").rglob("*_test.dart")):
        for line in violation_lines(path.read_text(encoding="utf-8")):
            location = f"{path.relative_to(ROOT).as_posix()}:{line}"
            if location not in allowed:
                print(f"{location}: dispose the semantics handle in the test body")
                failed = True
    return int(failed)


if __name__ == "__main__":
    raise SystemExit(main())
