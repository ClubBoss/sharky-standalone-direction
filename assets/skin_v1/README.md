# V7 skin asset slots

Deliver the files directly in this directory using these exact names.

| Slot | File name | Canvas size (pixels) | Format |
| --- | --- | --- | --- |
| `appIcon` | `app_icon.png` | 1024 × 1024 | PNG, opaque (no alpha) |
| `sharkyNeutral` | `sharky_neutral.png` | 360 × 360 | PNG, transparent background |
| `sharkyHappy` | `sharky_happy.png` | 360 × 360 | PNG, transparent background |
| `sharkyThinking` | `sharky_thinking.png` | 360 × 360 | PNG, transparent background |
| `sharkyConcerned` | `sharky_concerned.png` | 360 × 360 | PNG, transparent background |

Use a consistent square canvas and framing for the four expressions. The
360 px canvas provides 3× resolution at 120 pt; each expression must also
remain recognizable at 56 pt. Supply rights and provenance with the art for
owner approval.

The directory is already declared in `pubspec.yaml`: a normal Flutter rebuild
bundles newly delivered files without changing the slot registry. Missing
files use the consuming widget's existing visual. These slots are not yet
connected to screens or to the native launcher icon; B104 reserves the
contract only, without changing call sites or generating native icon assets.
