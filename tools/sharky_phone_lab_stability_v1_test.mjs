import test from 'node:test';
import assert from 'node:assert/strict';
import { stableChangedFrameV1 } from './sharky_phone_lab_stability_v1.mjs';

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
