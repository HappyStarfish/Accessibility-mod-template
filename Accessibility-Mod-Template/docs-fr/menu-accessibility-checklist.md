CHECKLIST D'ACCESSIBILITE DES MENUS
=====================================

Checklist rapide AVANT d'implémenter la navigation clavier pour un menu.
Pour les patterns détaillés et les exemples de code, voir : `menu-accessibility-patterns.md`


1. COMPRENDRE LA STRUCTURE
---------------------------
- Comment le menu est-il structuré ? (Linéaire, grille, hiérarchique, à onglets)
- Quels types d'éléments existent ? (Boutons, curseurs, bascules, listes déroulantes, onglets)
- Quelles relations parent-enfant existent ?
- Y a-t-il des boîtes de dialogue modales nécessitant un traitement prioritaire ?


2. ANALYSER LES PATTERNS D'INTERACTION
----------------------------------------
- Comment chaque élément est-il activé ? (Clic, double-clic, survol)
- Comment les valeurs sont-elles modifiées ? (scrollBy, incrément, bascule, cycle de liste déroulante)
- Quels événements/handlers existent déjà ? (clickReleased, scrollBy, keyPressed)

IMPORTANT : Réutilisez les méthodes existantes, ne réinventez pas la roue !


3. VÉRIFIER LES SYSTÈMES D'ACCESSIBILITÉ EXISTANTS
----------------------------------------------------
- Existe-t-il déjà un FocusManager, IFocusable, ou similaire ?
- Quels éléments sont déjà enregistrés ?
- Comment les annonces sont-elles déjà faites ? (classe ScreenReader)


4. DÉFINIR LE CONCEPT DE NAVIGATION
-------------------------------------
Touches standard (adaptez au jeu si nécessaire) :
- Haut/Bas : Naviguer entre les éléments
- Gauche/Droite : Modifier les valeurs (curseurs, listes déroulantes) ou naviguer dans les groupes
- Entrée/Espace : Activer/Basculer
- Début/Fin : Aller au premier/dernier élément
- Retour arrière : Revenir en arrière (ex. du contenu d'un onglet à la liste des onglets)
- Échap : Fermer le menu (généralement géré par le jeu)


5. VÉRIFIER LES TEXTES DES LIBELLÉS
--------------------------------------
- [ ] Tous les libellés sont significatifs (pas vides, pas "item123")
- [ ] Les libellés proviennent de la localisation du jeu quand c'est possible
- [ ] Hiérarchie de repli définie pour les libellés manquants
      (voir `menu-accessibility-patterns.md` -> Résolution des libellés)


6. VÉRIFIER LA CAPTURE DES TOUCHES
------------------------------------
- [ ] Les touches de navigation ne "traversent" pas vers le jeu
- [ ] Les touches sont capturées AVANT que le jeu ne les traite
- [ ] Les touches ne sont capturées que quand le menu est réellement actif


7. CHECKLIST PAR PANNEAU/ÉCRAN
-------------------------------
Pour chaque nouveau panneau/écran, vérifier :

- [ ] Ouverture annoncée (nom de l'écran)
- [ ] La navigation annonce l'élément courant
- [ ] États vides gérés explicitement (jamais de silence)
- [ ] Actions confirmées ("Activé", "Changé en X")
- [ ] Le bouclage annonce "Premier élément" / "Dernier élément"
- [ ] Suivi de l'état pour la détection des changements
- [ ] Fermeture annoncée si pertinent


8. GESTION DES ÉTATS VIDES
----------------------------
Ne JAMAIS laisser l'utilisateur dans le silence. Toujours annoncer :

- "Aucun élément disponible" (liste vide)
- "Aucune sélection" (rien de sélectionné)
- "Inventaire vide" (pas de contenu)
- "Aucun résultat trouvé" (recherche/filtre sans résultat)


9. TESTER DE MANIÈRE INCRÉMENTALE
-----------------------------------
- Tester après chaque modification, pas tout d'un coup
- Rendre un type d'élément entièrement fonctionnel d'abord, puis le suivant
- Utiliser le mode débogage pour vérifier la collecte des éléments (voir state-management-guide.md)


DOCUMENTATION ASSOCIÉE
=======================
- `menu-accessibility-patterns.md` - Patterns détaillés, exemples de code, résolution des libellés
- `state-management-guide.md` - Architecture des handlers, mode débogage
- `ACCESSIBILITY_MODDING_GUIDE.md` - Patterns d'accessibilité généraux
