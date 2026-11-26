# Cartes

Grille de 24 × 15 cases. Le chemin est donné par ses coins (`waypoints`) ; les autres cases sont constructibles, sauf les ruines tant qu'elles sont debout.

| Carte | Chemin (coins) | Longueur | Fichier |
|---|---|---|---|
| Serpent | (0,1) → (21,1) → (21,5) → (2,5) → (2,9) → (21,9) → (21,13) → (0,13) | 93 cases | `data/maps/serpent.tres` |

## Terres corrompues

Cases teintées de la couleur d'une corruption (`MapData.corrupted_cells`). Une tour de cette corruption y fait **+25 %** de dégâts (et de poison), une tour de la corruption **opposée** y fait **−25 %** (`data/rules.tres` : `terrain_bonus`, `terrain_malus`). Les tours de base et les autres corruptions ne changent pas. Le fantôme de la tour affiche « +25 % » ou « -25 % » avant de construire.

| Carte | Corruption | Cases |
|---|---|---|
| Serpent | Ferveur | (9,3), (10,3) |
| Serpent | Démence | (15,7), (16,7) |
| Serpent | Abîme | (6,11), (7,11) |
| Serpent | Cendre | (22,2), (22,3) |
| Serpent | Pourriture | (13,11), (14,11) |
| Serpent | Os | (0,7), (1,7) |

## Ruines

Tas de pierres et d'os qui bloquent une bonne case (`MapData.ruins`). Clic sur une ruine : on paie **20 or** et le bâtisseur va la démolir (**4 s** de travail, dans sa file de chantiers). Un second clic avant la fin annule et rembourse. Une fois démolie, la case est constructible.

| Carte | Ruines |
|---|---|
| Serpent | (20,3), (3,7), (20,11), (10,3) (sur une terre de Ferveur) |
