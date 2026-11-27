# Vagues

Les vagues partent seules : 30 s avant la première, puis 30 s après la fin des apparitions de la précédente, ou 3 s dès que le terrain est vide. On peut les lancer plus tôt contre 0,5 or par seconde gagnée. PV d'un ennemi = PV de l'archétype × multiplicateur. Quand une vague n est vaincue : intérêts 3 % + bonus 10 + 2 × n . Élites : le joueur choisit leur corruption avant la vague (hasard sinon), la colonne « Élites » donne la corruption par défaut des données, qui n'est plus utilisée en jeu ; les tuer tous donne un stigmate de leur corruption.

« Type » : la corruption de la vague, ou son armure pour une vague neutre. Les fichiers sont `data/waves/wave_NN.tres`.

| # | Archétype | Type | Nombre | Intervalle (s) | × PV | PV par ennemi | Élites |
|---|---|---|---|---|---|---|---|
| 1 | Fantassin | Chair | 10 | 0,9 | 1,59 | 64 | — |
| 2 | Coureur | Chair | 10 | 0,7 | 1,59 | 40 | — |
| 3 | Fantassin | Carapace | 10 | 0,9 | 1,59 | 64 | — |
| 4 | Volant | Spectre | 10 | 0,9 | 1,59 | 48 | — |
| 5 | Horde | Chair | 24 | 0,3 | 3,72 | 52 | 1 × Champion Cendre (186 PV) |
| 6 | Soigneur | Spectre | 12 | 0,9 | 3,72 | 167 | — |
| 7 | Colosse | Carapace | 8 | 1,4 | 3,95 | 474 | 2 × Champion Abîme (198 PV) |
| 8 | Coureur | Spectre | 16 | 0,5 | 3,68 | 92 | — |
| 9 | Volant | Chair | 14 | 0,8 | 4,31 | 129 | 2 × Champion Ferveur (215 PV) |
| 10 | Seigneur | Carapace | 1 | 1 | 2,72 | 2448 | — |
| 11 | Horde | Carapace | 36 | 0,25 | 6,59 | 92 | 3 × Champion Pourriture (330 PV) |
| 12 | Fantassin | Démence | 18 | 0,6 | 9,44 | 378 | — |
| 13 | Soigneur | Chair | 16 | 0,7 | 12,93 | 582 | 3 × Champion Os (646 PV) |
| 14 | Volant | Cendre | 18 | 0,6 | 12,93 | 388 | — |
| 15 | Colosse | Ferveur | 12 | 1 | 12,35 | 1482 | — |
| 16 | Coureur | Carapace | 22 | 0,45 | 14,37 | 359 | 4 × Champion Démence (718 PV) |
| 17 | Horde | Pourriture | 44 | 0,22 | 17,11 | 240 | — |
| 18 | Volant | Abîme | 22 | 0,5 | 17,11 | 513 | — |
| 19 | Fantassin | Os | 24 | 0,5 | 22,26 | 890 | 4 × Champion Cendre (1113 PV) |
| 20 | Seigneur | Démence | 1 | 1 | 8,57 | 7713 | — |

Repère (`tools/test.sh`, joueur automatique qui laisse partir les vagues seules) : victoire avec 8 vies sur 20, 30 tours. Sans rien construire : défaite à la vague 2.
