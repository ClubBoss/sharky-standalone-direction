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
FROZEN_COMMANDS = [
    {"name": key, "cmd": ["flutter", "test", "test/" + key + ".dart"]}
    for key in ("new", "old", "fixed")
]
FROZEN_EFFECTIVE = [
    {"selector": row["name"], "path": row["cmd"][2], "blob_sha": A}
    for row in FROZEN_COMMANDS
]
FROZEN_SELECTOR_INPUTS = [{"name": "frozen-original-runner", "blob_sha": B}]



def report(rows):
    return {"lane": "tier-a", "blocking": True, "smoke": False, "complete": True,
            "files_attempted": len(rows),
            "effective_tests": FROZEN_EFFECTIVE,
            "selector_inputs": FROZEN_SELECTOR_INPUTS,
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
                                     "sdk": C + "c"*24,
                                     "test_manifest_sha": mod._canonical_digest(FROZEN_EFFECTIVE),
                                     "commands_sha": mod._canonical_digest(
                                         [[v["name"], v["cmd"]] for v in FROZEN_COMMANDS]),
                                     "selector_inputs_sha": mod._canonical_digest(FROZEN_SELECTOR_INPUTS),
                                     "runner_blob_sha": F, "workflow_blob_sha": E,
                                     "job_id": run_id + 10000, "log_complete": True,
                                     "test_authority": data}]}]}


def compare_fixture(base, candidate):
    # Synthetic test-only independent inventory anchored outside both reports.
    # Never use this builder to adapt real/truncated CI or to claim real proof.
    witness = {"schema": mod.WITNESS_SCHEMA, "gates": {}}
    for key in set(g["key"] for g in base["gates"] + candidate["gates"]):
        sides = {}
        for side, snapshot_obj in (("base", base), ("candidate", candidate)):
            gate = next((g for g in snapshot_obj["gates"] if g["key"] == key), None)
            if not gate:
                continue
            attempt = gate["attempts"][-1]
            sides[side] = {
                "source_sha": snapshot_obj["source"]["sha"],
                "source_tree": snapshot_obj["source"].get("tree"),
                "run_id": attempt["run_id"], "run_attempt": attempt["run_attempt"],
                "job_id": attempt["job_id"],
                "runner_blob_sha": F, "workflow_blob_sha": E,
                "ordered_commands": FROZEN_COMMANDS, "effective_tests": FROZEN_EFFECTIVE,
                "selector_inputs": FROZEN_SELECTOR_INPUTS,
            }
        witness["gates"][key] = sides
    return mod.compare(
        base, candidate, witness, mod._canonical_digest(witness),
        _synthetic_fixture=True,
    )


class ComparisonTests(unittest.TestCase):
    def test_command_status_differences_are_labelled_not_cause_claims(self):
        base = snapshot()
        cand = snapshot(sha=C, role="merged_main", tree=D,
                        data=report([("new", "fail"), ("old", "error"), ("fixed", "pass")]), run_id=2)
        result = compare_fixture(base, cand)
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
        g = compare_fixture(b, c)["comparison"]["Test Authority / Tier A"]
        self.assertEqual(g["status"], "UNVERIFIED")
        self.assertEqual(g["skipped"], ["candidate"])

    def test_missing_checkout_identity_cannot_prove_inherited(self):
        b, c = snapshot(), snapshot(sha=C, run_id=2)
        c["gates"][0]["attempts"][0]["checkout_sha"] = None
        g = compare_fixture(b, c)["comparison"]["Test Authority / Tier A"]
        self.assertEqual(g["status"], "UNVERIFIED")
        self.assertIn("candidate: exact checkout SHA/TREE missing", g["missing_evidence"])
        self.assertEqual(g["persistent_failures"], [])

    def test_checkout_commit_must_equal_selected_source_even_if_all_shas_look_valid(self):
        b, c = snapshot(), snapshot(sha=C, run_id=2)
        c["gates"][0]["attempts"][0]["checkout_sha"] = F
        g = compare_fixture(b, c)["comparison"]["Test Authority / Tier A"]
        self.assertEqual(g["status"], "UNVERIFIED")
        self.assertIn("candidate: checkout commit differs from selected source", g["missing_evidence"])
        self.assertEqual(g["persistent_failures"], [])

    def test_checkout_tree_must_match_independent_source_tree(self):
        b, c = snapshot(), snapshot(sha=C, run_id=2)
        c["gates"][0]["attempts"][0]["checkout_tree"] = A
        g = compare_fixture(b, c)["comparison"]["Test Authority / Tier A"]
        self.assertEqual(g["status"], "UNVERIFIED")
        self.assertIn("candidate: checkout TREE differs from selected source", g["missing_evidence"])

    def test_missing_source_tree_cannot_claim_comparable(self):
        b, c = snapshot(), snapshot(sha=C, run_id=2)
        c["source"]["tree"] = None
        g = compare_fixture(b, c)["comparison"]["Test Authority / Tier A"]
        self.assertEqual(g["status"], "UNVERIFIED")
        self.assertIn("candidate: source TREE not independently known", g["missing_evidence"])

    def test_synthetic_merge_must_use_its_actual_tested_commit(self):
        b, c = snapshot(), snapshot(sha=C, role="synthetic_merge", run_id=2)
        c["gates"][0]["attempts"][0]["checkout_sha"] = F
        g = compare_fixture(b, c)["comparison"]["Test Authority / Tier A"]
        self.assertEqual(g["status"], "UNVERIFIED")
        self.assertNotIn("identical", repr(g.get("new_failures", [])))

    def test_different_versions_or_sdk_incomparable(self):
        b, c = snapshot(), snapshot(sha=C, run_id=2)
        c["gates"][0]["attempts"][0]["sdk"] = "different-dart"
        g = compare_fixture(b, c)["comparison"]["Test Authority / Tier A"]
        self.assertEqual(g["status"], "UNVERIFIED")
        self.assertEqual(g["new_failures"], [])

    def test_unknown_equal_fingerprints_are_not_comparable(self):
        b, c = snapshot(), snapshot(sha=C, run_id=2)
        b["gates"][0]["attempts"][0]["environment"] = "unknown"
        c["gates"][0]["attempts"][0]["environment"] = "unknown"
        self.assertEqual(compare_fixture(b, c)["comparison"]["Test Authority / Tier A"]["status"], "UNVERIFIED")

    def test_truncated_log_cannot_establish_failure_lineage(self):
        b, c = snapshot(), snapshot(sha=C, run_id=2)
        c["gates"][0]["attempts"][0]["log_complete"] = False
        self.assertIn("log or event inventory incomplete", compare_fixture(b, c)["comparison"]["Test Authority / Tier A"]["reasons"])

    def test_different_commands_incomplete_inventory(self):
        b, c = snapshot(), snapshot(sha=C, run_id=2,
                                   data=report([("new", "fail"), ("old", "error")]))
        self.assertIn("different Test Authority command inventory", compare_fixture(b, c)["comparison"]["Test Authority / Tier A"]["reasons"])

    def test_retry_history_preserved_without_overwriting_old_fail(self):
        b, c = snapshot(), snapshot(sha=C, run_id=2)
        older = copy.deepcopy(c["gates"][0]["attempts"][0])
        older["run_attempt"] = 1
        older["conclusion"] = "failure"
        c["gates"][0]["attempts"][0]["run_attempt"] = 2
        c["gates"][0]["attempts"].insert(0, older)
        c["gates"][0]["selected"] = [2, 2]
        g = compare_fixture(b, c)["comparison"]["Test Authority / Tier A"]
        self.assertEqual(len(g["candidate_attempts"]), 2)
        self.assertEqual([a["run_attempt"] for a in g["candidate_attempts"]], [1, 2])

    def test_incomplete_smoke_not_comparable(self):
        b, c = snapshot(), snapshot(sha=C, run_id=2)
        c["gates"][0]["attempts"][0]["test_authority"]["smoke"] = True
        self.assertIn("Test Authority inventory incomplete or smoke-only", compare_fixture(b, c)["comparison"]["Test Authority / Tier A"]["reasons"])

    def test_unselected_attempts_do_not_leak_as_success(self):
        b, c = snapshot(), snapshot(sha=C, run_id=2)
        c["gates"][0]["selected"] = None
        g = compare_fixture(b, c)["comparison"]["Test Authority / Tier A"]
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

    def test_real_unwitnessed_runner_must_be_unverified(self):
        b, c = snapshot(), snapshot(sha=C, run_id=2)
        for item in (b, c):
            r = item["gates"][0]["attempts"][0]["test_authority"]
            r.pop("complete", None)
            r.pop("effective_tests", None)
            r.pop("selector_inputs", None)
        g = mod.compare(b, c)["comparison"]["Test Authority / Tier A"]
        self.assertEqual(g["status"], "UNVERIFIED")
        self.assertEqual(g["resolved_failures"], [])

    def test_without_independent_witness_no_lineage(self):
        b, c = snapshot(), snapshot(sha=C, run_id=2)
        g = mod.compare(b, c)["comparison"]["Test Authority / Tier A"]
        self.assertEqual(g["status"], "UNVERIFIED")
        self.assertIn("independently anchored", str(g["reasons"]))
        for key in ("new_failures", "persistent_failures", "resolved_failures"):
            self.assertEqual(g[key], [])

    def test_both_missing_or_invalid_lane_policy_fail_closed(self):
        for lane, policy in ((None, None), ("", None), ("other", True),
                             ("tier-a", None), ("tier-a", "true"),
                             ("tier-b", 1), ("tier-c", True),
                             ("tier-d", "false")):
            with self.subTest(lane=lane, policy=policy):
                b, c = snapshot(), snapshot(sha=C, run_id=2)
                for item in (b, c):
                    r = item["gates"][0]["attempts"][0]["test_authority"]
                    r["lane"], r["blocking"] = lane, policy
                g = compare_fixture(b, c)["comparison"]["Test Authority / Tier A"]
                self.assertEqual(g["status"], "UNVERIFIED")
                self.assertEqual(g["resolved_failures"], [])

    def test_known_nonblocking_lane_policy_is_allowed(self):
        b, c = snapshot(), snapshot(sha=C, run_id=2)
        for item in (b, c):
            r = item["gates"][0]["attempts"][0]["test_authority"]
            r["lane"], r["blocking"] = "tier-c", False
        g = compare_fixture(b, c)["comparison"]["Test Authority / Tier A"]
        self.assertEqual(g["status"], "COMPARABLE_COMMAND_RECEIPTS")

    def test_ineligible_terminal_conclusions_never_resolve(self):
        for conclusion in ("cancelled", "timed_out", "neutral", "stale", "action_required"):
            with self.subTest(conclusion=conclusion):
                b, c = snapshot(), snapshot(sha=C, run_id=2,
                      data=report([("new", "pass"), ("old", "pass"), ("fixed", "pass")]))
                c["gates"][0]["attempts"][0]["conclusion"] = conclusion
                g = compare_fixture(b, c)["comparison"]["Test Authority / Tier A"]
                self.assertEqual(g["status"], "UNVERIFIED")
                self.assertEqual(g["resolved_failures"], [])
                self.assertEqual(g["candidate_attempts"][0]["conclusion"], conclusion)

    def test_equal_truncated_subsets_do_not_prove_completeness(self):
        b, c = snapshot(), snapshot(sha=C, run_id=2,
             data=report([("new", "pass"), ("old", "pass"), ("fixed", "pass")]))
        for item in (b, c):
            r = item["gates"][0]["attempts"][0]["test_authority"]
            r["results"] = [x for x in r["results"] if x["name"] != "old"]
            r["files_attempted"] = len(r["results"])
        g = compare_fixture(b, c)["comparison"]["Test Authority / Tier A"]
        self.assertEqual(g["status"], "UNVERIFIED")
        self.assertEqual(g["resolved_failures"], [])
        self.assertIn("observed command inventory/count", str(g["reasons"]))

    def test_bad_attempt_count_cannot_prove_complete(self):
        b, c = snapshot(), snapshot(sha=C, run_id=2)
        c["gates"][0]["attempts"][0]["test_authority"]["files_attempted"] = "3"
        g = compare_fixture(b, c)["comparison"]["Test Authority / Tier A"]
        self.assertEqual(g["status"], "UNVERIFIED")

    def test_missing_effective_or_selector_evidence_fails(self):
        for field in ("effective_tests", "selector_inputs"):
            with self.subTest(field=field):
                b, c = snapshot(), snapshot(sha=C, run_id=2)
                c["gates"][0]["attempts"][0]["test_authority"].pop(field)
                g = compare_fixture(b, c)["comparison"]["Test Authority / Tier A"]
                self.assertEqual(g["status"], "UNVERIFIED")

    def test_skipped_individual_test_cannot_be_classified(self):
        b, c = snapshot(), snapshot(sha=C, run_id=2)
        c["gates"][0]["attempts"][0]["test_authority"]["results"][0]["status"] = "skip"
        g = compare_fixture(b, c)["comparison"]["Test Authority / Tier A"]
        self.assertEqual(g["status"], "UNVERIFIED")
        self.assertTrue(g["skipped"])

    def test_explicit_witness_digest_mismatch_fails_closed(self):
        b, c = snapshot(), snapshot(sha=C, run_id=2)
        w = {"schema": mod.WITNESS_SCHEMA, "gates": {}}
        g = mod.compare(b, c, w, "0"*64)["comparison"]["Test Authority / Tier A"]
        self.assertEqual(g["status"], "UNVERIFIED")

    def test_real_workflow_blob_provenance_is_required(self):
        b, c = snapshot(), snapshot(sha=C, run_id=2)
        c["gates"][0]["attempts"][0]["runner_blob_sha"] = None
        g = compare_fixture(b, c)["comparison"]["Test Authority / Tier A"]
        self.assertEqual(g["status"], "UNVERIFIED")

    def test_self_signed_witness_cannot_enable_public_comparison(self):
        b, c = snapshot(), snapshot(sha=C, run_id=2)
        # Intentionally plausible frozen witness, but made by same fixture
        # rather than independent producer GitHub/job attestation.
        frozen = {"schema": mod.WITNESS_SCHEMA, "gates": {}}
        for side, value in (("base", b), ("candidate", c)):
            a = value["gates"][0]["attempts"][0]
            frozen["gates"].setdefault("Test Authority / Tier A", {})[side] = {
                "source_sha": value["source"]["sha"],
                "source_tree": value["source"]["tree"],
                "run_id": a["run_id"], "run_attempt": a["run_attempt"],
                "job_id": a["job_id"], "runner_blob_sha": F,
                "workflow_blob_sha": E, "ordered_commands": FROZEN_COMMANDS,
                "effective_tests": FROZEN_EFFECTIVE,
                "selector_inputs": FROZEN_SELECTOR_INPUTS,
            }
        g = mod.compare(b, c, frozen, mod._canonical_digest(frozen))["comparison"]["Test Authority / Tier A"]
        self.assertEqual(g["status"], "UNVERIFIED")
        self.assertEqual(g["persistent_failures"], [])
        self.assertEqual(g["resolved_failures"], [])

    def test_cli_disallows_unverified_witness_override(self):
        import subprocess, sys
        result = subprocess.run(
            [sys.executable, str(SCRIPT), "--base", "unused_base.json",
             "--candidate", "unused_candidate.json", "--out-root", "unused_out",
             "--manifest-witness", "forged.json"],
            capture_output=True, text=True,
        )
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("unrecognized arguments", result.stderr)

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
