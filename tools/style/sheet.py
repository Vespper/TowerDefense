import json, sys
D = {
 "a": dict(letter="A", name="Gravure", sub="Encre noire sur papier sale, une seule couleur : celle de la corruption",
   bg="#1a1713", fg="#e4dcc6", acc="#86a832",
   pal=[("#15120f","Encre"),("#c9bfa6","Papier"),("#ddd4bc","Papier clair"),("#86a832","Pourriture"),("#d4582b","Cendre")],
   pour=["Le plus proche de Vermis : ça a l'air d'un vieux livre maudit.","Les corruptions sautent aux yeux, puisque c'est la seule couleur.","Très original pour un tower defense."],
   contre=["Le plus dur à produire : hachures, contours irréguliers, shader de papier.","Quand l'écran se remplit (horde, 30 tours), les hachures peuvent devenir du bruit.","Les 6 couleurs doivent rester rares pour garder l'effet."],
   godot="Sprites dessinés à la main (ou SVG) + un shader de grain papier et de tremblement d'encre sur tout l'écran."),
 "b": dict(letter="B", name="Pixel art lugubre", sub="Cases de 16 px agrandies, palette d'une vingtaine de teintes sombres",
   bg="#16130f", fg="#e0d6c0", acc="#d4582b",
   pal=[("#1e1c1a","Sol"),("#544536","Chemin"),("#6e6860","Pierre"),("#cfc4a6","Os"),("#86a832","Pourriture"),("#d4582b","Cendre")],
   pour=["Le plus simple à produire et à faire évoluer : un sprite = quelques minutes.","Très lisible même avec beaucoup d'ennemis.","Style rétro assumé, cohérent avec Vermis (illustrations pensées comme un jeu PS1/16 bits)."],
   contre=["Moins singulier : beaucoup de jeux indés l'utilisent.","L'ambiance repose sur la palette : il faut la tenir strictement.","Agrandir la carte impose un zoom entier (x2, x3) pour garder des pixels nets."],
   godot="Sprites PNG 16 px, filtre « Nearest », caméra au zoom entier. Animations image par image."),
 "c": dict(letter="C", name="Silhouettes et lueurs", sub="Monde presque noir, formes simples ; seules les corruptions émettent de la lumière",
   bg="#0e0f13", fg="#d8d6d0", acc="#86a832",
   pal=[("#18191e","Sol"),("#3a332b","Chemin"),("#22242b","Silhouette"),("#6a6e7a","Bord éclairé"),("#86a832","Pourriture"),("#d4582b","Cendre")],
   pour=["Le plus proche de ce qu'on a déjà : formes simples, on garde le code de dessin.","Ambiance immédiate : brouillard, halos, les tours de corruption « éclairent » la carte.","La lumière dit tout : on voit la corruption d'une vague de loin."],
   contre=["Risque de manquer de détail : il faut soigner les silhouettes.","Les halos coûtent un peu (Light2D ou shader de lueur), à surveiller avec 200 ennemis.","Moins « gravure » que Vermis, plus « lanterne dans la nuit »."],
   godot="Formes en code ou sprites sombres + WorldEnvironment glow, PointLight2D sur les tours de corruption, brouillard en shader."),
"d": dict(letter="D", name="Lueurs gravées", sub="Base C, décor gravé façon Vermis, éléments de jeu lisibles façon Isaac",
   bg="#101114", fg="#ddd8cc", acc="#86a832",
   pal=[("#18191d","Sol"),("#2b2c33","Hachures"),("#5a4c3d","Chemin"),("#5d5a58","Pierre des tours"),("#08080a","Contour"),("#86a832","Pourriture"),("#d4582b","Cendre")],
   pour=["Décor gravé, sombre et peu contrasté : l'ambiance Vermis reste en fond.","Tout ce qui compte en jeu a un contour noir épais et une valeur moyenne : on le voit d'un coup d'œil, comme dans Isaac.","Les corruptions restent les seules couleurs vives, avec leur halo."],
   contre=["Deux couches de style à tenir (décor gravé, objets à contour) : il faut des règles claires.","Les contours épais rendent les objets un peu plus « cartoon » que Vermis pur."],
   godot="Décor : une texture de sol gravée + shader de grain. Objets : sprites à contour (dessinés ou rendus depuis Blender avec un contour). Halos : glow + PointLight2D sur les tours de corruption."),
}
zones=[("Arbalète",416,280),("Pourriture",608,280),("Ennemi",534,158),("Ruine",864,345)]
for k,d in D.items():
    pal="".join(f'<div class="sw"><i style="background:{c}"></i>{n}</div>' for c,n in d["pal"])
    zo="".join(f'<div class="z"><div class="zi" style="background-position:{-(x*2-75)}px {-(y*2-75)}px"></div><span>{n}</span></div>' for n,x,y in zones)
    li=lambda l:"".join(f"<li>{t}</li>" for t in l)
    html=f'''<!doctype html><meta charset="utf-8"><style>
body{{margin:0;width:1600px;height:900px;background:{d["bg"]};color:{d["fg"]};font-family:Georgia,serif;overflow:hidden}}
h1{{position:absolute;left:24px;top:14px;margin:0;font-size:34px;font-weight:normal;letter-spacing:1px}}
h1 b{{color:{d["acc"]};margin-right:12px}}
.sub{{position:absolute;left:24px;top:56px;font-size:16px;opacity:.7;font-style:italic}}
.scene{{position:absolute;left:24px;top:90px;width:1024px;height:640px;background:url(scene_{k}.png);outline:1px solid #ffffff22}}
.zs{{position:absolute;left:24px;top:744px;display:flex;gap:16px}}
.z{{position:relative;width:150px;height:150px;outline:1px solid #ffffff22}}
.zi{{width:150px;height:150px;background:url(scene_{k}.png);background-size:2048px 1280px;image-rendering:{"pixelated" if k=="b" else "auto"}}}
.z span{{position:absolute;left:6px;bottom:4px;font-size:13px;background:#000a;padding:1px 6px}}
.note{{position:absolute;left:680px;top:752px;width:368px;font-size:13.5px;opacity:.75;line-height:1.45}}
.side{{position:absolute;left:1076px;top:90px;width:500px;font-size:16px;line-height:1.45}}
h2{{font-size:15px;text-transform:uppercase;letter-spacing:2px;margin:18px 0 6px;color:{d["acc"]};font-weight:normal}}
ul{{margin:0;padding-left:20px}} li{{margin-bottom:5px}}
.pal{{display:flex;flex-wrap:wrap;gap:8px 14px}} .sw{{font-size:13px;display:flex;align-items:center;gap:6px}}
.sw i{{display:inline-block;width:22px;height:22px;border:1px solid #ffffff44}}
</style>
<h1><b>{d["letter"]}</b>{d["name"]}</h1><div class="sub">{d["sub"]}</div>
<div class="scene"></div><div class="zs">{zo}</div>
<div class="note">Échelle réelle du jeu : cases de 40 px (ici agrandies × 1,6). Les vignettes sont zoomées × 3,2. Ennemi de Cendre empoisonné par la tour de Pourriture, carreau d'Arbalète en vol.</div>
<div class="side"><h2 style="margin-top:0">Palette</h2><div class="pal">{pal}</div>
<h2>Pour</h2><ul>{li(d["pour"])}</ul><h2>Contre</h2><ul>{li(d["contre"])}</ul>
<h2>Dans Godot</h2><div>{d["godot"]}</div></div>'''
    open(f"sheet_{k}.html","w").write(html)
