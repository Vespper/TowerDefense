# Feuille de route

Mise à jour à chaque fin de session (skill `fin-de-session`). Garder ce fichier court : l'historique est dans git.

## Jalons

1. ✱ **Prototype jouable** (en cours) — question : choisir ses éléments et placer ses tours le long du chemin est-il amusant ?
2. ⬜ Profondeur Element TD : niveaux d'élément, tours doubles puis triples, tours de soutien, ennemis mécaniques / morts-vivants / immunisés
3. ⬜ Contenu : 40 à 60 vagues, 3 à 5 cartes, équilibrage
4. ⬜ Habillage : style visuel, sons, menus, choix de la carte, meilleurs scores
5. ⬜ Mode cartes libres (labyrinthe construit avec les tours)
6. ⬜ Retour vers le roguelike : reprendre ce qui marche dans `Gameproject`

## Jalon 1 — prototype jouable (formes simples)

- [x] Projet, doc, conventions, scripts, CI (PR #1)
- [x] Carte à chemin fixe en données (`data/maps/serpent.tres`)
- [x] 6 éléments, cycle × 2 / × 0,5, essences pour les débloquer
- [x] Tours de base Flèche, Mortier, Magie + 6 tours d'éléments, amélioration ×3, revente 75 %
- [x] 7 archétypes (dont volants, soigneurs, boss), 20 vagues, intérêts 3 %
- [x] Circuit plus long (93 cases) et bâtisseur qui va construire les tours (temps de construction)
- [x] Session de test de Vespper : victoire avec 14 vies, pas assez de difficulté
- [x] Amélioration = chantier (tour hors service), vagues automatiques avec lancement anticipé, roue des éléments, difficulté relevée
- [x] Deuxième session de test : victoire avec 10 vies
- [x] Vagues neutres à armure (Flèche / Mortier / Magie), élites à élément, compte à rebours à 3 s quand le terrain est vide
- [ ] Arbre d'améliorations : 2 branches par tour
- [ ] Équilibrage après la session de test

## Prochaine étape

Arbre d'améliorations (2 branches par tour au niveau 2), puis nouvelle session de test.

## Journal

- 2026-11-25 — Armures des vagues neutres, élites à élément, 20 vagues refaites, compte à rebours à 3 s (PR #5).
- 2026-11-25 — Amélioration avec chantier, vagues automatiques, roue des éléments, difficulté relevée (PR #4).
- 2026-11-25 — Circuit plus long, bâtisseur qui construit les tours, vagues rééquilibrées (PR #3).
- 2026-11-25 — Passage au chemin fixe, 6 éléments, tours de base Flèche / Mortier / Magie, essences, 20 vagues (PR #2).
- 2026-11-25 — Création du projet : doc, conventions, scripts, CI, prototype à labyrinthe libre (PR #1).
