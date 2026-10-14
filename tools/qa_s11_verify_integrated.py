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
   # Retake must not change earned learning. The retake diagnostic is a set of
   # genuine new learner decisions: the saved history must keep the base as an
   # exact prefix, and anything appended must be reported and have exactly one
   # user_choice/decision_made/task_result per attempt. Earned XP and
   # completion/skip sets must be identical.
   appended={}
   for tag in ['B_retake_zero_finished','B_retake_diagnostic_finished','B_retake_restart']:
    s=observed[tag]=state(tag)
    for key in ['earnedXp','completedTaskIds','completedLessonIds','skippedTaskIds']:
     assert s[key]==base[key], f'{tag}:{key}:retake changed earned learning'
    n=len(base['learningEvidenceHistory'])
    assert s['learningEvidenceHistory'][:n]==base['learningEvidenceHistory'], f'{tag}:retake rewrote saved evidence'
    appended[tag]=s['learningEvidenceHistory'][n:]
   assert appended['B_retake_zero_finished']==[], 'zero retake must append no evidence'
   assert appended['B_retake_restart']==appended['B_retake_diagnostic_finished'], 'restart changed retake evidence'
   rows=[json.loads(x) for x in (root/'B_retake_diagnostic_finished'/'app-owned-telemetry.jsonl').read_text().splitlines() if x]
   for r in appended['B_retake_diagnostic_finished']:
    for name in ['user_choice','decision_made','task_result']:
     assert len([e for e in rows if e['name']==name and e['fields'].get('attempt_id')==r['recordId']])==1, f"retake diagnostic {r['recordId']}:{name} cardinality"
   observed['retake_diagnostic_appended']=[{k:r.get(k) for k in ('recordId','taskId','lessonId','choiceId','isCorrect','assistanceKind','runId','sessionId')} for r in appended['B_retake_diagnostic_finished']]
 else:
  # C2 on the source-owned route (act0_shell_preview_screen_v1 onContinue):
  # wrong -> mapped repair attempt WITH quickHint (not `repaired`, debt stays open)
  # -> Review "Practice this spot" -> Practice Queue repair answered unassisted ->
  # _appendPracticeQueueRepairOutcomeV1 records the outcome and clears the intent.
  def cardinality(tag,records):
   rows=[json.loads(x) for x in (root/tag/'app-owned-telemetry.jsonl').read_text().splitlines() if x]
   for r in records:
    for name in ['user_choice','decision_made','task_result']:
     m=[e for e in rows if e['name']==name and e['fields'].get('attempt_id')==r['recordId']]
     assert len(m)==1,f"{tag}:{r['recordId']}:{name}:cardinality={len(m)}"
     assert m[0]['fields']['chosen_action']==r['choiceId'] or name=='task_result'
   return rows
  def open_for(s,src): return [i for i in s['openRepairIntents'] if i.get('sourceTaskId')==src]
  def unresolved_for(s,src): return [e for e in (s.get('multiRepairQueue') or {}).get('entries',[]) if e.get('sourceTaskId')==src and e.get('resolutionState')=='unresolved']
  tags=['C2_wrong','C2_assisted','C2_review_debt_open','C2_independent_recheck','C2_review','C2_home','C2_restart']
  for tag in tags:observed[tag]=state(tag)
  w=observed['C2_wrong'];a=observed['C2_assisted'];d=observed['C2_review_debt_open'];q=observed['C2_independent_recheck']
  wr=w['learningEvidenceHistory'][-1];ar=a['learningEvidenceHistory'][-1];qr=q['learningEvidenceHistory'][-1]
  assert wr['taskId']=='actions_legal_context' and wr['choiceId']=='fold' and wr['expectedChoiceId']=='check' and not wr['isCorrect'] and wr['errorType'] not in ('',None,'none') and wr['assistanceKind']=='none'
  assert ar['choiceId']=='check' and ar['isCorrect'] and ar['assistanceKind']=='quickHint' and ar['taskId']=='actions_check_drill'
  provenance(ar); assert ar['runKind']=='repair'
  assert qr['taskId']==ar['taskId'] and qr['choiceId']=='check' and qr['isCorrect'] and qr['assistanceKind']=='none', 'independent attempt must be unassisted and correct'
  provenance(qr); assert qr['runKind']=='repair' and qr.get('startedBy')=='practice_repair_queue', 'independent attempt must come from the Practice Queue repair route'
  assert len({r['recordId'] for r in [wr,ar,qr]})==3
  assert a['learningEvidenceHistory'][:-1]==w['learningEvidenceHistory'] and d['learningEvidenceHistory']==a['learningEvidenceHistory'] and q['learningEvidenceHistory'][:-1]==d['learningEvidenceHistory']
  assert w['earnedXp']==a['earnedXp']==d['earnedXp'], 'wrong/assisted attempts must not earn XP'
  for s_ in [w,a,d]:
   assert open_for(s_,'actions_legal_context'), 'repair debt must stay open until the independent attempt'
   assert unresolved_for(s_,'actions_legal_context'), 'queue entry must stay unresolved until the independent attempt'
   assert 'actions_legal_context' not in s_['completedTaskIds'], 'WRONG_OR_ASSISTED_SOURCE_GRANTED_CURRICULUM_COMPLETION'
   assert not s_['repairOutcomeProjection'], 'assisted answer must not write an independent repair outcome'
  assert not open_for(q,'actions_legal_context') and not unresolved_for(q,'actions_legal_context'), 'independent attempt must close the debt'
  assert len(q['repairOutcomeProjection'])==1 and 'actions_legal_context' in json.dumps(q['repairOutcomeProjection']), 'exactly one independent repair outcome owned by the original source'
  observed['xp_delta_independent']=q['earnedXp']-a['earnedXp']
  rows=cardinality('C2_independent_recheck',[wr,ar,qr])
  assert [e['fields'].get('assistance_kind') for e in rows if e['name']=='decision_made' and e['fields'].get('attempt_id')==ar['recordId']]==['quickHint']
  assert [e['fields'].get('assistance_kind') for e in rows if e['name']=='decision_made' and e['fields'].get('attempt_id')==qr['recordId']]==['none']
  later=[t for t in ['C2_summary','C2_review','C2_home','C2_restart'] if (root/t).exists()]
  for tag in later:
   s_=observed[tag]=state(tag)
   assert s_['learningEvidenceHistory']==q['learningEvidenceHistory'] and s_['earnedXp']==q['earnedXp'] and s_['repairOutcomeProjection']==q['repairOutcomeProjection'], f'{tag}: persisted truth changed after independent attempt'
   assert not open_for(s_,'actions_legal_context')
  observed['summary_checkpoint']='REACHED' if 'C2_summary' in later else 'NOT_REACHED_ON_THIS_ROUTE'
  observed['observations']={'wrong_attempt_run_session':[wr.get('runId'),wr.get('sessionId')],'assisted_run_session':[ar['runId'],ar['sessionId']],'independent_run_session':[qr['runId'],qr['sessionId']]}
 verdict={'status':'PASS_'+mode.upper().replace('-','_'),'observed':observed}
except (AssertionError,KeyError,OSError,ValueError) as e:
 verdict={'status':'FAIL_'+mode.upper().replace('-','_'),'error':repr(e),'observed':observed}
(root/'integrated-verdict.json').write_text(json.dumps(verdict,indent=2));print(verdict['status'],verdict.get('error',''))
sys.exit(0 if verdict['status'].startswith('PASS') else 1)
