# Décisions

Une ligne par décision, la plus récente en bas. Ce qui est écrit ici n'est plus à rediscuter, sauf si Vespper le rouvre.

| Date | Sujet | Décision |
|---|---|---|
| 2026-11-25 | Projet | Le roguelike (`Gameproject`) est mis en pause. On fait d'abord un tower defense classique, dans un dépôt séparé ; on l'intégrera au roguelike plus tard. |
| 2026-11-25 | Référence | Element TD (mod Warcraft 3) : tours et vagues à éléments. |
| 2026-11-25 | Moteur et méthode | Mêmes que le roguelike : Godot 4.7 (GDScript, rendu Compatibility), données en `.tres`, une PR par petite étape jouable, Claude gère git. |
| 2026-11-25 | Carte | Chemin fixe et connu (comme Flash Element TD), défini par carte ; plusieurs cartes au fur et à mesure. Le labyrinthe construit avec les tours est abandonné pour l'instant (mode « cartes libres » plus tard). |
| 2026-11-25 | Éléments | Six éléments dès maintenant, cycle d'Element TD : Lumière > Ténèbres > Eau > Feu > Nature > Terre > Lumière. |
| 2026-11-25 | Tours de base | Flèche, Mortier, Magie (neutres, toujours disponibles). |
| 2026-11-25 | Référence | Reprendre vraiment le fonctionnement d'Element TD et des TD Warcraft 3 les plus connus. |
| 2026-11-25 | Bâtisseur | Un personnage se déplace et construit les tours, avec un temps de construction (garder un pied dans le futur jeu à personnage). |
| 2026-11-25 | Carte | Circuit plus long : la carte Serpent passe à 93 cases. |
| 2026-11-25 | Améliorations | Améliorer une tour prend du temps : la tour est hors service jusqu'à ce que le bâtisseur ait fini. |
| 2026-11-25 | Vagues | Lancement automatique avec compte à rebours ; on peut lancer la vague suivante plus tôt. |
| 2026-11-25 | Éléments | Afficher les forces et faiblesses sous forme de roue (schéma façon pierre-feuille-ciseaux). |
| 2026-11-25 | Vagues | Toutes les vagues ne sont pas élémentaires : vagues neutres avec armure en pierre-feuille-ciseaux contre Flèche / Mortier / Magie, élites à élément dans les vagues neutres, vagues d'éléments surtout en fin de partie, des volants. |
| 2026-11-25 | Rythme | Quand une vague est entièrement vaincue, le compte à rebours de la suivante tombe à 3 s. |
| 2026-11-25 | Améliorations | Arbre à 2 branches par tour : le choix se fait au passage au niveau 2 et il est définitif ; le niveau 3 renforce la même branche. |
| 2026-11-26 | Univers | Les éléments d'Element TD deviennent les **Six Corruptions** (ton grimdark, inspiration Vermis) : Ferveur > Démence > Abîme > Cendre > Os > Pourriture > Ferveur. Essences → Stigmates ; tours de base Arbalète / Trébuchet / Encensoir ; armures Chair / Carapace / Spectre. L'Indicible, hors de la roue, est la corruption ultime. |
| 2026-11-26 | Corruptions | Les fusions (tours à 2 corruptions) se débloqueront par des défis. Opposés : « Schisme » (malus de placement) et « fusions hérétiques » (plus fortes, avec un prix) ; « Rejet » gardé pour un mod de difficulté. |
| 2026-11-26 | Carte | Terres corrompues (+25 % pour la tour de cette corruption, −25 % pour l'opposée) et ruines que le bâtisseur démolit contre de l'or. Portes, aiguillages, chemin qui grandit et biomes notés pour plus tard. |
| 2026-11-27 | Interface | Maquette validée : barre du haut (ressources, vague), colonne droite (3 prochaines vagues, roue, minicarte), barre du bas (tour choisie, construction façon Warcraft 3, infos au survol). Carte plus grande que l'écran avec caméra qui suit le bâtisseur. Pause (P) avec ordres possibles. |
