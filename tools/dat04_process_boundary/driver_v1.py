#!/usr/bin/env python3
"""Kill an actual Flutter test VM during pending Act0ProgressStoreV1 writes.

MACHINE only: the file preference adapter is deterministic Linux storage, not
NSUserDefaults or an iPhone lifecycle receipt. No inherited in-memory state is
shared with any restarted VM. Run from repository root with flutter on PATH.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import signal
import subprocess
import time


ROOT = Path(__file__).resolve().parents[2]
CHILD = "tools/dat04_process_boundary/store_child_v1_test.dart"
SHELL = "tools/dat04_process_boundary/shell_fixtures_v1_test.dart"


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest() if path.exists() else None


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", default="output/dat04-process-boundary")
    args = parser.parse_args()
    out = (ROOT / args.output).resolve()
    out.mkdir(parents=True, exist_ok=False)  # Never overwrite previous evidence.
    serial = 0
    receipts = []
    source = {
        "head": subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=ROOT, text=True).strip(),
        "tree": subprocess.check_output(["git", "rev-parse", "HEAD^{tree}"], cwd=ROOT, text=True).strip(),
        "dirty": subprocess.check_output(["git", "status", "--porcelain"], cwd=ROOT, text=True),
        "files": {p: digest(ROOT / p) for p in [CHILD, SHELL, str(Path(__file__).relative_to(ROOT)),
                  "lib/ui_v2/act0_shell/act0_progress_store_v1.dart",
                  "lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart",
                  "pubspec.lock"]},
    }
    (out / "source.json").write_text(json.dumps(source, indent=2))

    def flutter(path, env, label):
        with (out / f"{label}.log").open("w") as log:
            subprocess.run(["flutter", "test", "--no-pub", path, "-r", "expanded"],
                           cwd=ROOT, env={**os.environ, **env}, stdout=log,
                           stderr=subprocess.STDOUT, check=True, timeout=120)

    fixture_file = out / "source-fixtures.json"
    flutter(SHELL, {"DAT04_FIXTURES": str(fixture_file)}, "source-fixtures")
    fixtures = json.loads(fixture_file.read_text())

    def child(file, op, *, payload=None, cut=None):
        nonlocal serial
        serial += 1
        marker = out / f"{serial:03}-boundary.json"
        result = out / f"{serial:03}-result.json"
        step = {"file": str(file), "op": op, "payload": payload,
                "cut": cut, "marker": str(marker), "result": str(result)}
        (out / f"{serial:03}-request.json").write_text(json.dumps(step))
        before = digest(file)
        with (out / f"{serial:03}-child.log").open("w") as log:
            proc = subprocess.Popen(["flutter", "test", "--no-pub", CHILD, "-r", "expanded"],
                                    cwd=ROOT, env={**os.environ, "DAT04_STEP": json.dumps(step)},
                                    stdout=log, stderr=subprocess.STDOUT)
            if cut:
                deadline = time.monotonic() + 90
                while not marker.exists() and proc.poll() is None and time.monotonic() < deadline:
                    time.sleep(0.05)
                if not marker.exists():
                    proc.terminate()
                    proc.wait(timeout=15)
                    raise AssertionError(f"{serial}: cut not reached; see child log")
                boundary = json.loads(marker.read_text())
                assert boundary["stage"] == cut and not result.exists()
                os.kill(boundary["pid"], signal.SIGKILL)
                code = proc.wait(timeout=30)
                assert code != 0 and not result.exists(), "Killed save must never acknowledge"
                receipt = {"operation": op, "stage": cut, "writer_pid": boundary["pid"],
                           "flutter_exit": code, "ack": "ABSENT", "before_sha256": before,
                           "after_cut_sha256": digest(file), "temp_sha256": digest(Path(f"{file}.next"))}
            else:
                assert proc.wait(timeout=90) == 0, f"{serial}: see child log"
                receipt = json.loads(result.read_text())
        return receipt

    def load(file):
        loaded = child(file, "load")
        return loaded, loaded["result"]

    seed = out / "seed.json"
    assert child(seed, "save", payload=fixtures["before"])["result"] is True
    assert load(seed)[1] == {"payload": fixtures["before"]}
    cuts = {
        "before_save": "old",
        "before_set:p_head": "old",
        "torn_set:p_head": "old",
        "after_set:p_head": "HOLD",
        "before_set:p_recovery": "HOLD",
        "torn_set:p_recovery": "HOLD",
        "after_set:p_recovery": "new",
        "torn_set:p_backup": "new",
        "after_set:p_backup": "new",
        "after_set:p": "new",
    }
    recovered_completed = None
    for phase in ["decision", "completed"]:
        for stage, expected in cuts.items():
            file = out / f"disk-{phase}-{stage.replace(':', '-')}.json"
            file.write_bytes(seed.read_bytes())
            receipt = child(file, "save", payload=fixtures[phase], cut=stage)
            loader, result = load(file)
            assert loader["pid"] != receipt["writer_pid"]
            want = "HOLD" if expected == "HOLD" else {"payload": fixtures["before" if expected == "old" else phase]}
            assert result == want, f"{phase} {stage}: recovered a partial/mixed snapshot"
            if result != "HOLD":
                # A second independent VM sees exactly the same complete bytes.
                assert load(file)[1] == result
            receipt.update(phase=phase, loader_pid=loader["pid"], outcome=expected,
                           after_load_sha256=digest(file))
            receipts.append(receipt)
            (out / "receipts.json").write_text(json.dumps(receipts, indent=2))
            print(f"PASS {phase} {stage}: {expected}; writer killed before ack", flush=True)
            if phase == "completed" and stage == "after_set:p_recovery":
                recovered_completed = result["payload"]

    # Corrupt the only new checkpoint after a real interruption. The older
    # valid backup must not resurrect stale completion, XP or independent proof.
    file = out / "corrupt-after-interruption.json"
    file.write_bytes(seed.read_bytes())
    cut = child(file, "save", payload=fixtures["completed"], cut="after_set:p_recovery")
    values = json.loads(file.read_text())
    values["flutter.p_recovery"] = "{corrupt"
    file.write_text(json.dumps(values))
    assert load(file)[1] == "HOLD"
    receipts.append({**cut, "control": "corrupt newest copy never exposes stale backup", "outcome": "HOLD"})

    for stage in ["torn_set:p_head", "after_set:p_head", "after_set:p_recovery"]:
        file = out / f"reset-{stage.replace(':', '-')}.json"
        assert child(file, "save", payload=fixtures["completed"])["result"] is True
        cut = child(file, "clear", cut=stage)
        result = load(file)[1]
        expected = ({"payload": fixtures["completed"]} if stage == "torn_set:p_head"
                    else "HOLD" if stage == "after_set:p_head" else {"payload": None})
        assert result == expected
        receipts.append({**cut, "control": "interrupted reset", "outcome": stage})

    # Duplicate delivery of the same immutable snapshot cannot add an award or
    # manufacture a second source decision. Validate by exact payload equality.
    file = out / "duplicate.json"
    for _ in range(2):
        assert child(file, "save", payload=recovered_completed)["result"] is True
    assert load(file)[1] == {"payload": recovered_completed}
    restored = out / "restart-payload.json"
    restored.write_text(recovered_completed)
    # Production parser + actual visible replay in another fresh Flutter VM.
    flutter(SHELL, {"DAT04_RESTART_PAYLOAD": str(restored)}, "restart-consumer")
    (out / "receipts.json").write_text(json.dumps(receipts, indent=2))
    (out / "verdict.json").write_text(json.dumps({
        "verdict": "PASS_MACHINE_SCOPED", "kill_cases": len(receipts),
        "duplicate_exact_payload": True, "fresh_shell_replay": True,
        "target_device_lifecycle": "NOT_RUN", "full_DAT04_acceptance": False,
        "source": source,
    }, indent=2))
    print(f"PASS_MACHINE_SCOPED: {len(receipts)} actual SIGKILL cases; duplicate/replay controls PASS", flush=True)


if __name__ == "__main__":
    main()
