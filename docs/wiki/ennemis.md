# Ennemis

L'archétype donne les stats de base ; la vague donne la corruption **ou** l'armure (Chair, Carapace, Spectre) et un multiplicateur de PV. Vitesse en px/s (une case = 40 px).

| Archétype | PV | Vitesse | Or | Vies perdues | Particularité | Fichier |
|---|---|---|---|---|---|---|
| Fantassin | 40 | 60 | 2 | 1 | — | `data/enemies/grunt.tres` |
| Coureur | 25 | 110 | 2 | 1 | rapide | `data/enemies/runner.tres` |
| Horde | 14 | 70 | 1 | 1 | très nombreux | `data/enemies/horde.tres` |
| Volant | 30 | 70 | 2 | 1 | volant | `data/enemies/flyer.tres` |
| Soigneur | 45 | 55 | 3 | 1 | en mourant, soigne de 25 % les ennemis à 100 px | `data/enemies/healer.tres` |
| Colosse | 120 | 40 | 5 | 2 | lent, résistant | `data/enemies/brute.tres` |
| Seigneur | 900 | 35 | 50 | 10 | boss | `data/enemies/boss.tres` |
| Champion | 50 | 50 | 8 | 2 | élite : glissé dans une vague, avec son propre corruption | `data/enemies/champion.tres` |

Signes visibles : couleur = corruption de la vague (gris = neutre) ; carré à plaques = Carapace ; translucide avec halo = Spectre ; couronne dorée = élite ; triangle avec ombre = volant ; croix blanche = soigneur ; anneau bleu clair = ralenti ; point vert = empoisonné ; barre blanche = PV.
