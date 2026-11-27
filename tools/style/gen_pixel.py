"""Direction B : pixel art lugubre, cases de 16 px, palette restreinte. Rendu 256x160 agrandi x4."""
import random, sys, os
from PIL import Image, ImageDraw

OUT = sys.argv[1]
rnd = random.Random(5)
P = {
    "k": (14, 12, 12), "g0": (30, 28, 26), "g1": (38, 35, 31), "g2": (48, 44, 37), "gr": (58, 56, 36),
    "p0": (66, 54, 41), "p1": (84, 69, 51), "p2": (104, 87, 64), "pd": (48, 39, 30),
    "s0": (40, 37, 36), "s1": (74, 69, 64), "s2": (110, 104, 95), "s3": (150, 142, 128),
    "b": (207, 196, 166), "w0": (70, 48, 33), "w1": (104, 74, 50),
    "r0": (60, 84, 26), "r1": (134, 168, 50), "r2": (196, 224, 90),
    "a0": (120, 40, 20), "a1": (212, 88, 43), "a2": (255, 177, 90),
}
W, H = 256, 160
img = Image.new("RGB", (W, H), P["g0"])
px = img.load()

def on_path(x, y):
    return (32 <= y < 48 and x < 192) or (176 <= x < 192 and 32 <= y < 128) or (112 <= y < 128 and x >= 176)

# sol tramé + herbes mortes
for y in range(H):
    for x in range(W):
        n = rnd.random()
        px[x, y] = P["g1"] if n < .35 else (P["g2"] if n < .42 else P["g0"])
for _ in range(70):
    x, y = rnd.randrange(W), rnd.randrange(H)
    for k in range(rnd.randint(1, 3)):
        if 0 <= x + k * 2 < W and y > 2:
            px[x + k * 2, y] = P["gr"]; px[x + k * 2, y - 1] = P["gr"]
# chemin
for y in range(H):
    for x in range(W):
        if on_path(x, y):
            n = rnd.random()
            px[x, y] = P["p1"] if n < .55 else (P["p0"] if n < .85 else P["p2"])
# bords du chemin : 1 px sombre
for y in range(1, H - 1):
    for x in range(1, W - 1):
        if not on_path(x, y) and any(on_path(x + dx, y + dy) for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))):
            px[x, y] = P["pd"]
for _ in range(40):
    x, y = rnd.randrange(W), rnd.randrange(H)
    if on_path(x, y):
        px[x, y] = P["s2"]

def sprite(w, h, draw_fn):
    s = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(s)
    draw_fn(d)
    # contour 1 px
    a = s.load()
    out = s.copy(); o = out.load()
    for y in range(h):
        for x in range(w):
            if a[x, y][3] == 0 and any(0 <= x + dx < w and 0 <= y + dy < h and a[x + dx, y + dy][3] > 0 for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))):
                o[x, y] = P["k"] + (255,)
    return out

def shadow(cx, cy, rx):
    d = ImageDraw.Draw(img)
    for x in range(cx - rx, cx + rx + 1):
        for y in (cy, cy + 1):
            if 0 <= x < W and (x + y) % 1 == 0:
                r, g, b = px[x, y]; px[x, y] = (r // 2, g // 2, b // 2)

def c(k):
    return P[k] + (255,)

def block(d):
    d.rectangle([1, 8, 14, 20], fill=c("s1"))
    d.rectangle([1, 8, 14, 13], fill=c("s2"))
    d.line([1, 8, 14, 8], fill=c("s3"))
    d.line([1, 14, 14, 14], fill=c("s0"))
    d.point([(4, 16), (9, 18), (12, 15)], fill=c("s0"))

def crossbow(d):
    block(d)
    d.line([4, 9, 12, 3], fill=c("w1"), width=2)       # fût
    d.line([8, 1, 15, 7], fill=c("w0"), width=1)       # arc
    d.point([(9, 1), (14, 6), (15, 7), (8, 1)], fill=c("w1"))
    d.line([9, 2, 14, 6], fill=c("b"))                 # corde
    d.point([(13, 2)], fill=c("s3"))                   # pointe du carreau
    d.point([(3, 10)], fill=c("b"))

def rot(d):
    block(d)
    d.rectangle([3, 5, 12, 12], fill=c("s0"))
    d.line([3, 5, 3, 12], fill=c("s1")); d.line([7, 5, 7, 12], fill=c("k"))
    d.ellipse([2, 2, 13, 7], fill=c("r1"))
    d.point([(5, 4), (6, 4), (10, 5)], fill=c("r2"))
    d.line([12, 6, 12, 13], fill=c("r1")); d.point([(12, 14)], fill=c("r0"))
    d.line([3, 7, 3, 10], fill=c("r0"))

def enemy(d):
    d.polygon([(2, 13), (3, 5), (5, 1), (8, 1), (10, 5), (11, 13), (8, 11), (6, 13), (4, 11)], fill=c("s0"))
    d.line([4, 2, 8, 2], fill=c("s1"))
    d.rectangle([5, 3, 8, 5], fill=c("k"))
    d.point([(6, 4), (8, 4)], fill=c("a2"))
    d.point([(5, 8), (6, 9), (8, 7)], fill=c("a1"))
    d.line([10, 7, 12, 8], fill=c("s1"))

def ruin(d):
    d.polygon([(1, 15), (1, 3), (3, 1), (4, 4), (6, 2), (6, 15)], fill=c("s2"))
    d.line([5, 4, 5, 15], fill=c("s1")); d.line([1, 3, 3, 1], fill=c("s3"))
    d.polygon([(9, 15), (9, 8), (11, 9), (13, 7), (13, 15)], fill=c("s2"))
    d.line([12, 9, 12, 15], fill=c("s1"))
    d.rectangle([5, 12, 8, 15], fill=c("b")); d.point([(6, 13), (8, 13)], fill=c("k"))
    d.point([(0, 15), (14, 15), (15, 14)], fill=c("s1"))

def paste(spr, x, y):
    img.paste(spr, (x, y), spr)

# disposition identique aux autres planches (cases 16 px)
shadow(105, 79, 8); paste(sprite(16, 22, crossbow), 96, 58)       # case (6,4)
shadow(153, 79, 8); paste(sprite(16, 22, rot), 144, 58)          # case (9,4)
for ex, ey in ((60, 40), (134, 41)):
    shadow(ex + 1, ey + 6, 5)
    paste(sprite(14, 14, enemy), ex - 7, ey - 8)
for rx, ry in ((216, 88), (40, 104)):
    shadow(rx + 1, ry + 6, 8); paste(sprite(16, 16, ruin), rx - 8, ry - 10)

# poison : bulles vertes autour de l'ennemi, spores entre cuve et cible
for x, y, k in ((129, 35, "r1"), (139, 33, "r2"), (141, 40, "r1"), (131, 44, "r0"), (150, 56, "r1"), (146, 50, "r2"), (142, 45, "r1")):
    px[x, y] = P[k]
# carreau en vol
for i, (x, y) in enumerate(((118, 55), (119, 54), (120, 53), (121, 52))):
    px[x, y] = P["s3"] if i < 3 else P["b"]

big = img.resize((W * 4, H * 4), Image.NEAREST)
big.save(os.path.join(OUT, "b.png"))
print("ok")
