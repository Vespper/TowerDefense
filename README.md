# TowerDefense

Tower defense classique à corruptions, qui reprend le fonctionnement d'Element TD (Warcraft 3), fait avec Godot 4.7.

Les ennemis suivent un chemin fixe ; on pose des tours de base (Arbalète, Trébuchet, Encensoir) et, en dépensant des stigmates, on débloque les tours des six corruptions. Chaque vague a une corruption : Ferveur > Démence > Abîme > Cendre > Os > Pourriture > Ferveur (× 2 contre la corruption suivante, × 0,5 contre la précédente).

- Lancer : ouvrir le dossier dans Godot 4.7 puis **F5**, ou `tools/run.sh`.
- Règles et vision : [`docs/design/gdd.md`](docs/design/gdd.md)
- Contenu et stats : [`docs/wiki/`](docs/wiki/README.md)
- Où on en est : [`docs/roadmap.md`](docs/roadmap.md)
- Installer le poste : [`docs/setup.md`](docs/setup.md)

## Contrôles

| Touche | Action |
|---|---|
| ZQSD / WASD / flèches | Déplacer le bâtisseur |
| 1 à 9 | Choisir une tour à commander (reste active pour en commander plusieurs) |
| Roue « Corruptions » | Clic sur une corruption : dépenser un stigmate pour la débloquer |
| Clic gauche | Commander la tour (le bâtisseur va la construire), ou choisir une tour posée. Sur une ruine : la faire démolir (20 or, re-clic pour annuler) |
| Clic droit, Échap | Annuler |
| U / I | Améliorer la tour choisie : au niveau 1, U prend la branche A et I la branche B |
| V (ou Suppr) | Vendre la tour choisie (annuler un chantier rembourse tout) |
| Espace, Entrée | Lancer la vague suivante en avance (les vagues partent seules sinon), contre de l'or |
| F | Vitesse x1, x2, x3 |
| P (ou Pause) | Pause : le temps s'arrête, on peut lire et donner des ordres |
| Molette | Zoomer / dézoomer |
| Clic molette glissé | Déplacer la vue (la caméra suit le bâtisseur dès qu'il bouge) |
| C | Recentrer la vue sur le bâtisseur |
| Clic sur la minicarte | Regarder à cet endroit |
| H | Afficher / cacher l'aide (commandes et rappels) |
| Survol | Le détail d'une tour, d'une ruine ou d'une terre s'affiche en bas à droite |
| R | Rejouer après la fin |
