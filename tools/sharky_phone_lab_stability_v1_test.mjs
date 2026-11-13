import test from 'node:test';
import assert from 'node:assert/strict';
import { stableChangedFrameV1, writeStableFramePairV1 } from './sharky_phone_lab_stability_v1.mjs';
import { createHash } from 'node:crypto';
import { mkdtempSync, writeFileSync, readFileSync, rmSync, unlinkSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { spawnSync } from 'node:child_process';

async function frames(before, initial, values) {
  let calls = 0;
  const result = await stableChangedFrameV1(
    { sha256: before }, { sha256: initial },
    async () => ({ sha256: values[Math.min(calls++, values.length - 1)] }),
  );
  return { ...result, calls };
}
test('a changed full frame must repeat exactly', async () => {
  const result = await frames('entry', 'home', ['home']);
  assert.equal(result.matched, true);
  assert.equal(result.calls, 1);
});
test('delayed asset/frame may settle within the same bounded interaction', async () => {
  const result = await frames('entry', 'loading-avatar', ['home', 'home']);
  assert.equal(result.matched, true);
  assert.equal(result.calls, 2);
  assert.deepEqual(result.samples.map(x => x.stable), ['home', 'home']);
});
test('unchanged stable entry cannot pass', async () => {
  const result = await frames('entry', 'entry', ['entry']);
  assert.equal(result.matched, false);
  assert.equal(result.calls, 6);
});
test('perpetual different full frames fail at the bound', async () => {
  const result = await frames('entry', 'a', ['b', 'c', 'd', 'e', 'f', 'g']);
  assert.equal(result.matched, false);
  assert.equal(result.calls, 6);
  assert.notEqual(result.after.sha256, result.stable.sha256);
});
test('a transient change that returns to entry does not pass', async () => {
  assert.equal((await frames('entry', 'transient', ['entry'])).matched, false);
});
test('invalid/unbounded sampling is rejected', async () => {
  for (const limit of [0, 7, Infinity, 1.5]) {
    await assert.rejects(stableChangedFrameV1({sha256:'a'},{sha256:'b'},async () => ({sha256:'b'}),limit), RangeError);
  }
});

test('fixture: delayed stable pair preserves the unchanged packager checksum contract', async () => {
  const dir = mkdtempSync(join(tmpdir(), 'sharky-stable-pair-'));
  const shot = (name, bytes) => {
    writeFileSync(join(dir, name), bytes);
    return { name, sha256: createHash('sha256').update(bytes).digest('hex') };
  };
  try {
    const before = shot('compact-live-before.png', 'fixture-entry');
    const initial = shot('compact-live-first-after.png', 'fixture-avatar-loading');
    const one = shot('compact-live-stable-1.png', 'fixture-home');
    const two = shot('compact-live-stable-2.png', 'fixture-home');
    const pending = [one, two];
    const transition = await stableChangedFrameV1(before, initial, async () => pending.shift());
    const proof = { interaction_details: {
      before_sha256: before.sha256,
      after_sha256: transition.after.sha256,
      stable_sha256: transition.stable.sha256,
    } };
    const packager = fileURLToPath(new URL('./package_sharky_evidence_v1.py', import.meta.url));
    const validates = () => {
      const result = spawnSync('python3', ['-c',
        'import importlib.util,json,sys;from pathlib import Path;s=importlib.util.spec_from_file_location("packager",sys.argv[1]);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);print(m.source_hashes_match(Path(sys.argv[2]),json.loads(sys.argv[3])))',
        packager, dir, JSON.stringify(proof)], { encoding: 'utf8' });
      assert.equal(result.status, 0, result.stderr);
      return result.stdout.trim() === 'True';
    };
    assert.equal(validates(), false, 'The old producer misses canonical pair files.');
    writeStableFramePairV1(dir, transition);
    assert.equal(validates(), true);
    assert.equal(readFileSync(join(dir, initial.name), 'utf8'), 'fixture-avatar-loading');
    writeFileSync(join(dir, 'compact-live-after.png'), 'tampered');
    assert.equal(validates(), false);
    writeStableFramePairV1(dir, transition);
    unlinkSync(join(dir, 'compact-live-stable.png'));
    assert.equal(validates(), false);
    assert.throws(() => writeStableFramePairV1(dir, { matched: false }));
  } finally { rmSync(dir, { recursive: true, force: true }); }
});
