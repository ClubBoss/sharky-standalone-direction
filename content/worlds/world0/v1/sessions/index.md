# Sessions

## Index

- w0.s01: seat layout orientation and blind anchors.
- w0.s02: action order tracing from blinds through the first street transition.
- w0.s03: basic action button accuracy under simple prompts. [Mixed checkpoint]
- w0.s04: repeat reps for stable seat recognition.
- w0.s05: repeat reps for stable street order reading.
- w0.s06: mixed checkpoint for seats, action buttons, and street order. [Mixed checkpoint]
- w0.s07: focused action-order checks with quicker acting seat reads.
- w0.s08: focused acting seat and seat-layout checks without guessing.
- w0.s09: focused seat-shift and action-order checks.
- w0.s10: checkpoint blend of seats, acting seat, actions, and street order.

The ladder starts with blind anchors, expands across seats and streets, repeats the same read from both blind sides, and then closes with mixed checkpoints.
The world still stops before strategy: the learner is only proving table-reading fluency, not preflop judgment or bet-sizing ideas.
Completion shape: the early sessions isolate one cue at a time, the middle sessions repeat the same read from both blind sides, and the closing checkpoints blend seats, actions, and streets into stable table-reading proof.
Handoff to W1: after W0, the learner should recognize layout and button meaning on sight so the next world can add stronger live decisions without reteaching table orientation.

Each session id maps to its folder.
