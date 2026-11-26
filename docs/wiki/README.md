# Wiki du contenu

Catalogue de tout ce qui existe dans le jeu, avec ses chiffres. La source de vérité reste `data/*.tres` : quand on change un `.tres`, on met à jour sa ligne ici dans la même PR.

| Page | Contenu | Données |
|---|---|---|
| [corruptions.md](corruptions.md) | Corruptions, cycle des forces, stigmates | `scripts/data/element.gd`, `data/rules.tres` |
| [tours.md](tours.md) | Tours de base et de corruptions, stats, améliorations | `data/towers/` |
| [ennemis.md](ennemis.md) | Archétypes d'ennemis | `data/enemies/` |
| [vagues.md](vagues.md) | Les 20 vagues | `data/waves/` |
| [cartes.md](cartes.md) | Cartes, chemins, terres corrompues, ruines | `data/maps/` |
| [batisseur.md](batisseur.md) | Le bâtisseur | `data/builder.tres` |

Repères : une case = 40 px. Règles générales (`data/rules.tres`) : 80 or, 20 vies et 1 stigmate au départ ; première vague après 30 s, puis 30 s après la fin des apparitions de la précédente (3 s si le terrain est vide), lancement anticipé à 0,5 or par seconde gagnée ; fin de vague n : intérêts 3 % + bonus 10 + 2 × n, un stigmate toutes les 4 vagues ; revente 75 % ; 3 niveaux de tour.
