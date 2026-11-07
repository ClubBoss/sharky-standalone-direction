# S12.V T2 Stage A - one-SB first real table iOS evidence (2026-10-20)

Source: current main 294b737c2ffd3998ae52c7a5b2e8fee27e0ef2ab plus
isolated SHARKY_T2_SB_CANARY=true patch. This is a gated experiment, not a
replacement for production V4 or a five-seat release.

Authentic XCTest route: clean app launch, source-owned placement and quick
check, Welcome, recommended lesson, first genuinely interactive table.
Standard iPhone 17 Pro and Compact iPhone SE 3rd generation both returned
one native UI test passed with zero failures. The screenshots attached here
are exported directly from two native XCTest .xcresult bundles. The complete
raw XCTest records and application/source binaries remain in the dedicated
Mac T2 workspace native_t2_receipts.

On-screen inspection: all five characters, hero cards, board, pot, blind
indicators and answer actions are visible in the first-table Engaged state.
This is a first-real-table scoped pass only. It is not an assertion that all
task, folded, feedback or review states have passed native assessment.
The source-owned SB Folded selection is exercised by a Flutter widget test,
but no authentic native Folded screenshot is admitted. The other four baked
characters cannot truthfully track every live fold/empty status yet.
Independent premium identity, hand/rail/seat contact and full river review
remain HOLD. Do not merge, ship, reopen PR #224, or admit Human P02.

An initial Standard attempt correctly failed because the pre-existing
simulator had persisted Home navigation state; it was not a source UI defect.
The tiny simulator app data was backed up, then the isolated T2 test device
reset to first-use. Both fresh-device reruns passed. No learner grades or
telemetry were injected or made up.
