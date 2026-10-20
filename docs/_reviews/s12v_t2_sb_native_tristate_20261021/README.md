# T2 Stage A tri-state one-SB source-truth repair (2026-10-21)

**Not Stage A PASS or S12.V PASS.**

Cause: original opt-in T2 candidate mapped `isOccupied=false` to the
Relaxed human, causing an occupied-looking chair for a source-empty seat.
The patch adds a genuine Empty plate and deterministic append-only
Engaged/Relaxed/Empty visual selection from source-owned SB seatId and
isOccupied/isInHand/isFolded (unoccupied has priority over other flags).
A missing SB seat also selects Empty. Temporary fallback to a cached
Engaged frame is removed while loading Empty/Relaxed.

True source: the existing 1093x1844 registered Empty, Engaged and Relaxed
plate images; new Empty plate is copied byte-for-byte from the accepted
provisional local art, not redrawn. The original preferred A source remains
immutable.

**QA:** 5/5 targeted Flutter tests, including all three actual bundled images;
dart format/analyze clean; rebuilt actual iOS Simulator binary. On fresh
test app state Standard iPhone 17 Pro and Compact SE3 each traverse first
real table from Welcome to source-owned answer actions with genuine XCTest
PASS 1/1. SHA-256 pins are in manifest.json. Two native PNGs are exported
from actual XCTest attachments, not projections.

Limits: first-table screenshots show SB Engaged, not a genuine authored
native Folded/Empty. Source state unit/widget tests prove visual selection
but do not substitute for real native Folded/Empty. V2 Relaxed facial
identity remains materially different; rejected hand-composite trial V3
was NOT incorporated. Four other human silhouettes remain baked/static
and outside admitted Stage A. Default V4 remains unchanged; PR remains
Draft and must not merge without owner acceptance. No change to grading,
telemetry, XP, due or other learner-truth invariants.

Raw .xcresult, logs and test-device data backups stay in the isolated
authorized Mac workspace under native_t2_receipts/tristate_{standard,compact}.
