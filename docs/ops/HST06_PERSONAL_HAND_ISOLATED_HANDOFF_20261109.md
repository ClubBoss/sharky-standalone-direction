# HST-06: isolated personal-hand delivery and integration handoff

Status: SOURCE CANDIDATE / NOT APP-ROUTED / NOT INDEPENDENTLY ACCEPTED.
Canonical user criterion: "TRI_VOLNY", gid=2026110801, row 330.
Base main: 2b547f031d5aef8ca0a8772e750f6d4ea53e82cb (verified 2026-11-09).
This branch intentionally owns only new paths under lib/features/hst06 and
test/features/hst06. It never changes main, Act0, TrainingPack, importer/editor,
SharedPreferences progress keys, W1 fingerprints, DAT-07 or Actions workflows.

## Working local flow (only after integrator adds a lawful route)

Open Hst06PersonalHandScreen -> choose structured manual or paste imported text
-> review per-record known facts, unknowns, warnings and blocking errors
-> tap Confirm personal save -> Hst06PersonalStore stores revision 1 locally.
Cancel, unsupported format, malformed cards/amounts, corrupt on-device
storage, duplicate or conflicting source ID cannot silently create a record.
One multi-hand paste yields one preview per separated record. Confirm one at a
time; to confirm another from the same paste, preview the text again.

The feature does not instantiate a TrainingPack, TrainingSpot, graded choice,
skill receipt, XP transaction or cloud sync. It never auto-promotes a user hand
into practice or an authored curriculum. There is no networking in this module.
Do not submit actual player hand histories to external CI, issue bodies or
LLM tools. Synthetic fixtures only.

## Exact supported formats

1. Structured manual No-Limit Holdem: explicitly entered title, named seats,
   optional hero/button seat, two known Hero cards, known three/four/five-card
   board, explicit stacks, actions and pot; empty fields mean unknown.
2. PokerStars EN plain-text No-Limit Holdem hands with "PokerStars Hand #"
   header, "Seat N: Name (stack in chips)" players, explicit "Dealt to"
   Hero, optional "*** FLOP/TURN/RIVER ***" board sections and text actions.
   Supported action verbs: folds, checks, calls, bets, raises-to. Amounts are
   exact validated decimal strings in explicitly known source currency units
   (USD/EUR/GBP when header provides code); no implicit chip/BB conversion.
   Multiple PokerStars headers can be previewed separately.

NOT supported by this HST-06 route: GGPoker, Winamax, the legacy four-line
simple converter, Omaha, tournaments with unverified field semantics, mixed
currency, JSON, CSV, damaged/exotic hand text. Legacy RoomHandHistoryImporter
recognizes more input kinds, but its SavedHand defaults are lossy: unknown
Hero may become seat zero, positions may be inferred without the real button,
and stacks/amounts may be rounded. The HST-06 preview calls that importer for
a compatibility diagnostic, but NEVER takes its default-fabricated facts
as evidence for the private record. A future format is admitted only with
source-grounded fixtures and coverage, not by changing this wording.

## Truth and dedupe contracts

- Hero is known only from a Dealt-to player matching a named seat; the
  button only from the explicit button-seat statement. Other positions
  are not inferred.
- Stacks and pot are nullable source-unit decimals. Explicit 0 stays 0;
  missing value stays null. No implicit stack reconstruction, guessed
  winner, inferred blinds or false exact pot. Collectors are shown only
  when named in source text.
- Card grammar is standard two-character Holdem notation (10 normalized
  to T); repeated card across Hero and final board blocks confirmation.
  Street board counts must be 3/4/5 and earlier board prefix preserved.
- Unknown/incomplete action data remains an explicit warning, not a claim
  that no actions occurred. Raise amount means "to", not incremental
  contribution. Parser is intentionally narrower than a full HH replayer.
- Origin and original raw-text SHA-256 digest are persisted, not raw
  imported text. Manual entries receive a canonical-content digest.
  Import identity = source provider + original room hand ID.
  Same ID + same normalized content: DUPLICATE, no write.
  Same ID + differing content: CONFLICT, old data preserved.
  Local revision starts at 1. Future editor integration may use revise()
  with an exact expected revision (compare-and-swap).
- Private storage key: hst06_private_hands_v1, schema version 1, device
  SharedPreferences. Corrupt storage fails closed, never overwritten.
  This is private app state, NOT encryption or an OS-backup guarantee.
  Large archives and account-to-device migration are outside this packet.
- Never use RoomHandHistoryEditorScreen's current "+ Spot" shortcut as the
  default personal-hand save: it converts SavedHand into practice content,
  which violates HST-06's ungraded-personal boundary.

## Targeted proposed tests

test/features/hst06/personal_hand_v1_test.dart:
  - supported formats, actors, seats/button/Hero, all four streets,
    exact decimal and raise-to semantics, known winner and pot
  - missing Hero, missing vs explicit-zero stack, duplicate cards,
    illegal street boards, mismatched currency, damaged amount,
    unsupported formats, multi-hand separation, manual fields
  - dedupe, collision conflict, revision CAS, corrupt-store nonoverwrite,
    preview/cancel has zero persistence

test/features/hst06/personal_hand_screen_v1_test.dart:
  - visible preview -> Cancel no save
  - explicit confirm -> one persisted personal hand
  - edited source invalidates stale preview
  - unsupported source cannot confirm
  - manual unknowns -> explicit confirmed local record

No actual test/analyze/format/native PASS has been established by the mere
presence of these tests. Record exact command, SDK, HEAD, exit status and
per-file assertions when a permitted runner becomes available. Do not run
SDK preparation, offline recovery or a broad checkpoint to force a green badge.

## Serial integration and release gate

1. Integrator checks owners of the legacy importer, RoomHandHistoryImportScreen,
   RoomHandHistoryEditorScreen and app navigation. These were not edited here.
2. Review this branch's source and test diffs. If accepted, add a bounded
   personal-hand navigation entry in an owned app area. The route should
   instantiate Hst06PersonalHandScreen and must never call "+ Spot" or
   TrainingPackStorageService as a side effect of import.
3. On a permitted existing SDK/resource: run dart format and dart analyze on
   only the new files, then the two focused Flutter test files. Record PASS,
   FAIL or NOT RUN verbatim. No SDK bootstrap/recovery workaround.
4. Test exactly-once confirm, duplicate, partial source and corruption on an
   iPhone 14 Pro EN native app, including actual cold restart and the
   personal-vs-training boundary. Capture source/binary/test receipts.
5. Independent HST-06 reviewer checks the complete route, privacy, 0 XP,
   no skill evidence and no auto-generated spot. Only then can the owner
   consider full HST-06 DoD and score.

No merge, point award, CI-success assumption or release admission is authorized
by this handoff.
