# Vagues

Les vagues partent seules : 30 s avant la première, puis 30 s après la fin des apparitions de la précédente, ou 3 s dès que le terrain est vide. On peut les lancer plus tôt contre 0,5 or par seconde gagnée. PV d'un ennemi = PV de l'archétype × multiplicateur. Quand une vague n est vaincue : intérêts 3 % + bonus 10 + 2 × n ; un stigmate après les vagues 4, 8, 12, 16, 20.

« Type » : la corruption de la vague, ou son armure pour une vague neutre. Les fichiers sont `data/waves/wave_NN.tres`.

| # | Archétype | Type | Nombre | Intervalle (s) | × PV | PV par ennemi | Élites |
|---|---|---|---|---|---|---|---|
| 1 | Fantassin | Chair | 10 | 0,9 | 1,8 | 72 | — |
| 2 | Coureur | Chair | 10 | 0,7 | 1,8 | 45 | — |
| 3 | Fantassin | Carapace | 10 | 0,9 | 1,8 | 72 | — |
| 4 | Volant | Spectre | 10 | 0,9 | 1,8 | 54 | — |
| 5 | Horde | Chair | 24 | 0,3 | 4,22 | 59 | 1 × Champion Cendre (211 PV) |
| 6 | Soigneur | Spectre | 12 | 0,9 | 4,22 | 190 | — |
| 7 | Colosse | Carapace | 8 | 1,4 | 4,49 | 539 | 2 × Champion Abîme (224 PV) |
| 8 | Coureur | Spectre | 16 | 0,5 | 3,6 | 90 | — |
| 9 | Volant | Chair | 14 | 0,8 | 4,22 | 127 | 2 × Champion Ferveur (211 PV) |
| 10 | Seigneur | Carapace | 1 | — | 2,64 | 2376 | — |
| 11 | Horde | Carapace | 36 | 0,25 | 6,44 | 90 | 3 × Champion Pourriture (322 PV) |
| 12 | Fantassin | Démence | 18 | 0,6 | 9,22 | 369 | — |
| 13 | Soigneur | Chair | 16 | 0,7 | 12,63 | 568 | 3 × Champion Os (632 PV) |
| 14 | Volant | Cendre | 18 | 0,6 | 12,63 | 379 | — |
| 15 | Colosse | Ferveur | 12 | 1,0 | 12,06 | 1447 | — |
| 16 | Coureur | Carapace | 22 | 0,45 | 14,04 | 351 | 4 × Champion Démence (702 PV) |
| 17 | Horde | Pourriture | 44 | 0,22 | 16,72 | 234 | — |
| 18 | Volant | Abîme | 22 | 0,5 | 16,72 | 502 | — |
| 19 | Fantassin | Os | 24 | 0,5 | 21,75 | 870 | 4 × Champion Cendre (1088 PV) |
| 20 | Seigneur | Démence | 1 | — | 8,38 | 7542 | — |

Repère (`tools/test.sh`, joueur automatique qui laisse partir les vagues seules) : victoire avec 8 vies sur 20, 30 tours. Sans rien construire : défaite à la vague 2.
