async page => {
  const gate = page.locator(
    'flt-semantics-placeholder[aria-label="Enable accessibility"]',
  );
  if (await gate.count()) {
    await gate.evaluate(element => element.click());
    await page.waitForTimeout(800);
  }
}
