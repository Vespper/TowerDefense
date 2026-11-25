# Wiki du contenu

Catalogue de tout ce qui existe dans le jeu, avec ses chiffres. La source de vérité reste `data/*.tres` : quand on change un `.tres`, on met à jour sa ligne ici dans la même PR.

| Page | Contenu | Données |
|---|---|---|
| [elements.md](elements.md) | Éléments, cycle des forces, couleurs | `scripts/data/element.gd`, `data/rules.tres` |
| [tours.md](tours.md) | Tours, stats, améliorations | `data/towers/` |
| [ennemis.md](ennemis.md) | Archétypes d'ennemis | `data/enemies/` |
| [vagues.md](vagues.md) | Les 10 vagues du prototype | `data/waves/` |

Repères : une case = 40 px. Règles générales (`data/rules.tres`) : 80 or et 20 vies au départ, bonus de fin de vague 15 + 3 × n, revente 75 %, 3 niveaux de tour.
