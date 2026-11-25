# Vagues

Les vagues partent seules : 30 s avant la première, puis 30 s après la fin des apparitions de la précédente (on peut les lancer plus tôt contre 0,5 or par seconde gagnée). PV d'un ennemi = PV de l'archétype × multiplicateur. Quand une vague n est vaincue : intérêts 3 % + bonus 10 + 2 × n ; une essence après les vagues 4, 8, 12, 16, 20.

| # | Archétype | Élément | Nombre | Intervalle (s) | × PV | PV par ennemi | Fichier |
|---|---|---|---|---|---|---|---|
| 1 | Fantassin | Terre | 10 | 0,9 | 1,8 | 72 | `wave_01.tres` |
| 2 | Coureur | Eau | 10 | 0,7 | 1,8 | 45 | `wave_02.tres` |
| 3 | Horde | Feu | 24 | 0,3 | 1,8 | 25 | `wave_03.tres` |
| 4 | Volant | Lumière | 10 | 0,9 | 1,8 | 54 | `wave_04.tres` |
| 5 | Fantassin | Nature | 14 | 0,8 | 4,22 | 169 | `wave_05.tres` |
| 6 | Soigneur | Ténèbres | 12 | 0,9 | 4,22 | 190 | `wave_06.tres` |
| 7 | Colosse | Terre | 8 | 1,4 | 4,49 | 539 | `wave_07.tres` |
| 8 | Coureur | Feu | 16 | 0,5 | 5,28 | 132 | `wave_08.tres` |
| 9 | Volant | Eau | 14 | 0,8 | 5,28 | 158 | `wave_09.tres` |
| 10 | Seigneur | Lumière | 1 | — | 3,3 | 2970 | `wave_10.tres` |
| 11 | Horde | Nature | 36 | 0,25 | 8,77 | 123 | `wave_11.tres` |
| 12 | Fantassin | Ténèbres | 18 | 0,6 | 10,03 | 401 | `wave_12.tres` |
| 13 | Soigneur | Eau | 16 | 0,7 | 11,94 | 537 | `wave_13.tres` |
| 14 | Volant | Feu | 18 | 0,6 | 11,94 | 358 | `wave_14.tres` |
| 15 | Colosse | Lumière | 12 | 1,0 | 11,39 | 1367 | `wave_15.tres` |
| 16 | Coureur | Terre | 22 | 0,45 | 13,28 | 332 | `wave_16.tres` |
| 17 | Horde | Ténèbres | 44 | 0,22 | 15,8 | 221 | `wave_17.tres` |
| 18 | Volant | Nature | 22 | 0,5 | 15,8 | 474 | `wave_18.tres` |
| 19 | Fantassin | Eau | 24 | 0,5 | 20,55 | 822 | `wave_19.tres` |
| 20 | Seigneur | Ténèbres | 1 | — | 7,92 | 7128 | `wave_20.tres` |

Repère (`tools/test.sh`, joueur automatique qui laisse partir les vagues seules) : victoire avec 6 vies sur 20, 30 tours. Sans rien construire : défaite à la vague 2.
