# Feuille de route

Mise à jour à chaque fin de session (skill `fin-de-session`). Garder ce fichier court : l'historique est dans git.

## Jalons

1. ✱ **Prototype jouable** (en cours) — question : construire son labyrinthe et choisir ses éléments est-il amusant ?
2. ⬜ Éléments à débloquer : essences, tours doubles — question : les choix d'éléments créent-ils des parties différentes ?
3. ⬜ Contenu : 30 vagues, nouveaux archétypes (volants, immunisés), 2 ou 3 cartes, équilibrage
4. ⬜ Habillage : style visuel, sons, menus, sauvegarde des meilleurs scores
5. ⬜ Retour vers le roguelike : reprendre ce qui marche dans `Gameproject`

## Jalon 1 — prototype jouable (formes simples)

- [x] Terrain en grille, labyrinthe libre, chemin recalculé, interdiction de fermer le passage
- [x] 10 vagues dans `data/waves/`, lancées à la main, victoire / défaite
- [x] 5 tours (Flèche + 4 éléments), cycle des éléments, amélioration ×3, revente 75 %
- [x] Interface : or, vies, prochaine vague, panneau de la tour, vitesse x1/x2/x3
- [x] Tests headless (terrain, partie complète automatique) et CI GitHub
- [ ] Session de test de Vespper : noter le ressenti dans `docs/decisions.md`
- [ ] Équilibrage après la session de test

## Prochaine étape

Vespper joue le prototype (F5) et dit ce qu'il ressent : difficulté, envie de construire le labyrinthe, lisibilité des éléments. Ensuite : déblocage des éléments par essences.

## Journal

- 2026-11-25 — Création du projet : doc, conventions, scripts, CI, prototype jouable (PR #1).
