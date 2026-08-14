#!/usr/bin/env node

import { spawn } from 'node:child_process';
import { createHash } from 'node:crypto';
import { mkdirSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';

const args = new Map();
for (let i = 2; i < process.argv.length; i += 2) args.set(process.argv[i], process.argv[i + 1]);
const baseUrl = (args.get('--base-url') || '').replace(/\/$/, '');
const targetSha = args.get('--target-sha') || '';
const outDir = args.get('--out') || 'output/phone_lab_browser';
const chromeBin = process.env.CHROME_BIN || '';
if (!baseUrl || !targetSha || !chromeBin) throw new Error('Missing --base-url, --target-sha, --out or CHROME_BIN');
if (typeof WebSocket !== 'function') throw new Error(`Node ${process.version} has no WebSocket client`);
mkdirSync(outDir, { recursive: true });

const sleep = ms => new Promise(resolve => setTimeout(resolve, ms));
const sha256 = bytes => createHash('sha256').update(bytes).digest('hex');
const CHROME_STARTUP_TIMEOUT_MS = 30000;

class AssertionFailure extends Error {
  constructor(message) { super(message); this.name = 'AssertionFailure'; }
}

class Cdp {
  constructor(url) { this.url = url; this.id = 0; this.pending = new Map(); this.events = []; }
  async connect() {
    this.ws = new WebSocket(this.url);
    await new Promise((resolve, reject) => {
      const timer = setTimeout(() => reject(new Error('CDP connect timeout')), 5000);
      this.ws.addEventListener('open', () => { clearTimeout(timer); resolve(); }, { once: true });
      this.ws.addEventListener('error', () => { clearTimeout(timer); reject(new Error('CDP websocket error')); }, { once: true });
    });
    this.ws.addEventListener('message', event => {
      const msg = JSON.parse(event.data);
      if (msg.id && this.pending.has(msg.id)) {
        const entry = this.pending.get(msg.id); clearTimeout(entry.timer); this.pending.delete(msg.id);
        msg.error ? entry.reject(new Error(JSON.stringify(msg.error))) : entry.resolve(msg.result || {});
      } else if (msg.method) {
        this.events.push(msg); if (this.events.length > 6000) this.events.shift();
      }
    });
  }
  send(method, params = {}, timeout = 15000) {
    const id = ++this.id;
    return new Promise((resolve, reject) => {
      const timer = setTimeout(() => { this.pending.delete(id); reject(new Error(`CDP timeout: ${method}`)); }, timeout);
      this.pending.set(id, { resolve, reject, timer });
      this.ws.send(JSON.stringify({ id, method, params }));
    });
  }
  close() { try { this.ws?.close(); } catch (_) {} }
}

async function evaluate(cdp, expression) {
  const result = await cdp.send('Runtime.evaluate', { expression, returnByValue: true, awaitPromise: true });
  if (result.exceptionDetails) throw new Error(JSON.stringify(result.exceptionDetails));
  return result.result?.value;
}

async function waitFor(cdp, expression, timeout = 30000) {
  const end = Date.now() + timeout; let value;
  while (Date.now() < end) {
    value = await evaluate(cdp, expression);
    if (value) return value;
    await sleep(300);
  }
  throw new Error(`Timed out waiting for ${expression}; last=${JSON.stringify(value)}`);
}

async function diagnostics(cdp) {
  return await evaluate(cdp, `(() => {
    const f = document.querySelector('iframe');
    let inner=null, href=null, bodyLength=0, rendered=false, renderNode=null, error=null;
    try {
      if (f) {
        inner=[f.contentWindow.innerWidth,f.contentWindow.innerHeight];
        href=f.contentWindow.location.href;
        bodyLength=f.contentDocument?.body?.innerHTML?.length || 0;
        const node=f.contentDocument?.querySelector('flutter-view,flt-glass-pane,canvas');
        rendered=!!node; renderNode=node?.tagName || null;
      }
    } catch(e) { error=String(e); }
    const r=f?.getBoundingClientRect();
    return {
      href:location.href, title:document.title, outer:[innerWidth,innerHeight], dataset:{...(document.body?.dataset||{})},
      frame:f?{src:f.src,href,inner,bodyLength,rendered,renderNode,rect:r?[r.left,r.top,r.width,r.height]:null,error}:null
    };
  })()`);
}

async function waitForEvaluablePhone(cdp, timeout = 15000) {
  const end = Date.now() + timeout; let d;
  while (Date.now() < end) {
    d = await diagnostics(cdp);
    const identity = String(d?.dataset?.productSha || '');
    if (d?.title === 'Sharky Phone Lab' && d?.frame?.href && identity) {
      report.stage = 'CANDIDATE_EVALUABLE';
      report.candidate_surface_evaluable = true;
      report.candidate_identity_evaluable = true;
      return d;
    }
    await sleep(300);
  }
  throw new Error(`Canonical Phone Lab surface not evaluable: ${JSON.stringify(d)}`);
}

async function waitPhone(cdp, width, height, requireRender = true, timeout = 35000) {
  const end = Date.now() + timeout; let d;
  while (Date.now() < end) {
    d = await diagnostics(cdp);
    const truth = d?.dataset?.viewportPass === 'true' && d?.dataset?.productSha === targetSha &&
      d?.frame?.inner?.[0] === width && d?.frame?.inner?.[1] === height;
    if (truth && (!requireRender || d.frame.rendered)) return d;
    await sleep(350);
  }
  throw new AssertionFailure(`Phone evidence assertion timeout: ${JSON.stringify(d)}`);
}

async function navigate(cdp, url) {
  report.stage = 'NAVIGATING_CANONICAL_SURFACE';
  const result = await cdp.send('Page.navigate', { url });
  if (result.errorText) throw new Error(`Navigation failed: ${result.errorText}`);
  await waitFor(cdp, 'document.readyState === "interactive" || document.readyState === "complete"', 15000);
}

async function screenshot(cdp, name) {
  const result = await cdp.send('Page.captureScreenshot', { format: 'png', captureBeyondViewport: false }, 20000);
  const bytes = Buffer.from(result.data, 'base64'); writeFileSync(join(outDir, name), bytes);
  return { name, sha256: sha256(bytes) };
}

const startupStartedAt = Date.now();
const chrome = spawn(chromeBin, [
  '--headless=new','--no-sandbox','--disable-gpu','--disable-dev-shm-usage',
  '--remote-debugging-port=9222','--remote-allow-origins=*',
  '--user-data-dir=/tmp/sharky-phone-lab-chrome','--hide-scrollbars','about:blank'
], { stdio: ['ignore','ignore','pipe'] });
let chromeStderr='';
let chromeSpawnError=null;
let chromeExited=false;
let chromeExitCode=null;
let chromeExitSignal=null;
chrome.stderr.on('data', c => { chromeStderr += c.toString(); });
chrome.on('error', error => { chromeSpawnError = error; });
chrome.on('exit', (code, signal) => {
  chromeExited = true;
  chromeExitCode = code;
  chromeExitSignal = signal;
});

function chromeStartupSnapshot(disposition) {
  return {
    disposition,
    chrome_bin: chromeBin,
    elapsed_ms: Date.now() - startupStartedAt,
    process_alive: !chromeSpawnError && !chromeExited,
    process_exited: chromeExited,
    spawn_error: chromeSpawnError ? String(chromeSpawnError?.stack || chromeSpawnError) : null,
    exit_code: chromeExitCode,
    exit_signal: chromeExitSignal,
    stderr_tail: chromeStderr.slice(-5000)
  };
}

let cdp;
let terminalExitCode = 0;
const report = {
  schema:'sharky_phone_lab_browser_proof_v1', target_sha:targetSha, base_url:baseUrl,
  terminal_classification:'INFRASTRUCTURE_FAILURE', stage:'CHROME_STARTING',
  cdp_ready:false, candidate_surface_evaluable:false, candidate_identity_evaluable:false,
  outer_viewport:null, profiles:{}, fit_mode:'FAIL', interaction:'FAIL', exact_sha_identity:'FAIL',
  retained_3px_overflow:'NOT_REACHED', console_overflow_signals:{},
  browser_startup: chromeStartupSnapshot('STARTING')
};

async function waitForChromeCdp(url, timeout = CHROME_STARTUP_TIMEOUT_MS) {
  const deadline = startupStartedAt + timeout;
  let lastError = null;
  while (Date.now() < deadline) {
    if (chromeSpawnError || chromeExited) {
      report.browser_startup = chromeStartupSnapshot('PROCESS_EXITED');
      throw new Error(`Chrome startup PROCESS_EXITED: ${JSON.stringify(report.browser_startup)}`);
    }
    try {
      const response = await fetch(url, { cache: 'no-store' });
      if (response.ok) {
        const value = await response.json();
        report.browser_startup = chromeStartupSnapshot('READY');
        return value;
      }
      lastError = new Error(`HTTP ${response.status}`);
    } catch (error) {
      lastError = error;
    }
    await sleep(200);
  }
  if (chromeSpawnError || chromeExited) {
    report.browser_startup = chromeStartupSnapshot('PROCESS_EXITED');
    throw new Error(`Chrome startup PROCESS_EXITED: ${JSON.stringify(report.browser_startup)}`);
  }
  report.browser_startup = chromeStartupSnapshot('STARTUP_TIMEOUT');
  throw new Error(`Chrome startup STARTUP_TIMEOUT after ${report.browser_startup.elapsed_ms}ms; last=${String(lastError?.stack || lastError || 'none')}; diagnostics=${JSON.stringify(report.browser_startup)}`);
}

function browserProofMarkdown() {
  const lines = [
    '## Phone Lab browser proof',
    '',
    `- Target SHA: \`${targetSha}\``,
    `- BROWSER_EVIDENCE_STATUS=${report.terminal_classification}`,
    `- Stage: ${report.stage}`,
    `- CDP ready: ${report.cdp_ready}`,
    `- Candidate surface evaluable: ${report.candidate_surface_evaluable}`,
    `- Candidate identity evaluable: ${report.candidate_identity_evaluable}`,
    `- CHROME STARTUP: ${report.browser_startup.disposition} in ${report.browser_startup.elapsed_ms} ms`
  ];
  if (report.terminal_classification === 'PASS') {
    lines.push(
      `- OUTER VIEWPORT: ${report.outer_viewport.join(' x ')} CSS`,
      `- COMPACT INNER: ${report.profiles.compact.measured_inner.join(' x ')} CSS - PASS`,
      `- TALL INNER: ${report.profiles.tall.measured_inner.join(' x ')} CSS - PASS`,
      `- FIT MODE: ${report.fit_mode}`,
      `- INTERACTION: ${report.interaction}`,
      `- EXACT SHA IDENTITY: ${report.exact_sha_identity}`,
      `- RETAINED 3PX OVERFLOW: ${report.retained_3px_overflow}`
    );
  } else {
    lines.push(`- Underlying error: ${report.error || 'unknown'}`);
    lines.push('- Rendered browser evidence unavailable; no browser PASS is claimed.');
  }
  return lines.join('\n') + '\n';
}

try {
  const targets = await waitForChromeCdp('http://127.0.0.1:9222/json/list');
  const target = targets.find(t => t.type === 'page' && !String(t.url).startsWith('chrome-extension://')) || targets.find(t => t.type === 'page');
  if (!target) throw new Error(`No page CDP target: ${JSON.stringify(targets.map(t => ({type:t.type,url:t.url})))}`);
  report.stage = 'CDP_DISCOVERED';
  cdp = new Cdp(target.webSocketDebuggerUrl); await cdp.connect();
  report.cdp_ready = true;
  report.stage = 'CDP_READY';
  await cdp.send('Page.enable'); await cdp.send('Runtime.enable'); await cdp.send('Log.enable'); await cdp.send('Network.enable');
  await cdp.send('Emulation.setDeviceMetricsOverride', { width:1280, height:720, deviceScaleFactor:1, mobile:false });

  async function profile(name, w, h) {
    cdp.events.length=0;
    await navigate(cdp, `${baseUrl}/phone?profile=${name}&surface=home&presentation=fit`);
    await waitForEvaluablePhone(cdp);
    report.stage = 'ASSERTING_BROWSER_EVIDENCE';
    const d = await waitPhone(cdp, w, h, true, 35000);
    const shot = await screenshot(cdp, `${name}-home-fit.png`);
    const scale = Number(d.dataset.displayScale || '0');
    report.profiles[name] = { expected:[w,h], measured_inner:d.frame.inner, outer:d.outer, display_scale:scale,
      viewport_pass:true, flutter_ready:true, render_node:d.frame.renderNode, product_sha:d.dataset.productSha,
      screenshot:shot.name, screenshot_sha256:shot.sha256 };
    report.outer_viewport=d.outer;
    return report.profiles[name];
  }

  const compact=await profile('compact',375,812);
  const tall=await profile('tall',402,874);
  report.fit_mode = compact.display_scale>0 && compact.display_scale<1 && tall.display_scale>0 && tall.display_scale<1 ? 'PASS':'FAIL';
  report.exact_sha_identity = compact.product_sha===targetSha && tall.product_sha===targetSha ? 'PASS':'FAIL';
  if (report.fit_mode!=='PASS' || report.exact_sha_identity!=='PASS') {
    throw new AssertionFailure(`Truth gate failed: ${JSON.stringify(report)}`);
  }

  cdp.events.length=0;
  await navigate(cdp, `${baseUrl}/phone?profile=compact&surface=live&presentation=fit`);
  await waitForEvaluablePhone(cdp);
  report.stage = 'ASSERTING_BROWSER_EVIDENCE';
  const live=await waitPhone(cdp,375,812,true,35000);
  const before=await screenshot(cdp,'compact-live-before.png');
  const r=live.frame.rect; const x=r[0]+r[2]*0.5; const y=r[1]+r[3]*0.965;
  await cdp.send('Input.dispatchMouseEvent',{type:'mouseMoved',x,y});
  await cdp.send('Input.dispatchMouseEvent',{type:'mousePressed',x,y,button:'left',buttons:1,clickCount:1});
  await cdp.send('Input.dispatchMouseEvent',{type:'mouseReleased',x,y,button:'left',buttons:0,clickCount:1});
  await sleep(1500); const after=await screenshot(cdp,'compact-live-after.png'); await sleep(900); const stable=await screenshot(cdp,'compact-live-stable.png');
  report.interaction_details={rendered_pointer:[Number(x.toFixed(1)),Number(y.toFixed(1))],before_sha256:before.sha256,after_sha256:after.sha256,stable_sha256:stable.sha256};
  if (before.sha256!==after.sha256 && after.sha256===stable.sha256) report.interaction='PASS';
  else throw new AssertionFailure(`Interaction did not reach stable transition: ${JSON.stringify(report.interaction_details)}`);

  async function overflow(profileName,w,h) {
    cdp.events.length=0;
    await navigate(cdp, `${baseUrl}/phone?profile=${profileName}&surface=runner_theory&presentation=fit`);
    await waitForEvaluablePhone(cdp);
    report.stage = 'ASSERTING_BROWSER_EVIDENCE';
    await waitPhone(cdp,w,h,true,35000); await sleep(1000);
    const shot=await screenshot(cdp,`${profileName}-runner-theory.png`);
    const text=cdp.events.map(e=>JSON.stringify(e)).join('\n');
    const exact=/BOTTOM OVERFLOWED BY 3 PIXELS/i.test(text), generic=/(?:BOTTOM )?OVERFLOWED BY \d+(?:\.\d+)? PIXELS/i.test(text);
    report.console_overflow_signals[profileName]={exact_3px:exact,generic_overflow:generic,screenshot:shot.name,screenshot_sha256:shot.sha256};
    return exact||generic;
  }
  report.retained_3px_overflow = (await overflow('compact',375,812)) || (await overflow('tall',402,874)) ? 'REPRODUCED_MOBILE':'NOT_REACHED';
  report.terminal_classification = 'PASS';
  report.stage = 'PASS';
} catch(error) {
  if (report.browser_startup.disposition === 'STARTING') {
    report.browser_startup = chromeStartupSnapshot(chromeSpawnError || chromeExited ? 'PROCESS_EXITED' : 'STARTUP_TIMEOUT');
  }
  report.terminal_classification = error instanceof AssertionFailure ? 'ASSERTION_FAILURE' : 'INFRASTRUCTURE_FAILURE';
  if (report.terminal_classification === 'ASSERTION_FAILURE') report.stage = 'ASSERTION_FAILURE';
  else if (report.stage !== 'CHROME_STARTING') report.stage = `INFRASTRUCTURE_FAILURE_AT_${report.stage}`;
  else report.stage = 'INFRASTRUCTURE_FAILURE_AT_CHROME_STARTING';
  try { report.failure_diagnostics=cdp?await diagnostics(cdp):null; } catch(_) {}
  report.error=String(error?.stack||error); report.chrome_stderr_tail=chromeStderr.slice(-5000);
  try { report.browser_events_tail=cdp?.events.slice(-120).map(e=>({method:e.method,params:e.params})); } catch(_) {}
  terminalExitCode = report.terminal_classification === 'ASSERTION_FAILURE' ? 21 : 20;
} finally {
  try { cdp?.close(); } catch (_) {}
  chrome.kill('SIGKILL');
}

writeFileSync(join(outDir,'browser-proof.json'),JSON.stringify(report,null,2)+'\n');
const md=browserProofMarkdown();
writeFileSync(join(outDir,'browser-proof.md'),md);
process.stdout.write(md);
process.exitCode = terminalExitCode;
