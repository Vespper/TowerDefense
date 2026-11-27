# Bâtisseur

| Stat | Valeur | Fichier |
|---|---|---|
| Vitesse | 320 px/s (8 cases/s) | `data/builder.tres` |
| Vitesse de construction | × 1 | `data/builder.tres` |
| Portée de construction | 34 px du centre de la case | `data/builder.tres` |

Le temps de construction de chaque tour est dans sa `TowerData` (`build_time`) : 1,5 s pour les tours de base, 2,5 s pour les tours de corruption.

Il démolit aussi les ruines commandées (4 s, `data/rules.tres` : `ruin_clear_time`), dans la même file que les tours.
