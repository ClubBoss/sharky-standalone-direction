# CI INSTRUCTIONS

## Validate Content
```bash
dart run tool/validate_all.dart
```

## Export Packs
```bash
dart run tools/generate_and_export_packs.dart
dart run tool/generate_packs_index.dart
```

## Run Tests
```bash
dart test
```

## Regression Check (Stage 17L)
Run the regression analyzer to compare the latest health metrics with the previous baseline and fail CI on regressions beyond thresholds:

```bash
# Generate current health metrics JSON
dart run tools/health_dashboard.dart --ci

# Compare against previous baseline (if present)
dart run tools/health_regression_analyzer.dart --baseline baseline/health_dashboard_prev.json

# Save current as new baseline (typically in a separate CI step on success)
mkdir -p baseline && cp health_dashboard.json baseline/health_dashboard_prev.json
```

GitHub Actions snippet:

```yaml
- name: Regression Check
	run: dart run tools/health_regression_analyzer.dart --baseline baseline/health_dashboard_prev.json

- name: Save Baseline
	if: success()
	run: |
		mkdir -p baseline
		cp health_dashboard.json baseline/health_dashboard_prev.json
```

## Update Dashboard History (Stage 17M)
Append summarized metrics to the history and regenerate the dashboard with trend charts:

```bash
dart run tools/ci_dashboard_export.dart --update-history
```

GitHub Actions snippet:

```yaml
- name: Update Dashboard History
	run: dart run tools/ci_dashboard_export.dart --update-history
```
