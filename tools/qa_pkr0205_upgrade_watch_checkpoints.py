#!/usr/bin/env python3
"""Read-only native screen, preference and process receipts at real UI holds."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import struct
import subprocess
import time

parser = argparse.ArgumentParser()
parser.add_argument('--log')
parser.add_argument('--sim', required=True)
parser.add_argument('--output')
parser.add_argument('--snapshot-dir')
args = parser.parse_args()
container = subprocess.check_output(
    ['xcrun', 'simctl', 'get_app_container', args.sim,
     'com.example.pokerAnalyzer', 'data'], text=True).strip()
def raw_snapshot(target):
    target.mkdir(parents=True, exist_ok=False)
    processes = subprocess.check_output(
        ['xcrun', 'simctl', 'spawn', args.sim, 'launchctl', 'list'],
        text=True, timeout=12)
    (target / 'launchctl-list.txt').write_text(processes)
    running = [int(line.split()[0]) for line in processes.splitlines()
               if 'UIKitApplication:com.example.pokerAnalyzer[' in line
               and line.split()[0].isdigit() and int(line.split()[0]) > 0]
    assert not running, 'PRODUCT_MUST_BE_TERMINATED_DURING_INSTALL_SNAPSHOTS'
    result = subprocess.run(
        ['python3', str(Path(__file__).with_name('qa_s12_probe_persistence.py')),
         '--container', container, '--output', str(target / 'discovery.json'),
         '--extracted-plist', str(target / 'learner.plist')],
        capture_output=True, text=True, timeout=15)
    (target / 'probe.log').write_text(result.stdout + result.stderr)
    assert result.returncode == 0 and (target / 'learner.plist').is_file(), 'NO_ACTUAL_APP_PREFERENCES'
    app_container = subprocess.check_output(
        ['xcrun', 'simctl', 'get_app_container', args.sim,
         'com.example.pokerAnalyzer', 'app'], text=True).strip()
    kernel = Path(app_container) / 'Frameworks/App.framework/flutter_assets/kernel_blob.bin'
    preference_files = {
        p.name: hashlib.sha256(p.read_bytes()).hexdigest()
        for p in sorted((Path(container) / 'Library/Preferences').glob('*.plist'))}
    (target / 'snapshot.json').write_text(json.dumps({
        'simulator': args.sim, 'data_container': container,
        'app_container': app_container, 'observed_epoch': time.time(),
        'running_product_pids': running,
        'plist_sha256': hashlib.sha256((target / 'learner.plist').read_bytes()).hexdigest(),
        'preference_files_sha256': preference_files,
        'installed_kernel_sha256': hashlib.sha256(kernel.read_bytes()).hexdigest(),
        'scope': 'READ_ONLY_EXISTING_CONTAINER_NO_RECONSTRUCTION'}, indent=2))

if args.snapshot_dir:
    raw_snapshot(Path(args.snapshot_dir))
    print('PKR0205U_READ_ONLY_INSTALL_SNAPSHOT_CAPTURED', flush=True)
    raise SystemExit(0)
assert args.log and args.output, 'WATCH_REQUIRES_LOG_AND_OUTPUT'
root = Path(args.output)
seen = set()
print('PKR0205U_READ_ONLY_CONTAINER_RESOLVED', flush=True)
while True:
    log = Path(args.log)
    content = log.read_text(errors='replace') if log.exists() else ''
    markers = re.findall(
        r'PKR0205U_(SCREEN|PERSIST)_CHECKPOINT ([A-Za-z0-9_]+) epoch=([0-9.]+)', content)
    for kind, tag, epoch in markers:
        if (kind, tag) in seen:
            continue
        seen.add((kind, tag))
        requested = float(epoch)
        target = root / 'screens' / tag if kind == 'SCREEN' else root / tag
        target.mkdir(parents=True, exist_ok=True)
        receipt = {'requested_epoch': requested, 'observed_epoch': time.time(),
                   'hold_budget_seconds': 45}
        try:
            assert 0 <= time.time() - requested < 4, 'CHECKPOINT_MARKER_DELAY'
            if kind == 'SCREEN':
                result = subprocess.run(
                    ['xcrun', 'simctl', 'io', args.sim, 'screenshot',
                     str(target / 'native.png')],
                    capture_output=True, text=True, timeout=40)
                (target / 'capture.log').write_text(result.stdout + result.stderr)
                receipt['returncode'] = result.returncode
                assert result.returncode == 0, 'SIMCTL_SCREENSHOT_FAILED'
                data = (target / 'native.png').read_bytes()
                assert data[:8] == b'\x89PNG\r\n\x1a\n', 'NOT_NATIVE_PNG'
                receipt['width'], receipt['height'] = struct.unpack('>II', data[16:24])
                assert (receipt['width'], receipt['height']) == (1179, 2556), 'NOT_14PRO_PORTRAIT'
                receipt['sha256'] = hashlib.sha256(data).hexdigest()
                receipt['status'] = 'CAPTURED_NATIVE_SCREEN'
            else:
                time.sleep(1)
                result = subprocess.run(
                    ['python3', str(Path(__file__).with_name('qa_s12_probe_persistence.py')),
                     '--container', container, '--output', str(target / 'discovery.json'),
                     '--extracted-plist', str(target / 'learner.plist')],
                    capture_output=True, text=True, timeout=15)
                (target / 'probe.log').write_text(result.stdout + result.stderr)
                assert result.returncode == 0, 'READ_ONLY_PREFERENCE_PROBE_FAILED'
                assert (target / 'learner.plist').is_file(), 'MISSING_RAW_PREFERENCE_RECEIPT'
                receipt['plist_sha256'] = hashlib.sha256((target / 'learner.plist').read_bytes()).hexdigest()
                traces = list(Path(container).rglob('act0_hnp_trace_v1.jsonl'))
                (target / 'trace-discovery.json').write_text(json.dumps([str(p) for p in traces]))
                assert len(traces) == 1, 'NO_UNIQUE_APP_OWNED_TELEMETRY'
                (target / 'app-owned-telemetry.jsonl').write_bytes(traces[0].read_bytes())
                processes = subprocess.check_output(
                    ['xcrun', 'simctl', 'spawn', args.sim, 'launchctl', 'list'],
                    text=True, timeout=12)
                (target / 'launchctl-list.txt').write_text(processes)
                rows = [line.split() for line in processes.splitlines()
                        if 'UIKitApplication:com.example.pokerAnalyzer[' in line]
                assert len(rows) == 1 and rows[0][0].isdigit(), 'NO_UNIQUE_RUNNING_PRODUCT_PID'
                pid = int(rows[0][0])
                assert pid > 0, 'PRODUCT_PROCESS_NOT_RUNNING'
                (target / 'process.json').write_text(json.dumps(
                    {'pid': pid, 'label': rows[0][-1], 'observed_epoch': time.time()}, indent=2))
                receipt['status'] = 'CAPTURED_NATIVE_PERSISTENCE'
            assert time.time() - requested < 44, 'CHECKPOINT_CAPTURE_OUTSIDE_HOLD'
        except (AssertionError, OSError, subprocess.SubprocessError) as exc:
            receipt['status'] = 'FAIL_' + kind
            receipt['error'] = repr(exc)
        receipt['completed_epoch'] = time.time()
        receipt['completed_lag_seconds'] = receipt['completed_epoch'] - requested
        (target / 'receipt.json').write_text(json.dumps(receipt, indent=2))
        print(kind, tag, receipt['status'], flush=True)
    time.sleep(0.25)
