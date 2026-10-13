#!/usr/bin/env python3
"""Judge the proportionate wrong-final branch from actual native preferences."""
import json
import plistlib
import re
import sys
from pathlib import Path
root=Path(sys.argv[1])
def load(tag):
    timing=json.loads((root/tag/'capture-timing.json').read_text())
    log=(root.parent/'wrong-tests.log').read_text()
    releases=re.findall(r'S11_PERSIST_RELEASE '+re.escape(tag)+r' epoch=([0-9.]+)',log)
    assert len(releases)==1 and timing['completed_epoch'] < float(releases[0])
    assert timing['completed_lag_seconds'] < 44
    p=plistlib.loads((root/tag/'learner.plist').read_bytes())
    return json.loads(p['flutter.act0_shell_progress_v1'])
observed={}
try:
    before=observed['before']=load('C1_wrong_prefinal')
    after=observed['after']=load('C1_wrong_answer')
    original=before['learningEvidenceHistory']
    rows=after['learningEvidenceHistory']
    assert len(original)==4 and len(rows)==5 and rows[:4]==original
    assert len({r['recordId'] for r in rows})==5
    final=rows[-1]
    assert final['taskId']=='first_table_guide_route_roles'
    assert final['worldId']=='world_1' and final['lessonId']=='what_poker_is'
    assert final['choiceId']=='learn' and final['expectedChoiceId']=='review'
    assert final.get('errorType') not in (None, '', 'none')
    assert final['isCorrect'] is False and final['assistanceKind']=='none'
    assert final['runKind']=='lesson' and final['runId'] and final['sessionId']
    assert before['earnedXp']==after['earnedXp']==25
    assert before['completedTaskIds']==after['completedTaskIds'] and len(after['completedTaskIds'])==5
    assert not before['completedLessonIds'] and not after['completedLessonIds']
    verdict={'status':'PASS_C1_WRONG_FINAL_NATIVE','observed':observed}
except (AssertionError, KeyError, OSError, ValueError) as exc:
    verdict={'status':'FAIL_C1_WRONG_FINAL_NATIVE','error':repr(exc),'observed':observed}
(root/'wrong-final-verdict.json').write_text(json.dumps(verdict,indent=2))
print(verdict['status'],verdict.get('error',''))
sys.exit(0 if verdict['status'].startswith('PASS') else 1)
