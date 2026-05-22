async page => {
  const outputDir = '.';
  const results = [];
  const excludedButtonNames = [
    /^Home$/i,
    /^Learn$/i,
    /^Practice$/i,
    /^Review$/i,
    /^You$/i,
    /^Continue$/i,
    /^Back$/i,
    /^Start$/i,
    /^Open Poker from Zero$/i,
    /^Later$/i,
    /^Replay$/i,
    /^Retry$/i,
    /^Lesson /i,
  ];

  const escapeRegExp = value =>
    value.replace(/[.*+?^${}()|[\]\\]/g, '\\\\$&');

  const clickButtonContaining = async text => {
    const button = page
      .getByRole('button', { name: new RegExp(escapeRegExp(text), 'i') })
      .first();
    await button.waitFor({ state: 'attached', timeout: 10000 });
    await button.scrollIntoViewIfNeeded().catch(() => {});
    await button.click({ force: true });
    await page.waitForTimeout(450);
  };

  const clickLastButtonContaining = async text => {
    const button = page
      .getByRole('button', { name: new RegExp(escapeRegExp(text), 'i') })
      .last();
    await button.waitFor({ state: 'attached', timeout: 10000 });
    await button.scrollIntoViewIfNeeded().catch(() => {});
    await button.click({ force: true });
    await page.waitForTimeout(450);
  };

  const clickButtonExact = async text => {
    const pattern = text
      .trim()
      .split(/\s+/)
      .map(escapeRegExp)
      .join('\\s+');
    const button = page
      .getByRole('button', {
        name: new RegExp('^' + pattern + '$', 'i'),
      })
      .first();
    await button.waitFor({ state: 'attached', timeout: 10000 });
    await button.scrollIntoViewIfNeeded().catch(() => {});
    await button.click({ force: true });
    await page.waitForTimeout(450);
  };

  const openTab = async label => {
    const tab = page.getByRole('button', { name: new RegExp('^' + escapeRegExp(label) + '$', 'i') }).last();
    await tab.waitFor({ state: 'visible', timeout: 10000 });
    await tab.click();
    await page.waitForTimeout(500);
  };

  const bodyText = async () => {
    try {
      const text = await page.locator('body').innerText();
      return text.replace(/\\s+/g, ' ').trim();
    } catch (_) {
      return '';
    }
  };

  const capture = async name => {
    const text = await bodyText();
    if (!text) {
      throw new Error('Blank surface at ' + name);
    }
    if (/Enable accessibility/i.test(text)) {
      throw new Error('Accessibility gate still visible at ' + name);
    }
    const file = outputDir + '/' + name + '.png';
    await page.screenshot({ path: file, fullPage: false });
    results.push({
      name,
      file,
      url: page.url(),
      excerpt: text.slice(0, 220),
    });
  };

  const firstRunnerOptionName = async () => {
    const names = await page.getByRole('button').allTextContents();
    for (const rawName of names) {
      const name = rawName.replace(/\\s+/g, ' ').trim();
      if (!name) {
        continue;
      }
      if (excludedButtonNames.some(pattern => pattern.test(name))) {
        continue;
      }
      if (/Start placement/i.test(name)) {
        continue;
      }
      return name;
    }
    return null;
  };

  const advanceRunnerToPrompt = async () => {
    for (let i = 0; i < 14; i += 1) {
      const optionName = await firstRunnerOptionName();
      if (optionName) {
        return optionName;
      }
      const continueButton = page
        .getByRole('button', {
          name: /^(Continue|Start|Open Poker from Zero|Next)$/i,
        })
        .first();
      if (await continueButton.count()) {
        await continueButton.click();
        await page.waitForTimeout(500);
        continue;
      }
      await page.waitForTimeout(400);
    }
    throw new Error('Runner did not reveal a visible prompt option.');
  };

  const ensureReviewTabVisible = async () => {
    const reviewTab = page.getByRole('button', { name: /^Review$/i }).last();
    if (await reviewTab.count()) {
      return;
    }
    const continueButton = page.getByRole('button', { name: /^Continue$/i }).first();
    if (await continueButton.count()) {
      await continueButton.click();
      await page.waitForTimeout(500);
    }
  };

  const ensureAccessibilityEnabled = async () => {
    const gate = page.locator(
      'flt-semantics-placeholder[aria-label="Enable accessibility"]',
    );
    if (await gate.count()) {
      await gate.evaluate(element => element.click());
      await page.waitForTimeout(700);
    }
  };

  await page.waitForLoadState('domcontentloaded');
  await page.waitForLoadState('networkidle').catch(() => {});
  await page.waitForTimeout(1200);
  await ensureAccessibilityEnabled();
  await page.waitForTimeout(600);
  await clickButtonExact('Start placement');
  await clickButtonContaining('I have not really played yet');

  await capture('placement');
  await clickButtonExact('Start from zero');
  await capture('welcome');

  await clickButtonExact('Open Poker from Zero');
  await clickButtonExact('Open Poker from Zero');

  await page.getByRole('button', { name: /^Home$/i }).last().waitFor({
    state: 'visible',
    timeout: 10000,
  });
  await capture('home');

  await openTab('Learn');
  await capture('learn');

  const runnerBaseUrl = await page.evaluate(
    () => window.location.origin + window.location.pathname,
  );
  const runnerUrl =
    runnerBaseUrl +
    '?act0_capture=runner&world=world_1&lesson=what_poker_is&task=what_poker_is_theory';
  await page.goto(runnerUrl, { waitUntil: 'domcontentloaded' });
  await page.waitForTimeout(800);
  await ensureAccessibilityEnabled();
  await page.waitForTimeout(700);
  await capture('runner_theory');

  const optionName = await advanceRunnerToPrompt();
  await capture('runner_drill');

  await clickButtonContaining(optionName);
  await page.waitForTimeout(700);
  await capture('runner_feedback');

  await ensureReviewTabVisible();
  await openTab('Review');
  await capture('review');

  await openTab('Practice');
  await capture('practice');

  await openTab('You');
  await capture('profile');

  return JSON.stringify({
    viewport: await page.evaluate(() => ({
      innerWidth: window.innerWidth,
      innerHeight: window.innerHeight,
      outerWidth: window.outerWidth,
      outerHeight: window.outerHeight,
      devicePixelRatio: window.devicePixelRatio,
      language: navigator.language,
      storedLanguage: window.localStorage.getItem('flutter.app_language_code'),
    })),
    surfaces: results,
    worldCompletionReachable: false,
  });
}
