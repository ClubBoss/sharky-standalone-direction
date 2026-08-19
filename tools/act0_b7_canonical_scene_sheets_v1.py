"""B7 canonical scene composition: local-only evidence sheets.

Composes the comparison sheets the B7 review asks for from captures produced by
`tools/act0_b7_canonical_scene_capture_v1.dart` and the pre-change baseline.
Generated output is local-only and uncommitted.
"""
import os
import sys
from PIL import Image, ImageDraw

FINAL = 'output/visual_gauntlet_b7_canonical_scene/candidate'
BASE = 'output/visual_gauntlet_b7_scene_camera/phase1'
OUT = os.path.join(FINAL, 'sheets')
PAD, LABEL_H = 12, 30
BG, FG = (14, 18, 26), (232, 238, 246)
STATES = ('decision', 'correct_feedback', 'wrong_feedback', 'repair', 'recheck')
VIEWPORTS = ('compact_375x812', 'canonical_402x874', 'large_430x932')


def final(v, state, scale=0.42):
    im = Image.open(f'{FINAL}/{v}/canonical/{state}.png').convert('RGB')
    return im.resize((int(im.width * scale), int(im.height * scale)), Image.LANCZOS)


def baseline(v, state, scale=0.42):
    im = Image.open(f'{BASE}/{v}/baseline_current/{state}.png').convert('RGB')
    return im.resize((int(im.width * scale), int(im.height * scale)), Image.LANCZOS)


def crop_band(path, top_frac, bottom_frac, scale=0.9):
    im = Image.open(path).convert('RGB')
    box = (0, int(im.height * top_frac), im.width, int(im.height * bottom_frac))
    im = im.crop(box)
    return im.resize((int(im.width * scale), int(im.height * scale)), Image.LANCZOS)


def sheet(cells, path, title):
    w = max(c[0].width for c in cells)
    h = max(c[0].height for c in cells)
    img = Image.new(
        'RGB',
        (PAD + len(cells) * (w + PAD), PAD + LABEL_H + h + PAD + LABEL_H),
        BG,
    )
    d = ImageDraw.Draw(img)
    d.text((PAD, PAD - 2), title, fill=FG)
    for i, (im, cap) in enumerate(cells):
        x, y = PAD + i * (w + PAD), PAD + LABEL_H
        img.paste(im, (x, y))
        d.text((x, y + h + 6), cap, fill=FG)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    img.save(path)
    print(path)


def main():
    v = 'canonical_402x874'
    # 1. baseline vs final canonical.
    sheet(
        [
            (baseline(v, 'decision'), 'BEFORE decision'),
            (final(v, 'decision'), 'AFTER decision'),
            (baseline(v, 'wrong_feedback'), 'BEFORE wrong feedback'),
            (final(v, 'wrong_feedback'), 'AFTER wrong feedback'),
        ],
        f'{OUT}/01_baseline_vs_final_402x874.png',
        'B7 canonical scene — baseline vs final — 402x874',
    )
    # 2. same-state table geometry comparison.
    for state in ('decision', 'correct_feedback'):
        sheet(
            [
                (baseline(v, state, 0.5), 'baseline'),
                (final(v, state, 0.5), 'canonical scene'),
            ],
            f'{OUT}/02_same_state_geometry_{state}_402x874.png',
            f'Same-state table geometry — {state} — 402x874',
        )
    # 3. state-to-state invariant proof.
    for viewport in VIEWPORTS:
        sheet(
            [(final(viewport, s, 0.34), s) for s in STATES],
            f'{OUT}/03_state_invariance_{viewport}.png',
            f'One physical scene across the learning loop — {viewport}',
        )
        sheet(
            [(baseline(viewport, s, 0.34), s) for s in STATES],
            f'{OUT}/03_state_invariance_BASELINE_{viewport}.png',
            f'BASELINE state-dependent geometry — {viewport}',
        )
    # 4. three-viewport contact sheet.
    for state in ('decision', 'wrong_feedback'):
        sheet(
            [(final(vp, state), vp) for vp in VIEWPORTS],
            f'{OUT}/04_viewports_{state}.png',
            f'Canonical scene — {state} — three viewports',
        )
    # 5/6. top and bottom surface close comparisons.
    for name, band in (('05_top_surface', (0.02, 0.34)), ('06_bottom_surface', (0.66, 1.0))):
        sheet(
            [
                (crop_band(f'{BASE}/{v}/baseline_current/decision.png', *band), 'BEFORE decision'),
                (crop_band(f'{FINAL}/{v}/canonical/decision.png', *band), 'AFTER decision'),
                (crop_band(f'{BASE}/{v}/baseline_current/wrong_feedback.png', *band), 'BEFORE feedback'),
                (crop_band(f'{FINAL}/{v}/canonical/wrong_feedback.png', *band), 'AFTER feedback'),
            ],
            f'{OUT}/{name}_402x874.png',
            f'{"Top coaching surface" if name.startswith("05") else "Bottom control shelf"} — 402x874',
        )


if __name__ == '__main__':
    sys.exit(main())
