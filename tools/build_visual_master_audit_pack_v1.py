#!/usr/bin/env python3
"""Build a truth-preserving, final-candidate visual-audit review pack."""
from __future__ import annotations
import hashlib, json, os, subprocess
from collections import defaultdict
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

ROOT=Path(__file__).resolve().parents[1]; RAW=Path(os.environ.get('VISUAL_AUDIT_RAW_ROOT', ROOT/'output/visual_master_audit/raw')); DEST=ROOT/'docs/evidence/visual_master_audit_v1'
STATUSES={'LIVE_PRODUCTION','PRODUCTION_RENDERER_INJECTED_STATE','SYNTHETIC_REFERENCE','PRODUCTION_CAPTURE_UNREACHABLE'}
FAMILIES=[
 ('placement_intro_question_result','PRODUCTION_RENDERER_INJECTED_STATE','core.placement'),('welcome_and_first_handoff','PRODUCTION_RENDERER_INJECTED_STATE','core.welcome'),('home','PRODUCTION_RENDERER_INJECTED_STATE','core.firstWeekHome'),('learn','PRODUCTION_RENDERER_INJECTED_STATE','core.firstWeekLearn'),('theory','LIVE_PRODUCTION','runner.theory.hand_rankings'),('table_read','LIVE_PRODUCTION','runner.table_read.live'),('decision','LIVE_PRODUCTION','runner.action_selection.live'),('VRT02','LIVE_PRODUCTION','runner.seat_selection.vrt02'),('incorrect_feedback','LIVE_PRODUCTION','runner.seat_selection.vrt02_incorrect'),('repair_recheck','LIVE_PRODUCTION','runner.table_read.recheck.live'),('practice','PRODUCTION_RENDERER_INJECTED_STATE','core.runnerDrill'),('review_queued_focused','PRODUCTION_RENDERER_INJECTED_STATE','core.firstWeekReview'),('profile_evidence','PRODUCTION_RENDERER_INJECTED_STATE','core.profileEvidence'),('session_summary','PRODUCTION_RENDERER_INJECTED_STATE','core.sessionSummary'),('lesson_completion','LIVE_PRODUCTION','runner.completion.review'),('world_band_milestone','PRODUCTION_RENDERER_INJECTED_STATE','core.worldCompletion'),('world3_derivative','LIVE_PRODUCTION','runner.world3_seat_derivative'),('hand_comparison','LIVE_PRODUCTION','runner.hand_comparison.live'),('showdown','LIVE_PRODUCTION','runner.showdown.live'),('course_map_locked_state','PRODUCTION_CAPTURE_UNREACHABLE',None),('Sharky_art_transition','PRODUCTION_CAPTURE_UNREACHABLE',None)]
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
def candidate_from_raw():
 candidates={json.loads(p.read_text()).get('candidate_commit_sha') for p in RAW.glob('*/manifest.json')}
 candidates.discard(None)
 if len(candidates)!=1: raise SystemExit(f'raw evidence must name one candidate SHA, found {sorted(candidates)}')
 return candidates.pop()
def rows(candidate):
 out=[]
 for p in sorted(RAW.glob('*/manifest.json')):
  m=json.loads(p.read_text())
  if m.get('candidate_commit_sha')!=candidate: continue
  for r in m.get('rows',[]):
   if r.get('content_status') not in STATUSES: raise SystemExit(f"bad status {r.get('content_status')}")
   image=Path(r['screenshot_path'])
   if not image.is_absolute(): image=RAW.parents[2]/image
   actual=sha(image)
   # Capture transport emits the POSIX `shasum` field; accept only its digest
   # token, then normalize the committed pack to the independently recomputed
   # digest.  This does not reconcile candidate freshness or alter pixels.
   if not image.exists() or not r.get('sha256') or r['sha256'].split()[0]!=actual: raise SystemExit(f"bad image/hash {image}")
   r['sha256']=actual; r['_image_path']=str(image)
   if r.get('candidate_commit_sha')!=candidate: raise SystemExit('non-final candidate row')
   out.append(r)
 if not out: raise SystemExit('No final-candidate raw capture rows found.')
 keys=[(r['visual_state_id'],r['device_class'],r.get('modifier','none')) for r in out]
 if len(keys)!=len(set(keys)): raise SystemExit('duplicate state/device/modifier row')
 return out
def apply_geometry_alias(rows):
 """Retain tall_phone as the canonical 402x874 sample, not a double-count."""
 tall={(r['visual_state_id'], r.get('modifier','none')): r for r in rows if r['device_class']=='tall_phone'}
 aliases=[r for r in rows if r['device_class']=='iphone17_class']
 missing=[r['visual_state_id'] for r in aliases if (r['visual_state_id'],r.get('modifier','none')) not in tall]
 if missing: raise SystemExit('iphone17 alias has no tall_phone peer: '+', '.join(missing))
 comparisons=[{'state':r['visual_state_id'],'modifier':r.get('modifier','none'),'geometry_alias':True,'canonical_device':'tall_phone','alias_device':'iphone17_class','same_sha256':r['sha256']==tall[(r['visual_state_id'],r.get('modifier','none'))]['sha256']} for r in aliases]
 if not all(x['same_sha256'] for x in comparisons): raise SystemExit('402x874 geometry alias rendered divergent pixels')
 return [r for r in rows if r['device_class']!='iphone17_class'], comparisons
def reject_semantic_duplicates(rows):
 buckets=defaultdict(list)
 for r in rows: buckets[(r['device_class'],r.get('modifier','none'),r['sha256'])].append(r['visual_state_id'])
 duplicates=[f"{key[0]}/{key[1]}: {', '.join(sorted(states))}" for key,states in buckets.items() if len(set(states))>1]
 if duplicates: raise SystemExit('duplicate semantic screenshots: '+'; '.join(duplicates))
def motion_results(rows):
 normal={(r['visual_state_id'],r['device_class']):r for r in rows if r.get('modifier','none')=='none'}
 reduced=[r for r in rows if r.get('modifier')=='reduced_motion']
 required={'core.placement','core.welcome','runner.seat_selection.vrt02_incorrect','runner.table_read.recheck.live','runner.completion.review','core.worldCompletion'}
 found={r['visual_state_id'] for r in reduced}
 if not required<=found: raise SystemExit('missing reduced-motion states: '+', '.join(sorted(required-found)))
 return [{'state':r['visual_state_id'],'geometry':r['device_class'],'modifier':'reduced_motion','result':'EXPECTED_STATIC_PARITY' if normal[(r['visual_state_id'],r['device_class'])]['sha256']==r['sha256'] else 'FRAME_CAPTURED','normal_sha256':normal[(r['visual_state_id'],r['device_class'])]['sha256'],'reduced_motion_sha256':r['sha256']} for r in reduced if (r['visual_state_id'],r['device_class']) in normal]
def label(r): return '\n'.join([f"state={r['visual_state_id']}",f"geometry={r['device_class']} modifier={r.get('modifier','none')}",f"phase={r.get('semantic_phase','unknown')}",f"status={r['content_status']}",f"sha={r['sha256'][:12]}"])
def render(group,path,title):
 font=ImageFont.load_default(); panels=[]
 for r in group:
  im=Image.open(r['_image_path']).convert('RGB'); im.thumbnail((310,620)); panel=Image.new('RGB',(320,740),'#101722'); panel.paste(im,((320-im.width)//2,106)); d=ImageDraw.Draw(panel); d.rectangle((0,0,320,106),fill='#162539'); d.multiline_text((5,4),label(r),font=font,fill='white',spacing=2); panels.append(panel)
 canvas=Image.new('RGB',(320*len(panels),770),'#070b12'); d=ImageDraw.Draw(canvas); d.text((8,4),title,font=font,fill='white')
 for i,p in enumerate(panels): canvas.paste(p,(320*i,30))
 path.parent.mkdir(parents=True,exist_ok=True); canvas.save(path,'WEBP',quality=82,method=6)
def main():
 candidate=candidate_from_raw(); data,geometry_aliases=apply_geometry_alias(rows(candidate)); reject_semantic_duplicates(data); motion=motion_results(data); DEST.mkdir(parents=True,exist_ok=True)
 for p in (DEST/'contact_sheets').glob('*.webp'): p.unlink()
 grouped=defaultdict(list)
 for r in data:
  # Keep contact sheets semantic and reviewable: shell journey versus real
  # task runner, then modifier.  A sheet is never a raw capture dump.
  semantic_group='shell_journey' if r['visual_state_id'].startswith('core.') else 'live_task_runner'
  grouped[(r.get('modifier','none'),semantic_group)].append(r)
 sheets=[]; index=1
 for key in sorted(grouped):
  group=grouped[key]
  for offset in range(0,len(group),6):
   part=group[offset:offset+6]; name=f'{index:02d}_{key[0]}_{key[1]}.webp'; render(part,DEST/'contact_sheets'/name,f'Visual Master Audit | {candidate[:12]} | {key[0]} | {key[1]}'); sheets.append({'path':'contact_sheets/'+name,'states':[r['visual_state_id'] for r in part]}); index+=1
 byid={r['visual_state_id'] for r in data}; coverage=[]
 for family,status,state in FAMILIES:
  coverage.append({'family':family,'status':status,'representative_state':state,'block_status':'none' if state else 'EXTERNAL_OR_ROUTE_ACCESS_REQUIRED','reason':None if state else 'No admitted production route/state injection exists in this bounded pack.'})
 missing=[f['family'] for f in coverage if f['status']!='PRODUCTION_CAPTURE_UNREACHABLE' and f['representative_state'] not in byid]
 if missing: raise SystemExit('missing family evidence: '+', '.join(missing))
 required_text={'runner.theory.hand_rankings','runner.table_read.live','runner.seat_selection.vrt02','runner.seat_selection.vrt02_incorrect','runner.table_read.recheck.live','core.placement','core.welcome','core.firstWeekReview','core.profileEvidence','core.sessionSummary'}
 text={r['visual_state_id'] for r in data if r.get('modifier')=='text_scale_1_4'}
 motion_states={r['visual_state_id'] for r in data if r.get('modifier')=='reduced_motion'}; motion=motion_results(data)
 gates={'all_rows_final_candidate_sha':True,'unique_state_device_modifier':True,'text_scale_1_4_minimum_10':len(text)>=10,'text_scale_required_families':required_text<=text,'reduced_motion_core_states':{'core.placement','core.welcome','runner.seat_selection.vrt02_incorrect','runner.completion.review','core.worldCompletion'}<=motion_states,'geometry_alias_policy':'iphone17_class and tall_phone share 402x874; only tall_phone is canonical for this pack.','geometry_alias_verified':bool(geometry_aliases)}
 for r in data: r.pop('_image_path',None)
 manifest={'schema':'visual_master_audit_manifest_v1','candidate_commit_sha':candidate,'rows':data,'contact_sheets':sheets,'geometry_aliases':geometry_aliases,'reduced_motion_results':motion,'core_family_coverage':coverage,'acceptance_gates':gates,'truth_rule':'Only LIVE_PRODUCTION is route/state-replayed production. PRODUCTION_RENDERER_INJECTED_STATE is actual production renderer with deterministic direct state and is composition-review-only.'}
 (DEST/'visual_master_audit_manifest_v1.json').write_text(json.dumps(manifest,indent=2)+'\n')
 counts=defaultdict(int)
 for r in data: counts[r['content_status']]+=1
 matrix=['# Visual Master Audit Capture Matrix v1','',f'Candidate: `{candidate}`','',f"Rows: **{len(data)}**; "+'; '.join(f'**{k}**: {v}' for k,v in sorted(counts.items()))+'.','', '## Acceptance gates','']+[f'- {k}: `{v}`' for k,v in gates.items()]+['','## Geometry aliases','']+[f"- `{x['alias_device']}` → `{x['canonical_device']}` for `{x['state']}`: `GEOMETRY_ALIAS`, same SHA: `{x['same_sha256']}`" for x in geometry_aliases]+['','## Reduced-motion results','']+[f"- `{x['state']}`: `{x['result']}`" for x in motion]+['','## Core-family coverage','','| Family | Status | Representative | Block |','| --- | --- | --- | --- |']+[f"| {x['family']} | {x['status']} | {x['representative_state'] or '—'} | {x['block_status']} |" for x in coverage]+['','| State | Geometry | Modifier | Phase | Status | SHA-256 |','| --- | --- | --- | --- | --- | --- |']+[f"| {r['visual_state_id']} | {r['device_class']} | {r.get('modifier','none')} | {r.get('semantic_phase')} | {r['content_status']} | `{r['sha256']}` |" for r in data]
 (DEST/'visual_master_audit_capture_matrix_v1.md').write_text('\n'.join(matrix)+'\n')
 (DEST/'visual_master_audit_gallery_v1.md').write_text('# Visual Master Audit Gallery v1\n\n'+f'Candidate: `{candidate}`\n\n'+'\n\n'.join(f"![{x['path']}]({x['path']})" for x in sheets)+'\n')
 (DEST/'visual_master_audit_issue_scorecard_template_v1.json').write_text(json.dumps({'schema':'visual_master_audit_issue_scorecard_template_v1','candidate_commit_sha':candidate,'issues':[]},indent=2)+'\n')
 print(json.dumps({'rows':len(data),'sheets':len(sheets),'gates':gates},indent=2))
if __name__=='__main__': main()
