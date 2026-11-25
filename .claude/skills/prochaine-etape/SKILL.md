---
name: prochaine-etape
description: Reprend le projet là où il en est : lit la feuille de route, propose et prépare la prochaine petite étape jouable.
---

1. Lis `docs/roadmap.md` (seulement lui pour commencer).
2. Identifie la prochaine tâche non cochée du jalon en cours.
3. Charge uniquement les docs utiles à cette tâche (voir le tableau de `CLAUDE.md`).
4. Propose un plan court : fichiers à créer ou modifier, ce que Vespper verra en lançant F5. Si la tâche est trop grosse pour une PR, découpe-la et mets à jour la roadmap.
5. Réalise l'étape (agent `godot-dev` pour le code si c'est utile), puis lance la skill `fin-de-session`.
