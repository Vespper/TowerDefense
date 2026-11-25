# Tours

Stats au niveau 1. Construction par le bâtisseur : 1,5 s pour une tour de base, 2,5 s pour une tour d'élément. Une amélioration prend ce temps × le niveau visé (Flèche niv. 2 : 3 s), pendant lequel la tour ne tire pas. Au niveau 2, on choisit une des deux branches de la tour (voir plus bas) ; le niveau 3 applique ses bonus une seconde fois. Amélioration vers le niveau N+1 : coût × 0,75 × N. Revente : 75 % du total dépensé. Portée en cases (40 px). Une zone touche sa cible, puis seulement les ennemis au sol autour.

## Tours de base (toujours disponibles)

| Tour | Coût | Dégâts | Tirs/s | Portée | Air | Effet | Fort contre | Faible contre | Fichier |
|---|---|---|---|---|---|---|---|---|---|
| Flèche | 12 | 8 | 1,4 | 3,5 | oui | — | Léger | Blindé | `data/towers/arrow.tres` |
| Mortier | 25 | 16 | 0,5 | 3,75 | non | zone 60 px | Blindé | Spectral | `data/towers/mortar.tres` |
| Magie | 30 | 10 | 0,8 | 3,25 | oui | rebondit sur 3 ennemis (90 px) | Spectral | Léger | `data/towers/magic.tres` |

Contre une armure : ×1,5 si la tour est forte, ×0,5 si elle est faible (`data/rules.tres`). Les tours d'élément ignorent les armures.

## Tours d'éléments (il faut avoir débloqué l'élément)

| Tour | Coût | Dégâts | Tirs/s | Portée | Air | Effet | Fichier |
|---|---|---|---|---|---|---|---|
| Lumière | 40 | 14 | 1,0 | 5,5 | oui | — | `data/towers/light.tres` |
| Ténèbres | 45 | 60 | 0,35 | 3,75 | oui | — | `data/towers/darkness.tres` |
| Eau | 40 | 6 | 2,0 | 3,25 | oui | zone 40 px, ralentit de 30 % pendant 1 s | `data/towers/water.tres` |
| Feu | 40 | 7 | 2,2 | 2,5 | oui | zone 55 px | `data/towers/fire.tres` |
| Nature | 40 | 6 | 1,5 | 3,75 | oui | poison 8/s pendant 3 s | `data/towers/nature.tres` |
| Terre | 45 | 20 | 0,8 | 3,25 | non | zone 60 px | `data/towers/earth.tres` |

## Arbre d'améliorations

Au passage au niveau 2, **U** choisit la branche A et **I** la branche B ; le niveau 3 renforce la même branche (U). Les bonus s'appliquent une fois au niveau 2 et deux fois au niveau 3 (ex. dégâts × 1,7 → × 2,89). Données : sous-ressources `TowerBranch` dans chaque `data/towers/*.tres`.

| Tour | Branche A (U) | Branche B (I) |
|---|---|---|
| Flèche | Perforante : dégâts × 1,7, portée × 1,1 | Rafale : cadence × 1,6, dégâts × 1,1 |
| Mortier | Obus lourds : dégâts × 1,75 | Fragmentation : zone + 25 px, dégâts × 1,3 |
| Magie | Chaîne : + 2 rebonds, dégâts × 1,3 | Arcane : dégâts × 1,75 |
| Lumière | Rayon : dégâts × 1,5, portée × 1,15 | Éclat : cadence × 1,45, dégâts × 1,15 |
| Ténèbres | Néant : dégâts × 1,8 | Ombres : cadence × 1,4, dégâts × 1,2 |
| Eau | Glace : ralentit de 10 % de plus, dégâts × 1,35 | Torrent : dégâts × 1,5, zone + 10 px |
| Feu | Brasier : zone + 15 px, dégâts × 1,4 | Fournaise : dégâts × 1,45, cadence × 1,15 |
| Nature | Venin : poison × 1,9, dégâts × 1,2 | Épines : dégâts × 1,5, cadence × 1,2 |
| Terre | Séisme : zone + 20 px, dégâts × 1,35 | Rocher : dégâts × 1,75, portée × 1,1 |
