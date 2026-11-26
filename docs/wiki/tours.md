# Tours

Stats au niveau 1. Construction par le bâtisseur : 1,5 s pour une tour de base, 2,5 s pour une tour de corruption. Une amélioration prend ce temps × le niveau visé (Arbalète niv. 2 : 3 s), pendant lequel la tour ne tire pas. Au niveau 2, on choisit une des deux branches de la tour (voir plus bas) ; le niveau 3 applique ses bonus une seconde fois. Amélioration vers le niveau N+1 : coût × 0,75 × N. Revente : 75 % du total dépensé. Portée en cases (40 px). Une zone touche sa cible, puis seulement les ennemis au sol autour.

## Tours de base (toujours disponibles)

| Tour | Coût | Dégâts | Tirs/s | Portée | Air | Effet | Fort contre | Faible contre | Fichier |
|---|---|---|---|---|---|---|---|---|---|
| Arbalète | 12 | 8 | 1,4 | 3,5 | oui | — | Chair | Carapace | `data/towers/crossbow.tres` |
| Trébuchet | 25 | 16 | 0,5 | 3,75 | non | zone 60 px | Carapace | Spectre | `data/towers/trebuchet.tres` |
| Encensoir | 30 | 10 | 0,8 | 3,25 | oui | rebondit sur 3 ennemis (90 px) | Spectre | Chair | `data/towers/censer.tres` |

Contre une armure : ×1,5 si la tour est forte, ×0,5 si elle est faible (`data/rules.tres`). Les tours de corruption ignorent les armures.

## Tours de corruption (il faut avoir débloqué la corruption)

| Tour | Coût | Dégâts | Tirs/s | Portée | Air | Effet | Fichier |
|---|---|---|---|---|---|---|---|
| Ferveur | 40 | 14 | 1,0 | 5,5 | oui | — | `data/towers/fervor.tres` |
| Démence | 45 | 60 | 0,35 | 3,75 | oui | — | `data/towers/madness.tres` |
| Abîme | 40 | 6 | 2,0 | 3,25 | oui | zone 40 px, ralentit de 30 % pendant 1 s | `data/towers/abyss.tres` |
| Cendre | 40 | 7 | 2,2 | 2,5 | oui | zone 55 px | `data/towers/ash.tres` |
| Pourriture | 40 | 6 | 1,5 | 3,75 | oui | poison 8/s pendant 3 s | `data/towers/rot.tres` |
| Os | 45 | 20 | 0,8 | 3,25 | non | zone 60 px | `data/towers/bone.tres` |

## Arbre d'améliorations

Au passage au niveau 2, **U** choisit la branche A et **I** la branche B ; le niveau 3 renforce la même branche (U). Les bonus s'appliquent une fois au niveau 2 et deux fois au niveau 3 (ex. dégâts × 1,7 → × 2,89). Données : sous-ressources `TowerBranch` dans chaque `data/towers/*.tres`.

| Tour | Branche A (U) | Branche B (I) |
|---|---|---|
| Arbalète | Carreaux lourds : dégâts × 1,7, portée × 1,1 | Rafale : cadence × 1,6, dégâts × 1,1 |
| Trébuchet | Pierres lourdes : dégâts × 1,75 | Mitraille : zone + 25 px, dégâts × 1,3 |
| Encensoir | Volutes : + 2 rebonds, dégâts × 1,3 | Myrrhe amère : dégâts × 1,75 |
| Ferveur | Sermon : dégâts × 1,5, portée × 1,15 | Litanie : cadence × 1,45, dégâts × 1,15 |
| Démence | Hurlement : dégâts × 1,8 | Murmures : cadence × 1,4, dégâts × 1,2 |
| Abîme | Étreinte : ralentit de 10 % de plus, dégâts × 1,35 | Marée noire : dégâts × 1,5, zone + 10 px |
| Cendre | Bûcher : zone + 15 px, dégâts × 1,4 | Braises : dégâts × 1,45, cadence × 1,15 |
| Pourriture | Spores : poison × 1,9, dégâts × 1,2 | Vermine : dégâts × 1,5, cadence × 1,2 |
| Os | Charnier : zone + 20 px, dégâts × 1,35 | Crâne : dégâts × 1,75, portée × 1,1 |
