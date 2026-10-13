#!/usr/bin/env python3
"""S11 hosted only: independently judge persisted, synthetic native learner evidence.
Never accepts a UI banner, exit code, fixture row or source-only result as graded proof.
"""
import json
import plistlib
import sys
from pathlib import Path

first_gate = len(sys.argv)==4 and sys.argv[1]=="--first"
clean_gate = len(sys.argv)==4 and sys.argv[1]=="--clean"
path=Path(sys.argv[2] if (first_gate or clean_gate) else sys.argv[1])
output=Path(sys.argv[3] if (first_gate or clean_gate) else sys.argv[2])
output.parent.mkdir(parents=True,exist_ok=True)
p=plistlib.load(path.open("rb"))
key="flutter.act0_shell_progress_v1"
assert key in p, "No persisted learner state"
state=json.loads(p[key])
records=state.get("learningEvidenceHistory",[])
if first_gate:
    target=[r for r in records if r.get("taskId")=="what_poker_is_find_hero"]
    passed=(len(target)==1 and target[0].get("choiceId")=="bottom" and
        target[0].get("expectedChoiceId")=="bottom" and target[0].get("isCorrect") is True and
        target[0].get("assistanceKind")=="none" and bool(target[0].get("recordId")) and
        bool(target[0].get("runId")) and bool(target[0].get("sessionId")))
    outcome={"status":"PASS_FIRST_NATIVE_GRADED" if passed else "FAIL_FIRST_NATIVE_GRADED",
        "count":len(records),"target":target,"earnedXp":state.get("earnedXp"),
        "completedTaskIds":state.get("completedTaskIds",[])}
    output.write_text(json.dumps(outcome,indent=2))
    print("S11_FIRST_NATIVE_GRADED",outcome["status"],"TARGET_COUNT",len(target))
    sys.exit(0 if passed else 1)
expected={
  "what_poker_is_find_hero":"bottom",
  "what_poker_is_table_read_transfer":"two_three_six",
  "what_poker_is_table_read_recheck":"two_three_four",
  "first_table_guide_one_clear_choice":"hero_btn_preflop_setup"
}
clean=[r for r in records if r.get("taskId") in expected and r.get("lessonId")=="what_poker_is"]
c1={
 "distinct":len({r.get("recordId") for r in clean}),
 "count":len(clean),
 "correct":[(r.get("taskId"),r.get("choiceId"),r.get("isCorrect")) for r in clean],
 "assistance":[r.get("assistanceKind") for r in clean],
 "run_ids":sorted({r.get("runId") for r in clean if r.get("runId")}),
 "passed": (
  len(clean)==4 and
  len({r.get("recordId") for r in clean})==4 and
  all(r.get("choiceId")==expected.get(r.get("taskId")) and r.get("isCorrect") is True for r in clean) and
  all(r.get("assistanceKind")=="none" for r in clean) and
  len({r.get("taskId") for r in clean})==4 and
  all(r.get("runId") and r.get("sessionId") for r in clean)
 )
}
if clean_gate:
    actual=clean
    valid=(
        c1["passed"] and len(actual)==4 and len(records)==4 and
        state.get("earnedXp")==25 and
        len(state.get("completedTaskIds",[]))==5 and
        not state.get("completedLessonIds",[]) and
        state.get("selectedTaskId")=="first_table_guide_route_roles" and
        state.get("resumeSelectedOptionId") is None and
        len(set(c1["run_ids"]))==1 and
        all(r.get("expectedChoiceId")==expected[r["taskId"]] and
            r.get("assistanceKind")=="none" and r.get("runKind")=="lesson" and
            r.get("sessionId") and r.get("recordId") for r in actual)
    )
    outcome={"status":"PASS_C1_FOUR_NATIVE_PERSISTED" if valid else "FAIL_C1_NATIVE_PERSISTED",
       "record_count":len(records),"records":actual,
       "earnedXp":state.get("earnedXp"),
       "completedTaskIds":state.get("completedTaskIds",[])}
    output.write_text(json.dumps(outcome,indent=2))
    print("S11_NATIVE_C1_PERSISTED",outcome["status"],"RECORDS",len(actual),"XP",state.get("earnedXp"))
    sys.exit(0 if valid else 1)
c2_records=[r for r in records if r.get("taskId") in ("actions_legal_context","actions_check_drill","actions_fold_drill","actions_call_drill","actions_raise_drill")]
wrong=[r for r in c2_records if r.get("taskId")=="actions_legal_context" and r.get("choiceId")=="fold" and r.get("isCorrect") is False]
assisted=[r for r in c2_records if r.get("taskId")=="actions_check_drill" and r.get("choiceId")=="check" and r.get("assistanceKind") in ("quickHint","theoryRecall") and r.get("isCorrect") is True]
recheck=[r for r in c2_records if r.get("sourceTaskId")=="actions_legal_context" and r.get("choiceId")=="check" and r.get("assistanceKind")=="none" and r.get("isCorrect") is True]
c2={
 "count":len(c2_records),
 "wrong_count":len(wrong),"assisted_count":len(assisted),"recheck_count":len(recheck),
 "attempts":[{"task":r.get("taskId"),"source":r.get("sourceTaskId"),"chosen":r.get("choiceId"),"correct":r.get("isCorrect"),"assistance":r.get("assistanceKind"),"record":r.get("recordId"),"run":r.get("runId")} for r in c2_records],
 "passed":bool(wrong and assisted and recheck and len({r["recordId"] for r in wrong[:1]+assisted[:1]+recheck[:1]})==3)
}
report={"evidence_class":"NATIVE_PERSISTED_SYNTHETIC","source_sha":"948261351e7c1b430790174fce5b80d48f613e50","total_records":len(records),"earnedXp":state.get("earnedXp"),"completedTaskIds":state.get("completedTaskIds",[]),"c1":c1,"c2":c2}
output.write_text(json.dumps(report,indent=2))
print("S11_PERSISTED_C1_PASS=",c1["passed"],"COUNT",c1["count"])
print("S11_PERSISTED_C2_PASS=",c2["passed"],"COUNT",c2["count"])
print("S11_PERSISTED_VERDICT_FILE",output)
if not c1["passed"] or not c2["passed"]:
    sys.exit(1)
