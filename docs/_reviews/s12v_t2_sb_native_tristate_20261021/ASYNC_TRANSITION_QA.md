# T2 SB asynchronous image-state safety, source and build QA

Issue: Flutter FutureBuilder can retain the prior completed snapshot when
its Future changes. A transition from Relaxed to Empty could temporarily
paint the previously loaded human pixels, even after source-seat selection
was corrected. The canary now keys its FutureBuilder by exact visual state
(Engaged, Relaxed, Empty) to force a fresh snapshot per state. The selected
store is the only image source while it loads, with no cached Engaged fallback.

Validation:
- dart format --set-exit-if-changed and targeted flutter analyze: clean.
- 5/5 Flutter tests: source-state priority, asset triplet, widget
  Engaged -> Relaxed -> Empty with state-key ownership, production flag off.
- Fresh incremental iOS Simulator build succeeded on this exact source.
- Built Runner.app/Frameworks/App.framework/App SHA256:
  6486ef6a31c3e92bfdf7d0b8460c046c4320e90427128afa67df357dd9bdf908
- Xcode build success was independently verified after the host wrapper's
  zsh read-only local variable assignment failed; xcodebuild did not fail.

Scope limits:
- The genuine Standard/Compact first-table XCTest receipts in manifest.json
  belong to the PREVIOUS T2 tri-state app binary SHA256
  a7b9e600e762b4bedba0673ace7473f3afca8658d5edf4021f04e9a674e53fad.
  They must not be relabeled as the current SHA6486 binary.
- No new native state-transition / Folded / Empty / full-river screenshot
  exists on SHA6486. No integrated T2 Stage A PASS is asserted.
- Unoccupied/occupied inactive source truth is covered by widget tests,
  NOT a fabricated learner proof.
- V2 Relaxed actor identity P1 hold; V3 exact-head trial rejected.
- Local Mac has under 5 GiB free. Further native cycles require resource
  check or an authorized hosted worker, not ad hoc disk purge.
- Default production V4 unchanged; no other-four-seat implementation;
  PR remains Draft; protected #224 and Human/P02 admission untouched.
