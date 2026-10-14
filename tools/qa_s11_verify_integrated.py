#!/usr/bin/env python3
"""Read-only integrated S11 receipt judgment; no state injection or reconstruction."""
import hashlib,json,plistlib,re,sys
from pathlib import Path
root=Path(sys.argv[1]);mode=sys.argv[2]
log=(root.parent/'native-tests.log').read_text()
ALLOWED_RUN_KINDS={'lesson','repair','placement','practice','spaced_review'}
def provenance(r):
 # Strict, for EVERY saved record of this (new) binary: source-owned run + session.
 assert r.get('runId'), f"MISSING_RUN_IDENTITY: {r.get('recordId')}"
 assert r.get('sessionId'), f"MISSING_SESSION_IDENTITY: {r.get('recordId')}"
 assert r['runId']==f"run_v1|{r['sourceWorldId']}|{r['sourceLessonId']}|{r['runKind']}|{r['runOrdinal']}", f"run identity missing/inconsistent: {r['recordId']}"
 assert r['worldId']==r['sourceWorldId'] and r['lessonId']==r['sourceLessonId']
 assert r['sessionId'] and r['recordId'], f"session identity missing: {r['recordId']}"
 assert r['runKind'] in ALLOWED_RUN_KINDS and r.get('startedBy'), f"run kind/startedBy missing: {r['recordId']}"
 if r['runKind']=='placement':
  assert r['startedBy']=='placement_diagnostic' and r['reviewKind']=='initialAssessment', f"placement assessment provenance: {r['recordId']}"
def state(tag):
 p=root/tag
 t=json.loads((p/'capture-timing.json').read_text())
 releases=re.findall(r'S11_PERSIST_RELEASE '+re.escape(tag)+r' epoch=([0-9.]+)',log)
 assert len(releases)==1 and t['completed_epoch']<float(releases[0])
 assert t['completed_lag_seconds']<44
 s=json.loads(plistlib.loads((p/'learner.plist').read_bytes())['flutter.act0_shell_progress_v1'])
 for r in s['learningEvidenceHistory']: provenance(r)   # full history, no grandfathering
 ids=[r['recordId'] for r in s['learningEvidenceHistory']]
 assert len(ids)==len(set(ids)), f'{tag}: duplicate record ids'
 return s
def journal(tag):
 return [json.loads(x) for x in (root/tag/'app-owned-telemetry.jsonl').read_text().splitlines() if x]
def delta_cardinality(ordered):
 # Each record appended between consecutive checkpoints has exactly one
 # user_choice/decision_made/task_result in the journal snapshot of the later
 # checkpoint (the journal is overwritten at relaunch, so earlier launches are
 # judged at the checkpoint where the record first appears).
 prev=[];checked=0
 for tag in [t for t in ordered if (root/t).exists()]:
  s=state(tag);h=s['learningEvidenceHistory']
  assert h[:len(prev)]==prev or not prev, f'{tag}: saved evidence rewritten'
  rows=journal(tag)
  for r in h[len(prev):]:
   for name in ['user_choice','decision_made','task_result']:
    m=[e for e in rows if e['name']==name and e['fields'].get('attempt_id')==r['recordId']]
    assert len(m)==1, f"{tag}:{r['recordId']}:{name}:cardinality={len(m)}"
    if name=='decision_made': assert m[0]['fields'].get('assistance_kind','none')==r['assistanceKind'], f"{tag}:{r['recordId']} assistance mismatch"
   checked+=1
  prev=h
 return checked
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
 if mode=='degraded':
  # No learner progress exists: judge from the native log, the pre-launch corruption
  # receipt and the post-run preference value. Never counts as learning evidence.
  pre=(root.parent/'degraded-pre.txt').read_text()
  assert 'corrupt-progress' in pre, 'corruption was not written before launch'
  assert 'S11_D1_DEGRADED_ENTRY_OK' in log and 'S11_D1_DEGRADED_PLACEMENT_REACHED' in log, 'entry/primary route did not operate on corrupt saved state'
  post=(root/'degraded-post.txt').read_text().strip()
  observed['pre_value_prefix']=pre.strip()[:40]
  observed['post_value_prefix']=post[:60]
  observed['saved_state_after_run']='still_corrupt' if 'corrupt-progress' in post else ('absent' if 'does not exist' in post else 'replaced_by_app')
  observed['d1_degraded']='PASS_SCOPED: app launched into usable first-use entry and primary route operated with corrupt saved progress'
  verdict={'status':'PASS_DEGRADED','observed':observed}
  (root/'integrated-verdict.json').write_text(json.dumps(verdict,indent=2));print(verdict['status']);sys.exit(0)
 if mode=='back-resume':
  tags=['AB_question_open','AB_after_back','AB_after_relaunch','AB_resumed_question']
  st=[state(t) for t in tags]
  base=st[0]
  assert base['selectedTaskId']=='what_poker_is_find_hero', 'saved resume point must be the open graded task'
  for t,s_ in zip(tags,st):
   for key in ['learningEvidenceHistory','earnedXp','completedTaskIds','completedLessonIds','selectedTaskId']:
    assert s_[key]==base[key], f'{t}: {key} changed across Back / kill / resume'
   assert not any(r['taskId']=='what_poker_is_find_hero' for r in s_['learningEvidenceHistory']), f'{t}: unanswered question gained a record'
  observed['saved_return']='PASS_SCOPED'
  observed['checkpoints']={t:{'xp':s_['earnedXp'],'records':len(s_['learningEvidenceHistory']),'selectedTaskId':s_['selectedTaskId'],'resumeInRunner':s_.get('resumeInRunner')} for t,s_ in zip(tags,st)}
  verdict={'status':'PASS_BACK_RESUME','observed':observed}
  (root/'integrated-verdict.json').write_text(json.dumps(verdict,indent=2));print(verdict['status']);sys.exit(0)
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
  order=['C1_prefinal','C1_final_answer','C1_summary','C1_home','C1_restart','C1_second_review_entry','recap_resumed_unanswered',tag,'recap_summary','recap_home','recap_restart','B_profile_before_retake','B_retake_zero_finished','B_retake_diagnostic_finished','B_retake_restart']
  observed['delta_cardinality_records_checked']=delta_cardinality(order)
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
    for lesson,start in base['lessonRunEvidenceBoundaries'].items():
     assert s['lessonRunEvidenceBoundaries'].get(lesson)==start, f'{tag}: retake moved historical lesson-run boundary {lesson}'
    n=len(base['learningEvidenceHistory'])
    assert s['learningEvidenceHistory'][:n]==base['learningEvidenceHistory'], f'{tag}:retake rewrote saved evidence'
    appended[tag]=s['learningEvidenceHistory'][n:]
   assert appended['B_retake_zero_finished']==[], 'zero retake must append no evidence'
   assert appended['B_retake_restart']==appended['B_retake_diagnostic_finished'], 'restart changed retake evidence'
   rows=[json.loads(x) for x in (root/'B_retake_diagnostic_finished'/'app-owned-telemetry.jsonl').read_text().splitlines() if x]
   for r in appended['B_retake_diagnostic_finished']:
    for name in ['user_choice','decision_made','task_result']:
     assert len([e for e in rows if e['name']==name and e['fields'].get('attempt_id')==r['recordId']])==1, f"retake diagnostic {r['recordId']}:{name} cardinality"
   assert all(r['runKind']=='placement' and r['reviewKind']=='initialAssessment' for r in appended['B_retake_diagnostic_finished']), 'retake diagnostic answers must be placement assessment evidence'
   assert len(appended['B_retake_diagnostic_finished'])==3
   observed['retake_diagnostic_appended']=[{k:r.get(k) for k in ('recordId','taskId','lessonId','choiceId','isCorrect','assistanceKind','runId','sessionId')} for r in appended['B_retake_diagnostic_finished']]
 else:
  # C2 on the observed native route: wrong -> mapped repair attempt WITH quickHint
  # (not independent; intent+queue stay open) -> Review 'Practice this spot' -> a
  # second repair run answered unassisted, which clears the matched intent and queue.
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
  hw=w['learningEvidenceHistory']
  placement=[r for r in hw if r['runKind']=='placement']
  assert len(placement)==3 and hw[:3]==placement, 'first-install Placement diagnostic must be three explicit placement-assessment records'
  assert len({r['runId'] for r in placement})==1 and all(r['reviewKind']=='initialAssessment' for r in placement)
  assert wr['runKind']=='lesson' and wr['startedBy']=='placement_recommendation', 'recommended lesson must own a real lesson run'
  assert wr['runId']!=placement[0]['runId'], 'lesson run distinct from the assessment run'
  assert wr['reviewKind']=='initialAssessment', 'first actual actions_legal_context decision is initial assessment, not unseen transfer'
  assert wr['taskId']=='actions_legal_context' and wr['choiceId']=='fold' and wr['expectedChoiceId']=='check' and not wr['isCorrect'] and wr['errorType'] not in ('',None,'none') and wr['assistanceKind']=='none'
  assert ar['choiceId']=='check' and ar['isCorrect'] and ar['assistanceKind']=='quickHint' and ar['taskId']=='actions_check_drill'
  provenance(ar); assert ar['runKind']=='repair'
  assert qr['taskId']==ar['taskId'] and qr['choiceId']=='check' and qr['isCorrect'] and qr['assistanceKind']=='none', 'independent attempt must be unassisted and correct'
  provenance(qr); assert qr['runKind']=='repair', 'independent attempt must be a repair-run record'
  assert qr['runId']!=ar['runId'], 'independent attempt must be a distinct run from the assisted attempt'
  # An unassisted same-spot answer minutes after help is an immediate independent repair
  # attempt - not new-situation transfer, not delayed retention.
  assert ar['reviewKind']==qr['reviewKind']=='alternateSameSignal'
  assert qr['reviewKind'] not in ('unseenTransfer','spacedReview')
  observed['independence_class']='immediate_same_spot_repair_attempt'
  assert len({r['recordId'] for r in [wr,ar,qr]})==3
  assert a['learningEvidenceHistory'][:-1]==w['learningEvidenceHistory'] and d['learningEvidenceHistory']==a['learningEvidenceHistory'] and q['learningEvidenceHistory'][:-1]==d['learningEvidenceHistory']
  assert w['earnedXp']==a['earnedXp']==d['earnedXp'], 'wrong/assisted attempts must not earn XP'
  for s_ in [w,a,d,q]:
   assert not [f for f in s_['durableRetentionHistory'] if f.get('sourceTaskId')=='what_poker_is_table_read_transfer'], 'placement answers must not seed durable retention / due review'
   mem=[m for m in s_['retentionMemory'] if m.get('taskId')=='actions_legal_context']
   assert all(m.get('successfulRecheckCount',0)==0 for m in mem), 'help / same-spot repair must not prove retention or mastery'
  for s_ in [w,a,d]:
   assert open_for(s_,'actions_legal_context'), 'repair debt must stay open until the independent attempt'
   assert unresolved_for(s_,'actions_legal_context'), 'queue entry must stay unresolved until the independent attempt'
   assert 'actions_legal_context' not in s_['completedTaskIds'], 'WRONG_OR_ASSISTED_SOURCE_GRANTED_CURRICULUM_COMPLETION'
   assert not s_['repairOutcomeProjection'], 'assisted answer must not write an independent repair outcome'
   assert s_['multiRepairQueue']['entries'][0]['attemptCount']==1
  assert not open_for(q,'actions_legal_context') and not unresolved_for(q,'actions_legal_context'), 'independent attempt must close the debt'
  # Native repair run 38570840358 showed repairOutcomeProjection stays empty on this route; closure is the
  # cleared intent + pruned queue entry. Report the projection rather than assert a shape.
  observed['repair_outcome_projection_at_independent']=q['repairOutcomeProjection']
  observed['xp_delta_independent']=q['earnedXp']-a['earnedXp']
  observed['delta_cardinality_records_checked']=delta_cardinality(['C2_wrong','C2_assisted','C2_review_debt_open','C2_independent_recheck','C2_review','C2_home','C2_restart'])
  rows=cardinality('C2_independent_recheck',q['learningEvidenceHistory'])
  assert [e['fields'].get('assistance_kind') for e in rows if e['name']=='decision_made' and e['fields'].get('attempt_id')==ar['recordId']]==['quickHint']
  assert [e['fields'].get('assistance_kind') for e in rows if e['name']=='decision_made' and e['fields'].get('attempt_id')==qr['recordId']]==['none']
  later=[t for t in ['C2_summary','C2_review','C2_home','C2_restart'] if (root/t).exists()]
  for tag in later:
   s_=observed[tag]=state(tag)
   assert s_['learningEvidenceHistory']==q['learningEvidenceHistory'] and s_['earnedXp']==q['earnedXp'] and s_['repairOutcomeProjection']==q['repairOutcomeProjection'], f'{tag}: persisted truth changed after independent attempt'
   assert not open_for(s_,'actions_legal_context')
  # The HNP journal is overwritten at process launch, so the pre-restart snapshot (C2_home) holds the closure events.
  final=[e for e in [json.loads(x) for x in (root/'C2_home'/'app-owned-telemetry.jsonl').read_text().splitlines() if x] if e['name']=='repair_completed']
  observed['repair_completed_telemetry']=[{k:e['fields'].get(k) for k in ('result','repairStatus','attemptOrdinal')} for e in final]
  assert len(final)>=2 and final[0]['fields'].get('repairStatus')=='open' and final[-1]['fields'].get('repairStatus')=='fixed' and final[-1]['fields'].get('result')=='correct', 'independent completion must close the repair in telemetry'
  observed['observations']={'placement_run_session':[placement[0]['runId'],placement[0]['sessionId']],'wrong_attempt_run_session':[wr['runId'],wr['sessionId']],'assisted_run_session':[ar['runId'],ar['sessionId']],'independent_run_session':[qr['runId'],qr['sessionId']]}
  observed['c2_core']='PASS'
  # The C2 honest Summary / session closure is a MANDATORY gate: a route that never
  # shows one is a HOLD, not a pass.
  assert 'C2_summary' in later, 'HOLD_C2_SUMMARY_NOT_REACHED'
 verdict={'status':'PASS_'+mode.upper().replace('-','_'),'observed':observed}
except (AssertionError,KeyError,OSError,ValueError) as e:
 hold='HOLD_C2_SUMMARY_NOT_REACHED' in repr(e)
 verdict={'status':('HOLD_' if hold else 'FAIL_')+mode.upper().replace('-','_'),'error':repr(e),'observed':observed}
(root/'integrated-verdict.json').write_text(json.dumps(verdict,indent=2));print(verdict['status'],verdict.get('error',''))
sys.exit(0 if verdict['status'].startswith('PASS') else 1)
