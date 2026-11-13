// Keep exact full-frame equality: tolerate delayed rendering, never mask it.
export async function stableChangedFrameV1(before, initial, capture, maxAttempts = 6) {
  if (!Number.isInteger(maxAttempts) || maxAttempts < 1 || maxAttempts > 6) {
    throw new RangeError('Expected one to six stability samples');
  }
  let after = initial;
  let lastPair = { after: initial, stable: initial };
  const samples = [];
  for (let attempt = 1; attempt <= maxAttempts; attempt++) {
    const stable = await capture(attempt);
    lastPair = { after, stable };
    samples.push({ after: after.sha256, stable: stable.sha256 });
    if (before.sha256 !== after.sha256 && after.sha256 === stable.sha256) {
      return { matched: true, after, stable, samples };
    }
    after = stable;
  }
  return { matched: false, ...lastPair, samples };
}
