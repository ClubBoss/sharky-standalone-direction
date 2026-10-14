#!/usr/bin/env python3
"""Read-only preference extraction at XCTest's real UI checkpoints.
No writes to app state, route, clocks, or preferences.
"""
import argparse
import hashlib
import struct
import json
import re
import subprocess
import time
from pathlib import Path

parser = argparse.ArgumentParser()
parser.add_argument('--log', required=True)
parser.add_argument('--sim', required=True)
parser.add_argument('--output', required=True)
args = parser.parse_args()
root = Path(args.output)
seen = set()
# Resolve once before UI checkpoints; simctl container discovery previously
# consumed the checkpoint's entire hold window on the hosted runner.
container = subprocess.check_output(['xcrun', 'simctl', 'get_app_container', args.sim, 'com.example.pokerAnalyzer', 'data'], text=True).strip()
print('S11_READ_ONLY_CONTAINER_RESOLVED', flush=True)
while True:
    log = Path(args.log)
    content = log.read_text(errors='replace') if log.exists() else ''
    for kind, tag, epoch in re.findall(r'S11_(SCREEN|PERSIST)_CHECKPOINT ([A-Za-z0-9_]+) epoch=([0-9.]+)', content):
        if (kind, tag) in seen:
            continue
        seen.add((kind, tag))
        if kind == 'SCREEN':
            target = root / 'screens' / tag
            target.mkdir(parents=True, exist_ok=True)
            requested = float(epoch)
            budget = 30 if tag in ('first_install_intro', 'placement_unselected', 'placement_selected') else 15
            receipt = {'requested_epoch': requested, 'observed_epoch': time.time(), 'hold_budget_seconds': budget}
            try:
                assert 0 <= time.time() - requested < 4, 'SCREEN_MARKER_DELAY'
                result = subprocess.run(['xcrun', 'simctl', 'io', args.sim, 'screenshot', str(target / 'native.png')], capture_output=True, text=True, timeout=budget - 5)
                (target / 'capture.log').write_text(result.stdout + result.stderr)
                receipt['returncode'] = result.returncode
                assert result.returncode == 0, 'SIMCTL_SCREENSHOT_FAILED'
                data = (target / 'native.png').read_bytes()
                assert data[:8] == b'\x89PNG\r\n\x1a\n', 'NOT_NATIVE_PNG'
                receipt['width'], receipt['height'] = struct.unpack('>II', data[16:24])
                assert receipt['width'] >= 375 and receipt['height'] > receipt['width']
                receipt['sha256'] = hashlib.sha256(data).hexdigest()
                assert time.time() - requested < budget - 1, 'SCREEN_CAPTURE_OUTSIDE_HOLD'
                receipt['status'] = 'CAPTURED_NATIVE_SCREEN'
            except (AssertionError, OSError, subprocess.TimeoutExpired) as exc:
                receipt['status'] = 'FAIL_NATIVE_SCREEN'
                receipt['error'] = repr(exc)
            receipt['completed_epoch'] = time.time()
            (target / 'receipt.json').write_text(json.dumps(receipt, indent=2))
            print(kind, tag, receipt['status'], flush=True)
            continue
        target = root / tag
        target.mkdir(parents=True, exist_ok=True)
        lag = time.time() - float(epoch)
        (target / 'capture-timing.json').write_text(json.dumps({'requested_epoch': float(epoch), 'observed_epoch': time.time(), 'lag_seconds': lag}))
        if not 0 <= lag < 40:
            (target / 'probe.log').write_text('CHECKPOINT_MARKER_DELAY; refusing stale state capture')
            continue
        time.sleep(1)
        result = subprocess.run(['python3', str(Path(__file__).with_name('qa_s11_probe_persistence.py')), '--container', container, '--output', str(target / 'discovery.json'), '--extracted-plist', str(target / 'learner.plist')], capture_output=True, text=True)
        end_lag = time.time() - float(epoch)
        (target / 'capture-timing.json').write_text(json.dumps({'requested_epoch': float(epoch), 'initial_lag_seconds': lag, 'completed_epoch': time.time(), 'completed_lag_seconds': end_lag}))
        if end_lag >= 44 and (target / 'learner.plist').exists():
            (target / 'learner.plist').rename(target / 'late-learner.plist')
            result.stdout += '\nLATE_CHECKPOINT_EXTRACTION; quarantined, cannot pass verifier'
        (target / 'probe.log').write_text(result.stdout + result.stderr)
        print(tag, result.returncode, flush=True)
    time.sleep(0.25)
