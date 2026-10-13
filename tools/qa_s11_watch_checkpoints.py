#!/usr/bin/env python3
"""Read-only preference extraction at XCTest's real UI checkpoints.
No writes to app state, route, clocks, or preferences.
"""
import argparse
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
while True:
    log = Path(args.log)
    content = log.read_text(errors='replace') if log.exists() else ''
    for tag, epoch in re.findall(r'S11_PERSIST_CHECKPOINT (C[12]_[A-Za-z0-9_]+) epoch=([0-9.]+)', content):
        if tag in seen:
            continue
        seen.add(tag)
        target = root / tag
        target.mkdir(parents=True, exist_ok=True)
        lag = time.time() - float(epoch)
        (target / 'capture-timing.json').write_text(json.dumps({'requested_epoch': float(epoch), 'observed_epoch': time.time(), 'lag_seconds': lag}))
        if not 0 <= lag < 12:
            (target / 'probe.log').write_text('CHECKPOINT_MARKER_DELAY; refusing stale state capture')
            continue
        time.sleep(1)
        container = subprocess.check_output(['xcrun', 'simctl', 'get_app_container', args.sim, 'com.example.pokerAnalyzer', 'data'], text=True).strip()
        result = subprocess.run(['python3', str(Path(__file__).with_name('qa_s11_probe_persistence.py')), '--container', container, '--output', str(target / 'discovery.json'), '--extracted-plist', str(target / 'learner.plist')], capture_output=True, text=True)
        (target / 'probe.log').write_text(result.stdout + result.stderr)
        print(tag, result.returncode, flush=True)
    time.sleep(0.25)
