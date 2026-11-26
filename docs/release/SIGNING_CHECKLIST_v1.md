# iOS signing checklist — A8.1 / O4

Owner-only, after O4. The unsigned B105 dry run needs no Apple account:
`tools/release/ios_release_dryrun_v1.sh` (macOS, Flutter 3.35, Xcode).
It builds the B89 default-OFF release profile and checks the placeholder identity;
it does **not** sign, archive or upload. Run it before replacing the placeholder.

- [ ] **Team and access.** Activate Apple Developer Program membership; sign into
  Xcode → Settings → Accounts and confirm access to App Store Connect.
  [[OWNER: Apple team name / Team ID / App Store Connect role]]
- [ ] **App identity.** Register an explicit App ID and create the iOS app record
  in App Store Connect (English U.S., chosen name and SKU). In
  `ios/Flutter/AppIdentity.xcconfig`, replace `SHARKY_BUNDLE_ID` and uncomment/set
  `DEVELOPMENT_TEAM`. Select that team for Runner in Signing & Capabilities.
  [[OWNER: permanent bundle ID / app name / SKU]]
- [ ] **Certificates and provisioning.** Enable Automatically manage signing;
  verify an Apple Distribution certificate with its private key is available
  to Xcode and that the App Store distribution profile matches the Team ID and
  App ID. Allow Xcode to manage the profile; do not share keys or credentials.
  [[OWNER: distribution certificate / provisioning verified]]
- [ ] **Archive.** Use the accepted source commit and the next unused build number
  in `pubspec.yaml`. Prepare release settings with `flutter build ios --release
  --config-only --no-codesign` (no custom Dart defines for B89). Open
  `ios/Runner.xcworkspace` in Xcode; select Runner, Release archive configuration,
  and a generic physical iOS device; Product → Archive. In Organizer verify the
  permanent bundle ID, version/build number, signing and privacy report; run
  the required candidate checks from [RELEASE.md](../RELEASE.md).
  If the final beta uses the separate `SHARKY_BETA_METRICS` profile in RELEASE.md,
  rebuild and verify that exact candidate rather than reusing B105 evidence.
  [[OWNER: source commit / version + build / archive / checks]]
- [ ] **TestFlight.** Complete the owner metadata and privacy declarations in
  App Store Connect. In Organizer choose Distribute App → App Store Connect →
  Upload; confirm the build processes in TestFlight and assign the approved
  internal group. External testing requires Beta App Review; follow
  [RELEASE.md](../RELEASE.md) for tester metadata and physical iPhone checks.
  [[OWNER: upload/build status / approved tester group]]

A8.1.pre does not close REL-01: the signed candidate, its required green checks,
and O4 remain separate release gates.
