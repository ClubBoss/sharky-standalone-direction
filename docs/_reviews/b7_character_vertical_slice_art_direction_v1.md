# B7 Character Vertical Slice — Art Direction Record v1

Status: IMPLEMENTATION RECORD (not authority)
Freshness date: 2026-08-19

Records the art-direction mini-gauntlet required before the production slice,
and the exact reasons the rejected candidates were rejected. It does not close
B7, does not admit an asset pack, and does not change any campaign authority.

## Why a gauntlet was required first

The admitted question is whether authored character art creates a class-level
lift over the accepted B3 procedural renderer. Building one production
implementation and judging it would confound two different failures: a bad
art *direction* and a bad asset *hypothesis*. Three materially different
directions were therefore prototyped and judged inside the exact current table
scene, not against a mood board.

## The constraint that decided the outcome

Measured on the canonical viewport, the near opponent volume renders at
**61 x 68 logical px** (table width ~207 logical px, `volumeScale` 1.204 at
depth 0.682), of which the table-side quarter is occluded by the rail. The
hero foreground band is roughly **255 x 55 logical px** of visible height.

At that size a head is ~30 px wide. This is the governing fact: any direction
whose quality depends on rendered detail cannot resolve, and any direction that
retreats into shadow stops reading as a person at all.

## Candidates

All three were authored from the same anatomy and composited through the same
Flutter path, so only the treatment varied.

### A — stylized premium illustration (SELECTED)

Confident, few-value-step shape language. Facial features stated as planes
rather than drawn detail. Bold hair silhouette, clear shoulder asymmetry,
visible neck and collar.

Selected because it was the only candidate that held **believable human
presence and phone-scale readability at the same time**. Its one real weakness
in the gauntlet — sitting lighter than the `#0A1725` room and so reading
slightly pasted on — is a value-grading problem, and was fixed by grading the
palette into Deep Ocean, adding a felt bounce, a rim falloff and a lower-body
dissolve. Its weakness was correctable; the others' were structural.

### B — restrained semi-realistic 2.5D (REJECTED)

Natural proportions, soft volumetric shading, rendered features, cloth folds.

Rejected: at 61 px the realistic detail does not resolve. Folds read as smears
rather than material and the softly-rendered features read as mush, which
pushes the figure toward the uncanny rather than toward believability. It also
costs the most art detail per identity — the worst possible trade for a
direction intended to scale to five opponents.

### C — graphic cinematic Deep Ocean (REJECTED)

Figure as a deep, near-monochrome mass, described almost entirely by a strong
specular rim, face held in shadow.

Rejected, and this one was rejected against expectation. It scored best on
environment integration and lowest on competition with poker information, and
its concept is the most distinctly Sharky of the three. But in-scene it loses
the thing the slice exists to create: at seat scale the face disappears
entirely and the figure reads as a dark shape, which is a return to the
pre-B3 silhouette problem the B3 admission already called `INSUFFICIENT`. The
failure is the direction itself, not its execution, so it is not correctable
by grading.

C's discipline was kept as a *constraint* on A — room-matched values, no
element brighter than the felt — rather than as its own direction.

## Rejection is of the direction, not of the hypothesis

Neither rejection is evidence against authored assets. Both rejected candidates
still outperformed the procedural baseline on human presence; they were
rejected relative to A, not relative to B3.

## Production slice built from the selection

- one authored opponent, resolved to the nearest left-flank seat;
- one authored first-person hero foreground;
- no folded variant, no second identity, no pack.

Authoring script: `tools/art/act0_b7_character_art_v1.py`. Runtime never runs
it and never depends on it; it depends only on the baked PNGs.
