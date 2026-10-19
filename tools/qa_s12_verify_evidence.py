#!/usr/bin/env python3
"""S11 hosted only: independently judge persisted, synthetic native learner evidence.
Never accepts a UI banner, exit code, fixture row or source-only result as graded proof.
"""
import json
import re
import hashlib
import plistlib
import sys
from pathlib import Path

# Independent screenshot gate: actual PNG bytes must arrive during the held UI
# frame. Missing, late, failed or corrupted native captures cannot become PASS.
if len(sys.argv) == 4 and sys.argv[1] == '--screens':
    log = Path(sys.argv[2]).read_text()
    root = Path(sys.argv[3])
    markers = re.findall(r'S11_SCREEN_CHECKPOINT ([A-Za-z0-9_]+) epoch=([0-9.]+)', log)
    verdict = {'status': 'FAIL_NATIVE_SCREENS', 'screens': []}
    try:
        assert markers, 'NO_NATIVE_SCREEN_CHECKPOINTS'
        assert len({tag for tag, _ in markers}) == len(markers), 'DUPLICATE_SCREEN_TAG'
        for tag, epoch in markers:
            path = root / 'screens' / tag
            receipt = json.loads((path / 'receipt.json').read_text())
            releases = re.findall(r'S11_SCREEN_RELEASE ' + re.escape(tag) + r' epoch=([0-9.]+)', log)
            assert len(releases) == 1, 'SCREEN_RELEASE_NOT_PROVEN'
            assert receipt['status'] == 'CAPTURED_NATIVE_SCREEN' and receipt['returncode'] == 0
            assert float(epoch) == receipt['requested_epoch']
            assert receipt['completed_epoch'] < float(releases[0])
            budget = 45
            assert receipt['hold_budget_seconds'] == budget
            assert 0 <= receipt['completed_epoch'] - float(epoch) < budget - 1
            data = (path / 'native.png').read_bytes()
            assert data[:8] == b'\x89PNG\r\n\x1a\n'
            assert hashlib.sha256(data).hexdigest() == receipt['sha256']
            verdict['screens'].append({'tag': tag, **receipt})
        verdict['status'] = 'PASS_NATIVE_SCREENS'
    except (AssertionError, KeyError, OSError, ValueError) as exc:
        verdict['error'] = repr(exc)
    (root / (Path(sys.argv[2]).stem + '-screen-verdict.json')).write_text(json.dumps(verdict, indent=2))
    print(verdict['status'], len(verdict['screens']), verdict.get('error', ''))
    sys.exit(0 if verdict['status'] == 'PASS_NATIVE_SCREENS' else 1)

raise SystemExit("Use --screens LOG CHECKPOINTS")
