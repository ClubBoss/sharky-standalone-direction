# V9: owner iPhone confirmation

After the skin lands, rerun `./tools/capture_act0_screens_v1.sh v9 walkthrough` and resolve FAIL rows in `build/v9/REPORT.md` before device confirmation. Widget captures are at the 393×852 reference viewport, not native iPhone screenshots.

On the physical iPhone 14 Pro with the final build (~30 minutes):

- [ ] Feel haptics on correct/incorrect answers and confirm system haptics settings are respected.
- [ ] Scroll long explanations and answer lists with a finger; check inertia, edge gestures and touch targets.
- [ ] Open a system keyboard where applicable; verify safe-area/keyboard avoidance, dismissal and focus with the real keyboard.
- [ ] Interrupt mid-answer and mid-repair with lock/background, notification or call; reopen and confirm the same learner state, no duplicated XP or lost progress.
- [ ] On a disposable test account/install, check update/reinstall and first launch with the intended iOS data-retention behavior; do not delete the owner's real learner data.

The automated walkthrough finds route/layout failures; the owner still signs off V9 on the final skin and device.
