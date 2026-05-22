async page => {
  await page.goto('about:blank');
  await page.goto('http://127.0.0.1:7357/', { waitUntil: 'domcontentloaded' });
  await page.waitForLoadState('networkidle').catch(() => {});
  await page.evaluate(() => {
    window.localStorage.setItem(
      'flutter.app_language_code',
      JSON.stringify('en'),
    );
  });
}
