# PHP-6 Sharky Production Integration Proof v1

Status: deterministic packet evidence — not Human Novice Proof and not a claim
of full Sharky visual completeness.

Baseline: `03938eb0c4c65f64e77fe4df8779c923364c3d23`

## Packet 6A — reachable state and continuity contract

The active production owner is
`lib/ui_v2/act0_shell/act0_sharky_presence_v1.dart`. It is the one resolver
used by the Welcome presenter/guide, Review presence, lesson/session runner,
and `Act0SharkyCompanionAvatarV1` state renderer. Home, Learn, and Profile do
not independently instantiate Sharky; their role in this matrix is explicitly
absence of a duplicate mascot owner.

| Semantic state | Mood | Canonical route point | Growth stages | Renderer/guard |
| --- | --- | --- | --- | --- |
| neutral | neutral | Welcome orientation | Foundation; Developing component proof | `act0_sharky_companion_state_v1_test.dart`; `act0_sharky_growth_stage_v1_test.dart` |
| coach | thinking | open repair / instructional prompt | Foundation, Developing | same resolver contract; `act0_sharky_companion_states_consumer_v1_test.dart` |
| repair | repair | incorrect or failed repair | Foundation, Developing | same resolver contract; Session Summary consumer guard |
| confirm | happy | completed local repair | Foundation, Developing | same resolver contract; Session Summary consumer guard |
| improve | happy + accent ring | valid later-improvement observation | Foundation, Developing | `act0_sharky_improvement_observation_v1.dart`; Session Summary consumer guard |
| milestone | celebrate + accent ring | world completion / W4→W5 boundary | Foundation, Developing | `act0_sharky_companion_state_v1_test.dart`; Session Summary consumer guard |

Foundation and Developing are a separate, bounded axis. The stage resolver is
world-number based (Foundation through W4, Developing from W5) and the shared
frame adds the admitted growth ring without changing state semantics. The
companion remains one shared character renderer: the state controls mood/tone
and rings, while stage controls only the frame treatment.

Small-size contract:

- 16 dp is brand-presence-only; it does not claim reliable state recognition.
- 34 dp carries major valence only; adjacent states remain frame/copy-aware.
- 68/92 dp are the session-summary and guide-card proof sizes respectively.
- The deterministic component capture uses 92 dp so crop, fallback loading,
  state ring, and growth ring are visible without inventing a natural route.

Reduced motion is now an active production guard. When
`MediaQuery.disableAnimations` is true, `Act0SharkyPresenceMascotV1` neither
creates nor renders its motion builder, while keeping the same keyed image
visible for every mood. Motion continues to use the existing 2400 ms bounded
presence treatment only when motion is allowed.

## Packet 6B — deterministic captures

Existing `screen_review_fast_v1` infrastructure now has the
`sharky_evidence` group. It captures the actual shared companion renderer at
three deterministic rows and packages the standard local-only contact sheet
and ZIP:

| Capture | State/stage | Claim boundary |
| --- | --- | --- |
| `developing` | neutral + Developing | frame/growth treatment and fallback loading |
| `improve` | improve + Foundation | accent-ring state treatment and fallback loading |
| `milestone` | milestone + Foundation | accent-ring state treatment and fallback loading |

Command: `./tools/screen_review_fast_v1.sh sharky_evidence compact`

This is deterministic component evidence. It is not a seeded learner journey,
native proof, Human Novice Proof, or a claim that the provisional fallback art
is state-distinct.

## EXTERNAL_ASSET_INPUT_REQUIRED

No runtime-eligible approved asset exists in
`assets/design/sharky_character_v1/sharky_character_package_manifest_v1.json`:
all four package files are references and declare `runtimeEligibility: false`.
The shared resolver therefore correctly retains its one admitted provisional
fallback and no asset migration is permitted in this packet.

| State / mood | Growth stage | Intended active surface and size | Current fallback | Learner-visible limitation | Functional block |
| --- | --- | --- | --- | --- | --- |
| neutral / neutral | Foundation, Developing | Welcome 64/80 dp; shared 16/34/92 dp frames | `sharky_neutral_fallback_v1.png` | canonical on-identity neutral art is not admitted | visual completeness only |
| coach / thinking | Foundation, Developing | guide/lesson prompt 72/92 dp; 16/34 dp small contexts | same | thinking pose is not admitted at runtime | visual completeness only |
| repair / repair | Foundation, Developing | feedback and Session Summary 64/68 dp; 16/34 dp small contexts | same | repair pose is not admitted at runtime | visual completeness only |
| confirm / happy | Foundation, Developing | feedback and Session Summary 64/68 dp; 16/34 dp small contexts | same | acknowledgement pose is not admitted at runtime | visual completeness only |
| improve / happy | Foundation, Developing | Session Summary 68 dp plus accent ring; 16/34 dp small contexts | same | later-improvement treatment has no admitted state art; ring/copy carry its distinction | visual completeness only |
| milestone / celebrate | Foundation, Developing | world-completion and Session Summary 64/68 dp; 16/34 dp small contexts | same | earned-completion pose is not admitted at runtime | visual completeness only |

Required external input: an owner-approved, runtime-eligible, versioned
character package with the supplied state-to-file map, transparent exports,
safe bounds, semantics labels, and the declared fallback policy. The unresolved
SHK-CREST-01 contradiction remains verification-only here because this packet
does not create or admit art.

## Validation boundary

- focused state, stage, consumer, identity, and presence tests;
- deterministic `sharky_evidence` capture package on the candidate head;
- `flutter analyze`, canonical authority lane, release gate, and exact-head CI
  remain required before merge.

Provisional packet disposition: `PHP6_CLOSED_WITH_EXTERNAL_ASSET_INPUT_REQUIRED`
once the remaining repository gates and exact-head merge evidence are green.
