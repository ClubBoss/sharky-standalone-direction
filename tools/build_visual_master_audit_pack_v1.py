#!/usr/bin/env python3
"""Build a truth-preserving, final-candidate visual-audit review pack."""
from __future__ import annotations
import hashlib, json, subprocess
from collections import defaultdict
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

ROOT=Path(__file__).resolve().parents[1]; RAW=ROOT/'output/visual_master_audit/raw'; DEST=ROOT/'docs/evidence/visual_master_audit_v1'
STATUSES={'LIVE_PRODUCTION','PRODUCTION_RENDERER_INJECTED_STATE','SYNTHETIC_REFERENCE','PRODUCTION_CAPTURE_UNREACHABLE'}
FAMILIES=[
 ('placement_intro_question_result','PRODUCTION_RENDERER_INJECTED_STATE','core.placement'),('welcome_and_first_handoff','PRODUCTION_RENDERER_INJECTED_STATE','core.welcome'),('home','PRODUCTION_RENDERER_INJECTED_STATE','core.firstWeekHome'),('learn','PRODUCTION_RENDERER_INJECTED_STATE','core.firstWeekLearn'),('theory','LIVE_PRODUCTION','runner.theory.hand_rankings'),('table_read','LIVE_PRODUCTION','runner.table_read.live'),('decision','LIVE_PRODUCTION','runner.action_selection.live'),('VRT02','LIVE_PRODUCTION','runner.seat_selection.vrt02'),('incorrect_feedback','LIVE_PRODUCTION','runner.seat_selection.vrt02_incorrect'),('repair_recheck','LIVE_PRODUCTION','runner.table_read.recheck.live'),('practice','PRODUCTION_RENDERER_INJECTED_STATE','core.runnerDrill'),('review_queued_focused','PRODUCTION_RENDERER_INJECTED_STATE','core.firstWeekReview'),('profile_evidence','PRODUCTION_RENDERER_INJECTED_STATE','core.profileEvidence'),('session_summary','PRODUCTION_RENDERER_INJECTED_STATE','core.sessionSummary'),('lesson_completion','LIVE_PRODUCTION','runner.completion.review'),('world_band_milestone','PRODUCTION_RENDERER_INJECTED_STATE','core.worldCompletion'),('world3_derivative','LIVE_PRODUCTION','runner.world3_seat_derivative'),('hand_comparison','LIVE_PRODUCTION','runner.hand_comparison.live'),('showdown','LIVE_PRODUCTION','runner.showdown.live'),('course_map_locked_state','PRODUCTION_CAPTURE_UNREACHABLE',None),('Sharky_art_transition','PRODUCTION_CAPTURE_UNREACHABLE',None)]
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
def head(): return subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip()
def rows(candidate):
 out=[]
 for p in sorted(RAW.glob('*/manifest.json')):
  m=json.loads(p.read_text())
  if m.get('candidate_commit_sha')!=candidate: continue
  for r in m.get('rows',[]):
   if r.get('content_status') not in STATUSES: raise SystemExit(f"bad status {r.get('content_status')}")
   image=Path(r['screenshot_path']);
   if not image.exists() or not r.get('sha256') or r['sha256']!=sha(image): raise SystemExit(f"bad image/hash {image}")
   if r.get('candidate_commit_sha')!=candidate: raise SystemExit('non-final candidate row')
   out.append(r)
 if not out: raise SystemExit('No final-candidate raw capture rows found.')
 keys=[(r['visual_state_id'],r['device_class'],r.get('modifier','none')) for r in out]
 if len(keys)!=len(set(keys)): raise SystemExit('duplicate state/device/modifier row')
 return out
def label(r): return '\n'.join([f"state={r['visual_state_id']}",f"geometry={r['device_class']} modifier={r.get('modifier','none')}",f"phase={r.get('semantic_phase','unknown')}",f"status={r['content_status']}",f"sha={r['sha256'][:12]}"])
def render(group,path,title):
 font=ImageFont.load_default(); panels=[]
 for r in group:
  im=Image.open(r['screenshot_path']).convert('RGB'); im.thumbnail((310,620)); panel=Image.new('RGB',(320,740),'#101722'); panel.paste(im,((320-im.width)//2,106)); d=ImageDraw.Draw(panel); d.rectangle((0,0,320,106),fill='#162539'); d.multiline_text((5,4),label(r),font=font,fill='white',spacing=2); panels.append(panel)
 canvas=Image.new('RGB',(320*len(panels),770),'#070b12'); d=ImageDraw.Draw(canvas); d.text((8,4),title,font=font,fill='white')
 for i,p in enumerate(panels): canvas.paste(p,(320*i,30))
 path.parent.mkdir(parents=True,exist_ok=True); canvas.save(path,'WEBP',quality=82,method=6)
def main():
 candidate=head(); data=rows(candidate); DEST.mkdir(parents=True,exist_ok=True)
 for p in (DEST/'contact_sheets').glob('*.webp'): p.unlink()
 grouped=defaultdict(list)
 for r in data: grouped[(r.get('modifier','none'),r.get('semantic_phase','unknown'))].append(r)
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
 motion={r['visual_state_id'] for r in data if r.get('modifier')=='reduced_motion'}
 gates={'all_rows_final_candidate_sha':True,'unique_state_device_modifier':True,'text_scale_1_4_minimum_10':len(text)>=10,'text_scale_required_families':required_text<=text,'reduced_motion_core_states':{'core.placement','core.welcome','runner.seat_selection.vrt02_incorrect','runner.completion.review','core.worldCompletion'}<=motion,'geometry_alias_policy':'iphone17_class and tall_phone share 402x874; only tall_phone is canonical for this pack.'}
 manifest={'schema':'visual_master_audit_manifest_v1','candidate_commit_sha':candidate,'rows':data,'contact_sheets':sheets,'core_family_coverage':coverage,'acceptance_gates':gates,'truth_rule':'Only LIVE_PRODUCTION is route/state-replayed production. PRODUCTION_RENDERER_INJECTED_STATE is actual production renderer with deterministic direct state and is composition-review-only.'}
 (DEST/'visual_master_audit_manifest_v1.json').write_text(json.dumps(manifest,indent=2)+'\n')
 counts=defaultdict(int)
 for r in data: counts[r['content_status']]+=1
 matrix=['# Visual Master Audit Capture Matrix v1','',f'Candidate: `{candidate}`','',f"Rows: **{len(data)}**; "+'; '.join(f'**{k}**: {v}' for k,v in sorted(counts.items()))+'.','', '## Acceptance gates','']+[f'- {k}: `{v}`' for k,v in gates.items()]+['','## Core-family coverage','','| Family | Status | Representative | Block |','| --- | --- | --- | --- |']+[f"| {x['family']} | {x['status']} | {x['representative_state'] or '—'} | {x['block_status']} |" for x in coverage]+['','| State | Geometry | Modifier | Phase | Status | SHA-256 |','| --- | --- | --- | --- | --- | --- |']+[f"| {r['visual_state_id']} | {r['device_class']} | {r.get('modifier','none')} | {r.get('semantic_phase')} | {r['content_status']} | `{r['sha256']}` |" for r in data]
 (DEST/'visual_master_audit_capture_matrix_v1.md').write_text('\n'.join(matrix)+'\n')
 (DEST/'visual_master_audit_gallery_v1.md').write_text('# Visual Master Audit Gallery v1\n\n'+f'Candidate: `{candidate}`\n\n'+'\n\n'.join(f"![{x['path']}]({x['path']})" for x in sheets)+'\n')
 (DEST/'visual_master_audit_issue_scorecard_template_v1.json').write_text(json.dumps({'schema':'visual_master_audit_issue_scorecard_template_v1','candidate_commit_sha':candidate,'issues':[]},indent=2)+'\n')
 print(json.dumps({'rows':len(data),'sheets':len(sheets),'gates':gates},indent=2))
if __name__=='__main__': main()
