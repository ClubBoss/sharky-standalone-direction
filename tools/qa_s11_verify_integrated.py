#!/usr/bin/env python3
"""Read-only integrated S11 receipt judgment; no state injection or reconstruction."""
import hashlib,json,plistlib,re,sys
from pathlib import Path
root=Path(sys.argv[1]);mode=sys.argv[2]
log=(root.parent/'native-tests.log').read_text()
def state(tag):
 p=root/tag
 t=json.loads((p/'capture-timing.json').read_text())
 releases=re.findall(r'S11_PERSIST_RELEASE '+re.escape(tag)+r' epoch=([0-9.]+)',log)
 assert len(releases)==1 and t['completed_epoch']<float(releases[0])
 assert t['completed_lag_seconds']<44
 return json.loads(plistlib.loads((p/'learner.plist').read_bytes())['flutter.act0_shell_progress_v1'])
def provenance(r):
 assert r['runId']==f"run_v1|{r['sourceWorldId']}|{r['sourceLessonId']}|{r['runKind']}|{r['runOrdinal']}"
 assert r['worldId']==r['sourceWorldId'] and r['lessonId']==r['sourceLessonId']
 assert r['sessionId'] and r['recordId']
def trace(tag,s,records=None):
 rows=[json.loads(x) for x in (root/tag/'app-owned-telemetry.jsonl').read_text().splitlines() if x]
 for r in (records if records is not None else s['learningEvidenceHistory']):
  provenance(r)
  for name in ['user_choice','decision_made','task_result']:
   matches=[e for e in rows if e['name']==name and e['fields'].get('attempt_id')==r['recordId']]
   assert len(matches)==1, f"{tag}:{r['recordId']}:{name}:cardinality={len(matches)}"
   e=matches[0]['fields'];assert e['chosen_action']==r['choiceId'] and e['correct']==r['isCorrect']
 return len(rows)
observed={}
try:
 if mode in ('clean-recap','wrong-recap'):
  b=observed['before']=state('C1_second_review_entry')
  tag='recap_wrong' if mode=='wrong-recap' else 'recap_correct'
  a=observed['answer']=state(tag);old=b['learningEvidenceHistory'];rs=a['learningEvidenceHistory']
  assert len(rs)==len(old)+1 and rs[:-1]==old
  r=rs[-1];provenance(r)
  assert r['taskId']=='what_poker_is_review' and r['lessonId']=='what_poker_is_content' and r['worldId']=='world_1'
  assert r['expectedChoiceId']=='pot_committed_chips' and r['assistanceKind']=='none'
  wrong=mode=='wrong-recap';assert r['choiceId']==('everyone_folds' if wrong else 'pot_committed_chips') and r['isCorrect']==(not wrong)
  assert r['errorType'] not in ('',None,'none') if wrong else r['errorType']=='none'
  assert a['earnedXp']==b['earnedXp'] and a['completedTaskIds']==b['completedTaskIds']
  assert 'what_poker_is_content' not in a['completedLessonIds']
  trace('C1_summary',state('C1_summary'))
  current=[x for x in rs if x['lessonId']=='what_poker_is_content']
  trace(tag,a,[r] if wrong else current)
  trace('C1_second_review_entry',b,[x for x in old if x['lessonId']=='what_poker_is_content'])
  if wrong:
   resumed=observed['resumed']=state('recap_resumed_unanswered')
   assert resumed['learningEvidenceHistory']==old and resumed['earnedXp']==b['earnedXp']
  if not wrong:
   for tag in ['recap_summary','recap_home','recap_restart']:
    s=observed[tag]=state(tag)
    assert s['learningEvidenceHistory']==rs and s['earnedXp']==b['earnedXp']+3
    assert 'what_poker_is_review' in s['completedTaskIds'] and 'what_poker_is_content' in s['completedLessonIds']
   trace('recap_summary',observed['recap_summary'],current)
   base=state('B_profile_before_retake')
   for tag in ['B_retake_zero_finished','B_retake_diagnostic_finished','B_retake_restart']:
    s=observed[tag]=state(tag)
    for key in ['learningEvidenceHistory','earnedXp','completedTaskIds','completedLessonIds','skippedTaskIds']:
     assert s[key]==base[key], f'{tag}:{key}:retake changed earned learning'
 else:
  tags=['C2_wrong','C2_assisted','C2_independent_recheck','C2_summary','C2_review','C2_home','C2_restart']
  for tag in tags:observed[tag]=state(tag)
  w=observed['C2_wrong'];a=observed['C2_assisted'];q=observed['C2_independent_recheck']
  wr=w['learningEvidenceHistory'][-1];ar=a['learningEvidenceHistory'][-1];qr=q['learningEvidenceHistory'][-1]
  assert wr['taskId']=='actions_legal_context' and wr['choiceId']=='fold' and wr['expectedChoiceId']=='check' and not wr['isCorrect'] and wr['errorType'] not in ('',None,'none')
  assert ar['taskId']=='actions_check_drill' and ar['choiceId']=='check' and ar['isCorrect'] and ar['assistanceKind']=='quickHint'
  assert qr['sourceTaskId']=='actions_legal_context' and qr['choiceId']=='check' and qr['isCorrect'] and qr['assistanceKind']=='none'
  assert len({r['recordId'] for r in [wr,ar,qr]})==3
  assert a['learningEvidenceHistory'][:-1]==w['learningEvidenceHistory'] and q['learningEvidenceHistory'][:-1]==a['learningEvidenceHistory']
  assert w['earnedXp']==a['earnedXp']==q['earnedXp']
  for s in [w,a]:
   assert any(i.get('sourceTaskId')=='actions_legal_context' for i in s['openRepairIntents']), 'ASSISTANCE_CLOSED_INDEPENDENT_RECHECK_DEBT'
   assert 'actions_legal_context' not in s['completedTaskIds'], 'WRONG_OR_ASSISTED_SOURCE_GRANTED_CURRICULUM_COMPLETION'
  assert not any(i.get('sourceTaskId')=='actions_legal_context' for i in q['openRepairIntents'])
  trace('C2_independent_recheck',q)
  for tag in tags[3:]:
   s=observed[tag];assert s['learningEvidenceHistory']==q['learningEvidenceHistory'] and s['earnedXp']==q['earnedXp']
 verdict={'status':'PASS_'+mode.upper().replace('-','_'),'observed':observed}
except (AssertionError,KeyError,OSError,ValueError) as e:
 verdict={'status':'FAIL_'+mode.upper().replace('-','_'),'error':repr(e),'observed':observed}
(root/'integrated-verdict.json').write_text(json.dumps(verdict,indent=2));print(verdict['status'],verdict.get('error',''))
sys.exit(0 if verdict['status'].startswith('PASS') else 1)
