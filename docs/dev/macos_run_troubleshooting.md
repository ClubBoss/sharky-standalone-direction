# macOS Run Troubleshooting

## Symptoms
- Gray or blank macOS window appears after flutter run, sometimes after a few seconds.
- Terminal logs include `Failed to foreground app; open returned 1`.
- Running VS Code command `Developer: Reload Window` temporarily restores visibility.

## Fast fixes
- Stop the current run with `q` and restart (`flutter run -d macos --debug`).
- In VS Code, trigger `Developer: Reload Window` to reset the renderer.
- If the macOS app process remains, terminate it manually (Activity Monitor or `pkill` by bundle name).

## Recommended run commands
- `flutter run -d macos --debug`
- `flutter run -d macos --debug --enable-software-rendering` (forces software rendering to avoid GPU hang-ups).

## Notes
- "Failed to foreground app; open returned 1" is a known non-blocker when the app still launches successfully.
