# Feuille de route

Mise à jour à chaque fin de session (skill `fin-de-session`). Garder ce fichier court : l'historique est dans git.

## Jalons

1. ✱ **Prototype jouable** (en cours) — question : choisir ses corruptions et placer ses tours le long du chemin est-il amusant ?
2. ⬜ Profondeur : fusions de corruptions (15 tours doubles, débloquées par défis), opposés (Schisme, fusions hérétiques), L'Indicible, niveaux de corruption, tours de soutien, ennemis mécaniques / morts-vivants / immunisés
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
- [x] Arbre d'améliorations : 2 branches par tour, choisies au niveau 2 (U / I)
- [x] Habillage grimdark du vocabulaire : les Six Corruptions, stigmates, Arbalète / Trébuchet / Encensoir, Chair / Carapace / Spectre
- [x] Terres corrompues et ruines à démolir sur la carte Serpent
- [x] Carte Charnier 40 × 24 (146 cases), caméra qui suit le bâtisseur, pause (P)
- [x] Nouvelle interface selon la maquette (barre du haut, colonne droite, barre du bas, minicarte, aide H)
- [x] Partie raccourcie à 10 vagues (réglable), gains de stigmates bien visibles
- [ ] Équilibrage après la session de test

## Prochaine étape

Session de test de Vespper (armures, élites, arbre d'améliorations, nouveaux noms), puis équilibrage. Ensuite : Schisme (opposés côte à côte), puis fusions de corruptions (noms et idées dans le GDD), puis portes qui s'ouvrent.

## Journal

- 2026-11-27 — Partie de 10 vagues, stigmates annoncés et marqués dans les prochaines vagues.
- 2026-11-27 — Nouvelle interface : barres, prochaines vagues, minicarte, infos au survol, aide (H).
- 2026-11-27 — Carte Charnier plus grande, caméra, pause (PR #10).
- 2026-11-26 — Terres corrompues et ruines à démolir (PR #8).
- 2026-11-26 — Renommage grimdark : les Six Corruptions, nouvelle roue, stigmates, nouveaux noms des tours et armures (PR #7).
- 2026-11-25 — Arbre d'améliorations : 2 branches par tour, touche I pour la branche B (PR #6).
- 2026-11-25 — Armures des vagues neutres, élites à élément, 20 vagues refaites, compte à rebours à 3 s (PR #5).
- 2026-11-25 — Amélioration avec chantier, vagues automatiques, roue des éléments, difficulté relevée (PR #4).
- 2026-11-25 — Circuit plus long, bâtisseur qui construit les tours, vagues rééquilibrées (PR #3).
- 2026-11-25 — Passage au chemin fixe, 6 éléments, tours de base Flèche / Mortier / Magie, essences, 20 vagues (PR #2).
- 2026-11-25 — Création du projet : doc, conventions, scripts, CI, prototype à labyrinthe libre (PR #1).
