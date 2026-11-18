"""Off-stage character art authoring for Visual Gauntlet B7.

The app never runs this. It bakes transparent PNGs that the deterministic
Flutter compositor in `lib/ui_v2/act0_shell/act0_scene_character_asset_v1.dart`
draws into the seat volumes B1 already owns. Runtime depends on the baked PNGs
only, the same way it would depend on a painter's exported artwork.

Art here owns anatomy, head shape, facial planes, hair, hands, clothing and
pose. It deliberately owns nothing else: no haze, no seat placement, no rail
crop, no state, no motion. Those stay in Dart.

Usage:
    python3 tools/art/act0_b7_character_art_v1.py --direction c --out <dir>
"""

from __future__ import annotations

import argparse
import math
import os

import numpy as np
from PIL import Image, ImageDraw, ImageFilter

# Opponent volume aspect is `0.245 : 0.275` from `Act0SceneSeatSlotV1.volumeSize`.
OPP_W, OPP_H = 768, 862
# Hero band aspect follows `widthFactor 0.74 / heightFactor 0.19` on a 0.60
# aspect scene.
HERO_W, HERO_H = 1440, 616

SS = 2  # mask supersample


# ---------------------------------------------------------------- primitives


def _mask(w, h, fn) -> np.ndarray:
    img = Image.new("L", (w * SS, h * SS), 0)
    fn(ImageDraw.Draw(img), SS)
    return np.asarray(img.resize((w, h), Image.LANCZOS), np.float32) / 255.0


def m_ellipse(w, h, cx, cy, rx, ry, rot=0.0) -> np.ndarray:
    def draw(d, s):
        pts = []
        for i in range(240):
            t = i * math.tau / 240
            x, y = rx * math.cos(t), ry * math.sin(t)
            pts.append(((cx + x * math.cos(rot) - y * math.sin(rot)) * s,
                        (cy + x * math.sin(rot) + y * math.cos(rot)) * s))
        d.polygon(pts, fill=255)

    return _mask(w, h, draw)


def m_poly(w, h, pts) -> np.ndarray:
    return _mask(w, h, lambda d, s: d.polygon([(x * s, y * s) for x, y in pts], fill=255))


def m_ribbon(w, h, pts, w0, w1=None) -> np.ndarray:
    """A stroked path with a tapering width, stamped so joints stay smooth.

    PIL's wide polyline butt-joins every segment, which scallops any curve. A
    limb is exactly the case where that shows, so limbs are stamped instead.
    """
    w1 = w0 if w1 is None else w1

    def draw(d, s):
        n = len(pts)
        for i in range(n):
            t = i / max(n - 1, 1)
            r = (w0 * (1 - t) + w1 * t) * 0.5 * s
            x, y = pts[i][0] * s, pts[i][1] * s
            d.ellipse([x - r, y - r, x + r, y + r], fill=255)

    return _mask(w, h, draw)


def bez(p0, p1, p2, n=64):
    out = []
    for i in range(n + 1):
        t, u = i / n, 1 - i / n
        out.append((u * u * p0[0] + 2 * u * t * p1[0] + t * t * p2[0],
                    u * u * p0[1] + 2 * u * t * p1[1] + t * t * p2[1]))
    return out


def bez3(p0, p1, p2, p3, n=64):
    out = []
    for i in range(n + 1):
        t, u = i / n, 1 - i / n
        out.append((u**3 * p0[0] + 3 * u * u * t * p1[0] + 3 * u * t * t * p2[0] + t**3 * p3[0],
                    u**3 * p0[1] + 3 * u * u * t * p1[1] + 3 * u * t * t * p2[1] + t**3 * p3[1]))
    return out


def blur(a, r):
    if r <= 0:
        return a
    img = Image.fromarray((np.clip(a, 0, 1) * 255).astype(np.uint8), "L")
    return np.asarray(img.filter(ImageFilter.GaussianBlur(r)), np.float32) / 255.0


def shift(a, dx, dy):
    """Translate a mask, clamping at the border.

    Wrapping here would manufacture an edge along the canvas cut, which is
    exactly where a figure is legitimately cropped by the rail.
    """
    dx, dy = int(round(dx)), int(round(dy))
    pad = ((abs(dy), abs(dy)), (abs(dx), abs(dx)))
    q = np.pad(a, pad, mode="edge")
    h, w = a.shape
    y0 = abs(dy) - dy
    x0 = abs(dx) - dx
    return q[y0:y0 + h, x0:x0 + w]


def inset_guard(w, h, m_px):
    """Zero within `m_px` of the canvas edge.

    A figure cropped by the frame has no silhouette there, so it must not be
    given a lamp edge there either.
    """
    g = np.ones((h, w), np.float32)
    m_px = int(max(1, m_px))
    g[:m_px, :] = 0
    g[-m_px:, :] = 0
    g[:, :m_px] = 0
    g[:, -m_px:] = 0
    return blur(g, m_px * 0.6)


def rgb(s):
    s = s.lstrip("#")
    return np.array([int(s[i:i + 2], 16) / 255.0 for i in (0, 2, 4)], np.float32)


def grad(w, h, p0, p1, c0, c1):
    ys, xs = np.mgrid[0:h, 0:w].astype(np.float32)
    xs /= w
    ys /= h
    vx, vy = p1[0] - p0[0], p1[1] - p0[1]
    t = np.clip(((xs - p0[0]) * vx + (ys - p0[1]) * vy) / (vx * vx + vy * vy or 1e-6), 0, 1)[..., None]
    return c0 * (1 - t) + c1 * t


class Layer:
    """Premultiplied RGBA accumulator."""

    def __init__(self, w, h):
        self.w, self.h = w, h
        self.p = np.zeros((h, w, 3), np.float32)
        self.a = np.zeros((h, w), np.float32)

    def _c(self, color):
        if isinstance(color, np.ndarray) and color.ndim == 3:
            return color
        return np.broadcast_to(np.asarray(color, np.float32), (self.h, self.w, 3))

    def over(self, m, color):
        a = np.clip(m, 0, 1)[..., None]
        self.p = self._c(color) * a + self.p * (1 - a)
        self.a = a[..., 0] + self.a * (1 - a[..., 0])

    def tint(self, m, color, amount=1.0):
        k = (np.clip(m, 0, 1) * amount * self.a)[..., None]
        self.p = self._c(color) * self.a[..., None] * k + self.p * (1 - k)

    def add(self, m, color, amount=1.0):
        k = (np.clip(m, 0, 1) * amount * self.a)[..., None]
        self.p = np.clip(self.p + np.asarray(color, np.float32) * k, 0, 1)

    def image(self):
        a = np.clip(self.a, 0, 1)[..., None]
        straight = np.where(a > 1e-4, self.p / np.maximum(a, 1e-4), 0)
        return Image.fromarray(
            np.concatenate([np.clip(straight, 0, 1) * 255, a * 255], axis=2).astype(np.uint8),
            "RGBA")


def edge(m, dx, dy, soft):
    """A thin edge on the side the shape is displaced *away* from.

    `(dx, dy)` points from the shape toward the light, so the returned sliver
    is the lit silhouette.
    """
    return blur(np.clip(m - shift(m, dx, dy), 0, 1), soft)


def core_shadow(layer, m, dx, dy, soft, strength, color):
    """The broad turn of a form away from the key light."""
    layer.tint(m * blur(np.clip(m - shift(m, dx, dy), 0, 1), soft), color, strength)


# ------------------------------------------------------------------ palettes

# Sampled against the shipped scene: the room beside this seat is `#0A1725`,
# so every value here is authored to sit inside Deep Ocean rather than on top
# of it. A figure lighter than its room is the definition of pasted on.
SPECULAR = rgb("AFC8DC")

PALETTES = {
    "a": dict(  # stylized premium illustration
        cloth=rgb("22324655"[:6]), cloth_sh=rgb("0C1420"), cloth_lit=rgb("35506E"),
        inner=rgb("172436"),
        skin=rgb("7A5847"), skin_sh=rgb("3A2A24"), skin_lit=rgb("A87E62"),
        hair=rgb("14161E"), hair_lit=rgb("3D4857"),
        rim=0.85, face=0.95,
    ),
    "b": dict(  # restrained semi-realistic 2.5D
        cloth=rgb("212C3A"), cloth_sh=rgb("0C1119"), cloth_lit=rgb("35455A"),
        inner=rgb("161E29"),
        skin=rgb("6B5344"), skin_sh=rgb("33261F"), skin_lit=rgb("93705A"),
        hair=rgb("12131A"), hair_lit=rgb("313A46"),
        rim=0.55, face=0.62,
    ),
    "c": dict(  # graphic cinematic Deep Ocean
        cloth=rgb("131F31"), cloth_sh=rgb("060B13"), cloth_lit=rgb("2C4665"),
        inner=rgb("0A1220"),
        skin=rgb("4E3A2E"), skin_sh=rgb("1C1720"), skin_lit=rgb("8A6449"),
        hair=rgb("0A0D14"), hair_lit=rgb("2B3646"),
        rim=1.15, face=0.55,
    ),
}


# ------------------------------------------------------------------- anatomy

def opponent_geometry(w, h):
    """Seated opponent, three-quarter, turned toward the felt.

    The seat this slice fills is on the left flank, so the figure faces screen
    right: the facial mass sits right of the skull centre, the ear rides the
    far edge, and the table-side shoulder is rolled down and forward. That
    asymmetry is most of what separates a seated person from a bust.
    """
    X = lambda v: v * w
    Y = lambda v: v * h
    g = {}

    head_outline = (
        bez3((X(.448), Y(.042)), (X(.521), Y(.046)), (X(.564), Y(.083)), (X(.569), Y(.148)))
        + bez3((X(.569), Y(.148)), (X(.575), Y(.215)), (X(.556), Y(.262)), (X(.498), Y(.303)))
        + bez3((X(.498), Y(.303)), (X(.463), Y(.329)), (X(.413), Y(.316)), (X(.381), Y(.269)))
        + bez3((X(.381), Y(.269)), (X(.348), Y(.219)), (X(.337), Y(.176)), (X(.340), Y(.137)))
        + bez3((X(.340), Y(.137)), (X(.344), Y(.081)), (X(.385), Y(.042)), (X(.448), Y(.042)))
    )
    g["head"] = m_poly(w, h, head_outline)
    g["ear"] = m_ellipse(w, h, X(.343), Y(.188), X(.024), Y(.033), -0.22)
    g["neck"] = m_ribbon(w, h, bez((X(.452), Y(.292)), (X(.458), Y(.348)), (X(.472), Y(.408))),
                         X(.112), X(.130))

    # Trapezius, then deltoid, then a body that narrows slightly as it drops
    # behind the rail. A silhouette that runs straight to both frame corners
    # reads as furniture, not as a person.
    torso = (
        bez3((X(.386), Y(.392)), (X(.336), Y(.418)), (X(.278), Y(.448)), (X(.248), Y(.524)))
        + [(X(.234), Y(1.0)), (X(.800), Y(1.0))]
        + bez3((X(.772), Y(.552)), (X(.734), Y(.466)), (X(.636), Y(.414)), (X(.548), Y(.392)))
    )
    g["torso"] = m_poly(w, h, torso)

    g["arm"] = m_ribbon(
        w, h,
        bez3((X(.722), Y(.570)), (X(.836), Y(.630)), (X(.876), Y(.708)), (X(.872), Y(.792))),
        X(.148), X(.104))
    # A hand on the wood, not a stone beside the body: wrist, back of hand and
    # a thumb break, so the rail crop lands on something that was a hand.
    g["hand"] = np.clip(
        m_ellipse(w, h, X(.878), Y(.836), X(.078), Y(.056), 0.34)
        + m_ribbon(w, h, bez((X(.834), Y(.858)), (X(.894), Y(.882)), (X(.946), Y(.860))),
                   X(.046), X(.030))
        + m_ribbon(w, h, bez((X(.826), Y(.822)), (X(.862), Y(.868)), (X(.856), Y(.908))),
                   X(.034), X(.026)),
        0, 1)
    g["thumb_break"] = m_ribbon(
        w, h, bez((X(.836), Y(.826)), (X(.868), Y(.866)), (X(.862), Y(.902))), X(.008))

    g["X"], g["Y"] = X, Y
    return g


def opponent_hair(w, h, g, style):
    """Hair silhouette. Identity at this scale lives almost entirely here."""
    X, Y = g["X"], g["Y"]
    if style == "swept":
        back = m_ellipse(w, h, X(.434), Y(.142), X(.130), Y(.122), -0.06)
        front = m_poly(w, h, [
            (X(.328), Y(.180)), (X(.330), Y(.084)), (X(.394), Y(.028)), (X(.516), Y(.026)),
            (X(.584), Y(.086)), (X(.588), Y(.170)), (X(.560), Y(.116)), (X(.498), Y(.094)),
            (X(.424), Y(.110)), (X(.372), Y(.152))])
        # Sideburn in front of the ear: a small asymmetry that stops the hair
        # reading as a moulded helmet.
        front = np.clip(front + m_ribbon(
            w, h, bez((X(.348), Y(.140)), (X(.344), Y(.176)), (X(.352), Y(.208))), X(.030)), 0, 1)
    else:  # cropped
        back = m_ellipse(w, h, X(.442), Y(.140), X(.122), Y(.112), -0.03)
        front = m_poly(w, h, [
            (X(.334), Y(.166)), (X(.338), Y(.088)), (X(.400), Y(.036)), (X(.514), Y(.036)),
            (X(.578), Y(.090)), (X(.580), Y(.158)), (X(.548), Y(.130)), (X(.440), Y(.124)),
            (X(.374), Y(.150))])
        front = np.clip(front + m_ribbon(
            w, h, bez((X(.346), Y(.132)), (X(.342), Y(.166)), (X(.350), Y(.194))), X(.024)), 0, 1)
    return back, np.clip(front, 0, 1) * np.clip(g["head"] + back, 0, 1)


def opponent_face(w, h, g, turn):
    """Facial planes. At 60 px wide these must be planes, never drawn detail."""
    X, Y = g["X"], g["Y"]
    fx = .450 + turn
    F = lambda v: X(fx + v)
    p = {}
    p["brow"] = m_poly(w, h, [(F(-.086), Y(.146)), (F(.084), Y(.140)),
                              (F(.080), Y(.174)), (F(-.088), Y(.180))]) * g["head"]
    p["eye_far"] = m_ellipse(w, h, F(-.050), Y(.182), X(.030), Y(.0115), 0.05) * g["head"]
    p["eye_near"] = m_ellipse(w, h, F(.046), Y(.178), X(.025), Y(.0100), 0.02) * g["head"]
    p["nose"] = m_poly(w, h, [(F(.004), Y(.166)), (F(.036), Y(.228)), (F(.000), Y(.234))]) * g["head"]
    p["nostril"] = m_ellipse(w, h, F(.016), Y(.238), X(.024), Y(.0075)) * g["head"]
    p["mouth"] = m_ellipse(w, h, F(.012), Y(.266), X(.038), Y(.0085), 0.03) * g["head"]
    p["cheek"] = m_ellipse(w, h, F(.044), Y(.214), X(.048), Y(.040), 0.2) * g["head"]
    # The plane where the face turns away from us, on the far side of the head.
    p["turn"] = blur(np.clip(g["head"] - shift(g["head"], X(.055), 0), 0, 1), X(.030)) * g["head"]
    p["jawline"] = blur(np.clip(g["head"] - shift(g["head"], 0, -Y(.022)), 0, 1), X(.014)) * g["head"]
    return p


# ---------------------------------------------------------------- treatments

# One cool overhead lamp, slightly to the room's left, exactly as B2 lights the
# felt and the rail. Offsets are small: this is an edge, not a wash.
def light(w, h):
    """Offset pointing from the figure toward the overhead lamp."""
    return -w * 0.011, -h * 0.017


def render_opponent(w, h, direction):
    pal = PALETTES[direction]
    lx, ly = light(w, h)
    g = opponent_geometry(w, h)
    hair_back, hair_front = opponent_hair(w, h, g, "cropped" if direction == "b" else "swept")
    X, Y = g["X"], g["Y"]

    L = Layer(w, h)
    body = np.clip(g["torso"] + g["arm"] + g["hand"], 0, 1)
    cloth = np.clip(g["torso"] + g["arm"], 0, 1)

    L.over(hair_back, pal["hair"])
    L.over(g["neck"], pal["skin_sh"])

    # -- garment -------------------------------------------------------------
    if direction == "c":
        # The garment is one deep mass; form arrives as a lamp edge rather than
        # internal rendering, so it never competes with the board.
        L.over(cloth, grad(w, h, (0.28, 0.36), (0.86, 1.0), pal["cloth"], pal["cloth_sh"]))
    else:
        L.over(cloth, grad(w, h, (0.24, 0.34), (0.90, 1.0), pal["cloth_lit"], pal["cloth_sh"]))

    if direction != "c":
        collar = m_ribbon(w, h, bez((X(.388), Y(.406)), (X(.464), Y(.480)), (X(.546), Y(.402))),
                          X(.040)) * body
        L.over(collar, pal["inner"])
    else:
        # Even the graphic direction needs the neckline break, or the head
        # floats on the shoulder mass. It is stated as shadow, not as a shape.
        collar = m_ribbon(w, h, bez((X(.396), Y(.406)), (X(.464), Y(.472)), (X(.540), Y(.402))),
                          X(.048)) * body
        L.tint(blur(collar, X(.010)), pal["cloth_sh"], 0.85)

    # Shoulder seam and the fold that a rolled near shoulder actually makes.
    seam = m_ribbon(w, h, bez((X(.678), Y(.432)), (X(.760), Y(.492)), (X(.774), Y(.584))),
                    X(.012)) * body
    L.tint(blur(seam, X(.007)), pal["cloth_sh"], 0.70)
    if direction == "b":
        for a, b, c in (((.640, .470), (.548, .616), (.470, .820)),
                        ((.286, .520), (.340, .672), (.318, .860)),
                        ((.700, .620), (.640, .742), (.616, .900))):
            f = m_ribbon(w, h, bez((X(a[0]), Y(a[1])), (X(b[0]), Y(b[1])), (X(c[0]), Y(c[1]))),
                         X(.022)) * body
            L.tint(blur(f, X(.016)), pal["cloth_sh"], 0.50)

    core_shadow(L, cloth, lx * 2.2, ly * 2.2, X(.10),
                0.70 if direction == "c" else 0.50, pal["cloth_sh"])
    # Contact darkening where the arm crosses the chest.
    L.tint(blur(g["arm"] * shift(g["torso"], X(.06), 0), X(.02)), pal["cloth_sh"], 0.55)
    # The near arm has to detach from the chest or the whole upper body reads
    # as one poncho.
    L.tint(blur(edge(g["arm"], -X(.02), -Y(.004), X(.014)) * g["torso"], X(.010)),
           pal["cloth_sh"], 0.80)

    # -- head ----------------------------------------------------------------
    L.over(g["ear"], pal["skin_sh"])
    L.over(g["head"], grad(w, h, (0.34, 0.05), (0.60, 0.32), pal["skin_lit"], pal["skin"]))
    p = opponent_face(w, h, g, turn=0.030 if direction != "a" else 0.036)
    f = pal["face"]

    # The far plane of a turned head, always. Without it a head reads flat no
    # matter how carefully the features are placed.
    L.tint(p["turn"], pal["skin_sh"], 0.45)

    if direction == "a":
        L.tint(blur(p["brow"], X(.010)), pal["skin_sh"], 0.62 * f)
        L.tint(blur(p["eye_far"], X(.0022)), pal["skin_sh"] * 0.72, 1.0 * f)
        L.tint(blur(p["eye_near"], X(.0022)), pal["skin_sh"] * 0.72, 0.96 * f)
        L.tint(blur(p["nose"], X(.006)), pal["skin_sh"], 0.55 * f)
        L.tint(blur(p["nostril"], X(.004)), pal["skin_sh"], 0.70 * f)
        L.tint(blur(p["mouth"], X(.006)), pal["skin_sh"], 0.55 * f)
        L.add(blur(p["cheek"], X(.016)), pal["skin_lit"] * 0.55, 0.60)
        # A single catch on the brow ridge. One specular is the difference
        # between a face and a mask at this size.
        L.add(blur(m_ellipse(w, h, g["X"](.470), g["Y"](.152), g["X"](.060),
                             g["Y"](.014), -0.10) * g["head"], g["X"](.008)),
              SPECULAR * 0.5, 0.55)
    elif direction == "b":
        L.tint(blur(p["brow"], X(.020)), pal["skin_sh"], 0.55 * f)
        L.tint(blur(p["eye_far"], X(.008)), pal["skin_sh"], 0.85 * f)
        L.tint(blur(p["eye_near"], X(.008)), pal["skin_sh"], 0.80 * f)
        L.tint(blur(p["nose"], X(.014)), pal["skin_sh"], 0.55 * f)
        L.tint(blur(p["nostril"], X(.008)), pal["skin_sh"], 0.60 * f)
        L.tint(blur(p["mouth"], X(.012)), pal["skin_sh"], 0.45 * f)
        L.add(blur(p["cheek"], X(.024)), pal["skin_lit"] * 0.45, 0.45)
    else:
        # Graphic: the face is mostly in shadow, carried by one lit brow and
        # cheekbone plane. That is what a poker room under a single lamp
        # actually looks like, and it is the only face treatment that survives
        # being 30 px wide without turning to mush.
        L.tint(blur(p["brow"], X(.026)), pal["skin_sh"], 0.85)
        L.tint(blur(p["eye_far"], X(.016)), pal["skin_sh"], 0.85 * f)
        L.tint(blur(p["eye_near"], X(.016)), pal["skin_sh"], 0.75 * f)
        L.tint(blur(p["nose"], X(.018)), pal["skin_sh"], 0.50 * f)
        L.tint(blur(p["mouth"], X(.016)), pal["skin_sh"], 0.40 * f)
        L.add(blur(p["cheek"], X(.028)), pal["skin_lit"] * 0.72, 0.70)

    L.tint(p["jawline"], pal["skin_sh"], 0.50 if direction != "b" else 0.38)
    core_shadow(L, g["head"], lx * 1.6, ly * 1.6, X(.05),
                0.55 if direction == "c" else 0.38, pal["skin_sh"])
    # Jaw shadow onto the neck: the cheapest proof a head is attached to a body.
    L.tint(blur(g["neck"] * shift(blur(g["head"], X(.02)), 0, Y(.052)), X(.016)),
           pal["skin_sh"], 0.90)

    # -- hair ----------------------------------------------------------------
    L.over(hair_front, pal["hair"])
    hair_all = np.clip(hair_back + hair_front, 0, 1)
    L.add(edge(hair_all, -lx * 1.4, -ly * 1.4, X(.012)), pal["hair_lit"],
          0.90 if direction != "c" else 0.65)
    # A broad sheen across the crown. Hair without one is a moulded cap.
    L.add(blur(m_ellipse(w, h, X(.452), Y(.066), X(.086), Y(.026), -0.18) * hair_all, X(.020)),
          pal["hair_lit"], 0.85)

    # -- hand ----------------------------------------------------------------
    L.over(g["hand"], grad(w, h, (0.82, 0.76), (1.0, 0.94), pal["skin"], pal["skin_sh"]))
    L.tint(blur(g["thumb_break"], X(.006)), pal["skin_sh"], 0.70)
    core_shadow(L, g["hand"], lx * 0.9, ly * 0.9, X(.016), 0.55, pal["skin_sh"])

    # -- lamp ----------------------------------------------------------------
    whole = np.clip(body + g["head"] + hair_all + g["neck"], 0, 1)
    # The lamp is above and slightly left, so the rim is strongest across the
    # head and the far shoulder and dies out further down. A rim of constant
    # weight is what makes an asset read as a sticker with a stroke on it.
    falloff = grad(w, h, (0.0, 0.02), (0.0, 0.86), np.float32([1, 1, 1]),
                   np.float32([0.12, 0.12, 0.12]))[..., 0]
    L.add(edge(whole, -lx, -ly, X(.006)) * falloff * inset_guard(w, h, X(.008)),
          SPECULAR, pal["rim"])
    # Bounce off the felt. The table is a big lit green plane immediately
    # table-side of this seat, so it throws a weak cool-green fill onto the
    # shadow side. It costs almost nothing and it is most of why the figure
    # belongs to this room rather than to its own PNG.
    bounce = edge(whole, X(.028), Y(.012), X(.030)) * grad(
        w, h, (0.0, 0.34), (0.0, 1.0), np.float32([0.25, 0.25, 0.25]),
        np.float32([1, 1, 1]))[..., 0]
    L.add(bounce, rgb("2F6D5C"), 0.42 if direction == "c" else 0.30)

    # Dissolve the lower body into the room instead of ending on a straight
    # cut. The figure is seated under the table's own shadow there, and a hard
    # horizontal edge at the bottom of a PNG is the single loudest tell that a
    # scene element was pasted in rather than lit in place.
    fade = grad(w, h, (0.0, 0.72), (0.0, 1.0), np.float32([1, 1, 1]),
                np.float32([0.14, 0.14, 0.14]))[..., 0]
    L.tint(1.0 - fade, pal["cloth_sh"] * 0.35, 1.0)
    L.a = L.a * (0.18 + 0.82 * fade)
    L.p = L.p * (0.18 + 0.82 * fade)[..., None]
    return L.image()


# ---------------------------------------------------------------- hero hands

def hero_hand(w, h, cx, cy, s, side, tilt):
    """The back of a hand resting on the rail, seen from the learner's own eyes.

    `side` is `+1` for the right hand and `tilt` rolls the whole hand toward
    the felt, because a rested hand angles in toward the cards. Fingers are
    kept close and slightly curled: a spread hand at this size reads as a claw,
    which is the single most common way first-person hands go wrong.
    """
    ct, st = math.cos(tilt * side), math.sin(tilt * side)

    def P(x, y):
        x = x * side
        return (cx + (x * ct - y * st) * s, cy + (x * st + y * ct) * s)

    back = np.clip(
        m_poly(w, h, [P(-.54, .54), P(-.62, -.08), P(-.38, -.40), P(.36, -.38),
                      P(.62, .02), P(.54, .56)])
        + m_ellipse(w, h, *P(0, .08), .62 * s, .50 * s), 0, 1)

    fingers = np.zeros((h, w), np.float32)
    creases = np.zeros((h, w), np.float32)
    knuckles = np.zeros((h, w), np.float32)
    # Index through little: shorter and rolled further away each time, so the
    # hand foreshortens instead of fanning flat.
    for bx, cx1, tx, ln, wd in ((-.33, -.37, -.38, .48, .28),
                                (-.10, -.12, -.12, .54, .29),
                                (.13, .12, .14, .47, .28),
                                (.35, .37, .40, .36, .25)):
        fingers = np.clip(fingers + m_ribbon(
            w, h, bez3(P(bx, -.28), P(cx1, -.48), P(cx1, -.62), P(tx, -.28 - ln * .62)),
            wd * s, wd * .80 * s), 0, 1)
        creases = np.clip(creases + m_ribbon(
            w, h, [P(bx - wd * .46, -.34), P(bx + wd * .46, -.36)], .028 * s), 0, 1)
        knuckles = np.clip(knuckles + m_ellipse(
            w, h, *P(bx, -.32), wd * .50 * s, wd * .34 * s), 0, 1)
    thumb = m_ribbon(w, h, bez3(P(-.48, .46), P(-.80, .30), P(-.88, -.02), P(-.74, -.30)),
                     .30 * s, .23 * s)
    web = m_ribbon(w, h, bez(P(-.50, .22), P(-.60, -.02), P(-.52, -.24)), .045 * s)
    return np.clip(back + fingers + thumb, 0, 1), knuckles, np.clip(creases + web, 0, 1)


def render_hero(w, h, direction):
    """The learner's own forearms and hands on the rail.

    Strictly first person: no frontal avatar, because the hero is the camera.
    The arms are authored in the outer thirds and the torso is deliberately a
    low gradient rather than a silhouette, so the hole-card lane, the hero
    plate and the dealer button are never covered and nothing reads as a dome
    sitting on the rail. This is the closest cloth to the camera and out of the
    lamp's throw, so it stays the darkest cloth in the scene - but it is cloth,
    with a cuff and a hand, not a black bar.
    """
    pal = PALETTES[direction]
    lx, ly = -w * 0.005, -h * 0.016
    sleeve = pal["cloth_sh"] * 0.85
    sleeve_lit = pal["cloth"] * 1.02
    cuff = pal["inner"] * 1.25
    skin = pal["skin"] * 0.94
    skin_sh = pal["skin_sh"] * 0.90
    skin_lit = pal["skin_lit"] * 0.90
    X = lambda v: v * w
    Y = lambda v: v * h

    L = Layer(w, h)
    # Torso: low, wide and soft. It grounds the arms without ever becoming a
    # shape the learner has to look past.
    chest = m_poly(w, h, [(0, h)]
                   + bez3((X(0), Y(.94)), (X(.24), Y(.72)), (X(.40), Y(.596)), (X(.50), Y(.590)))
                   + bez3((X(.50), Y(.590)), (X(.60), Y(.596)), (X(.76), Y(.72)), (X(1.0), Y(.94)))
                   + [(w, h)])
    L.over(chest, grad(w, h, (0.5, .60), (0.5, 1.0), sleeve_lit * 0.85, sleeve * 0.55))

    for side in (-1, 1):
        hx = .5 + .390 * side
        # Forearm: foreshortened, running from the bottom corner up to the
        # wrist at the rail.
        arm = m_ribbon(w, h, bez3(
            (X(hx) + X(.010) * side, Y(.240)), (X(hx) + X(.044) * side, Y(.520)),
            (X(hx) + X(.072) * side, Y(.780)), (X(hx) + X(.104) * side, Y(1.06))),
            X(.094), X(.140))
        L.over(arm, grad(w, h, (0.5, .18), (0.5, .90), sleeve_lit, sleeve))
        core_shadow(L, arm, lx * 1.8, ly * 0.4, X(.012), 0.60, pal["cloth_sh"])

        cuff_m = m_ribbon(w, h, [(X(hx) - X(.026) * side, Y(.256)),
                                 (X(hx) + X(.026) * side, Y(.236))], X(.078), X(.072))
        L.over(cuff_m, cuff)
        L.add(edge(cuff_m, -lx, -ly, X(.0035)), SPECULAR, 0.40)

        hand, knuck, creases = hero_hand(w, h, X(hx), Y(.148), X(.072), side, -0.34)
        L.over(hand, grad(w, h, (0.5, .02), (0.5, .26), skin_lit, skin))
        L.tint(blur(creases, X(.0022)), skin_sh, 0.70)
        L.add(blur(knuck, X(.0035)), skin_lit * 0.45, 0.45)
        core_shadow(L, hand, lx * 0.8, ly * 0.4, X(.007), 0.52, skin_sh)
        L.add(edge(hand, -lx, -ly, X(.0028)) * inset_guard(w, h, X(.004)),
              SPECULAR, 0.80 if direction == "c" else 0.58)

    L.add(edge(chest, -lx, -ly, X(.0035)) * inset_guard(w, h, X(.004)), SPECULAR,
          0.24 if direction == "c" else 0.18)
    return L.image()


# ---------------------------------------------------------------------- main

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--direction", default="c", choices=sorted(PALETTES))
    ap.add_argument("--out", required=True)
    args = ap.parse_args()
    os.makedirs(args.out, exist_ok=True)
    render_opponent(OPP_W, OPP_H, args.direction).save(
        os.path.join(args.out, "opponent_near_left_in_hand.png"))
    render_hero(HERO_W, HERO_H, args.direction).save(
        os.path.join(args.out, "hero_foreground.png"))
    print(args.out)


if __name__ == "__main__":
    main()
