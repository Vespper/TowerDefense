# TowerDefense

Tower defense classique à éléments, qui reprend le fonctionnement d'Element TD (Warcraft 3), fait avec Godot 4.7.

Les ennemis suivent un chemin fixe ; on pose des tours de base (Flèche, Mortier, Magie) et, en dépensant des essences, on débloque les tours des six éléments. Chaque vague a un élément : Lumière > Ténèbres > Eau > Feu > Nature > Terre > Lumière (× 2 contre l'élément suivant, × 0,5 contre le précédent).

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
| Roue « Éléments » | Clic sur un élément : dépenser une essence pour le débloquer |
| Clic gauche | Commander la tour (le bâtisseur va la construire), ou choisir une tour posée |
| Clic droit, Échap | Annuler |
| U / V (ou Suppr) | Améliorer / vendre la tour choisie (annuler un chantier rembourse tout) |
| Espace, Entrée | Lancer la vague suivante en avance (les vagues partent seules sinon), contre de l'or |
| F | Vitesse x1, x2, x3 |
| R | Rejouer après la fin |
