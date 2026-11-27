"""Génère les scènes SVG des directions A (gravure) et C (silhouettes et lueurs).
Scène commune : 16 x 10 cases de 40 px (640 x 400), même disposition que le jeu."""
import math, random, sys, os

OUT = sys.argv[1]
W, H = 640, 400
ROT = "#86a832"
ROT_L = "#c4e05a"
ASH = "#d4582b"
ASH_L = "#ffb15a"

# Chemin : rangée 2 jusqu'à la colonne 11, descend jusqu'à la rangée 7, puis sort à droite.
PATH = [(-20, 100), (460, 100), (460, 300), (660, 300)]
CROSS = (260, 180)
ROTT = (380, 180)
ENEMY = (334, 102)
ENEMY2 = (150, 100)
RUINS = [(540, 220), (100, 260)]


def ang(a, b):
    return math.degrees(math.atan2(b[1] - a[1], b[0] - a[0]))


def pts(p):
    return " ".join(f"{x},{y}" for x, y in p)


# ---------------------------------------------------------------- A : gravure
def scene_a():
    rnd = random.Random(3)
    INK = "#15120f"
    PAPER = "#c9bfa6"
    PAPER_L = "#ddd4bc"
    o = []
    o.append(f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {W} {H}" width="1024" height="640">')
    o.append(f'''<defs>
<pattern id="h1" width="5" height="5" patternUnits="userSpaceOnUse" patternTransform="rotate(40)"><rect width="5" height="5" fill="{PAPER}"/><line x1="0" y1="0" x2="0" y2="5" stroke="{INK}" stroke-width="2.9"/></pattern>
<pattern id="h2" width="4" height="4" patternUnits="userSpaceOnUse" patternTransform="rotate(-40)"><line x1="0" y1="0" x2="0" y2="4" stroke="{INK}" stroke-width="1.6"/></pattern>
<pattern id="h3" width="7" height="7" patternUnits="userSpaceOnUse" patternTransform="rotate(10)"><line x1="0" y1="0" x2="0" y2="7" stroke="{INK}" stroke-width=".9"/></pattern>
<pattern id="hv" width="3" height="3" patternUnits="userSpaceOnUse"><line x1="0" y1="0" x2="0" y2="3" stroke="{INK}" stroke-width="1.3"/></pattern>
<filter id="rough" x="-5%" y="-5%" width="110%" height="110%"><feTurbulence type="fractalNoise" baseFrequency=".06" numOctaves="2" seed="4"/><feDisplacementMap in="SourceGraphic" scale="2.6"/></filter>
<filter id="glow" x="-50%" y="-50%" width="200%" height="200%"><feGaussianBlur stdDeviation="3.5" result="b"/><feMerge><feMergeNode in="b"/><feMergeNode in="SourceGraphic"/></feMerge></filter>
<radialGradient id="vig" cx="50%" cy="50%" r="72%"><stop offset=".55" stop-color="{INK}" stop-opacity="0"/><stop offset="1" stop-color="{INK}" stop-opacity=".92"/></radialGradient>
</defs>''')
    o.append('<g filter="url(#rough)">')
    # sol : hachures denses, plus une seconde couche par plaques
    o.append(f'<rect width="{W}" height="{H}" fill="url(#h1)"/>')
    for _ in range(26):
        x, y = rnd.uniform(0, W), rnd.uniform(0, H)
        o.append(f'<ellipse cx="{x:.0f}" cy="{y:.0f}" rx="{rnd.uniform(25, 70):.0f}" ry="{rnd.uniform(12, 30):.0f}" fill="url(#h2)" opacity="1"/>')
    # herbes mortes : touffes claires griffées dans le noir
    for _ in range(90):
        x, y = rnd.uniform(0, W), rnd.uniform(0, H)
        if 80 < y < 120 or (440 < x < 480 and 80 < y < 320) or (280 < y < 320 and x > 440):
            continue
        for k in range(3):
            dx = (k - 1) * 2.2
            o.append(f'<path d="M{x+dx:.1f},{y:.1f} q{dx*.6:.1f},-4 {dx*1.4+rnd.uniform(-1,1):.1f},-{rnd.uniform(5,8):.1f}" stroke="{PAPER_L}" stroke-width=".9" fill="none"/>')
    # chemin : papier clair, ornières, bords encrés
    d = "M" + " L".join(f"{x},{y}" for x, y in PATH)
    o.append(f'<path d="{d}" stroke="{INK}" stroke-width="46" fill="none" stroke-linejoin="round"/>')
    o.append(f'<path d="{d}" stroke="{PAPER_L}" stroke-width="38" fill="none" stroke-linejoin="miter"/>')
    o.append(f'<path d="{d}" stroke="url(#h3)" stroke-width="38" fill="none" opacity=".55"/>')
    for off in (-8, 8):
        dd = "M" + " L".join(f"{x+(off if 440<x<480 else 0)},{y+(off if not 440<x<480 else 0)}" for x, y in PATH)
    for _ in range(140):
        t = rnd.random()
        seg = rnd.choice([(0, 460, 100, 'h'), (100, 300, 460, 'v'), (460, 640, 300, 'h')])
        if seg[3] == 'h':
            x, y = rnd.uniform(seg[0], seg[1]), seg[2] + rnd.uniform(-16, 16)
        else:
            x, y = seg[2] + rnd.uniform(-16, 16), rnd.uniform(seg[0], seg[1])
        o.append(f'<circle cx="{x:.1f}" cy="{y:.1f}" r="{rnd.uniform(.6,1.5):.1f}" fill="{INK}"/>')
    # ornières
    o.append(f'<path d="M-20,93 L452,93 L452,308 L660,308" stroke="{INK}" stroke-width="1.2" fill="none" stroke-dasharray="14 5 3 6"/>')
    o.append(f'<path d="M-20,108 L468,108 L468,292 L660,292" stroke="{INK}" stroke-width="1.2" fill="none" stroke-dasharray="9 7 18 4"/>')

    def shadow(cx, cy, rx, ry):
        o.append(f'<ellipse cx="{cx}" cy="{cy}" rx="{rx}" ry="{ry}" fill="{INK}" opacity=".85"/>')

    def block(cx, cy):
        shadow(cx + 6, cy + 16, 20, 7)
        o.append(f'<rect x="{cx-15}" y="{cy+1}" width="30" height="15" fill="url(#hv)" stroke="{INK}" stroke-width="1.6"/>')
        o.append(f'<rect x="{cx-15}" y="{cy-13}" width="30" height="14" fill="{PAPER_L}" stroke="{INK}" stroke-width="1.6"/>')
        for i in range(3):  # joints de pierre
            o.append(f'<line x1="{cx-15}" y1="{cy+6+i*4}" x2="{cx+15}" y2="{cy+6+i*4}" stroke="{PAPER}" stroke-width=".7"/>')
        o.append(f'<line x1="{cx-5}" y1="{cy+1}" x2="{cx-5}" y2="{cy+6}" stroke="{INK}" stroke-width="1"/><line x1="{cx+6}" y1="{cy+10}" x2="{cx+6}" y2="{cy+16}" stroke="{PAPER}" stroke-width="1"/>')

    # Arbalète
    cx, cy = CROSS
    block(cx, cy)
    a = ang((cx, cy - 6), ENEMY)
    o.append(f'<g transform="translate({cx},{cy-6}) rotate({a:.1f})">')
    o.append(f'<rect x="-9" y="-2.5" width="22" height="5" fill="{PAPER_L}" stroke="{INK}" stroke-width="1.6"/>')
    o.append(f'<path d="M10,-13 Q17,0 10,13" stroke="{INK}" stroke-width="3.2" fill="none"/>')
    o.append(f'<path d="M10,-13 L4,0 L10,13" stroke="{INK}" stroke-width=".9" fill="none"/>')
    o.append(f'<line x1="4" y1="0" x2="18" y2="0" stroke="{INK}" stroke-width="1.4"/>')
    o.append('</g>')
    # carreau en vol
    bx, by = 300, 138
    o.append(f'<g transform="translate({bx},{by}) rotate({a:.1f})"><line x1="-8" y1="0" x2="6" y2="0" stroke="{INK}" stroke-width="1.8"/><path d="M6,-2.5 L10,0 L6,2.5Z" fill="{INK}"/><path d="M-8,0 l-3,-3 M-8,0 l-3,3" stroke="{INK}" stroke-width="1"/></g>')
    for i in range(4):
        o.append(f'<line x1="{bx-14-i*7:.0f}" y1="{by+10+i*5.5:.0f}" x2="{bx-10-i*7:.0f}" y2="{by+7+i*5.5:.0f}" stroke="{PAPER_L}" stroke-width="1"/>')

    # tour de Pourriture : cuve de bile sur bloc
    cx, cy = ROTT
    block(cx, cy)
    o.append(f'<path d="M{cx-13},{cy-10} L{cx-11},{cy+4} Q{cx},{cy+8} {cx+11},{cy+4} L{cx+13},{cy-10}Z" fill="url(#h1)" stroke="{INK}" stroke-width="1.8"/>')
    for k in (-6, 1, 7):
        o.append(f'<line x1="{cx+k}" y1="{cy-8}" x2="{cx+k*0.9:.1f}" y2="{cy+5}" stroke="{INK}" stroke-width="2"/>')
    o.append(f'<g filter="url(#glow)"><ellipse cx="{cx}" cy="{cy-10}" rx="13" ry="5.5" fill="{ROT}" stroke="{INK}" stroke-width="1.6"/>')
    o.append(f'<circle cx="{cx-4}" cy="{cy-11}" r="2.2" fill="{ROT_L}"/><circle cx="{cx+5}" cy="{cy-9}" r="1.4" fill="{ROT_L}"/>')
    o.append(f'<path d="M{cx+8},{cy-7} q2,6 0,11 q-1,2 1,4" stroke="{ROT}" stroke-width="2.4" fill="none"/><path d="M{cx-9},{cy-6} q-1,5 0,8" stroke="{ROT}" stroke-width="2" fill="none"/></g>')
    # spores vers l'ennemi
    ex, ey = ENEMY
    o.append('<g filter="url(#glow)">')
    for i in range(7):
        t = i / 7
        x = cx + (ex - cx) * t + math.sin(i * 1.7) * 5
        y = cy - 16 + (ey - (cy - 16)) * t - math.sin(t * math.pi) * 18
        o.append(f'<circle cx="{x:.1f}" cy="{y:.1f}" r="{1.4+t*1.6:.1f}" fill="none" stroke="{ROT}" stroke-width="1.3"/>')
    o.append('</g>')

    # ennemi : silhouette encapuchonnée, braises de Cendre, empoisonné
    def enemy(ex, ey, s=1.0, fade=1.0):
        shadow(ex + 3, ey + 11 * s, 11 * s, 3.5 * s)
        o.append(f'<g transform="translate({ex},{ey}) scale({s})" opacity="{fade}">')
        o.append(f'<path d="M-9,11 L-7,-2 Q-6,-14 2,-16 Q10,-14 9,-3 L11,11 L6,8 L3,11 L-1,8 L-4,11Z" fill="url(#h1)" stroke="{INK}" stroke-width="1.8"/>')
        o.append(f'<path d="M-4,-12 Q2,-17 8,-11 Q8,-5 3,-4 Q-3,-5 -4,-12Z" fill="{INK}"/>')
        o.append(f'<path d="M8,-1 L15,1 L13,3 M15,1 L16,-2" stroke="{INK}" stroke-width="2" fill="none"/>')
        o.append(f'<g filter="url(#glow)"><circle cx="2" cy="-9" r="1.4" fill="{ASH_L}"/><circle cx="6" cy="-9" r="1.2" fill="{ASH_L}"/>')
        o.append(f'<path d="M-3,2 l3,3 l-1,3 M4,0 l1,4" stroke="{ASH}" stroke-width="1.3" fill="none"/></g>')
        o.append('</g>')
    enemy(*ENEMY2, s=.9, fade=.9)
    enemy(*ENEMY)
    # nuage de poison sur l'ennemi
    o.append('<g filter="url(#glow)">')
    for dx, dy, r in ((-10, -6, 2.6), (9, -15, 2), (12, 4, 1.8), (-6, 8, 1.6), (0, -22, 1.5)):
        o.append(f'<circle cx="{ex+dx}" cy="{ey+dy}" r="{r}" fill="none" stroke="{ROT}" stroke-width="1.3"/>')
    o.append('</g>')

    # ruines : colonnes brisées, gravats, crâne
    def ruin(cx, cy):
        shadow(cx + 4, cy + 14, 22, 7)
        o.append(f'<path d="M{cx-14},{cy+12} L{cx-14},{cy-16} L{cx-9},{cy-20} L{cx-6},{cy-14} L{cx-4},{cy-17} L{cx-4},{cy+12}Z" fill="{PAPER_L}" stroke="{INK}" stroke-width="1.6"/>')
        o.append(f'<rect x="{cx-9}" y="{cy-14}" width="5" height="26" fill="url(#hv)"/>')
        o.append(f'<path d="M{cx+3},{cy+12} L{cx+3},{cy-4} L{cx+8},{cy-1} L{cx+12},{cy-6} L{cx+12},{cy+12}Z" fill="{PAPER_L}" stroke="{INK}" stroke-width="1.6"/>')
        o.append(f'<rect x="{cx+8}" y="{cy-2}" width="4" height="14" fill="url(#hv)"/>')
        for dx, dy, r in ((-17, 12, 3), (-1, 14, 3.5), (15, 13, 2.5), (8, 16, 2)):
            o.append(f'<circle cx="{cx+dx}" cy="{cy+dy}" r="{r}" fill="{PAPER_L}" stroke="{INK}" stroke-width="1.2"/>')
        # crâne
        o.append(f'<circle cx="{cx-1}" cy="{cy+7}" r="4" fill="{PAPER_L}" stroke="{INK}" stroke-width="1.2"/><circle cx="{cx-2.5}" cy="{cy+7}" r="1" fill="{INK}"/><circle cx="{cx+.8}" cy="{cy+7}" r="1" fill="{INK}"/>')
        o.append(f'<path d="M{cx+18},{cy+10} l6,-3" stroke="{PAPER_L}" stroke-width="2"/>')
    for r in RUINS:
        ruin(*r)
    o.append('</g>')
    o.append(f'<rect width="{W}" height="{H}" fill="url(#vig)"/>')
    o.append('</svg>')
    return "\n".join(o)


# ------------------------------------------------- C : silhouettes et lueurs
def scene_c():
    rnd = random.Random(7)
    BG = "#121318"
    o = []
    o.append(f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {W} {H}" width="1024" height="640">')
    o.append(f'''<defs>
<filter id="noise" x="0" y="0" width="100%" height="100%"><feTurbulence type="fractalNoise" baseFrequency=".9" numOctaves="2" seed="2"/><feColorMatrix values="0 0 0 0 .5  0 0 0 0 .5  0 0 0 0 .5  0 0 0 .09 0"/><feComposite in2="SourceGraphic" operator="in"/></filter>
<filter id="fog" x="0" y="0" width="100%" height="100%"><feTurbulence type="fractalNoise" baseFrequency=".012 .03" numOctaves="3" seed="9"/><feColorMatrix values="0 0 0 0 .55  0 0 0 0 .6  0 0 0 0 .66  0 0 0 .55 -.18"/></filter>
<filter id="glow" x="-80%" y="-80%" width="260%" height="260%"><feGaussianBlur stdDeviation="2.5" result="b"/><feGaussianBlur stdDeviation="7" result="c"/><feMerge><feMergeNode in="c"/><feMergeNode in="b"/><feMergeNode in="SourceGraphic"/></feMerge></filter>
<filter id="soft"><feGaussianBlur stdDeviation="4"/></filter>
<radialGradient id="lr" r="50%"><stop offset="0" stop-color="{ROT}" stop-opacity=".45"/><stop offset="1" stop-color="{ROT}" stop-opacity="0"/></radialGradient>
<radialGradient id="la" r="50%"><stop offset="0" stop-color="{ASH}" stop-opacity=".4"/><stop offset="1" stop-color="{ASH}" stop-opacity="0"/></radialGradient>
<radialGradient id="ln" r="50%"><stop offset="0" stop-color="#d8cfb8" stop-opacity=".22"/><stop offset="1" stop-color="#d8cfb8" stop-opacity="0"/></radialGradient>
<radialGradient id="vig" cx="50%" cy="50%" r="70%"><stop offset=".5" stop-color="#000" stop-opacity="0"/><stop offset="1" stop-color="#000" stop-opacity=".85"/></radialGradient>
<linearGradient id="rim" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#4a4d57"/><stop offset=".25" stop-color="#22242b"/><stop offset="1" stop-color="#16171c"/></linearGradient>
</defs>''')
    o.append(f'<rect width="{W}" height="{H}" fill="{BG}"/>')
    # sol : dalles très sombres, quadrillage à peine visible
    for gx in range(16):
        for gy in range(10):
            v = rnd.randint(-4, 4)
            o.append(f'<rect x="{gx*40+1}" y="{gy*40+1}" width="38" height="38" rx="3" fill="rgb({24+v},{26+v},{31+v})"/>')
    o.append(f'<rect width="{W}" height="{H}" fill="#fff" filter="url(#noise)"/>')
    # chemin : bande plus chaude et plus claire, bords flous
    d = "M" + " L".join(f"{x},{y}" for x, y in PATH)
    o.append(f'<path d="{d}" stroke="#0b0b0d" stroke-width="48" fill="none" filter="url(#soft)"/>')
    o.append(f'<path d="{d}" stroke="#3a332b" stroke-width="38" fill="none"/>')
    o.append(f'<path d="{d}" stroke="#4a4137" stroke-width="18" fill="none" filter="url(#soft)" opacity=".8"/>')
    for _ in range(60):
        seg = rnd.choice([(0, 460, 100, 'h'), (100, 300, 460, 'v'), (460, 640, 300, 'h')])
        if seg[3] == 'h':
            x, y = rnd.uniform(seg[0], seg[1]), seg[2] + rnd.uniform(-16, 16)
        else:
            x, y = seg[2] + rnd.uniform(-16, 16), rnd.uniform(seg[0], seg[1])
        o.append(f'<circle cx="{x:.1f}" cy="{y:.1f}" r="{rnd.uniform(.8,2):.1f}" fill="#2a251f"/>')
    # flaques de lumière
    o.append(f'<circle cx="{ROTT[0]}" cy="{ROTT[1]-6}" r="70" fill="url(#lr)"/>')
    o.append(f'<circle cx="{ENEMY[0]}" cy="{ENEMY[1]}" r="38" fill="url(#la)"/>')
    o.append(f'<circle cx="{ENEMY2[0]}" cy="{ENEMY2[1]}" r="30" fill="url(#la)"/>')
    o.append(f'<circle cx="{CROSS[0]}" cy="{CROSS[1]-10}" r="48" fill="url(#ln)"/>')

    def shadow(cx, cy, rx, ry):
        o.append(f'<ellipse cx="{cx}" cy="{cy}" rx="{rx}" ry="{ry}" fill="#000" opacity=".6" filter="url(#soft)"/>')

    def block(cx, cy):
        shadow(cx + 5, cy + 16, 20, 6)
        o.append(f'<rect x="{cx-15}" y="{cy-13}" width="30" height="29" rx="2" fill="url(#rim)"/>')
        o.append(f'<line x1="{cx-14}" y1="{cy+1}" x2="{cx+14}" y2="{cy+1}" stroke="#0c0d10" stroke-width="1.5"/>')
        o.append(f'<line x1="{cx-14}" y1="{cy-12.5}" x2="{cx+14}" y2="{cy-12.5}" stroke="#6a6e7a" stroke-width="1"/>')

    cx, cy = CROSS
    block(cx, cy)
    a = ang((cx, cy - 6), ENEMY)
    o.append(f'<g transform="translate({cx},{cy-6}) rotate({a:.1f})">')
    o.append('<rect x="-9" y="-2.5" width="22" height="5" fill="#0d0e11" stroke="#555a66" stroke-width=".8"/>')
    o.append('<path d="M10,-13 Q17,0 10,13" stroke="#0d0e11" stroke-width="3.6" fill="none"/><path d="M10,-13 Q17,0 10,13" stroke="#5c606c" stroke-width=".8" fill="none"/>')
    o.append('<path d="M10,-13 L4,0 L10,13" stroke="#8a8a8a" stroke-width=".6" fill="none"/>')
    o.append('</g>')
    o.append(f'<circle cx="{cx-10}" cy="{cy-2}" r="1.6" fill="#e6dcc4" filter="url(#glow)"/>')  # lanterne neutre
    # carreau : trait de lumière pâle
    bx, by = 300, 138
    o.append(f'<g transform="translate({bx},{by}) rotate({a:.1f})" filter="url(#glow)"><line x1="-16" y1="0" x2="8" y2="0" stroke="#e6dcc4" stroke-width="1.4" stroke-linecap="round" opacity=".9"/></g>')

    cx, cy = ROTT
    block(cx, cy)
    o.append(f'<path d="M{cx-13},{cy-10} L{cx-11},{cy+4} Q{cx},{cy+8} {cx+11},{cy+4} L{cx+13},{cy-10}Z" fill="#101114" stroke="#3c404a" stroke-width="1"/>')
    o.append(f'<g filter="url(#glow)"><ellipse cx="{cx}" cy="{cy-10}" rx="12.5" ry="5" fill="{ROT}"/><circle cx="{cx-4}" cy="{cy-11}" r="2" fill="{ROT_L}"/><circle cx="{cx+5}" cy="{cy-9.5}" r="1.3" fill="{ROT_L}"/>')
    o.append(f'<path d="M{cx+8},{cy-7} q2,6 0,11 q-1,2 1,4" stroke="{ROT}" stroke-width="1.8" fill="none"/></g>')
    ex, ey = ENEMY
    o.append('<g filter="url(#glow)">')
    for i in range(8):
        t = i / 8
        x = cx + (ex - cx) * t + math.sin(i * 1.7) * 5
        y = cy - 16 + (ey - (cy - 16)) * t - math.sin(t * math.pi) * 18
        o.append(f'<circle cx="{x:.1f}" cy="{y:.1f}" r="{1+t*1.4:.1f}" fill="{ROT}" opacity="{.5+t*.5:.2f}"/>')
    o.append('</g>')

    def enemy(ex, ey, s=1.0):
        shadow(ex + 3, ey + 11 * s, 11 * s, 3.5 * s)
        o.append(f'<g transform="translate({ex},{ey}) scale({s})">')
        o.append('<path d="M-9,11 L-7,-2 Q-6,-14 2,-16 Q10,-14 9,-3 L11,11 L6,8 L3,11 L-1,8 L-4,11Z" fill="#0b0b0e" stroke="#3a3238" stroke-width=".9"/>')
        o.append('<path d="M8,-1 L15,1 L13,3 M15,1 L16,-2" stroke="#0b0b0e" stroke-width="2" fill="none"/>')
        o.append(f'<g filter="url(#glow)"><circle cx="2" cy="-9" r="1.3" fill="{ASH_L}"/><circle cx="6" cy="-9" r="1.1" fill="{ASH_L}"/>')
        o.append(f'<path d="M-3,2 l3,3 l-1,3 M4,0 l1,4" stroke="{ASH}" stroke-width="1.1" fill="none"/></g>')
        o.append('</g>')
    enemy(*ENEMY2, s=.9)
    enemy(*ENEMY)
    o.append('<g filter="url(#glow)">')
    for dx, dy, r in ((-10, -6, 1.8), (9, -15, 1.4), (12, 4, 1.3), (-6, 8, 1.2)):
        o.append(f'<circle cx="{ex+dx}" cy="{ey+dy}" r="{r}" fill="{ROT}"/>')
    o.append('</g>')

    def ruin(cx, cy):
        shadow(cx + 4, cy + 14, 22, 6)
        o.append(f'<path d="M{cx-14},{cy+12} L{cx-14},{cy-16} L{cx-9},{cy-20} L{cx-6},{cy-14} L{cx-4},{cy-17} L{cx-4},{cy+12}Z" fill="url(#rim)" stroke="#6a6e7a" stroke-width="1"/>')
        o.append(f'<path d="M{cx+3},{cy+12} L{cx+3},{cy-4} L{cx+8},{cy-1} L{cx+12},{cy-6} L{cx+12},{cy+12}Z" fill="url(#rim)" stroke="#6a6e7a" stroke-width="1"/>')
        for dx, dy, r in ((-17, 12, 3), (-1, 14, 3.5), (15, 13, 2.5), (8, 16, 2)):
            o.append(f'<circle cx="{cx+dx}" cy="{cy+dy}" r="{r}" fill="#1d1f25" stroke="#3a3d46" stroke-width=".6"/>')
        o.append(f'<circle cx="{cx-1}" cy="{cy+7}" r="3.6" fill="#8d8676"/><circle cx="{cx-2.4}" cy="{cy+7}" r=".9" fill="#111"/><circle cx="{cx+.6}" cy="{cy+7}" r=".9" fill="#111"/>')
    for r in RUINS:
        ruin(*r)
    o.append(f'<rect width="{W}" height="{H}" filter="url(#fog)" opacity=".28"/>')
    o.append(f'<rect width="{W}" height="{H}" fill="url(#vig)"/>')
    o.append('</svg>')
    return "\n".join(o)


open(os.path.join(OUT, "scene_a.svg"), "w").write(scene_a())
open(os.path.join(OUT, "scene_c.svg"), "w").write(scene_c())
print("ok")
