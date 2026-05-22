async page => {
  const normalizeText = text => text.replace(/\s+/g, ' ').trim();
  const prepare = async url => {
    await page.goto(url, { waitUntil: 'domcontentloaded' });
    await page.waitForLoadState('networkidle').catch(() => {});
    await page.waitForTimeout(1200);
    const gate = page.locator('flt-semantics-placeholder[aria-label="Enable accessibility"]');
    if (await gate.count()) {
      await gate.evaluate(element => element.click());
      await page.waitForTimeout(900);
    }
    await page.waitForTimeout(700);
  };

  await prepare('http://127.0.0.1:7357/?act0_capture=learn');
  const bodyText = normalizeText(await page.locator('body').innerText().catch(() => ''));
  const screenshotBytes = await page.screenshot({ path: './learn.png', fullPage: false });
  return JSON.stringify({
    href: await page.evaluate(() => location.href),
    innerWidth: await page.evaluate(() => window.innerWidth),
    innerHeight: await page.evaluate(() => window.innerHeight),
    excerpt: bodyText.slice(0, 400),
    forbiddenLessonSequenceChrome: /\b\d+\s+Lesson\s+\d+\s+(Done|Now|Next|Locked)\b/.test(bodyText),
    screenshotBytes: screenshotBytes.length
  });
}
