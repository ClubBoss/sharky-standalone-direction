"""Offline, exact-source tests; no GitHub calls, Flutter SDK or workflow edits."""
import copy
import importlib.util
import json
import tempfile
import unittest
from pathlib import Path

SCRIPT = Path(__file__).resolve().parents[2] / "tools" / "test_authority" / "compare_existing_ci_v1.py"
spec = importlib.util.spec_from_file_location("compare_existing_ci_v1", SCRIPT)
mod = importlib.util.module_from_spec(spec)
spec.loader.exec_module(mod)
A, B, C, D, E, F = [v * 40 for v in "abcdef"]


def report(rows):
    return {"lane": "tier-a", "blocking": True, "smoke": False, "complete": True,
            "results": [{"name": key, "cmd": ["flutter", "test", "test/" + key + ".dart"], "status": value}
                        for key, value in rows]}


def snapshot(sha=A, role="pr_head", tree=B, data=None, run_id=1):
    data = data if data is not None else report([("new", "pass"), ("old", "fail"), ("fixed", "fail")])
    return {"schema": mod.SCHEMA, "repo": "ClubBoss/sharky-standalone-direction",
            "source": {"role": role, "sha": sha, "tree": tree},
            "gates": [{"key": "Test Authority / Tier A", "selected": [run_id, 1],
                       "attempts": [{"run_id": run_id, "run_attempt": 1, "status": "completed",
                                     "conclusion": "failure", "url": "https://github.com/ClubBoss/sharky-standalone-direction/actions/runs/"+str(run_id),
                                     "source_sha": sha, "checkout_sha": sha, "checkout_tree": tree,
                                     "workflow_sha": E, "environment": E + "e"*24,
                                     "sdk": C + "c"*24, "test_manifest_sha": F + "f"*24,
                                     "commands_sha": D + "d"*24, "log_complete": True,
                                     "test_authority": data}]}]}


class ComparisonTests(unittest.TestCase):
    def test_command_status_differences_are_labelled_not_cause_claims(self):
        base = snapshot()
        cand = snapshot(sha=C, role="merged_main", tree=D,
                        data=report([("new", "fail"), ("old", "error"), ("fixed", "pass")]), run_id=2)
        result = mod.compare(base, cand)
        g = result["comparison"]["Test Authority / Tier A"]
        self.assertEqual(g["status"], "COMPARABLE_COMMAND_RECEIPTS")
        self.assertEqual([len(g[k]) for k in ("new_failures", "persistent_failures", "resolved_failures")], [1, 1, 1])
        self.assertEqual(len(g["new_failures"][0]["command_id_sha256"]), 64)
        self.assertNotIn("argv", json.dumps(g))
        self.assertFalse(result["merge_permitted"])
        self.assertFalse(result["acceptance_inferred"])

    def test_skipped_cannot_be_pass(self):
        b, c = snapshot(), snapshot(sha=C, run_id=2)
        c["gates"][0]["attempts"][0]["conclusion"] = "skipped"
        g = mod.compare(b, c)["comparison"]["Test Authority / Tier A"]
        self.assertEqual(g["status"], "UNVERIFIED")
        self.assertEqual(g["skipped"], ["candidate"])

    def test_missing_checkout_identity_cannot_prove_inherited(self):
        b, c = snapshot(), snapshot(sha=C, run_id=2)
        c["gates"][0]["attempts"][0]["checkout_sha"] = None
        g = mod.compare(b, c)["comparison"]["Test Authority / Tier A"]
        self.assertEqual(g["status"], "UNVERIFIED")
        self.assertIn("candidate: exact checkout SHA/TREE missing", g["missing_evidence"])
        self.assertEqual(g["persistent_failures"], [])

    def test_different_versions_or_sdk_incomparable(self):
        b, c = snapshot(), snapshot(sha=C, run_id=2)
        c["gates"][0]["attempts"][0]["sdk"] = "different-dart"
        g = mod.compare(b, c)["comparison"]["Test Authority / Tier A"]
        self.assertEqual(g["status"], "UNVERIFIED")
        self.assertEqual(g["new_failures"], [])

    def test_unknown_equal_fingerprints_are_not_comparable(self):
        b, c = snapshot(), snapshot(sha=C, run_id=2)
        b["gates"][0]["attempts"][0]["environment"] = "unknown"
        c["gates"][0]["attempts"][0]["environment"] = "unknown"
        self.assertEqual(mod.compare(b, c)["comparison"]["Test Authority / Tier A"]["status"], "UNVERIFIED")

    def test_truncated_log_cannot_establish_failure_lineage(self):
        b, c = snapshot(), snapshot(sha=C, run_id=2)
        c["gates"][0]["attempts"][0]["log_complete"] = False
        self.assertIn("log or event inventory incomplete", mod.compare(b, c)["comparison"]["Test Authority / Tier A"]["reasons"])

    def test_different_commands_incomplete_inventory(self):
        b, c = snapshot(), snapshot(sha=C, run_id=2,
                                   data=report([("new", "fail"), ("old", "error")]))
        self.assertIn("different Test Authority command inventory", mod.compare(b, c)["comparison"]["Test Authority / Tier A"]["reasons"])

    def test_retry_history_preserved_without_overwriting_old_fail(self):
        b, c = snapshot(), snapshot(sha=C, run_id=2)
        older = copy.deepcopy(c["gates"][0]["attempts"][0])
        older["run_attempt"] = 1
        older["conclusion"] = "failure"
        c["gates"][0]["attempts"][0]["run_attempt"] = 2
        c["gates"][0]["attempts"].insert(0, older)
        c["gates"][0]["selected"] = [2, 2]
        g = mod.compare(b, c)["comparison"]["Test Authority / Tier A"]
        self.assertEqual(len(g["candidate_attempts"]), 2)
        self.assertEqual([a["run_attempt"] for a in g["candidate_attempts"]], [1, 2])

    def test_incomplete_smoke_not_comparable(self):
        b, c = snapshot(), snapshot(sha=C, run_id=2)
        c["gates"][0]["attempts"][0]["test_authority"]["smoke"] = True
        self.assertIn("Test Authority inventory incomplete or smoke-only", mod.compare(b, c)["comparison"]["Test Authority / Tier A"]["reasons"])

    def test_unselected_attempts_do_not_leak_as_success(self):
        b, c = snapshot(), snapshot(sha=C, run_id=2)
        c["gates"][0]["selected"] = None
        g = mod.compare(b, c)["comparison"]["Test Authority / Tier A"]
        self.assertEqual(g["status"], "UNVERIFIED")
        self.assertEqual(len(g["candidate_attempts"]), 1)

    def test_invalid_duplicate_attempt_rejected(self):
        s = snapshot()
        s["gates"][0]["attempts"].append(copy.deepcopy(s["gates"][0]["attempts"][0]))
        with self.assertRaisesRegex(ValueError, "duplicate attempt"):
            mod.validate(s)

    def test_strict_source_roles_and_sha(self):
        s = snapshot(role="inferred_main")
        with self.assertRaises(ValueError):
            mod.validate(s)
        s["source"]["role"] = "pr_head"
        s["source"]["sha"] = "short"
        with self.assertRaises(ValueError):
            mod.validate(s)

    def test_json_output_is_unique_across_two_invocations(self):
        import subprocess, sys
        b,c=snapshot(),snapshot(sha=C, run_id=2)
        with tempfile.TemporaryDirectory() as tmp:
            p=Path(tmp)
            (p/"b.json").write_text(json.dumps(b));(p/"c.json").write_text(json.dumps(c))
            outputs=[]
            for _ in range(2):
                r=subprocess.run([sys.executable,str(SCRIPT),"--base",str(p/"b.json"),"--candidate",str(p/"c.json"),"--out-root",str(p/"out")],capture_output=True,text=True)
                self.assertEqual(r.returncode,0,r.stderr)
                loc=Path(r.stdout.splitlines()[0].partition("=")[2])
                self.assertTrue(loc.is_file());outputs.append(loc)
            self.assertNotEqual(outputs[0],outputs[1])
            self.assertTrue(outputs[0].exists())


if __name__ == "__main__":
    unittest.main()
