async page => {
  const outputDir = '.';
  const baseUrl = "http://127.0.0.1:7357/";
  const viewportWidth = 393;
  const viewportHeight = 852;
  const startedServer = 0;
  const surfaces = [
    { name: 'placement', mode: 'walkthrough', query: '?act0_capture=placement' },
    { name: 'welcome', mode: 'walkthrough', query: '?act0_capture=welcome' },
    { name: 'home', mode: 'walkthrough', query: '?act0_capture=home' },
    { name: 'learn', mode: 'walkthrough', query: '?act0_capture=learn' },
    { name: 'runner_theory', mode: 'direct_state', query: '?act0_capture=runner_theory' },
    { name: 'runner_drill', mode: 'direct_state', query: '?act0_capture=runner_drill' },
    { name: 'runner_feedback_or_review', mode: 'direct_state', query: '?act0_capture=runner_feedback' },
    { name: 'review', mode: 'direct_state', query: '?act0_capture=review' },
    { name: 'practice', mode: 'direct_state', query: '?act0_capture=practice' },
    { name: 'profile', mode: 'direct_state', query: '?act0_capture=profile' },
    { name: 'world_completion', mode: 'direct_state', query: '?act0_capture=world_completion' },
  ];

  const normalizeText = text => text.replace(/\s+/g, ' ').trim();

  const inspectSurface = async () => {
    const bodyText = normalizeText(
      await page.locator('body').innerText().catch(() => ''),
    );
    const gateVisible = /Enable accessibility/i.test(bodyText);
    const buttonNames = (await page.getByRole('button').allTextContents().catch(() => []))
      .map(normalizeText)
      .filter(Boolean);
    return {
      bodyText,
      gateVisible,
      blank: bodyText.length === 0,
      buttonCount: buttonNames.length,
      buttonNames,
    };
  };

  const prepareSurface = async url => {
    await page.goto(url, { waitUntil: 'domcontentloaded' });
    await page.waitForLoadState('networkidle').catch(() => {});
    await page.waitForTimeout(1200);
    const gate = page.locator(
      'flt-semantics-placeholder[aria-label="Enable accessibility"]',
    );
    if (await gate.count()) {
      await gate.evaluate(element => element.click());
      await page.waitForTimeout(900);
    }
    await page.waitForTimeout(700);
  };

  const waitForWarmRuntime = async () => {
    const warmUrl = baseUrl + '?act0_capture=learn';
    for (let attempt = 0; attempt < 4; attempt += 1) {
      await prepareSurface(warmUrl);
      const inspection = await inspectSurface();
      const warmShot = await page.screenshot({ fullPage: false });
      if (!inspection.blank || warmShot.length >= 12000) {
        return;
      }
      await page.waitForTimeout(1500);
    }
  };

  await page.goto(baseUrl, { waitUntil: 'domcontentloaded' });
  await page.waitForLoadState('networkidle').catch(() => {});
  await page.waitForTimeout(700);

  const viewport = await page.evaluate(() => ({
    href: location.href,
    innerWidth: window.innerWidth,
    innerHeight: window.innerHeight,
    outerWidth: window.outerWidth,
    outerHeight: window.outerHeight,
    devicePixelRatio: window.devicePixelRatio,
    language: navigator.language,
    storedLanguage: localStorage.getItem('flutter.app_language_code'),
  }));

  const manifest = {
    generatedAt: new Date().toISOString(),
    appUrl: baseUrl,
    outputDir,
    viewport,
    startedFlutterServer: Boolean(startedServer),
    surfaces: [],
  };

  await waitForWarmRuntime();

  for (const surface of surfaces) {
    const timestamp = new Date().toISOString();
    const url = baseUrl + surface.query;
    const entry = {
      surface: surface.name,
      mode: surface.mode,
      url,
      viewportWidth,
      viewportHeight,
      captured: false,
      blankCheck: false,
      gatedCheck: false,
      timestamp,
    };

    try {
      await prepareSurface(url);
      const inspection = await inspectSurface();
      const file = outputDir + '/' + surface.name + '.png';
      const screenshotBytes = await page.screenshot({
        path: file,
        fullPage: false,
      });
      const visualNonBlank = screenshotBytes.length >= 12000;
      entry.blankCheck = !inspection.blank || visualNonBlank;
      entry.gatedCheck = !inspection.gateVisible;
      entry.buttonCount = inspection.buttonCount;
      entry.excerpt = inspection.bodyText.slice(0, 220);
      if (surface.name === 'learn') {
        entry.forbiddenLessonSequenceChrome =
          /\b\d+\s+Lesson\s+\d+\s+(Done|Now|Next|Locked)\b/.test(
            inspection.bodyText,
          );
      }
      entry.screenshotBytes = screenshotBytes.length;
      entry.visualNonBlank = visualNonBlank;
      if (!entry.blankCheck) {
        throw new Error('Blank surface');
      }
      if (inspection.gateVisible) {
        throw new Error('Accessibility gate still visible');
      }
      if (entry.forbiddenLessonSequenceChrome) {
        throw new Error('Forbidden compact lesson sequence chrome visible');
      }
      entry.captured = true;
      entry.file = file;
    } catch (error) {
      entry.failureReason = String(error && error.message ? error.message : error);
    }

    manifest.surfaces.push(entry);
  }

  return JSON.stringify(manifest);
}
