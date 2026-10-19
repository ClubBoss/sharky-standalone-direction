#!/usr/bin/env python3
"""Read-only integrated S11 receipt judgment; no state injection or reconstruction."""
import hashlib,json,plistlib,re,sys
from pathlib import Path
root=Path(sys.argv[1]);mode=sys.argv[2]
log=(root.parent/'native-tests.log').read_text()
ALLOWED_RUN_KINDS={'lesson','repair','placement','practice','spaced_review','recheck'}
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
 if mode=='closure':
  tags=['C9_before_prerequisites']+[f'C9_guide_answer_{i}' for i in range(5)]+['C9_guide_summary','C9_source_question','C9_source_wrong','C9_guided_repair_question','C9_independent_correction','C9_original_recheck_question','C9_original_recheck_answer','C9_original_recheck_completed']+[f'C9_actions_answer_{i}' for i in range(6)]+['C9_actions_summary','C9_home','C9_restart']
  for tag in tags: observed[tag]=state(tag)
  observed['delta_cardinality_records_checked']=delta_cardinality(tags)
  before=observed['C9_before_prerequisites'];guide=observed['C9_guide_summary']
  assert before['completedTaskIds']==[] and before['earnedXp']==0
  guide_tasks={'what_poker_is_theory','what_poker_is_find_hero','what_poker_is_table_read_transfer','what_poker_is_table_read_recheck','first_table_guide_one_clear_choice','first_table_guide_route_roles'}
  assert guide_tasks<=set(guide['completedTaskIds']) and 'what_poker_is' in guide['completedLessonIds']
  assert guide['skippedTaskIds']==before['skippedTaskIds'], 'prerequisites must be earned, not injected skips'
  w=observed['C9_source_wrong'];c=observed['C9_independent_correction'];r=observed['C9_original_recheck_answer'];done=observed['C9_original_recheck_completed'];summary=observed['C9_actions_summary']
  wr=w['learningEvidenceHistory'][-1];cr=c['learningEvidenceHistory'][-1];rr=r['learningEvidenceHistory'][-1]
  assert wr['taskId']=='actions_legal_context' and wr['choiceId']=='fold' and wr['expectedChoiceId']=='check' and not wr['isCorrect'] and wr['errorType']=='misread_action_legality' and wr['assistanceKind']=='none'
  assert wr['runKind']=='lesson' and wr['startedBy']=='learn_route'
  assert cr['taskId']=='actions_check_drill' and cr['choiceId']=='check' and cr['isCorrect'] and cr['assistanceKind']=='none' and cr['reviewKind']=='alternateSameSignal' and cr['runKind']=='repair'
  assert rr['taskId']=='actions_legal_context' and rr['choiceId']=='check' and rr['isCorrect'] and rr['assistanceKind']=='none' and rr['errorType']=='none'
  assert rr['runKind']=='recheck' and rr['reviewKind']=='originalSourceRecheck' and rr['startedBy']=='same_signal_feedback_cta'
  assert len({wr['recordId'],cr['recordId'],rr['recordId']})==3 and len({wr['runId'],cr['runId'],rr['runId']})==3
  assert not any(i['sourceTaskId']=='actions_legal_context' for i in done['openRepairIntents'])
  assert not any(i.get('sourceTaskId')=='actions_legal_context' and i.get('resolutionState')=='unresolved' for i in done['multiRepairQueue']['entries'])
  rows=journal('C9_original_recheck_completed')
  for name in ['recheck_started','recheck_result']:
   matches=[e['fields'] for e in rows if e['name']==name and e['fields'].get('source_task_id')=='actions_legal_context']
   assert len(matches)==1, f'{name} must occur exactly once for original source'
   assert matches[0]['recheck_task_id']=='actions_legal_context'
   if name=='recheck_result': assert matches[0]['result']=='correct' and matches[0]['proof_status']=='unassisted'
  actions={'actions_theory','actions_legal_context','actions_check_drill','actions_fold_drill','actions_call_drill','actions_raise_drill','actions_review'}
  assert (actions-{'actions_theory'})<=set(summary['completedTaskIds'])
  assert 'actions_theory' in summary['skippedTaskIds'] and 'actions_theory' not in summary['completedTaskIds']
  assert 'fold_check_call_raise' not in summary['completedLessonIds'], 'skipped theory is not earned lesson completion'
  assert 'S11_GATE_STATE C9_actions_summary' in log and ('Session complete' in log.split('S11_NATIVE_TREE_BEGIN C9_actions_summary\n')[1].split('S11_NATIVE_TREE_END')[0] or 'What finished' in log.split('S11_NATIVE_TREE_BEGIN C9_actions_summary\n')[1].split('S11_NATIVE_TREE_END')[0])
  assert 'S11_GATE_STATE C9_actions_summary_metrics' in log
  assert any(e['name']=='session_complete' and e['fields'].get('lesson_id')=='fold_check_call_raise' and e['fields'].get('source_surface')=='act0_completion' for e in journal('C9_actions_summary'))
  # Earned task XP comes from authored rewards, never from skips or number of retries.
  reward={t:5 for t in guide_tasks|actions}
  assert set(summary['completedTaskIds'])<=set(reward)
  assert summary['earnedXp']==sum(reward[t] for t in summary['completedTaskIds'])
  assert observed['C9_restart']==observed['C9_home']==summary, 'ordinary navigation/restart must preserve saved truth'
  observed['closure_receipts']={'wrong':wr,'correction':cr,'original_recheck':rr,'earnedXp':summary['earnedXp'],'completedTaskIds':summary['completedTaskIds'],'completedLessonIds':summary['completedLessonIds'],'remainingDebt':len(summary['multiRepairQueue']['entries'])}
 elif mode=='repair':
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
  base=state('C2_home')
  for tag in ['C2_you','C2_restart','C2_restart_you','C2_restart_home']:
   saved=state(tag)
   assert saved==base, f'{tag}: saved state changed across ordinary restart / tab navigation'
  observed['postrestart_you_home']='PASS_SCOPED'

  # The C2 honest Summary / session closure is a MANDATORY gate: a route that never
  # shows one is a HOLD, not a pass.
  assert 'C2_summary' in later, 'HOLD_C2_SUMMARY_NOT_REACHED'
 verdict={'status':'PASS_'+mode.upper().replace('-','_'),'observed':observed}
except (AssertionError,KeyError,OSError,ValueError) as e:
 hold='HOLD_C2_SUMMARY_NOT_REACHED' in repr(e)
 verdict={'status':('HOLD_' if hold else 'FAIL_')+mode.upper().replace('-','_'),'error':repr(e),'observed':observed}
(root/'integrated-verdict.json').write_text(json.dumps(verdict,indent=2));print(verdict['status'],verdict.get('error',''))
sys.exit(0 if verdict['status'].startswith('PASS') else 1)
