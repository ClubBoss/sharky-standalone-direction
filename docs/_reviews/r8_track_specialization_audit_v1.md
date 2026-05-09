# R8 Track Specialization Audit v1

Date: 2026-03-06
Status: CLOSED (shipped)

## 1) Track chooser behavior
- One-time chooser is shown after World10 completion when `world10_track_choice_seen_v1` is false.
- Choice is persisted in SharedPreferences:
- `world10_track_choice_seen_v1` (bool)
- `world10_track_choice_v1` (string: cash/tournament/mixed)
- Dismiss fallback is deterministic: defaults to `mixed`.

## 2) Pack routing (post-World10)
- `world10_spine_followup_v1_b0` -> Cash
- `world10_spine_followup_v1_b1` -> Tournament
- `world10_spine_followup_v1_b2` -> Mixed

## 3) Runtime wiring SSOT
- Session path resolver SSOT: `lib/services/drill_runtime_adapter_v1.dart`.
- Function: `_sessionPathForId(String sessionId)`.
- Mapping includes:
- followup pack ids -> track `s01`
- direct track session ids (`cash.sXX`, `tournament.sXX`, `mixed.sXX`) -> corresponding track session paths

## 4) Content inventory
- Sessions per track: 3 (`s01..s03`)
- Drills per track: 24 (8 per session)
- Total drills across all tracks: 72

## 5) Guards present
- Chooser + routing guards (Session Result contracts):
- `track choice v1 is one-time, persists cash selection, and routes deterministically`
- `track choice v1 seen flag skips chooser and routes directly to tournament root`
- `track choice v1 dismiss defaults to mixed and routes to b2`
- Session chaining guard (all tracks):
- `r8 track sessions chain deterministically from s01 to s03 for all tracks`

## 6) Gate policy
- `flutter analyze`
- `./tools/fast_loop_world1_v1.sh`

Result: R8 target delivered with deterministic routing, persisted chooser behavior, track content roots wired, and regression guards in place.
