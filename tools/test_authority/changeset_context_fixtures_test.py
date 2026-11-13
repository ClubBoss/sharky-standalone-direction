from pathlib import Path
import subprocess,tempfile,os,json,shutil,atexit
# Isolate synthetic children from CI, policy/receipt controls and Git overrides.
# Evidence destination is captured separately and never passed as execution authority.
EVIDENCE_DESTINATION = os.environ.get("SHARKY_FIXTURE_EVIDENCE_DIR")
def fixture_environment(source):
 clean = {k:v for k,v in source.items() if not k.startswith(
  ("GITHUB_", "SHARKY_", "FAST_LOOP_", "TEST_AUTHORITY_", "TEST_POLICY_", "GIT_", "MOCK_"))
  and k not in {"CHECKPOINT", "CAPTURE", "TRACE"}}
 clean.update(GIT_CONFIG_GLOBAL=os.devnull, GIT_CONFIG_NOSYSTEM="1")
 return clean
BASE_ENV = fixture_environment(os.environ)
SOURCE = Path(__file__).resolve().parents[2]
def capable_bash():
 for value in [shutil.which("bash"), "/opt/homebrew/bin/bash", "/usr/local/bin/bash", "/bin/bash"]:
  if value and Path(value).is_file() and subprocess.run([value,"-c","type mapfile >/dev/null 2>&1"],capture_output=True,env=BASE_ENV).returncode==0:
   return value
 raise RuntimeError("BLOCKED: Bash with mapfile required; no installation attempted")
BASH=capable_bash()
p=Path(tempfile.mkdtemp(prefix="sharky-portable-process-fixtures-"))
atexit.register(shutil.rmtree,p,ignore_errors=True)
(p/"tools").mkdir()
for f in (SOURCE/"tools").glob("*"):
 if f.is_file() and f.name in ["release_gate_world1.sh","fast_loop_world1_v1.sh","_fast_loop_test_tiers_v1.sh","collect_changeset_v1.py"]:
  shutil.copyfile(f,p/"tools"/f.name)
r=Path(tempfile.mkdtemp(prefix='changeset-context-git-'));atexit.register(shutil.rmtree,r,ignore_errors=True)
def git(*args):
 q=subprocess.run(['git','-C',str(r),*args],capture_output=True,text=True,env=BASE_ENV);assert q.returncode==0,(args,q.stderr);return q.stdout.strip()
def put(n,s='fixture\n'):
 f=r/n;f.parent.mkdir(parents=True,exist_ok=True);f.write_text(s)
git('init','-q');git('config','user.email','fixture@example.invalid');git('config','user.name','Fixture')
put('pubspec.yaml','name: fixture\n');put('lib/seed.dart');git('add','.');git('commit','-qm','seed');ancestor=git('rev-parse','HEAD')
git('checkout','-qb','prhead');put('content/example/v1/pr.yaml');git('add','.');git('commit','-qm','head');head=git('rev-parse','HEAD')
git('checkout','-qb','base',ancestor);put('lib/base.dart');git('add','.');git('commit','-qm','base');base=git('rev-parse','HEAD')
git('merge','--no-ff','-m','synthetic','prhead');put('lib/resolution.dart');git('add','.');git('commit','--amend','--no-edit','-q');candidate=git('rev-parse','HEAD')
repo='ClubBoss/sharky-standalone-direction'
pr={'repository':{'full_name':repo},'action':'synchronize','number':7,'pull_request':{'base':{'sha':base,'repo':{'full_name':repo}},'head':{'sha':head,'repo':{'full_name':'fork/sharky'}}}}
eventpath=p/'event-fixture.json';results=[]
clean=BASE_ENV.copy()
def event_env(name,event,sha=candidate,ref='refs/pull/7/merge'):
 eventpath.write_text(json.dumps(event))
 return {**clean,'GITHUB_ACTIONS':'true','GITHUB_EVENT_NAME':name,'GITHUB_REPOSITORY':repo,'GITHUB_SHA':sha,'GITHUB_REF':ref,'GITHUB_EVENT_PATH':str(eventpath)}
def check(label,env,code=0,includes=(),scope=None):
 q=subprocess.run(['python3',str(p/'tools/collect_changeset_v1.py'),str(r),'--with-scope'],env=env,capture_output=True,text=True)
 assert q.returncode==code,(label,q.returncode,q.stdout,q.stderr)
 if code:assert not q.stdout
 if scope:assert q.stdout.startswith('SCOPE:'+scope+'\n')
 for name in includes:assert name in q.stdout.splitlines(),(label,name,q.stdout)
 (p/(label+'.txt')).write_text(q.stdout+q.stderr);results.append({'name':label,'exit':q.returncode})
check('ci_synthetic',event_env('pull_request',pr),includes=['content/example/v1/pr.yaml','lib/resolution.dart'],scope='bounded')
check('ci_sha_mismatch',event_env('pull_request',pr,sha=head),75)
bad=json.loads(json.dumps(pr));bad['pull_request']['base']['sha']=ancestor
check('ci_parent_mismatch',event_env('pull_request',bad),75)
bad=json.loads(json.dumps(pr));bad['pull_request']=None
check('ci_malformed_nested',event_env('pull_request',bad),75)
check('ci_ref_mismatch',event_env('pull_request',pr,ref='refs/pull/8/merge'),75)
bad=json.loads(json.dumps(pr));bad['action']='closed'
check('ci_unsupported_action',event_env('pull_request',bad),75)
check('ci_unsupported_event',event_env('merge_group',pr),75)
bad=json.loads(json.dumps(pr));bad['repository']['full_name']='other/repo'
check('ci_repo_mismatch',event_env('pull_request',bad),75)
env=event_env('pull_request',pr);eventpath.write_text('{bad')
check('ci_invalid_json',env,75)
git('checkout','-q',head)
check('ci_pr_head',event_env('pull_request',pr,sha=head),scope='bounded',includes=['content/example/v1/pr.yaml'])
push={'repository':{'full_name':repo},'ref':'refs/heads/main','deleted':False,'before':base,'after':head}
check('ci_force_push_directdiff',event_env('push',push,sha=head,ref='refs/heads/main'),includes=['lib/base.dart','content/example/v1/pr.yaml'],scope='bounded')
push['before']='1'*40
check('ci_missing_before_object',event_env('push',push,sha=head,ref='refs/heads/main'),75)
push['before']='0'*40
check('ci_newbranch_full',event_env('push',push,sha=head,ref='refs/heads/main'),scope='full-scope')
for event in ['workflow_dispatch','schedule']:
 check('ci_'+event,event_env(event,{'repository':{'full_name':repo}},sha=head,ref='refs/heads/main'),scope='full-scope')
check('local_full_scope',clean,scope='full-scope',includes=['lib/seed.dart'])
# Real consumers in local fallback: no PR env, mock SDK executables only.
for f in (p/'tools').glob('*'):
 if f.is_file():put('tools/'+f.name,f.read_text())
source=SOURCE/'tools/_world1_selected_tests_v1.sh'
put('tools/_world1_selected_tests_v1.sh',source.read_text())
put('tools/_test_policy_v1.sh','test_policy_should_run_full_suite_v1() { TEST_POLICY_FULL_SUITE_V1=0; TEST_POLICY_REASON_V1=fixture; }; test_policy_require_full_suite_enabled_v1() { :; }\n')
put('tools/_fast_loop_cache_v1.sh','fast_loop_compute_cache_key_v1() { echo fixture; }; fast_loop_cache_matches_v1() { return 1; }; fast_loop_write_cache_v1() { :; }\n')
put('tools/lint_tools_v1.sh','#!/bin/sh\nprintf "lint\\n" >> "$TRACE"\n');(r/'tools/lint_tools_v1.sh').chmod(0o755)
(r/'tools/fast_loop_world1_v1.sh').chmod(0o755)
put('mockbin/dart','#!/bin/sh\nprintf "dart %s\\n" "$*" >> "$TRACE"\nif [ "$1" = run ]; then exit "${MOCK_VALIDATOR_RC:-0}"; fi\n')
put('mockbin/flutter','#!/bin/sh\nprintf "flutter %s\\n" "$*" >> "$TRACE"\n')
for f in (r/'mockbin').iterdir():f.chmod(0o755)
(r/'mockbin/bash').symlink_to(BASH)
trace=r/'trace';env={**clean,'PATH':str(r/'mockbin')+':'+clean['PATH'],'TRACE':str(trace)}
for label,target,args,extra,code in [
 ('local_gate_full','release_gate_world1.sh',[],{},0),
 ('local_content_failure','release_gate_world1.sh',[],{'MOCK_VALIDATOR_RC':'8'},8),
 ('local_plan_observational','fast_loop_world1_v1.sh',['--print-plan'],{},0),
 ('local_diagnostic_no_tests','fast_loop_world1_v1.sh',['--no-tests','--no-analyze'],{},0),
]:
 if trace.exists():trace.unlink()
 q=subprocess.run([BASH,'tools/'+target,*args],cwd=r,env={**env,**extra},capture_output=True,text=True)
 lines=trace.read_text() if trace.exists() else ''
 assert q.returncode==code,(label,q.stdout,q.stderr,lines)
 if label=='local_gate_full':
  assert lines.count('dart run tools/validate_training_content.dart\n')==1
  assert 'flutter gen-l10n' in lines and 'dart format' in lines
  # All declared selected family members must appear, no fake path triggers.
  helper=(r/'tools/_world1_selected_tests_v1.sh').read_text()+(r/'tools/_fast_loop_test_tiers_v1.sh').read_text()
  import re
  paths=set(re.findall(r'(?m)^\s+(test/[^\s]+\.dart)\s*$',helper))
  assert paths and all(path in lines for path in paths),(paths,lines)
  assert 'flutter test -r expanded\n' not in lines # no policy-forbidden unqualified suite
 if label=='local_content_failure':assert 'flutter test' not in lines
 if label=='local_plan_observational':assert not trace.exists()
 if label=='local_diagnostic_no_tests':
  assert 'flutter test' not in lines
  assert 'REQUESTED CHECKS PASS' in q.stdout and 'not release acceptance' in q.stdout
 (p/(label+'.txt')).write_text(q.stdout+q.stderr+'\nTRACE\n'+lines);results.append({'name':label,'exit':q.returncode})
(p/'CONTEXT_RESULT.json').write_text(json.dumps(results,indent=2))
print(len(results),'context and composed fallback cases PASS')

if EVIDENCE_DESTINATION:
 destination=Path(EVIDENCE_DESTINATION)/Path(__file__).stem
 destination.mkdir(parents=True,exist_ok=True)
 for artifact in p.glob("*.txt"):
  shutil.copyfile(artifact,destination/artifact.name)
 for artifact in p.glob("*RESULT.json"):
  shutil.copyfile(artifact,destination/artifact.name)
