from pathlib import Path
import subprocess,tempfile,os,json,shutil,atexit,shlex
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
import hashlib
root=Path(tempfile.mkdtemp(prefix='changeset-fixture-'));atexit.register(shutil.rmtree,root,ignore_errors=True)
def git(*args,ok=True):
 q=subprocess.run(['git','-C',str(root),*args],capture_output=True,text=True,env=BASE_ENV)
 if ok:assert q.returncode==0,(args,q.stderr)
 return q.stdout.strip()
def put(n,s='x\n'):
 f=root/n;f.parent.mkdir(parents=True,exist_ok=True);f.write_text(s)
git('init','-q');git('config','user.email','fixture@example.invalid');git('config','user.name','Fixture')
put('seed');put('lib/cancel.dart','original\n');put('lib/delete.dart');put('lib/old.dart')
git('add','.');git('commit','-qm','base');base=git('rev-parse','HEAD')
for name in ['content/example/v1/data.yaml','lib/committed.dart','test/committed.dart','lib/l10n/fixture.arb']:put(name)
git('mv','lib/old.dart','lib/new.dart');git('rm','lib/delete.dart');git('add','.');git('commit','-qm','PR');head=git('rev-parse','HEAD')
env={**BASE_ENV,'SHARKY_CHANGE_MODE':'pr','SHARKY_CHANGE_BASE':base,'SHARKY_CHANGE_HEAD':head,'SHARKY_CHANGE_CANDIDATE':head}
results=[]
def run(label,override=None,code=0,includes=(),excludes=()):
 e={**env,**(override or {})}
 q=subprocess.run(['python3',str(p/'tools/collect_changeset_v1.py'),str(root)],env=e,capture_output=True,text=True)
 assert q.returncode==code,(label,q)
 paths=q.stdout.splitlines()
 for x in includes:assert x in paths,(label,x,paths)
 for x in excludes:assert x not in paths,(label,x,paths)
 if code:assert not q.stdout,(label,'partial stdout')
 (p/(label+'.txt')).write_text(q.stdout+q.stderr);results.append({'name':label,'exit':q.returncode})
run('committed',includes=['content/example/v1/data.yaml','lib/old.dart','lib/new.dart','lib/delete.dart','lib/committed.dart','test/committed.dart','lib/l10n/fixture.arb'])
put('lib/cancel.dart','staged\n');git('add','lib/cancel.dart');put('lib/cancel.dart','original\n')
put('lib/space name.dart');put('lib/untracked.dart')
run('dirty_union',includes=['lib/cancel.dart','lib/space name.dart','lib/untracked.dart'])
run('missingbase',{'SHARKY_CHANGE_BASE':''},75)
run('unknownobject',{'SHARKY_CHANGE_BASE':'1'*40},75)
run('checkout_mismatch',{'SHARKY_CHANGE_CANDIDATE':base,'SHARKY_CHANGE_HEAD':base},75)
run('synthetic_unknown',{'SHARKY_CHANGE_MODE':'synthetic'},75)
put('lib/new\nline.dart')
run('newline_unknown',code=75)
(root/'lib/new\nline.dart').unlink()
# Clean repo for true empty and staged conflicts.
git('reset','--hard','-q',head)
(root/'lib/space name.dart').unlink();(root/'lib/untracked.dart').unlink()
run('empty',{'SHARKY_CHANGE_BASE':head},excludes=['lib/committed.dart'])
blob=git('rev-parse','HEAD:seed')
q=subprocess.run(['git','-C',str(root),'update-index','--index-info'],input=f'100644 {blob} 1\tconflict\n100644 {blob} 2\tconflict\n100644 {blob} 3\tconflict\n',text=True,capture_output=True,env=BASE_ENV)
assert q.returncode==0
run('conflict_unknown',code=75)
git('reset','--hard','-q',head)
# Shallow clone read-only transport from local fixture, no network.
shallow_parent=Path(tempfile.mkdtemp(prefix='changeset-shallow-'));atexit.register(shutil.rmtree,shallow_parent,ignore_errors=True);shallow=shallow_parent/'repo'
subprocess.run(['git','clone','-q','--depth','1',root.as_uri(),str(shallow)],check=True,env=BASE_ENV)
oldroot=root;root=shallow;run('shallow_unknown',{'SHARKY_CHANGE_BASE':head},75);root=oldroot
# Release gate integration uses ONLY fake SDK commands and a fake nested fast loop.
for f in ['release_gate_world1.sh','_fast_loop_test_tiers_v1.sh','collect_changeset_v1.py']:
 put('tools/'+f,(p/'tools'/f).read_text())
put('pubspec.yaml','name: fixture\n')
put('tools/_test_policy_v1.sh','test_policy_should_run_full_suite_v1() { TEST_POLICY_FULL_SUITE_V1=0; TEST_POLICY_REASON_V1=fixture; }; test_policy_require_full_suite_enabled_v1() { :; }\n')
put('tools/fast_loop_world1_v1.sh','#!/bin/sh\nprintf "fastloop\\n" >> "$TRACE"\n')
(root/'tools/fast_loop_world1_v1.sh').chmod(0o755)
binpath=root/'mockbin';binpath.mkdir();(binpath/'bash').symlink_to(BASH)
for exe in ['dart','flutter']:
 put('mockbin/'+exe,'#!/bin/sh\nprintf "%s\\n" "'+exe+' $*" >> "$TRACE"\n')
 (binpath/exe).chmod(0o755)
put('mockbin/rg', '#!/bin/sh\nprintf \"UNEXPECTED_RG_DEPENDENCY\\n\" >> \"$TRACE\"\nexit 127\n')
(binpath/'rg').chmod(0o755)
trace=root/'trace'
e={**env,'PATH':str(binpath)+':'+os.environ['PATH'],'TRACE':str(trace)}
q=subprocess.run([BASH,'tools/release_gate_world1.sh'],cwd=root,env=e,capture_output=True,text=True)
assert q.returncode==0,(q.stdout,q.stderr)
lines=trace.read_text();assert 'dart run tools/validate_training_content.dart\n' in lines
assert 'UNEXPECTED_RG_DEPENDENCY' not in lines
assert '--staged-only' not in lines
assert 'flutter gen-l10n' in lines
assert 'lib/committed.dart' in lines and 'lib/delete.dart' not in lines and 'lib/old.dart' not in lines
(p/'gate_committed.txt').write_text(q.stdout+q.stderr+'\nTRACE\n'+lines)
results.append({'name':'gate_committed_full_validator','exit':q.returncode})
trace.unlink()
q=subprocess.run([BASH,'tools/release_gate_world1.sh'],cwd=root,env={**e,'SHARKY_CHANGE_BASE':''},capture_output=True,text=True)
assert q.returncode==75 and not trace.exists()
(p/'gate_unknown.txt').write_text(q.stdout+q.stderr);results.append({'name':'gate_unknown_no_sdk_dispatch','exit':q.returncode})

# Fast-loop integration with real changed-selector and fake SDK/cache/lint.
put('tools/fast_loop_world1_v1.sh',(p/'tools/fast_loop_world1_v1.sh').read_text())
put('tools/_world1_selected_tests_v1.sh','WORLD1_SELECTED_TESTS_STATE_V1=(test/fixture.dart)\nWORLD1_SELECTED_TESTS_V1=(test/fixture.dart)\nWORLD1_SELECTED_TESTS_CAMPAIGN_GUARDS_V1=(test/campaign.dart)\n')
put('tools/_fast_loop_cache_v1.sh','fast_loop_compute_cache_key_v1() { echo fixture; }; fast_loop_cache_matches_v1() { return 1; }; fast_loop_write_cache_v1() { :; }\n')
put('tools/lint_tools_v1.sh','#!/bin/sh\nprintf "lint\\n" >> "$TRACE"\n')
(root/'tools/lint_tools_v1.sh').chmod(0o755)
for label,args,override,expect in [
 ('fast_committed',['--no-analyze'],{},0),
 ('fast_forced',['--force-tests','--no-analyze'],{},0),
 ('fast_unknown',['--print-plan'],{'SHARKY_CHANGE_BASE':''},75),
 ('fast_nested_unknown',['--print-plan'],{'SHARKY_CHANGE_BASE':'','FAST_LOOP_ALREADY_RAN':'1'},75)]:
 if trace.exists():trace.unlink()
 q=subprocess.run([BASH,'tools/fast_loop_world1_v1.sh',*args],cwd=root,env={**e,**override},capture_output=True,text=True)
 assert q.returncode==expect,(label,q.stdout,q.stderr)
 lines=trace.read_text() if trace.exists() else ''
 if expect==0:
  assert 'dart run tools/validate_training_content.dart\n' in lines
  assert '--staged-only' not in lines
 else:assert not trace.exists()
 (p/(label+'.txt')).write_text(q.stdout+q.stderr+'\nTRACE\n'+lines)
 results.append({'name':label,'exit':q.returncode})

# Composition: real gate -> real fast-loop with mock SDK only.
put('tools/fast_loop_actual.sh',(p/'tools/fast_loop_world1_v1.sh').read_text())
put('tools/fast_loop_world1_v1.sh','#!/bin/sh\nprintf "nested\\n" >> "$TRACE"\nexec '+shlex.quote(BASH)+' tools/fast_loop_actual.sh "$@"\n')
(root/'tools/fast_loop_world1_v1.sh').chmod(0o755)
put('mockbin/dart','#!/bin/sh\nprintf "dart %s\\n" "$*" >> "$TRACE"\nif [ "$1" = run ] && [ "$2" = tools/validate_training_content.dart ]; then exit "${MOCK_VALIDATOR_RC:-0}"; fi\n')
for label,target,args,override,code,nested in [
 ('composed_once','tools/release_gate_world1.sh',[],{},0,1),
 ('composed_validator_failure','tools/release_gate_world1.sh',[],{'MOCK_VALIDATOR_RC':'9'},9,0),
 ('composed_nested_noop','tools/release_gate_world1.sh',[],{'FAST_LOOP_ALREADY_RAN':'1'},0,1),
 ('standalone_forced_once','tools/fast_loop_actual.sh',['--force-tests','--no-analyze'],{},0,0),
 ('unknown_owner','tools/fast_loop_actual.sh',['--print-plan'],{'SHARKY_CONTENT_OWNER_V1':'unknown'},75,0),
]:
 if trace.exists():trace.unlink()
 q=subprocess.run([BASH,target,*args],cwd=root,env={**e,**override},capture_output=True,text=True)
 lines=trace.read_text().splitlines() if trace.exists() else []
 assert q.returncode==code,(label,q.returncode,q.stdout,q.stderr,lines)
 assert lines.count('nested')==nested,(label,lines)
 assert lines.count('dart run tools/validate_training_content.dart')==(0 if label=='unknown_owner' else 1),(label,lines)
 if label=='composed_once':assert 'DELEGATED_TO_RELEASE_GATE' in q.stdout
 if label=='composed_validator_failure':assert 'FAST LOOP PASS' not in q.stdout
 (p/(label+'.txt')).write_text(q.stdout+q.stderr+'\nTRACE\n'+'\n'.join(lines))
 results.append({'name':label,'exit':q.returncode})
(p/'RESULT.json').write_text(json.dumps({'status':'ISOLATED_MOCK_ONLY_NOT_APPLIED','cases':results,'hashes':{str(f.relative_to(p)):hashlib.sha256(f.read_bytes()).hexdigest() for f in sorted((p/'tools').iterdir()) if f.is_file()}},indent=2))
print((p/'RESULT.json').read_text())

if EVIDENCE_DESTINATION:
 destination=Path(EVIDENCE_DESTINATION)/Path(__file__).stem
 destination.mkdir(parents=True,exist_ok=True)
 for artifact in p.glob("*.txt"):
  shutil.copyfile(artifact,destination/artifact.name)
 for artifact in p.glob("*RESULT.json"):
  shutil.copyfile(artifact,destination/artifact.name)
