# TowerDefense

Tower defense classique à éléments, inspiré d'Element TD (Warcraft 3), fait avec Godot 4.7.

On construit un labyrinthe avec ses tours sur un terrain ouvert ; les ennemis prennent toujours le plus court chemin vers la sortie. Chaque tour a un élément (Feu, Eau, Nature, Terre), chaque vague aussi : Eau > Feu > Nature > Terre > Eau.

- Lancer : ouvrir le dossier dans Godot 4.7 puis **F5**, ou `tools/run.sh`.
- Règles et vision : [`docs/design/gdd.md`](docs/design/gdd.md)
- Contenu et stats : [`docs/wiki/`](docs/wiki/README.md)
- Où on en est : [`docs/roadmap.md`](docs/roadmap.md)
- Installer le poste : [`docs/setup.md`](docs/setup.md)

## Contrôles

| Touche | Action |
|---|---|
| 1 à 5 | Choisir une tour à poser (reste active pour en poser plusieurs) |
| Clic gauche | Poser la tour, ou choisir une tour posée |
| Clic droit, Échap | Annuler |
| U / S (ou Suppr) | Améliorer / vendre la tour choisie |
| Espace, Entrée | Lancer la vague suivante |
| F | Vitesse x1, x2, x3 |
| R | Rejouer après la fin |
