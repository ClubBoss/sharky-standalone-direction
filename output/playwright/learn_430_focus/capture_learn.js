async page => {
  const normalizeText = text => text.replace(/\s+/g, ' ').trim();
  await page.goto('http://127.0.0.1:7357/?act0_capture=learn', { waitUntil: 'domcontentloaded' });
  await page.waitForLoadState('networkidle').catch(() => {});
  await page.waitForTimeout(1800);
  const gate = page.locator('flt-semantics-placeholder[aria-label="Enable accessibility"]');
  if (await gate.count()) {
    await gate.evaluate(element => element.click());
    await page.waitForTimeout(900);
  }
  await page.waitForTimeout(900);
  const bodyText = normalizeText(await page.locator('body').innerText().catch(() => ''));
  const shot = await page.screenshot({ path: 'learn_430.png', fullPage: false });
  return {
    width: await page.evaluate(() => window.innerWidth),
    height: await page.evaluate(() => window.innerHeight),
    bodyText,
    forbiddenLessonSequenceChrome: /\b\d+\s+Lesson\s+\d+\s+(Done|Now|Next|Locked)\b/.test(bodyText),
    screenshotBytes: shot.length,
  };
}
