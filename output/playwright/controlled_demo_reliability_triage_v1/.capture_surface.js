async page => {
  const surfaceName = "world_completion";
  const surfaceMode = "direct_state";
  const surfaceUrl = "http://127.0.0.1:7357/?act0_capture=world_completion";
  const viewportName = "large_phone";
  const viewportWidth = Number("430");
  const viewportHeight = Number("932");

  await page.goto(surfaceUrl, { waitUntil: 'domcontentloaded' });
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

  let bodyText = '';
  for (let attempt = 0; attempt < 16; attempt += 1) {
    bodyText = (await page.locator('body').innerText().catch(() => ''))
      .replace(/\s+/g, ' ')
      .trim();
    if (bodyText.length > 0) {
      break;
    }
    await page.waitForTimeout(500);
  }
  const buttonNames = (await page.getByRole('button').allTextContents().catch(() => []))
    .map(text => text.replace(/\s+/g, ' ').trim())
    .filter(Boolean);

  return JSON.stringify({
    surface: surfaceName,
    mode: surfaceMode,
    url: surfaceUrl,
    viewport: viewportName,
    viewportWidth,
    viewportHeight,
    buttonCount: buttonNames.length,
    excerpt: bodyText.slice(0, 220),
    bodyTextLength: bodyText.length,
    gateVisible: /Enable accessibility/i.test(bodyText),
    blank: bodyText.length === 0,
    forbiddenLessonSequenceChrome:
      surfaceName === 'learn' && viewportName === 'compact_phone'
        ? /\b\d+\s+Lesson\s+\d+\s+(Done|Now|Next|Locked)\b/.test(bodyText)
        : false,
  });
}
