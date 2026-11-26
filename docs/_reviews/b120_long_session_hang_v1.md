# B120 · Long-session hang — already fixed on main (source re-check)
- Baseline: HEAD = local `origin/main` at `4fdcd9a0f8f09f91a6bd0dc443d246eb76011e95`; B110 (`2c301f2cf`, #880) already addressed this lane.
- `.hotfix_old.diff` targeted long default settle timeouts, open-ended teaching loops and Result navigation, not a demonstrated product timer leak.
- `act0_w1_long_session_v1_test.dart:64` bounds `_settle` to 5 seconds with route diagnostics; both choreography/practice helpers also cap settling at 5 seconds.
- `_tapTeachingContinue` (line 169) checks enabled callbacks and pumps 1 second for the 820 ms dwell; `_finishTeaching` (line 361) caps retries at 40.
- Route loop (line 2526) has 40-attempt and 3600/5200-step caps, clears tap history, and follows the Result primary CTA with explicit close fallback (line 2786).
- B110 also bounds storage readback and persisted seeding to 3 seconds per operation in `runAsync`; later B113 only changes opt-in walkthrough miss selection, not default traversal.
- Runner `dispose` (line 1652) cancels theory, review and choreography timers; choreography progresses through finite beats, reveal timers are cancelled, and manual action-trail autoplay is not activated by this traversal.
- No remaining old hang mechanism found in the exercised path; no Dart changes needed. A permanently stalled platform I/O or synchronous isolate freeze is not ruled out by source review.
- PLAN records #880 as CI green; no fresh Flutter/CI run (sandbox), no new Roadmap ID, no changed Dart files to analyze. Recommend closing the stale branch without reapplying its diff.
