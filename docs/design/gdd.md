# Game design document

Document vivant et condensé. Une règle tranchée par Vespper passe dans `docs/decisions.md` ; ici on garde la description du jeu et les questions ouvertes. Les chiffres sont dans `data/` et le catalogue dans `docs/wiki/`.

## Vision

Un tower defense **classique**, lisible et profond, dans l'esprit d'Element TD (mod Warcraft 3) : on construit son propre labyrinthe sur un terrain ouvert, on choisit quels éléments développer, et chaque vague teste un point faible différent. Une partie dure 20 à 40 minutes.

Ce projet est aussi un banc d'essai : les systèmes qui marchent ici (labyrinthe, éléments, tours combinées) pourront être repris dans le roguelike `Gameproject`.

## Piliers

1. **Le labyrinthe est la première arme.** Une Flèche à 10 or qui allonge le chemin de 4 cases vaut souvent mieux qu'une grosse tour. Le joueur voit en permanence le chemin des ennemis.
2. **Les éléments forcent des choix.** On ne peut pas tout prendre : chaque vague a un élément, et on paie de ne pas avoir la bonne réponse.
3. **Lisible d'un coup d'œil.** Une couleur par élément, une forme par rôle d'ennemi, chaque effet a un signe visible (anneau bleu = ralenti, point vert = poison, cercle = zone).
4. **Pas de hasard injuste.** Les vagues sont connues à l'avance (la prochaine est annoncée) : on perd parce qu'on a mal préparé, pas par malchance.

## Boucle de jeu

1. Phase de construction : on voit la prochaine vague (archétype, nombre, élément), on pose, améliore ou vend des tours.
2. On lance la vague quand on est prêt (on peut continuer à construire pendant).
3. Chaque ennemi tué rapporte de l'or ; chaque ennemi qui sort coûte des vies.
4. Fin de vague : bonus d'or. Retour en 1.
5. Victoire après la dernière vague ; défaite à 0 vie.

## Terrain et labyrinthe

- Grille de 24 × 15 cases, une entrée à gauche, une sortie à droite (prototype : une seule carte).
- Une tour occupe une case et bloque le passage. Les ennemis prennent le plus court chemin (4 directions, pas de diagonale) et le recalculent à chaque tour posée ou vendue.
- **Interdit de fermer le passage** : une pose qui couperait la sortie, pour l'entrée ou pour un ennemi déjà sur le terrain, est refusée (case rouge). On ne peut pas non plus construire sous un ennemi.
- Le chemin actuel est dessiné en léger sur le sol.

## Éléments

Quatre éléments pour commencer, en cycle :

> **Eau > Feu > Nature > Terre > Eau**
> L'Eau éteint le Feu, le Feu brûle la Nature, la Nature fend la Terre, la Terre boit l'Eau.

- Attaque forte : dégâts × 1,5. Attaque faible : × 0,75. Sinon × 1. Le Neutre n'a ni bonus ni malus.
- Chaque vague a un élément (la couleur des ennemis). Les poisons suivent aussi le multiplicateur.
- Chaque élément a une identité : **Feu** dégâts de zone, **Eau** ralentit, **Nature** poison dans la durée, **Terre** gros coup lent à longue portée.

## Tours

- **Flèche** (neutre, 10 or) : la brique du labyrinthe, dégâts modestes.
- **Une tour par élément** (25 à 35 or), avec l'effet de son élément.
- **Amélioration** : 3 niveaux. Chaque niveau multiplie les dégâts (et le poison) par 1,6 ; le coût vaut 75 % du prix × niveau actuel.
- **Revente** : 75 % de tout ce qui a été dépensé sur la tour.

À venir (voir la feuille de route) :
- **Déblocage des éléments** : on commence avec la Flèche seule ; tous les 5 vagues on gagne une *essence* pour débloquer ou renforcer un élément. C'est le cœur stratégique d'Element TD.
- **Tours doubles** (deux éléments, ex. Feu + Eau = Vapeur) puis **triples**, débloquées par les combinaisons d'essences.

## Ennemis

Le rôle vient de l'**archétype**, l'élément vient de la **vague**.

| Archétype | Rôle |
|---|---|
| Fantassin | standard, référence d'équilibrage |
| Coureur | rapide et fragile : teste la longueur du labyrinthe et le ralentissement |
| Essaim | nombreux et très fragiles : teste les dégâts de zone |
| Colosse | lent et très résistant, coûte 2 vies : teste les dégâts bruts |
| Seigneur (boss) | une seule unité énorme en dernière vague, coûte 10 vies |

À venir : ennemis volants (ignorent le labyrinthe), ennemis immunisés au ralentissement, ennemis qui se soignent.

## Vagues

- 10 vagues dans le prototype, définies dans `data/waves/` : archétype, élément, nombre, intervalle, multiplicateur de PV.
- Cible du jeu complet : 30 à 40 vagues, un boss toutes les 10.
- La prochaine vague est annoncée dans la barre du haut.

## Économie

- Départ : 80 or, 20 vies.
- Or par ennemi tué (selon l'archétype) + bonus de fin de vague : 15 + 3 × numéro de la vague.
- À venir : intérêts sur l'or gardé en fin de vague (récompenser l'épargne contre la construction immédiate), à tester.

## Contrôles

Clavier + souris. Voir le tableau du `README.md`.

## Direction artistique (prototype)

Formes simples dessinées en code, fond sombre, éléments de jeu saturés. Couleurs : Feu rouge-orangé, Eau bleu, Nature vert, Terre ocre, Neutre gris clair. Le style définitif viendra plus tard, une fois le jeu amusant.

## Questions ouvertes

- Garder 4 éléments ou passer à 6 comme Element TD (Lumière, Ténèbres) ?
- Déblocage par essences tous les 5 vagues, ou achat avec une seconde monnaie ?
- Vagues lancées à la main, ou chronomètre avec bonus si on appelle la vague en avance ?
- Plusieurs cartes, ou une carte ouverte unique comme Element TD ?
- Intérêts sur l'or : oui ou non ?
