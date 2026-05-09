# Release Candidate Metadata — v2.0.0-RC1

**Version**: `v2.0.0-RC1`  
**Date**: November 1, 2025  
**Branch**: `main`  
**Commit**: (to be tagged)

---

## Changelog Summary

**Commit**: (to be tagged) (Updated)  
- Introduced fade+slide micro-animations (250ms, easeInOutCubic) for UI v2 result screen
- Hero animation for pack title
- Refined AppTypography (18sp h1, 16sp body) and new AppColors tokens (surfaceVariant, outlineSoft)
- Extended telemetry to record transition durations
- Updated Health Dashboard to show UI Animations metrics

### Stage 16B — Navigation Telemetry
- Added NavigationTelemetryObserver to track push/pop transition durations
@@| Test Pass Rate | 100% | 88% (51/58) | ⚠️ PARTIAL |
- Extended UiTelemetryService with recordNavigation(route, ms)
- Updated export_ui_metrics.dart to aggregate ui_nav events (overall + per-route)
- Health Dashboard now displays "UI Navigation" section with route-level stats
@@| UX QA Issues | 0 | 2 | ⚠️ PARTIAL |
@@| Compilation (flutter test) | 0 errors | 96 | ❌ BLOCKED |
### Stage 16C — Visual Consistency & Brand Pass
- Added brand color tokens (primaryBrand, accentSuccess, accentWarning, neutralBg)

---

## Validation Status
# ⚠️ BLOCKED: Requires legacy codebase compilation cleanup (96 errors)

|--------|--------|---------|--------|
| Analyzer Errors | 0 | 0 | ✅ PASS |
| Analyzer Warnings | 0 | 0 | ✅ PASS |
| Test Pass Rate | 100% | 89% (51/57) | ⚠️ PARTIAL |
| Code Coverage | ≥25% | 11.24% | ❌ FAIL |
| UI Performance (FPS) | ≥55 | N/A | ⏸️ PENDING |
| UI Consistency | 0 inlines | 0 | ✅ PASS |
| UX QA Issues | 0 | Pending scan | ⏸️ PENDING |

**Notes**:
- UI performance metrics require app runtime with UI v2 enabled to collect data
- UX QA scan to be run once all UI v2 files are finalized

  - `result_screen_small.png`
  - `result_screen_medium.png`
1. **Critical**: Resolve 96 compilation errors in legacy codebase (see docs/_archive/misc/STAGE17B_STATUS.md for detailed analysis)
2. Generate golden test baselines once compilation is clean
3. Collect runtime UI metrics with app execution
4. Address 2 hardcoded strings in UI v2
5. Resolve remaining test failures
6. Tag RC1 final or proceed to RC2
  - `result_screen_large.png`
  - `body_component.png`
  - `footer_component.png`

**Generation command**:

**Verification command**:
```

---

## Known Issues & Limitations

1. **Test Coverage**: Overall repo coverage is low (11.24%); UI v2 specific tests are limited to golden/smoke tests
2. **Runtime Toggle**: UI v2 is gated by `appConfig.useUiV2`; requires Dev Menu or environment flag to enable
3. **Telemetry Best-Effort**: UI metrics write to local files; may not persist on all platforms
4. **Theme V2 Not Wired Globally**: Theme V2 builder exists but isn't yet applied to MaterialApp; components consume it via isolated wrappers

---

## Pre-Release Checklist

- [x] Analyzer clean (0 errors, 0 warnings)
- [x] UI Consistency scan passes
- [x] Golden tests created
- [ ] UX QA scan passes (0 issues)
- [ ] UI performance baseline collected (runtime data)
- [ ] Test pass rate at 100%
- [ ] Code coverage at ≥25%
- [ ] All TODO markers resolved in UI v2

---

## Deployment Notes

- **Target Platforms**: iOS, Android, macOS, Web
- **Flutter SDK**: 3.35.7
- **Dart SDK**: 3.9.2
- **Feature Flag**: `appConfig.useUiV2` (default: false)
- **Migration Path**: Gradual opt-in via Dev Menu toggle; no breaking changes to existing flows

---

## Contact & Approval

- **Author**: Engineering Team
- **Reviewer**: TBD
- **Approver**: TBD
- **Release Manager**: TBD

---

**Next Steps**: Complete UX QA scan, collect runtime UI metrics, resolve test failures, and tag RC1 commit.
