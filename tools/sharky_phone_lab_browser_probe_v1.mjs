#!/usr/bin/env node

import { spawn } from 'node:child_process';
import { createHash } from 'node:crypto';
import { mkdirSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';

const args = new Map();
for (let i = 2; i < process.argv.length; i += 2) {
  args.set(process.argv[i], process.argv[i + 1]);
}
const baseUrl = (args.get('--base-url') || '').replace(/\/$/, '');
const targetSha = args.get('--target-sha') || '';
const outDir = args.get('--out') || 'output/phone_lab_browser';
const chromeBin = process.env.CHROME_BIN || '';
if (!baseUrl || !targetSha || !chromeBin) {
  throw new Error('Usage requires --base-url, --target-sha, --out and CHROME_BIN');
}
if (typeof WebSocket !== 'function') {
  throw new Error(`Node ${process.version} does not expose a WebSocket client`);
}
mkdirSync(outDir, { recursive: true });

const sleep = ms => new Promise(resolve => setTimeout(resolve, ms));
const hash = bytes => createHash('sha256').update(bytes).digest('hex');

class CdpClient {
  constructor(url) {
    this.url = url;
    this.nextId = 0;
    this.pending = new Map();
    this.events = [];
  }

  async connect() {
    this.socket = new WebSocket(this.url);
    await new Promise((resolve, reject) => {
      const timeout = setTimeout(() => reject(new Error('CDP websocket timeout')), 5000);
      this.socket.addEventListener('open', () => {
        clearTimeout(timeout);
        resolve();
      }, { once: true });
      this.socket.addEventListener('error', event => {
        clearTimeout(timeout);
        reject(new Error(`CDP websocket error: ${event.message || 'unknown'}`));
      }, { once: true });
    });
    this.socket.addEventListener('message', event => {
      const message = JSON.parse(event.data);
      if (message.id && this.pending.has(message.id)) {
        const { resolve, reject, timer } = this.pending.get(message.id);
        clearTimeout(timer);
        this.pending.delete(message.id);
        if (message.error) reject(new Error(JSON.stringify(message.error)));
        else resolve(message.result || {});
      } else if (message.method) {
        this.events.push(message);
        if (this.events.length > 5000) this.events.shift();
      }
    });
  }

  send(method, params = {}, timeoutMs = 10000) {
    const id = ++this.nextId;
    return new Promise((resolve, reject) => {
      const timer = setTimeout(() => {
        this.pending.delete(id);
        reject(new Error(`CDP timeout: ${method}`));
      }, timeoutMs);
      this.pending.set(id, { resolve, reject, timer });
      this.socket.send(JSON.stringify({ id, method, params }));
    });
  }

  close() {
    try { this.socket.close(); } catch (_) {}
  }
}

async function pollJson(url, timeoutMs = 10000) {
  const deadline = Date.now() + timeoutMs;
  let lastError;
  while (Date.now() < deadline) {
    try {
      const response = await fetch(url, { cache: 'no-store' });
      if (response.ok) return await response.json();
      lastError = new Error(`HTTP ${response.status}`);
    } catch (error) {
      lastError = error;
    }
    await sleep(200);
  }
  throw lastError || new Error(`Timed out fetching ${url}`);
}

async function evaluate(cdp, expression) {
  const result = await cdp.send('Runtime.evaluate', {
    expression,
    returnByValue: true,
    awaitPromise: true,
  });
  const remote = result.result || {};
  if (remote.exceptionDetails) throw new Error(JSON.stringify(remote.exceptionDetails));
  return remote.value;
}

async function waitFor(cdp, expression, timeoutMs = 25000) {
  const deadline = Date.now() + timeoutMs;
  let value;
  while (Date.now() < deadline) {
    value = await evaluate(cdp, expression);
    if (value) return value;
    await sleep(350);
  }
  throw new Error(`Timed out waiting for condition: ${expression}; last=${JSON.stringify(value)}`);
}

async function navigate(cdp, url) {
  await cdp.send('Page.navigate', { url });
  await waitFor(cdp, 'document.readyState === "complete" || document.readyState === "interactive"', 15000);
}

async function screenshot(cdp, filename) {
  const result = await cdp.send('Page.captureScreenshot', {
    format: 'png',
    captureBeyondViewport: false,
  }, 15000);
  const bytes = Buffer.from(result.data, 'base64');
  writeFileSync(join(outDir, filename), bytes);
  return { filename, sha256: hash(bytes), bytes };
}

const chromeArgs = [
  '--headless=new',
  '--no-sandbox',
  '--disable-gpu',
  '--disable-dev-shm-usage',
  '--remote-debugging-port=9222',
  '--remote-allow-origins=*',
  '--user-data-dir=/tmp/sharky-phone-lab-chrome',
  '--hide-scrollbars',
  'about:blank',
];
const chrome = spawn(chromeBin, chromeArgs, {
  stdio: ['ignore', 'ignore', 'pipe'],
});
let chromeStderr = '';
chrome.stderr.on('data', chunk => { chromeStderr += chunk.toString(); });
let cdp;

const report = {
  schema: 'sharky_phone_lab_browser_proof_v1',
  target_sha: targetSha,
  base_url: baseUrl,
  outer_viewport: null,
  profiles: {},
  fit_mode: 'FAIL',
  interaction: 'FAIL',
  exact_sha_identity: 'FAIL',
  retained_3px_overflow: 'NOT_REACHED',
  console_overflow_signals: {},
};

try {
  const tabs = await pollJson('http://127.0.0.1:9222/json/list', 12000);
  if (!tabs.length) throw new Error('Chrome exposed no CDP tab');
  cdp = new CdpClient(tabs[0].webSocketDebuggerUrl);
  await cdp.connect();
  await cdp.send('Page.enable');
  await cdp.send('Runtime.enable');
  await cdp.send('Log.enable');
  await cdp.send('Emulation.setDeviceMetricsOverride', {
    width: 1280,
    height: 720,
    deviceScaleFactor: 1,
    mobile: false,
  });

  async function probeProfile(profile, expectedWidth, expectedHeight) {
    cdp.events.length = 0;
    const url = `${baseUrl}/phone.html?profile=${profile}&surface=home&presentation=fit`;
    await navigate(cdp, url);
    await waitFor(cdp, `document.body?.dataset.viewportPass === 'true' && document.body?.dataset.productSha === ${JSON.stringify(targetSha)}`, 30000);
    await sleep(1800);
    const truth = await evaluate(cdp, `(() => {
      const frame = document.querySelector('iframe');
      return {
        outer: [window.innerWidth, window.innerHeight],
        inner: frame ? [frame.contentWindow.innerWidth, frame.contentWindow.innerHeight] : null,
        profile: document.body.dataset.profile,
        scale: Number(document.body.dataset.displayScale || '0'),
        viewportPass: document.body.dataset.viewportPass,
        productSha: document.body.dataset.productSha,
        frameHref: frame?.contentWindow.location.href || null,
        flutterReady: !!frame?.contentDocument?.querySelector('flutter-view, flt-glass-pane'),
      };
    })()`);
    const expectedPass = truth.inner?.[0] === expectedWidth && truth.inner?.[1] === expectedHeight;
    if (!expectedPass || truth.viewportPass !== 'true') {
      throw new Error(`${profile} inner viewport mismatch: ${JSON.stringify(truth)}`);
    }
    if (!truth.flutterReady) throw new Error(`${profile} Flutter frame did not boot`);
    if (truth.productSha !== targetSha) throw new Error(`${profile} SHA mismatch`);
    const shot = await screenshot(cdp, `${profile}-home-fit.png`);
    report.profiles[profile] = {
      expected: [expectedWidth, expectedHeight],
      measured_inner: truth.inner,
      outer: truth.outer,
      display_scale: truth.scale,
      viewport_pass: true,
      flutter_ready: true,
      product_sha: truth.productSha,
      screenshot: shot.filename,
      screenshot_sha256: shot.sha256,
    };
    report.outer_viewport = truth.outer;
    return truth;
  }

  const compact = await probeProfile('compact', 375, 812);
  const tall = await probeProfile('tall', 402, 874);
  report.fit_mode = compact.scale > 0 && compact.scale < 1 && tall.scale > 0 && tall.scale < 1 ? 'PASS' : 'FAIL';
  report.exact_sha_identity = compact.productSha === targetSha && tall.productSha === targetSha ? 'PASS' : 'FAIL';
  if (report.fit_mode !== 'PASS' || report.exact_sha_identity !== 'PASS') {
    throw new Error(`Phone Lab truth gate failed: fit=${report.fit_mode} sha=${report.exact_sha_identity}`);
  }

  // Raw-pointer interaction proof on the ordinary root. This is deliberately
  // the same browser-level input class used by the accepted web feasibility
  // proof: no semantics activation and no direct state mutation.
  cdp.events.length = 0;
  await navigate(cdp, `${baseUrl}/phone.html?profile=compact&surface=live&presentation=fit`);
  await waitFor(cdp, `document.body?.dataset.viewportPass === 'true' && document.body?.dataset.productSha === ${JSON.stringify(targetSha)}`, 30000);
  await sleep(2200);
  const before = await screenshot(cdp, 'compact-live-before.png');
  const rect = await evaluate(cdp, `(() => {
    const r = document.querySelector('iframe').getBoundingClientRect();
    return {left:r.left, top:r.top, width:r.width, height:r.height};
  })()`);
  const x = rect.left + rect.width * 0.5;
  const y = rect.top + rect.height * 0.965;
  await cdp.send('Input.dispatchMouseEvent', { type: 'mouseMoved', x, y });
  await cdp.send('Input.dispatchMouseEvent', { type: 'mousePressed', x, y, button: 'left', buttons: 1, clickCount: 1 });
  await cdp.send('Input.dispatchMouseEvent', { type: 'mouseReleased', x, y, button: 'left', buttons: 0, clickCount: 1 });
  await sleep(1400);
  const after = await screenshot(cdp, 'compact-live-after.png');
  await sleep(900);
  const stable = await screenshot(cdp, 'compact-live-stable.png');
  report.interaction_details = {
    logical_pointer: [187.5, Math.round(812 * 0.965 * 10) / 10],
    rendered_pointer: [Math.round(x * 10) / 10, Math.round(y * 10) / 10],
    before_sha256: before.sha256,
    after_sha256: after.sha256,
    stable_sha256: stable.sha256,
  };
  if (before.sha256 !== after.sha256 && after.sha256 === stable.sha256) {
    report.interaction = 'PASS';
  } else {
    throw new Error(`Raw-pointer interaction did not produce a stable state transition: ${JSON.stringify(report.interaction_details)}`);
  }

  async function captureOverflowEvidence(profile) {
    cdp.events.length = 0;
    const url = `${baseUrl}/phone.html?profile=${profile}&surface=runner_theory&presentation=fit`;
    await navigate(cdp, url);
    await waitFor(cdp, `document.body?.dataset.viewportPass === 'true' && document.body?.dataset.productSha === ${JSON.stringify(targetSha)}`, 30000);
    await sleep(2200);
    const shot = await screenshot(cdp, `${profile}-runner-theory.png`);
    const eventText = cdp.events.map(event => JSON.stringify(event)).join('\n');
    const exact = /BOTTOM OVERFLOWED BY 3 PIXELS/i.test(eventText);
    const generic = /(?:BOTTOM )?OVERFLOWED BY \d+(?:\.\d+)? PIXELS/i.test(eventText);
    report.console_overflow_signals[profile] = {
      exact_3px: exact,
      generic_overflow: generic,
      screenshot: shot.filename,
      screenshot_sha256: shot.sha256,
    };
    return exact || generic;
  }

  const compactOverflow = await captureOverflowEvidence('compact');
  const tallOverflow = await captureOverflowEvidence('tall');
  if (compactOverflow || tallOverflow) {
    report.retained_3px_overflow = 'REPRODUCED_MOBILE';
  } else {
    // Console silence alone is not strong enough to adjudicate a visible
    // Flutter debug overflow banner. The screenshots are retained for the
    // mastermind/visual inspection and the report stays NOT_REACHED until it
    // is visually adjudicated.
    report.retained_3px_overflow = 'NOT_REACHED';
  }

  if (report.interaction !== 'PASS') throw new Error('Interaction proof failed');
} catch (error) {
  report.error = String(error?.stack || error);
  report.chrome_stderr_tail = chromeStderr.slice(-5000);
  writeFileSync(join(outDir, 'browser-proof.json'), JSON.stringify(report, null, 2) + '\n');
  throw error;
} finally {
  try { cdp?.close(); } catch (_) {}
  chrome.kill('SIGKILL');
}

writeFileSync(join(outDir, 'browser-proof.json'), JSON.stringify(report, null, 2) + '\n');
const markdown = [
  '## Phone Lab browser proof',
  '',
  `- Target SHA: \`${targetSha}\``,
  `- OUTER VIEWPORT: ${report.outer_viewport?.join(' × ')} CSS`,
  `- COMPACT INNER: ${report.profiles.compact.measured_inner.join(' × ')} CSS — PASS`,
  `- TALL INNER: ${report.profiles.tall.measured_inner.join(' × ')} CSS — PASS`,
  `- FIT MODE: ${report.fit_mode}`,
  `- INTERACTION: ${report.interaction}`,
  `- EXACT SHA IDENTITY: ${report.exact_sha_identity}`,
  `- RETAINED 3PX OVERFLOW: ${report.retained_3px_overflow}`,
].join('\n') + '\n';
writeFileSync(join(outDir, 'browser-proof.md'), markdown);
process.stdout.write(markdown);
