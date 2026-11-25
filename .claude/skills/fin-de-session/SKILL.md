---
name: fin-de-session
description: Met à jour la feuille de route et le journal des décisions en fin de session, pour que la session suivante reparte sans relire tout l'historique.
---

1. Dans `docs/roadmap.md` :
   - coche les tâches terminées, ajoute celles découvertes ;
   - réécris « Prochaine étape » en une ou deux phrases concrètes ;
   - ajoute une ligne datée au « Journal » (ce qui a été fait, numéro de PR). Garde au plus 10 lignes : supprime les plus anciennes (git garde l'historique).
2. Si Vespper a tranché quelque chose (gameplay, style, technique), ajoute une ligne à `docs/decisions.md` et retire la question de `docs/design/gdd.md` si elle y figurait.
3. Si l'architecture a changé (nouvel autoload, nouvelle convention), mets à jour `docs/architecture.md` ou `docs/conventions.md` en quelques lignes.
4. Ne touche pas aux autres fichiers. Résume en trois lignes ce qui a été mis à jour.
