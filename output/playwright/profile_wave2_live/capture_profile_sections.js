await page.waitForLoadState('networkidle').catch(() => {});
await page.waitForTimeout(1400);
const gate = page.locator('flt-semantics-placeholder[aria-label="Enable accessibility"]');
if (await gate.count()) {
  await gate.evaluate(element => element.click());
  await page.waitForTimeout(900);
}
await page.waitForTimeout(900);
await page.screenshot({ path: 'profile_top.png', fullPage: false });
await page.evaluate(() => window.scrollTo(0, 620));
await page.waitForTimeout(700);
await page.screenshot({ path: 'profile_middle.png', fullPage: false });
await page.evaluate(() => window.scrollTo(0, 1280));
await page.waitForTimeout(700);
await page.screenshot({ path: 'profile_lower.png', fullPage: false });
JSON.stringify({
  top: 'profile_top.png',
  middle: 'profile_middle.png',
  lower: 'profile_lower.png',
  href: await page.evaluate(() => location.href),
  scrollY: await page.evaluate(() => window.scrollY),
});
