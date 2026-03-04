# Guide de configuration pour les nouveaux projets de mods d'accessibilite

Ce guide n'est necessaire que pour la configuration initiale du projet.

---

## Entretien de configuration

Lorsque l'utilisateur interagit avec Claude pour la premiere fois dans ce repertoire (par ex. "Bonjour", "Nouveau projet", "C'est parti"), menez cet entretien.

**Posez ces questions UNE PAR UNE. Attendez la reponse apres CHAQUE question.**

### Etape 1 : Niveau d'experience

Question : Quelle est votre experience en programmation et en modding ? (Peu/Aucune ou Beaucoup)

- Retenir la reponse pour le reste de l'entretien
- Si "Peu/Aucune" : Expliquer les concepts de maniere contextuelle dans les etapes suivantes (voir les notes "Pour les debutants")
- Si "Beaucoup" : Communication breve et technique sans explications detaillees

### Etape 2 : Nom du jeu

Question : Quel est le nom du jeu que vous souhaitez rendre accessible ?

### Etape 2b : Familiarite avec le jeu

Question : Dans quelle mesure connaissez-vous ce jeu ? (Tres bien / Un peu / Pas du tout)

- **"Tres bien"** : L'utilisateur peut guider la priorisation des fonctionnalites et expliquer les mecaniques. Le noter dans project_status.md.
- **"Un peu"** : L'utilisateur a quelques connaissances mais pourrait avoir besoin d'aide pour comprendre les systemes du jeu. Le noter pour plus tard.
- **"Pas du tout"** : Marquer pour l'extraction des textes de tutoriel apres la decompilation (voir Etape 7b). Lors de la planification des fonctionnalites, Claude devrait expliquer les mecaniques de jeu decouvertes de maniere plus detaillee.

Retenir la reponse - elle affecte l'Etape 7b et la Phase 1.5 (planification des fonctionnalites).

### Etape 2c : Verification du code source ouvert

Apres avoir appris le nom du jeu, rechercher **automatiquement** du code source disponible publiquement :

**Recherches a effectuer :**
- Recherche web : "[Nom du jeu] source code site:github.com"
- Recherche web : "[Nom du jeu] open source game"
- Recherche web : "[Nom du jeu] gitlab source"

**Si le jeu a du code source disponible publiquement :**

Informer l'utilisateur :

> Bonne nouvelle ! [Nom du jeu] semble etre open source. Le code source est disponible a [URL]. C'est un avantage considerable pour le modding d'accessibilite :
>
> - Nous avons le vrai code source avec des noms de variables, des commentaires et de la documentation corrects - beaucoup plus facile a utiliser que le resultat d'une decompilation
> - Nous pouvons potentiellement contribuer nos fonctionnalites d'accessibilite directement au jeu via une pull request
> - Pas de decompilation necessaire - le code est plus facile a lire et a comprendre
> - Nous pouvons compiler et tester le jeu nous-memes

**Demander :** "Voulez-vous travailler directement avec le code source (recommande), ou creer un mod separe ?"

#### Option A : Modification directe du source (recommandee)

**Avantages :**
- Vrai code source avec commentaires et documentation
- Possibilite de soumettre les fonctionnalites d'accessibilite en PR au projet original
- Pas de decompilateur, pas de MelonLoader/BepInEx necessaire
- Meilleure integration, moins de problemes de compatibilite avec les mises a jour du jeu
- Les developpeurs peuvent relire votre code et aider a l'ameliorer

**Changements dans le flux de travail :**
- Cloner le depot au lieu de decompiler
- Configurer l'environnement de compilation en suivant les instructions de build du projet
- Sauter les Etapes 5 a 7 (mod loader, configuration Tolk, decompilation) - y revenir si necessaire selon l'architecture du jeu
- L'integration du lecteur d'ecran depend de l'architecture audio/UI du jeu
- L'analyse de la Phase 1 est bien plus facile avec le vrai code source
- Le repertoire `decompiled/` n'est pas necessaire - utiliser directement le source clone

**Important : Verification de la licence !**

Lire le fichier LICENSE du depot avant de commencer le travail. Licences courantes :
- **MIT, Apache, BSD :** Permissives - modifications libres, obligation d'inclure la licence originale
- **GPL :** Les modifications doivent etre partagees sous la meme licence (pas de probleme pour les mods d'accessibilite - ils devraient etre ouverts de toute facon)
- **Personnalisee / "source available" :** Lire attentivement - peut restreindre les modifications ou la redistribution

Si la licence n'est pas claire, le noter dans `project_status.md` et suggerer a l'utilisateur de demander aux developpeurs.

**Etapes de configuration adaptees pour le travail direct sur le source :**
1. Cloner le depot dans un repertoire local
2. Suivre les instructions README/build du projet pour configurer l'environnement de developpement
3. Verifier que vous pouvez compiler et lancer le jeu depuis le source
4. Identifier comment le jeu gere la sortie audio et l'UI (ceci remplace l'analyse par decompilation)
5. Creer une branche pour le travail d'accessibilite
6. Continuer avec l'analyse de la Phase 1 (bien plus facile avec le vrai source)

#### Option B : Mod separe (si le jeu a un systeme de plugins/mods)

Parfois utile meme pour les jeux open source :
- Le jeu a une API de mods/plugins existante
- Plus facile a distribuer (les utilisateurs installent un mod au lieu de compiler le jeu)
- Pas besoin de maintenir un fork a travers les mises a jour du jeu

Si l'utilisateur choisit cette option : continuer avec le flux de configuration normal (Etape 3+), mais utiliser le code source pour l'analyse au lieu de decompiler.

**Si le jeu n'est PAS open source :** Continuer normalement avec l'Etape 3. Aucune action necessaire.

Pour les debutants : "Open source" signifie que les developpeurs du jeu ont publie le code source du programme publiquement. Pensez-y comme obtenir la recette au lieu du plat fini - nous pouvons voir exactement comment tout fonctionne, ce qui rend l'ajout de fonctionnalites d'accessibilite beaucoup plus facile. Certains developpeurs acceptent aussi les contributions de la communaute, donc notre travail d'accessibilite pourrait se retrouver dans le jeu officiel au benefice de tous.

---

### IMPORTANT : Limiter la recherche Internet pendant la configuration !

Apres avoir appris le nom du jeu, **ne PAS rechercher les details internes du jeu en ligne** (systemes d'UI, mecaniques de jeu, structure du code, fonctionnement de fonctionnalites specifiques). Une comprehension generale du genre est acceptable ("c'est un RPG au tour par tour", "c'est un city builder"), mais l'analyse detaillee des systemes du jeu **DOIT attendre le code source decompile** (Phase 1).

**Recherches Internet autorisees pendant la configuration :**
- Le jeu est-il open source ? (Etape 2c)
- Quel moteur utilise-t-il ? (Etape 4)
- Quel mod loader la communaute utilise-t-elle ? (Etape 4b/4e)
- Le modding est-il faisable pour les moteurs non-Unity ? (Etape 4d)

**NON autorise avant la decompilation :**
- Comment le systeme d'UI/menus du jeu fonctionne
- Quelles classes ou systemes le jeu utilise en interne
- L'architecture du jeu, la gestion d'etat, les systemes d'evenements
- Tout ce qui appartient a l'analyse de la Phase 1

**Pourquoi ?** Les informations sur Internet concernant les details internes des jeux ne sont pas fiables - elles peuvent etre obsoletes, erronees, ou decrire une version differente. Le code source decompile est la seule source fiable. Les recherches prematurees gaspillent des tokens et peuvent mener a de fausses hypotheses difficiles a corriger par la suite.

---

### Etape 3 : Chemin d'installation

Question : Ou le jeu est-il installe ? (par ex. `C:\Program Files (x86)\Steam\steamapps\common\NomDuJeu`)

### Etape 4 : Proposer la verification automatique

Une fois le chemin du jeu connu, proposer :

Question : Dois-je verifier automatiquement le repertoire du jeu ? Je peux detecter le moteur de jeu, l'architecture (32/64-bit) et l'infrastructure de modding existante.

**Si oui :**

Effectuer ces verifications et collecter les resultats :

1. **Detecter le moteur de jeu :**
   - Verifier si `UnityPlayer.dll` existe -> jeu Unity
   - Verifier si le repertoire `[NomDuJeu]_Data\Managed` existe -> jeu Unity
   - Verifier les fichiers `.pak` ou `UnrealEngine`/`UE4` dans les noms de fichiers -> Unreal Engine
   - Verifier `libgodot` ou les fichiers `.pck` -> Godot
   - Verifier `data.win` ou les fichiers `audiogroup` -> GameMaker
   - Si incertain : Noter comme "Moteur inconnu"

2. **Detecter l'architecture :**
   - Repertoire `MonoBleedingEdge` present -> 64-bit
   - Repertoire `Mono` (sans "BleedingEdge") -> 32-bit
   - Fichiers avec "x64" dans le nom -> 64-bit
   - Les proprietes du fichier `.exe` peuvent aussi indiquer l'architecture

3. **Verifier l'infrastructure de modding existante :**
   - Repertoire `MelonLoader` -> MelonLoader installe (Unity)
   - Repertoire `BepInEx` -> BepInEx installe (Unity)
   - Repertoire `Mods` ou `plugins` -> Support de mods possible
   - `UE4SS` ou similaire -> Outils de modding Unreal
   - Dossier Workshop ou integration Steam Workshop

4. **Pour Unity avec mod loader - Lire le log (si present) :**
   - **MelonLoader** (`MelonLoader/Latest.log`) : Extraire le nom du jeu, le developpeur, le type de runtime (net35/net6), la version Unity
   - **BepInEx** (`BepInEx/LogOutput.log`) : Verifier l'initialisation reussie, la version Unity, les erreurs eventuelles

4b. **Si aucun mod loader n'est installe - Rechercher le consensus communautaire :**
   - Recherche web : "[Nom du jeu] mods"
   - Recherche web : "[Nom du jeu] MelonLoader OR BepInEx"
   - Verifier Nexus Mods, Thunderstore ou les sites de mods specifiques au jeu
   - Noter quel mod loader les autres mods pour ce jeu utilisent
   - Si aucun mod existant n'est trouve, le noter - le choix du mod loader se basera sur des heuristiques (voir Etape 4e)

5. **Verifier la version Unity (pour les jeux Unity) :**
   - Si la version Unity est 4.x ou plus ancienne (3.x, 2.x) : **Avertissement critique** - MelonLoader et BepInEx ne fonctionnent PAS, seul le patching d'assemblage est possible. Les jeux aussi anciens sont rares mais existent.
   - Si la version Unity est 5.x : **Avertissement** - MelonLoader peut ne pas fonctionner, essayer BepInEx 5.x en premier
   - Si la version Unity est 2017-2018 : Fonctionne generalement, mais peut necessiter une version plus ancienne de MelonLoader
   - Si la version Unity est 2019+ : Support complet, aucun probleme attendu
   - Voir `docs/legacy-unity-modding.md` pour les details sur les anciennes versions Unity

6. **Verifier les DLL Tolk :**
   - Pour 64-bit : Verifier si `Tolk.dll` et `nvdaControllerClient64.dll` sont dans le repertoire du jeu
   - Pour 32-bit : Verifier si `Tolk.dll` et `nvdaControllerClient32.dll` sont dans le repertoire du jeu

**Resume des resultats :**

Afficher un resume de ce qui a ete detecte :
- Moteur de jeu : Unity / Unreal / Godot / GameMaker / Inconnu
- Architecture : 64-bit / 32-bit / Inconnue
- Mod loader : MelonLoader / BepInEx / Aucun installe (+ recommandation communautaire si recherchee)
- Infos du log du mod loader : Nom du jeu, developpeur, runtime, version Unity (si disponible)
- DLL Tolk : Presentes / Manquantes

Question : Est-ce correct ? (Attendre la confirmation)

**Les etapes suivantes dependent du moteur - voir Etape 4d ci-dessous.**

**Si non (verification manuelle preferee) :**

Continuer avec les etapes manuelles 4a-4c.

---

### Etape 4d : Etapes suivantes specifiques au moteur

Selon le moteur detecte, proceder differemment :

#### Si jeu Unity

Continuer avec l'Etape 4e (Mod Loader). Les jeux Unity offrent le meilleur support de modding pour les mods d'accessibilite.

#### Si jeu NON-Unity

**N'abandonnez pas immediatement !** Mais soyez honnete sur ce qui est realiste. La faisabilite depend fortement du moteur et de l'existence d'une communaute de modding active pour ce jeu specifique.

**D'abord, effectuer systematiquement ces verifications generales :**

1. **Rechercher le support officiel de modding :**
   - Le jeu a-t-il une integration Steam Workshop ?
   - Le developpeur a-t-il publie des outils de modding ou un SDK ?
   - Y a-t-il un dossier `Mods` ou similaire dans le repertoire du jeu ?

2. **Rechercher des ressources communautaires de modding :**
   - Recherche web : "[Nom du jeu] modding guide"
   - Recherche web : "[Nom du jeu] mod loader"
   - Verifier Nexus Mods, Thunderstore, ModDB pour les mods existants
   - Chercher des serveurs Discord ou forums specifiques au jeu

3. **Verifier dans quel langage le code du jeu est ecrit :**
   - C# / .NET / Mono -> Tres moddable (voir jeux .NET ci-dessous)
   - Java -> Moddable avec des outils specifiques a Java
   - Scripts Lua dans le repertoire du jeu -> Moddable en editant les scripts
   - Scripts Python dans le repertoire du jeu -> Moddable en editant les scripts
   - C++ uniquement -> Difficile (voir sections ci-dessous)

Pour les debutants : Differents jeux utilisent differents "moteurs" (la technologie sous-jacente). Chaque moteur necessite des outils differents pour le modding. Les jeux ecrits en C# ou avec des langages de script (Lua, Python) sont generalement beaucoup plus faciles a modder que les jeux en C++ pur.

**Puis proceder selon le moteur detecte :**

---

##### Unreal Engine (UE4 / UE5)

**NOTE : Les informations de cette section sont basees sur des recherches, pas sur une experience eprouvee en modding d'accessibilite. Aucun modele etabli pour les mods d'accessibilite avec lecteur d'ecran dans les jeux Unreal n'existe encore. Utilisez ceci comme point de depart pour l'investigation, pas comme un flux de travail garanti.**

**Comment identifier :** Fichiers `.pak`, `UE4` ou `UE5` dans les noms de fichiers, structure de repertoire `Engine/Binaries`.

**Ce qui existe :**
- **UE4SS** (RE-UE4SS) est le framework de modding communautaire standard pour les jeux Unreal. Il s'injecte dans le jeu et fournit une couche de script Lua et une API de mods C++. Comparable en role a MelonLoader/BepInEx, mais pour Unreal.
- UE4SS peut hooker les fonctions reflechies du jeu (concept similaire a Harmony, mais uniquement pour les fonctions marquees UFUNCTION dans le systeme de reflexion du moteur - pas pour les fonctions C++ arbitraires).
- Les mods Lua peuvent lire/ecrire les proprietes des objets du jeu, hooker l'execution de fonctions et reagir aux evenements du jeu.
- Les mods C++ compiles en DLL peuvent en theorie appeler Tolk pour la sortie vers le lecteur d'ecran.

**Outils d'analyse :**
- UE4SS genere des dumps SDK/headers montrant les noms de classes, proprietes et signatures de fonctions - c'est l'equivalent le plus proche de la decompilation Unity, mais ne donne que la structure API, pas le code d'implementation.
- FModel extrait et parcourt les assets du jeu depuis les fichiers .pak.
- KismetKompiler peut decompiler le bytecode Blueprint (pour les jeux fortement bases sur Blueprint).

**Barrieres d'accessibilite pour les moddeurs aveugles :**
- FModel et le Live Property Viewer d'UE4SS sont des outils GUI visuels - **pas accessibles avec un lecteur d'ecran**.
- La sortie du dump SDK/headers est basee sur du texte et pourrait etre parcourue avec des outils CLI - cette partie est accessible.
- Il n'existe **aucun mod d'accessibilite avec lecteur d'ecran** pour aucun jeu Unreal dont s'inspirer. Ce serait un territoire inexplore.
- L'analyse du code du jeu est plus difficile qu'avec Unity car on n'obtient que les signatures API, pas le code source complet.

**Evaluation realiste :**
- **Faisable si :** Le jeu a une communaute de modding UE4SS active avec des hooks et API documentes. D'autres mods existent qui demontrent comment acceder aux donnees du jeu. Un collaborateur voyant pourrait aider avec l'analyse initiale utilisant des outils visuels.
- **Non faisable si :** Aucune communaute de modding n'existe, le jeu ne fonctionne pas avec UE4SS, ou la logique cle du jeu est dans des fonctions C++ natives non reflechies.
- **Notre template n'est PAS directement applicable.** Le langage du mod est Lua ou C++ (pas C#), le systeme de patching est different, et la structure du projet est completement differente. Les patrons d'accessibilite (classes Handler, wrapper ScreenReader, systeme Loc) pourraient etre adaptes conceptuellement, mais le code devrait etre reecrit.

**Si vous procedez :** Rechercher d'abord la compatibilite UE4SS pour ce jeu specifique. Verifier le Discord et la documentation UE4SS. Documenter les resultats dans `docs/game-api.md`.

---

##### Moteur Godot

**NOTE : Les informations de cette section sont basees sur des recherches, pas sur une experience eprouvee en modding d'accessibilite. Utilisez ceci comme point de depart, pas comme un flux de travail garanti.**

**Comment identifier :** Fichiers `.pck`, fichiers `libgodot`, ecran de demarrage Godot.

**Ce qui existe :**
- **Godot Mod Loader** est le framework de modding principal - mais il **doit etre integre par le developpeur du jeu**. Il ne peut pas etre injecte de l'exterieur (contrairement a MelonLoader/BepInEx). Si le jeu ne l'inclut pas, le modding au niveau des scripts est tres limite.
- Sans le Mod Loader : les mods fonctionnent en remplacant les fichiers du jeu via des paquets PCK. Decompiler les scripts du jeu, les modifier, reempaqueter en PCK. C'est fragile et casse lors des mises a jour du jeu.
- **Godot 4.5+** (sorti en septembre 2025) a un support integre du lecteur d'ecran via AccessKit. Si le jeu utilise Godot 4.5+ et des noeuds UI standard, l'UI peut deja etre partiellement accessible aux lecteurs d'ecran sans aucun modding.
- Godot est entierement open source (licence MIT), donc les details internes du moteur sont documentes.

**Outils d'analyse :**
- **gdsdecomp / GDRE Tools** peut decompiler le bytecode GDScript en source lisible - similaire a dnSpy pour .NET. C'est un outil CLI et devrait etre utilisable avec un lecteur d'ecran.
- **GdTool** est un outil CLI pour compiler/decompiler GDScript et gerer les fichiers PCK.

**Barrieres d'accessibilite pour les moddeurs aveugles :**
- Si le jeu n'a pas le Godot Mod Loader : seul le remplacement de fichiers PCK fonctionne, ce qui est laborieux et fragile.
- Le langage du mod est GDScript (pas C#), necessitant l'apprentissage d'un nouveau langage.
- Aucun mod d'accessibilite connu n'existe pour aucun jeu Godot pour le moment.

**Evaluation realiste :**
- **Meilleur cas :** Le jeu utilise Godot 4.5+ (AccessKit peut etre integre) ET a le Godot Mod Loader integre. Alors des mods GDScript avec appels TTS sont possibles.
- **Cas intermediaire :** Le jeu peut etre decompile avec gdsdecomp, les scripts modifies et reempaquetes. Fonctionne mais est fragile.
- **Pire cas :** Le jeu utilise Godot 3.x sans Mod Loader. Limite au remplacement de scripts, pas de support d'accessibilite integre.
- **Notre template n'est PAS directement applicable** (langage different, structure de mod differente), mais les patrons d'accessibilite (handlers modulaires, localisation, wrapper lecteur d'ecran) se transferent conceptuellement.

---

##### Jeux .NET (XNA, MonoGame, FNA, autres frameworks .NET)

**Comment identifier :** Les DLL du jeu peuvent etre ouvertes avec dnSpy/ILSpy et montrent du code C# lisible. Chercher `MonoGame.Framework.dll`, `FNA.dll`, `Microsoft.Xna.Framework.dll` ou d'autres assemblages .NET dans le repertoire du jeu.

**Bonne nouvelle : Ces jeux sont moddables avec les memes outils que les jeux Unity.**

- **BepInEx** supporte explicitement les jeux .NET framework au-dela d'Unity, y compris les jeux XNA, MonoGame et FNA.
- Le patching **Harmony** fonctionne de la meme maniere qu'avec Unity - patching IL a l'execution de n'importe quelle methode .NET.
- **dnSpy / ILSpy** decompilent le code du jeu en C# lisible, comme avec Unity.
- L'integration de **Tolk** fonctionne de maniere identique.

**Exemples prouves :**
- Stardew Valley (MonoGame) a SMAPI, un mod loader dedie avec des milliers de mods
- Celeste (MonoGame) a le mod loader Everest

**Evaluation realiste :**
- **Notre template est largement applicable.** Les patrons d'accessibilite, la structure Handler, le wrapper ScreenReader et le systeme Loc fonctionnent tous. Les principales differences sont dans la configuration du projet (references DLL differentes, pas de cycle de vie specifique a MelonLoader/Unity) et potentiellement des points d'entree differents.
- **La faisabilite est similaire a Unity** - si vous pouvez decompiler les DLL et que BepInEx fonctionne, le flux de travail complet s'applique.

**Si vous procedez :** Essayer BepInEx en premier. Utiliser dnSpy pour analyser le code du jeu. Adapter le Main.cs du template pour utiliser le patron `BaseUnityPlugin` de BepInEx (ou la classe de base appropriee pour le framework .NET specifique). Le reste du template (Handlers, ScreenReader, Loc) necessite des changements minimaux.

---

##### Jeux Java

**NOTE : Le modding de jeux Java est bien etabli (Minecraft est la plus grande communaute de modding dans le jeu video), mais utilise des outils completement differents de notre template base sur C#.**

**Comment identifier :** Fichiers `.jar`, Java Runtime requis, repertoires `jre` ou `jdk`.

**Ce qui existe :**
- Le bytecode Java preserve les metadonnees (noms de classes, noms de methodes) comme le .NET - la decompilation donne du code lisible.
- **Minecraft** a des mod loaders matures : Fabric (leger, utilise Mixin pour l'injection de bytecode) et NeoForge (API completes). Le systeme Mixin est conceptuellement similaire a Harmony.
- D'autres jeux Java peuvent ne pas avoir de mod loaders etablis, mais des decompilateurs Java (JD-GUI, Fernflower, CFR) et des bibliotheques de manipulation de bytecode existent.

**Barrieres d'accessibilite :**
- Notre template (C#, .NET, Tolk) n'est pas applicable - Java utilise un ecosysteme different.
- Tolk n'a pas de bindings Java (il faudrait JNI ou JNA pour appeler la DLL native).
- Le flux de developpement, les outils de build et la structure du projet sont completement differents.

**Evaluation realiste :**
- **Faisable pour Minecraft** et d'autres jeux Java avec des mod loaders etablis - mais necessite des connaissances en developpement Java et des outils specifiques au jeu.
- **Notre template n'est PAS applicable** en termes de code, mais les concepts d'accessibilite (handlers modulaires, integration lecteur d'ecran, localisation) se transferent a n'importe quel langage.
- Si quelqu'un voulait creer un template de modding d'accessibilite en Java, ce serait un projet separe.

---

##### Jeux avec scripts Lua integres

**Comment identifier :** Chercher `lua51.dll`, `lua52.dll`, `lua53.dll`, `lua54.dll` ou `luajit.dll` dans le repertoire du jeu. Chercher aussi des fichiers `.lua` ou `.luac`.

**Ce qui existe :**
- De nombreux moteurs personnalises integrent Lua comme couche de script. Si le jeu charge des scripts Lua depuis des fichiers, ceux-ci peuvent etre modifies ou etendus.
- Les jeux avec des API Lua completes incluent : World of Warcraft (addons UI), Factorio (mods de gameplay complets), Don't Starve, Garry's Mod.
- Le FFI (Foreign Function Interface) de LuaJIT peut appeler des DLL natives - ce qui signifie que Tolk pourrait potentiellement etre appele depuis des mods Lua.

**Evaluation realiste :**
- **Hautement specifique au jeu.** Certains jeux scriptes en Lua ont des API riches et des communautes actives (Factorio, WoW). D'autres utilisent simplement Lua pour la configuration interne sans surface de modding.
- **Si les scripts Lua sont editables et documentes :** C'est une voie viable. Le mod serait ecrit en Lua au lieu de C#, et Tolk pourrait etre appele via FFI.
- **Si le bytecode Lua est compile (fichiers `.luac` uniquement) :** La decompilation est possible mais moins fiable que la decompilation GDScript ou .NET.
- **Notre template n'est PAS directement applicable** (langage different), mais les patrons se transferent.

---

##### Jeux avec Python integre

**Comment identifier :** Chercher `python*.dll` dans le repertoire du jeu, ou des fichiers `.py` / `.pyc`.

**Ce qui existe :**
- **Ren'Py** (moteur de visual novel) : Base sur Python, open source, facile a modder en editant les fichiers de script `.rpy`. A une communaute.
- Certains moteurs personnalises integrent Python pour le scripting.
- La bibliotheque `ctypes` de Python peut appeler des DLL natives - l'integration de Tolk est simple depuis Python.
- Les fichiers `.pyc` (bytecode Python compile) peuvent etre decompiles avec des outils comme `uncompyle6` ou `decompyle3`.

**Evaluation realiste :**
- **Jeux Ren'Py :** Relativement faciles a modder. Les scripts sont souvent livres en fichiers `.rpy` lisibles. Les mods d'accessibilite pourraient ajouter des appels TTS.
- **Autres jeux scriptes en Python :** Depend de la quantite de logique de jeu en Python et de l'accessibilite des scripts.
- **Notre template n'est PAS directement applicable** (langage different), mais les patrons se transferent.

---

##### Moteurs personnalises ou proprietaires

**NOTE : Cette section decrit le processus general d'investigation lorsqu'un jeu utilise un moteur inconnu, personnalise ou proprietaire. L'objectif est d'evaluer systematiquement si le modding d'accessibilite est faisable avant d'investir un temps significatif.**

**Comment identifier :** Le jeu ne correspond a aucun des moteurs connus ci-dessus (pas de UnityPlayer.dll, pas de fichiers .pak, pas de marqueurs Godot, pas d'assemblages .NET, pas de Java). Le jeu peut utiliser un moteur open source peu connu (Torque, OGRE, Irrlicht, etc.), une version fortement modifiee d'un moteur connu, ou quelque chose entierement construit sur mesure.

**Etape 1 : Identifier le moteur**

Rechercher systematiquement :
- Recherche web : "[Nom du jeu] game engine"
- Recherche web : "[Nom du jeu] what engine"
- Recherche web : "[Nom du jeu] technology" ou "[Nom du jeu] made with"
- Verifier PCGamingWiki (liste souvent le moteur)
- Verifier l'article Wikipedia du jeu
- Verifier les interviews ou devblogs des developpeurs
- Examiner les fichiers DLL dans le repertoire du jeu pour des noms specifiques au moteur

**Etape 2 : Verifier si le moteur est open source**

Si vous avez identifie le nom du moteur :
- Recherche web : "[Nom du moteur] open source"
- Recherche web : "[Nom du moteur] github"
- Verifier la licence du moteur (MIT, GPL, proprietaire ?)

**Distinction importante :** Un moteur open source ne signifie PAS que le jeu est open source. Le jeu peut etre un produit commercial construit sur un moteur open source. Le source du moteur aide a comprendre les mecanismes internes, mais vous ne pouvez toujours pas acceder au code source specifique du jeu sauf si le developpeur le partage.

**Etape 3 : Investiguer la couche de scripting**

C'est la question la plus critique pour le modding d'accessibilite. Rechercher :
- Recherche web : "[Nom du moteur] scripting language"
- Recherche web : "[Nom du jeu] modding scripting"
- Chercher dans le repertoire du jeu des fichiers de script (.lua, .py, .cs, .js, .gd, .sq, .nut, ou extensions specifiques au moteur)
- Verifier si les scripts sont en texte brut (lisibles) ou en bytecode compile

**Question cle : Le langage de script peut-il appeler des DLL externes (comme Tolk) ?**

- **Oui, nativement** (par ex. Lua avec FFI, Python avec ctypes) : L'integration du lecteur d'ecran est possible depuis les mods
- **Pas de FFI natif** : La sortie vers le lecteur d'ecran necessite soit une modification du moteur (niveau C++), soit des solutions de contournement (basees sur fichier, sur le presse-papiers) - les deux fragiles ou necessitant une aide voyante
- **Pas de couche de scripting du tout** : Tombe dans la categorie "Jeux C++ purs" ci-dessous

**Etape 4 : Verifier le support de modding existant**

- Recherche web : "[Nom du jeu] modding support"
- Recherche web : "[Nom du jeu] mods"
- Verifier Nexus Mods, ModDB, Steam Workshop
- Verifier si le developpeur a publie des outils de modding ou de la documentation
- Chercher un dossier `mods/` ou similaire dans le repertoire du jeu

**Etape 5 : Evaluer la surface de modding**

Si le modding existe, determiner ce qui peut etre modifie :
- **Contenu uniquement** (textures, niveaux, traductions) : Pas suffisant pour les mods d'accessibilite
- **Logique de jeu via scripts** (combat, IA, evenements, dialogues) : Utile, mais necessite un pont vers le lecteur d'ecran
- **Modification UI/GUI possible** : Critique pour l'accessibilite des menus
- **Chargement de plugins/DLL** : Meilleur cas - pourrait charger une DLL native avec Tolk

**Etape 6 : Evaluer la faisabilite pour l'accessibilite**

Evaluer la situation honnetement :

**Faisable (proceder avec prudence) :**
- Le jeu a du modding au niveau des scripts ET le langage de script peut appeler des DLL natives (Tolk)
- OU : Le jeu charge des plugins/DLL natifs qui peuvent hooker les evenements du jeu
- Communaute de modding active avec documentation

**Partiellement faisable (limitations significatives) :**
- Le modding au niveau des scripts existe mais pas de moyen d'appeler Tolk depuis les scripts
- Des solutions de contournement sont possibles (pont TTS base sur fichier, surveillance du presse-papiers) mais ajoutent de la latence et de la fragilite
- Le moteur est open source donc l'integration de Tolk pourrait theoriquement etre ajoutee au niveau du moteur, mais cela necessite la compilation C++ et probablement une assistance voyante
- L'UI/logique de jeu peut etre modifiee mais la sortie lecteur d'ecran necessite des outils externes

**Non faisable (etre honnete avec l'utilisateur) :**
- Pas de support de modding et pas de moyen d'injecter du code
- Le moteur est du C++ ferme sans couche de scripting
- Le seul "modding" est le remplacement d'assets (textures, sons)

**Quand partiellement faisable, discuter les options avec l'utilisateur :**

> Ce jeu utilise [Nom du moteur], qui a [support de scripting/modding], mais il n'y a pas de moyen direct d'envoyer du texte a votre lecteur d'ecran depuis un mod. Voici les options realistes :
>
> 1. **Contacter le developpeur** - Demander s'il ajouterait le support du lecteur d'ecran ou partagerait son build du moteur pour qu'on puisse ajouter l'integration Tolk. C'est la voie la plus durable.
> 2. **Outil pont externe** - Nous ecrivons un petit programme compagnon qui surveille un fichier ou le presse-papiers pour le texte du mod et le prononce via le lecteur d'ecran. Cela fonctionne mais ajoute de la latence et de la complexite.
> 3. **Modification du moteur** (si open source) - Ajouter une fonction native au langage de script du moteur qui appelle Tolk. Necessite du developpement C++ et quelqu'un qui peut compiler le moteur.
> 4. **Aide communautaire** - Verifier si des moddeurs voyants ou des developpeurs collaboreraient sur la partie integration du lecteur d'ecran.

**Notre template n'est PAS directement applicable** pour les moteurs personnalises (langage different, architecture differente), mais les patrons d'accessibilite (handlers modulaires, concept de wrapper lecteur d'ecran, localisation, suivi d'etat) se transferent conceptuellement a n'importe quel langage.

---

##### Jeux C++ purs (sans couche de scripting)

Si le jeu est ecrit purement en C++ sans aucune couche de scripting (Lua, Python, C#), etre franc avec l'utilisateur :

> **Avis important :** Les jeux ecrits purement en C++ sont extremement difficiles a modder pour l'accessibilite - surtout pour les moddeurs aveugles. Voici pourquoi :
>
> Les outils que les reverse engineers voyants utilisent (Cheat Engine, ReClass, Frida, x64dbg) ne sont fondamentalement **pas accessibles avec un lecteur d'ecran**. Ils necessitent de naviguer visuellement dans le jeu, d'inspecter les dispositions memoire a l'ecran et de croiser l'etat visuel du jeu avec les adresses memoire. Un utilisateur aveugle ne peut pas effectuer ces etapes de maniere autonome.
>
> Meme si quelqu'un de voyant aidait a trouver des adresses memoire, les resultats sont **peu fiables** : les adresses changent entre les sessions de jeu, les mises a jour et les configurations systeme. Construire des fonctionnalites d'accessibilite stables sur des adresses memoire mouvantes n'est pas une base viable.
>
> **De maniere realiste, un jeu C++ pur n'est moddable pour l'accessibilite que si :**
>
> 1. **Une communaute de modding etablie existe** avec des outils et API documentes. Si d'autres mods existent, nous pouvons etudier leur approche et construire sur des methodes eprouvees.
> 2. **Le jeu a un support officiel de modding** - un SDK, une API de plugins ou une interface de scripting qui fournit un acces stable et nomme aux donnees du jeu.
> 3. **Le jeu stocke des donnees dans des formats accessibles** - fichiers de configuration lisibles, fichiers de sauvegarde ou API analysables de l'exterieur.
>
> **Si rien de tout cela ne s'applique :**
>
> Etre honnete : ce jeu n'est actuellement pas moddable pour l'accessibilite par un moddeur aveugle. Ce n'est pas une question de competence - c'est une barriere d'outillage et d'acces.
>
> Suggerer des alternatives :
> - Contacter le developpeur du jeu directement et demander des fonctionnalites d'accessibilite ou une API d'accessibilite
> - Verifier s'il y a un projet d'accessibilite communautaire deja en cours (des volontaires voyants menent parfois ces initiatives)
> - Chercher un jeu different avec un gameplay similaire qui utilise un moteur moddable
> - Verifier si le developpeur est favorable a l'open source - meme un acces partiel (fichiers de donnees du jeu, documentation) peut aider

---

##### Jeux avec SDK de modding officiels

Certains jeux sont livres avec des outils de modding officiels quel que soit le moteur. Si la verification automatique ou la recherche communautaire a trouve un SDK, un editeur de mods ou une API de mods documentee :

- **C'est toujours la voie preferee.** Les outils officiels sont plus stables et mieux documentes que le reverse engineering.
- Verifier ce que le SDK permet : mods de contenu/assets uniquement, ou aussi mods de code/logique ?
- Pour l'accessibilite, nous avons besoin d'un acces au niveau du code (pour ajouter des appels au lecteur d'ecran). Les SDK uniquement pour les assets (editeurs de niveaux, echanges de textures) ne sont pas suffisants.
- Si le SDK fournit une interface de scripting (Lua, Python, C#), les mods d'accessibilite peuvent etre faisables. Evaluer au cas par cas.

---

##### Si aucune voie de modding n'est trouvee

Etre honnete avec l'utilisateur - certains jeux ne peuvent pas etre moddes. Facteurs qui rendent le modding difficile ou impossible :
- Pas de communaute ou d'outils de modding etablis pour ce jeu specifique
- DRM ou anti-triche lourd (bloque l'injection de DLL et l'acces memoire)
- C++ entierement compile sans couche de scripting ni API de modding
- Jeux en ligne uniquement avec logique cote serveur
- Moteurs tres obscurs ou proprietaires

**Important :** Ne pas suggerer des approches qui necessitent des outils inaccessibles aux utilisateurs de lecteurs d'ecran (Cheat Engine, scanners memoire, debogueurs visuels) sans clairement mentionner cette limitation. Recommander des outils inaccessibles gaspille du temps et cree de la frustration.

**Avertissement :** Les informations specifiques aux moteurs ci-dessus sont basees sur des recherches et peuvent etre incompletes ou obsoletes. Les ecosystemes de modding de jeux evoluent rapidement. Toujours verifier la compatibilite actuelle pour le jeu specifique.

---

### Etapes manuelles (uniquement si la verification automatique a ete refusee)

#### Etape 4a : Moteur de jeu (manuel)

Question : Savez-vous quel moteur de jeu le jeu utilise ?

- Indices pour identifier Unity : `UnityPlayer.dll` dans le repertoire du jeu ou un repertoire `[NomDuJeu]_Data\Managed`
- Indices pour Unreal Engine : `UnrealEngine` ou `UE4` dans les noms de fichiers, fichiers `.pak`
- Indices pour Godot : fichiers `libgodot` ou fichiers `.pck`
- Indices pour GameMaker : fichier `data.win`
- Si incertain : L'utilisateur peut regarder dans le repertoire du jeu ou vous aidez a l'identification

**Si ce n'est PAS un jeu Unity :** Voir l'Etape 4d ci-dessus pour la suite.

#### Etape 4b : Architecture (manuelle)

Question : Savez-vous si le jeu est 32-bit ou 64-bit ?

Indices pour le determiner :
- Repertoire `MonoBleedingEdge` = generalement 64-bit
- Repertoire `Mono` = generalement 32-bit
- Fichiers avec "x64" dans le nom = 64-bit

**IMPORTANT :** L'architecture determine quelles DLL Tolk sont necessaires !

#### Etape 4c : Mod Loader (manuel, Unity uniquement)

Question : Un mod loader (MelonLoader ou BepInEx) est-il deja installe ?

Indices pour le determiner :
- Repertoire `MelonLoader` dans le dossier du jeu -> MelonLoader est installe
- Repertoire `BepInEx` dans le dossier du jeu -> BepInEx est installe
- Aucun des deux -> Il faut en installer un (voir Etape 4e)

Pour les debutants : Un mod loader est un programme qui charge notre code de mod dans le jeu. MelonLoader et BepInEx incluent tous deux "Harmony", une bibliotheque pour hooker les fonctions du jeu. Nous n'avons pas besoin de telecharger Harmony separement.

---

### Etape 4e : Selection du mod loader (Unity uniquement)

**Objectif :** Determiner quel mod loader utiliser pour ce jeu. C'est crucial - utiliser le mauvais mod loader peut signifier que le mod ne fonctionnera pas du tout.

**Si un mod loader a deja ete detecte (verification automatique ou manuelle) :**

Utiliser celui qui est installe. Si les deux sont installes, demander lequel l'utilisateur prefere (generalement rester avec celui que la communaute de modding du jeu utilise).

**Si aucun mod loader n'est encore installe :**

1. **Rechercher le consensus communautaire :**
   - Recherche web : "[Nom du jeu] mods"
   - Recherche web : "[Nom du jeu] modding guide"
   - Verifier Nexus Mods, Thunderstore ou les sites de mods specifiques au jeu
   - Regarder ce que les autres mods pour ce jeu utilisent

2. **Evaluer les resultats :**
   - Si la communaute utilise **MelonLoader** : Utiliser MelonLoader
   - Si la communaute utilise **BepInEx** : Utiliser BepInEx
   - Si **les deux** sont utilises : L'un ou l'autre fonctionne - demander la preference de l'utilisateur ou recommander ce que la majorite utilise
   - Si **aucun mod n'existe** pour ce jeu : Voir les indications ci-dessous

3. **Heuristiques generales (quand aucune indication communautaire n'existe) :**
   - Jeux Il2Cpp (pas de dossier `[Jeu]_Data\Managed`, ou le log MelonLoader indique "Il2Cpp") : **MelonLoader** est generalement plus fiable
   - Jeux Mono (dossier classique `[Jeu]_Data\Managed` avec `Assembly-CSharp.dll`) : Les deux fonctionnent, BepInEx a plus de ressources communautaires
   - Tres anciennes versions Unity (5.x) : Essayer d'abord **BepInEx 5.x**, MelonLoader peut ne pas le supporter

**Differences cles pour l'utilisateur :**

- **MelonLoader :** S'installe via un installeur EXE. Les mods vont dans le dossier `Mods/`. A son propre fichier de log (`MelonLoader/Latest.log`).
- **BepInEx :** S'installe en extrayant un ZIP dans le dossier du jeu. Les mods (plugins) vont dans le dossier `BepInEx/plugins/`. A son propre fichier de log (`BepInEx/LogOutput.log`).
- **Les deux :** Incluent Harmony pour le patching. Les deux supportent Tolk pour la sortie lecteur d'ecran. Le code principal du mod (classes Handler, wrapper ScreenReader, systeme Loc) est quasi identique.

Pour les debutants : Pensez aux mod loaders comme differentes marques d'adaptateurs electriques - ils delivrent tous les deux du courant (chargent votre mod), juste avec des prises legerement differentes (configuration et structure). La partie importante - les fonctionnalites reelles de votre mod - fonctionne de la meme maniere avec l'un ou l'autre.

**Si aucun mod n'existe pour ce jeu :**

Ce n'est pas necessairement un bloqueur, mais cela signifie :
- Personne n'a verifie qu'un mod loader fonctionne avec ce jeu
- Il peut y avoir un anti-triche, un DRM ou d'autres obstacles
- L'installation pourrait necessiter du depannage

Suggerer d'essayer le mod loader correspondant au runtime du jeu (MelonLoader pour Il2Cpp, l'un ou l'autre pour Mono). Si ca ne fonctionne pas, essayer l'autre. Documenter les resultats.

**Instructions d'installation :**

**MelonLoader :**
- Telechargement : https://github.com/LavaGang/MelonLoader.Installer/releases
- Lancer l'installeur et le pointer vers l'EXE du jeu
- Apres l'installation, il devrait y avoir un repertoire `MelonLoader` dans le repertoire du jeu
- Demarrer le jeu une fois pour creer la structure de repertoires et generer le fichier de log

**BepInEx :**
- Telechargement : https://github.com/BepInEx/BepInEx/releases
- Pour les jeux Unity Mono : Telecharger le build approprie (x64 ou x86, correspondant a l'architecture du jeu)
- Pour les jeux Unity Il2Cpp : Telecharger le build Il2Cpp (bien que MelonLoader soit generalement meilleur pour Il2Cpp)
- Extraire le contenu du ZIP dans le repertoire du jeu (la ou se trouve l'EXE du jeu)
- Demarrer le jeu une fois pour creer la structure de repertoires (`BepInEx/plugins/`, `BepInEx/config/`, etc.)

**Apres l'installation :** Continuer avec l'Etape 5 (Tolk).

**Enregistrer le mod loader choisi** dans `project_status.md` - cela affecte la structure du projet, la configuration de build et les templates de code.

---

### Etape 5 : Tolk (si signale comme manquant lors de la verification automatique)

Si les DLL Tolk sont manquantes, expliquer :
- Telechargement : https://github.com/ndarilek/tolk/releases
- **IMPORTANT : Vous avez besoin des DEUX DLL - pas seulement Tolk.dll !**
- Pour 64-bit : `Tolk.dll` + `nvdaControllerClient64.dll` depuis le repertoire x64
- Pour 32-bit : `Tolk.dll` + `nvdaControllerClient32.dll` depuis le repertoire x86
- Copier les DEUX DLL dans le repertoire du jeu (la ou se trouve le .exe)
- Sans `nvdaControllerClient*.dll`, NVDA ne recevra aucune sortie ! (JAWS fonctionne via COM, pas de DLL supplementaire necessaire)

Pour les debutants : Tolk est une bibliotheque qui peut communiquer avec divers lecteurs d'ecran (NVDA, JAWS, etc.). Notre mod utilise Tolk pour envoyer du texte a votre lecteur d'ecran. Tolk.dll est le pont, et nvdaControllerClient*.dll est specifiquement necessaire pour que NVDA puisse recevoir le texte.

### Etape 6 : SDK .NET

Question : Avez-vous deja le SDK .NET installe ?

Verifier avec : `dotnet --version` dans PowerShell.

Si non, installer via WinGet (prefere - Claude Code peut l'executer automatiquement) :

```powershell
winget install Microsoft.DotNet.SDK.8
```

Apres l'installation, **redemarrer le terminal** pour que la commande `dotnet` soit disponible.

Si WinGet n'est pas disponible, telechargement manuel : https://dotnet.microsoft.com/download (recommande : SDK .NET 8 ou plus recent).

Pour les debutants : Le SDK .NET est un outil de developpement de Microsoft. Nous en avons besoin pour compiler notre code C# en un fichier DLL que le mod loader (MelonLoader ou BepInEx) peut ensuite charger.

### Etape 7 : Decompilation

Question : Avez-vous un outil de decompilation (dnSpy ou ILSpy) installe ?

Si non, expliquer les options :

**ILSpy (recommande) :**

Installer l'outil en ligne de commande via dotnet (prefere - Claude Code peut l'executer automatiquement) :

```powershell
dotnet tool install ilspycmd -g
```

Apres l'installation, **redemarrer le terminal** pour que la commande `ilspycmd` soit disponible.

- **Avantage :** Entierement controlable en ligne de commande, Claude Code peut automatiser toute la decompilation
- Utilisation en ligne de commande : `ilspycmd -p -o decompiled "[Jeu]_Data\Managed\Assembly-CSharp.dll"`
- Cela rend tout le processus de decompilation automatisable - Claude Code peut le faire pour vous

Optionnellement, installer aussi la version GUI via WinGet :

```powershell
winget install icsharpcode.ILSpy
```

Si ni WinGet ni dotnet tool ne sont disponibles, telechargement manuel : https://github.com/icsharpcode/ILSpy/releases

**dnSpy (alternative) :**
- Telechargement : https://github.com/dnSpy/dnSpy/releases
- Non disponible via WinGet (projet arrete)
- Outil base sur une GUI avec un flux de travail manuel
- L'utiliser pour decompiler `Assembly-CSharp.dll` depuis `[Jeu]_Data\Managed\`
- Le code decompile devrait etre copie dans `decompiled/` dans ce repertoire de projet

**Instructions pour lecteur d'ecran pour dnSpy :**
1. Ouvrir DnSpy.exe
2. Utiliser Ctrl+O pour selectionner la DLL (par ex. Assembly-CSharp.dll)
3. Dans le menu "File", selectionner "Export to Project"
4. Appuyer une fois sur Tab - atterrit sur un bouton sans libelle pour la selection du repertoire cible
5. La, selectionner le repertoire cible (l'ideal est de creer un sous-repertoire "decompiled" dans ce repertoire de projet au prealable, pour que Claude Code puisse facilement trouver le code source)
6. Apres avoir confirme la selection du repertoire, appuyer sur Tab plusieurs fois jusqu'a atteindre le bouton "Export"
7. L'export prend environ trente secondes
8. Puis fermer dnSpy

Pour les debutants : Les jeux sont ecrits dans un langage de programmation puis "compiles" (traduits en code machine). Decompiler fait l'inverse - nous obtenons du code lisible. Nous en avons besoin pour comprendre comment le jeu fonctionne et ou accrocher nos fonctionnalites d'accessibilite.

### Etape 7b : Extraction des textes de tutoriel (si l'utilisateur ne connait pas bien le jeu)

Si l'utilisateur a indique a l'Etape 2b qu'il ne connait pas bien le jeu ("Un peu" ou "Pas du tout") :

**Proposer :** "Je peux rechercher dans le code decompile et les fichiers du jeu les textes de tutoriel, textes d'aide et instructions de gameplay. Je les ecrirai dans un fichier pour que vous puissiez lire les mecaniques du jeu avant ou pendant que nous commencions le modding. Dois-je le faire ?"

**Si oui :**

1. **Rechercher les textes de tutoriel/aide dans le code decompile :**
   ```
   Grep pattern: Tutorial
   Grep pattern: [Hh]elp[Tt]ext
   Grep pattern: [Ii]nstruction
   Grep pattern: [Hh]ow[Tt]o
   Grep pattern: [Tt]ip[Ss]
   Grep pattern: [Hh]int
   Grep pattern: [Gg]uide
   ```

2. **Rechercher les fichiers de localisation/ressources :**
   - Chercher dans `[Jeu]_Data/StreamingAssets/` des fichiers JSON, XML, CSV ou TXT
   - Chercher dans `[Jeu]_Data/Resources/` des assets textuels
   - Rechercher des fichiers contenant "tutorial", "help", "tips" dans leurs noms
   - Verifier les fichiers de localisation pour les cles contenant ces termes

3. **Preference linguistique :**
   - Essayer de trouver les textes dans la langue de l'utilisateur en premier
   - Se rabattre sur l'anglais si la langue de l'utilisateur n'est pas disponible
   - Si plusieurs langues existent, extraire la langue de l'utilisateur + l'anglais

4. **Ecrire les resultats dans `docs/tutorial-texts.md` :**
   - Organiser par sujet/mecanique de jeu si possible
   - Inclure le contexte (de quelle classe/fichier le texte provient)
   - Marquer les textes flous ou fragmentaires comme tels
   - Ajouter une note indiquant que ce sont des textes de jeu extraits, pas de la documentation du mod

5. **Resumer pour l'utilisateur :**
   - Apercu bref de ce qui a ete trouve
   - Quelles mecaniques de jeu sont couvertes
   - Les lacunes eventuelles (mecaniques qui semblent exister mais n'ont pas de texte de tutoriel)

**Si non :** Continuer avec l'Etape 8. L'utilisateur peut toujours le demander plus tard.

Pour les debutants : Les tutoriels de jeu expliquent les mecaniques de base etape par etape. Lire ces textes vous aide a comprendre ce que le jeu fait, ce qui est utile pour decider quelles fonctionnalites ont besoin d'un support d'accessibilite en priorite.

### Etape 8 : Langues

**IMPORTANT : La localisation n'est PAS optionnelle.** Toutes les chaines que le lecteur d'ecran annonce DOIVENT passer par `Loc.Get()` des la premiere fonctionnalite. `Loc.cs` est cree dans le cadre du framework de base en Phase 2. C'est non negociable car :
- Ajouter la localisation apres coup signifie toucher chaque handler - un gaspillage de temps enorme
- Meme un mod "monolingue" beneficie d'avoir toutes les chaines au meme endroit
- Ajouter une nouvelle langue plus tard est trivial quand le systeme est deja en place

Question : Quelles langues le mod devrait-il supporter ? Recommandation de commencer avec 1 a 3 :

1. **Anglais** (toujours - sert de fallback et atteint le plus grand nombre d'utilisateurs)
2. **Votre langue maternelle** (si differente de l'anglais)
3. **Optionnellement :** Une langue supplementaire si vous ou quelqu'un que vous connaissez peut traduire

**Conseils pour l'utilisateur :**
- Commencer avec 1 ou 2 langues. Vous pouvez toujours en ajouter plus tard.
- Ajouter une nouvelle langue est simple : ajouter un dictionnaire, etendre la methode `Add()`, puis remplir toutes les chaines d'un coup. Cela peut meme etre fait par quelqu'un qui ne code pas - il a juste besoin de la liste des cles et des chaines en anglais.
- Se concentrer d'abord sur le fonctionnement du mod. Ne pas passer des semaines a traduire avant que les fonctionnalites soient terminees.
- Si le jeu a son propre systeme de traduction, utiliser les traductions du jeu pour les termes specifiques au jeu (noms d'objets, libelles de menus) quand c'est possible. Ne traduire que vos propres chaines de mod.
- Plus de 5 langues representent beaucoup de maintenance. N'y penser qu'apres que le mod soit stable et que vous ayez des traducteurs prets a aider.

Si le mod va supporter plus d'une langue :
- Le systeme de langues du jeu doit etre analyse pendant la decompilation
- Rechercher : `Language`, `Localization`, `I18n`, `currentLanguage`, `getAlias()`
- Voir `localization-guide.md` pour les instructions completes

Utiliser `templates/Loc.cs.template` comme point de depart (toujours, quel que soit le nombre de langues).

### Etape 9 : Configurer le repertoire du projet

Apres l'entretien :
- **Determiner le nom du mod :** `[NomDuJeu]Access` - abreger si 3+ mots (par ex. "PetIdleAccess", "DsaAccess" pour "Das Schwarze Auge")
- Creer `project_status.md` depuis `templates/project_status.md.template` - remplir toutes les informations collectees et cocher les etapes de configuration terminees. **C'est le document central de suivi pour l'ensemble du projet.** Le mettre a jour a chaque etape significative : fonctionnalites terminees, bugs decouverts, decisions d'architecture, notes pour la prochaine session.
- Creer `docs/game-api.md` depuis `templates/game-api.md.template` comme espace reserve pour les decouvertes sur le jeu
- Entrer les chemins concrets dans CLAUDE.md sous "Environment"

#### Alleger CLAUDE.md apres la configuration

Une fois `project_status.md` cree, alleger CLAUDE.md pour economiser des tokens pour le reste du projet :

1. **Remplacer la section "Project Start"** par :
   ```
   ## Session Start
   On greeting:
   1. Read `project_status.md` -- summarize phase, last work, pending tests, notes
   2. If pending tests exist, ask user for results before continuing
   3. Suggest next steps or ask what to work on
   Update `project_status.md` on significant progress and before session end.
   ```

2. **Retirer des References :**
   - `docs/setup-guide.md` -- plus necessaire
   - `docs/legacy-unity-modding.md` -- retirer si ce jeu n'est PAS une ancienne version Unity (5.x ou anterieure)

Cela economise des tokens par message pour toute la duree de vie du projet.

---

## Liste de verification utilisateur (a lire a voix haute)

Apres l'entretien, lire cette liste :

- Architecture du jeu connue (32-bit ou 64-bit)
- Mod loader installe et teste : MelonLoader (le jeu demarre avec la console MelonLoader) ou BepInEx (le fichier de log BepInEx est cree)
- DLL Tolk dans le repertoire du jeu (correspondant a l'architecture !)
- Outil de decompilation pret
- Assembly-CSharp.dll decompile et code copie dans le repertoire `decompiled/`

**Astuce :** Le script de validation verifie tous les points automatiquement :
```powershell
.\scripts\Test-ModSetup.ps1 -GamePath "C:\Chemin\vers\Jeu" -Architecture x64
```

---

## Gestion des tokens et conversations

**Expliquer ceci a l'utilisateur tot (pendant ou apres la configuration) :**

Claude Code relit l'integralite de la conversation a chaque fois que vous envoyez un message. Cela signifie que les longues conversations coutent de plus en plus de tokens. Pour etre efficace :

- **Demarrer une nouvelle conversation** chaque fois que vous terminez une fonctionnalite ou une tache distincte. Ne continuez pas dans la meme conversation pendant des heures.
- **Environ 30 a 40 messages** est un bon moment pour envisager de repartir a zero.
- **Avant de demarrer une nouvelle conversation :** Claude devrait toujours mettre a jour `project_status.md` pour que la prochaine conversation sache exactement ou en sont les choses.
- **Quand vous revenez :** Dites simplement "bonjour" ou "continuons" - Claude lit `project_status.md` et reprend la ou vous vous etiez arrete.

Ce n'est pas une limitation mais un avantage de flux de travail : les conversations fraiches ont un contexte clair et font moins d'erreurs.

---

## Flux de travail Session 2+

**Expliquer ceci a l'utilisateur a la fin de la premiere session (ou quand il demande comment fonctionne le flux de travail) :**

### Ce que vous devez faire

- **Demarrer une session :** Dites simplement "bonjour", "continuons", ou allez droit au but avec "J'ai teste le menu, voici ce qui s'est passe : ..."
- **Vous n'avez pas besoin de repeter** le nom du jeu, la configuration du projet, ce qui a ete fait avant ou les details techniques. Claude lit `project_status.md` et sait tout cela.
- **Rapporter les resultats de test :** Decrivez simplement ce qui s'est passe naturellement. "Le menu fonctionne mais l'element 3 est saute" ou "Rien ne se passe quand j'appuie sur F2" suffit. Claude posera des questions de suivi si necessaire.
- **Demander des fonctionnalites :** "Passons a l'inventaire" ou "Peut-on ajouter les annonces de sante ?" - Claude verifie le plan de fonctionnalites et commence a travailler.
- **Si quelque chose semble anormal :** "Je pense que X est casse depuis la derniere fois" - Claude va investiguer.

### Ce que Claude fait automatiquement

1. Lit `project_status.md` - connait la phase actuelle, toutes les fonctionnalites, problemes et notes de la derniere session
2. S'il y a des tests en attente, vous demande les resultats
3. Suggere sur quoi travailler ensuite (ou demande)
4. Avant la fin de la session, met a jour `project_status.md` avec tout ce qui s'est passe

### Le cycle

```
Debut de session -> Claude lit project_status.md -> resume -> demande quoi faire
  -> Vous dites sur quoi travailler (ou Claude suggere)
  -> Claude code -> compile -> vous testez en jeu -> rapportez les resultats
  -> Repeter jusqu'a ce que la fonctionnalite soit terminee
  -> Claude met a jour project_status.md -> suggere une nouvelle session
```

### Quand les choses tournent mal entre les sessions

- **Le jeu a ete mis a jour et le mod est casse :** Dites-le a Claude, il verifiera ce qui a change
- **Vous avez oublie ce qui etait prevu :** Dites simplement "bonjour" - Claude vous le dira
- **Vous voulez changer de direction :** Dites-le simplement, Claude adapte le plan
- **Vous avez perdu vos notes de test :** Claude peut reconstruire le contexte depuis `project_status.md` et le code

---

## Etapes suivantes

Apres avoir termine la configuration, proceder dans cet ordre :

0. **Lire ACCESSIBILITY_MODDING_GUIDE.md** - Lire `docs/ACCESSIBILITY_MODDING_GUIDE.md` completement, en particulier la section "Source Code Research Before Implementation". Ce guide definit les patrons et regles pour l'ensemble du projet.

0b. **Pour les anciennes versions Unity (5.x ou anterieure) :** Lire `docs/legacy-unity-modding.md` pour des informations importantes sur les problemes de compatibilite, les mod loaders alternatifs et le patching d'assemblage en solution de secours. Garder cela a l'esprit pendant l'analyse - certains patrons peuvent necessiter une adaptation.

1. **Analyse du code source** (Phase 1 ci-dessous) - Le Tier 1 est obligatoire avant tout codage
2. **Recherche/analyse du tutoriel** (Section 1.10) - Comprendre les mecaniques, souvent haute priorite
3. **Creer le plan de fonctionnalites** (Phase 1.5) - Les fonctionnalites les plus importantes en detail, le reste grossierement
4. **Remplir game-api.md** - Documenter les resultats de l'analyse (continu, mais les resultats du Tier 1 DOIVENT etre entres avant la Phase 2)

---

## CRITIQUE : Avant le premier build - Verifier le log !

**Ces valeurs DOIVENT etre lues depuis le log du mod loader, JAMAIS devinees !**

### Pour MelonLoader

#### Automatiquement avec le script (recommande)

```powershell
.\scripts\Get-MelonLoaderInfo.ps1 -GamePath "C:\Chemin\vers\Jeu"
```

Le script extrait toutes les valeurs et affiche l'attribut MelonGame pret a l'emploi.

#### Manuellement (si le script n'est pas disponible)

**Etape 1 :** Demarrer le jeu une fois avec MelonLoader (cree le log).

**Etape 2 :** Chemin du log : `[RepertoireDuJeu]\MelonLoader\Latest.log`

Rechercher ces lignes et noter les valeurs EXACTES :

```
Game Name: [COPIER EXACTEMENT]
Game Developer: [COPIER EXACTEMENT]
Runtime Type: [net35 or net6]
```

#### Entrer les valeurs dans le code/projet (MelonLoader)

**Attribut MelonGame (Main.cs) :**
```csharp
[assembly: MelonGame("DEVELOPPEUR_DU_LOG", "NOM_DU_JEU_DU_LOG")]
```
- Les majuscules/minuscules DOIVENT correspondre exactement
- Les espaces DOIVENT correspondre exactement
- Avec un nom incorrect, le mod se chargera mais ne s'initialisera PAS !

**TargetFramework (csproj) :**
- Si le log indique `Runtime Type: net35` -> utiliser `<TargetFramework>net472</TargetFramework>`
- Si le log indique `Runtime Type: net6` -> utiliser `<TargetFramework>net6.0</TargetFramework>`
- Referencer les DLL MelonLoader depuis le sous-repertoire correspondant (net35/ ou net6/)

**AVERTISSEMENT :** N'utilisez PAS `netstandard2.0` pour les jeux net35 !
netstandard2.0 n'est qu'une specification API, pas un runtime. Mono a des problemes de compatibilite avec - le mod se chargera mais ne s'initialisera pas (pas de message d'erreur, juste du silence).

**Pourquoi est-ce si important ?**
1. **Nom du developpeur incorrect** = Le mod se charge mais OnInitializeMelon() n'est jamais appele. Pas d'erreur dans le log, juste du silence.
2. **Framework incorrect** = Le mod se charge mais ne peut pas s'executer. Pas d'erreur dans le log, juste du silence.

**En cas de crash ou d'echec silencieux :** Lire la section "CRITICAL: Accessing Game Code" de `technical-reference.md`.

### Pour BepInEx

#### Log et configuration

**Etape 1 :** Demarrer le jeu une fois avec BepInEx (cree les fichiers de configuration et de log).

**Etape 2 :** Chemin du log : `[RepertoireDuJeu]\BepInEx\LogOutput.log`

Verifier dans le log :
- Initialisation reussie de BepInEx
- Version Unity
- Erreurs ou avertissements eventuels

#### Entrer les valeurs dans le code/projet (BepInEx)

**Attribut BepInPlugin (Main.cs) :**
```csharp
[BepInPlugin("com.auteur.nommodd", "NomDuMod", "1.0.0")]
```
- Le premier parametre (GUID) est un identifiant unique - utiliser la notation de domaine inverse
- Ceci ne necessite PAS de valeurs du log - vous les choisissez vous-meme
- Mais le GUID doit etre unique parmi tous les mods pour ce jeu

**TargetFramework (csproj) :**
- La plupart des jeux BepInEx Mono : `<TargetFramework>net472</TargetFramework>` ou `<TargetFramework>net35</TargetFramework>`
- Verifier ce que les autres mods BepInEx pour ce jeu utilisent, ou verifier les DLL dans `BepInEx/core/`
- Referencer les DLL BepInEx : `BepInEx/core/BepInEx.dll` et les DLL Unity pertinentes depuis `[Jeu]_Data/Managed/`

**References du projet (csproj) pour BepInEx :**
```xml
<Reference Include="BepInEx">
    <HintPath>[RepertoireDuJeu]\BepInEx\core\BepInEx.dll</HintPath>
</Reference>
<Reference Include="0Harmony">
    <HintPath>[RepertoireDuJeu]\BepInEx\core\0Harmony.dll</HintPath>
</Reference>
<Reference Include="UnityEngine">
    <HintPath>[RepertoireDuJeu]\[Jeu]_Data\Managed\UnityEngine.dll</HintPath>
</Reference>
<Reference Include="UnityEngine.CoreModule">
    <HintPath>[RepertoireDuJeu]\[Jeu]_Data\Managed\UnityEngine.CoreModule.dll</HintPath>
</Reference>
<Reference Include="Assembly-CSharp">
    <HintPath>[RepertoireDuJeu]\[Jeu]_Data\Managed\Assembly-CSharp.dll</HintPath>
</Reference>
```

**Repertoire de sortie :** La DLL compilee va dans `BepInEx/plugins/` (pas `Mods/`).

### Commun aux deux mod loaders

**Exclure le repertoire decompile (csproj) :**
Le csproj DOIT contenir ces lignes, sinon les fichiers decompiles seront compiles (des centaines d'erreurs !) :
```xml
<ItemGroup>
  <Compile Remove="decompiled\**" />
  <Compile Remove="templates\**" />
</ItemGroup>
```

**Commande de build - TOUJOURS avec le fichier projet !**
```
dotnet build [NomDuMod].csproj
```
N'utilisez PAS simplement `dotnet build` ! Le repertoire `decompiled/` contient souvent son propre fichier `.csproj` provenant du jeu decompile. Si MSBuild trouve plusieurs fichiers projet, il abandonne.

---

## Flux de travail du demarrage du projet

### Phase 1 : Analyse du code source (avant le codage)

**PREREQUIS : Le code source decompile DOIT etre dans `decompiled/` avant de commencer cette phase !**

La Phase 1 travaille EXCLUSIVEMENT avec le code source decompile - pas avec des recherches Internet, pas avec des suppositions, pas avec des articles de wiki. Si `decompiled/` est vide ou n'existe pas, ARRETER et revenir a l'Etape 7 (Decompilation). Toutes les commandes Grep/Glob de cette phase ciblent le repertoire `decompiled/`.

Objectif : Comprendre tous les systemes pertinents pour l'accessibilite AVANT de commencer le developpement du mod.

**Comment aborder cette phase - n'essayez pas de tout faire en une fois !**

L'analyse est divisee en tiers :

- **Tier 1 (Essentiel - a faire avant TOUT codage) :** Etapes 1.1, 1.2, 1.3, 1.4, 1.5 - Structure, Entrees, UI, Decision de gestion d'etat et Localisation (si multilingue). Sans ceux-ci, vous ne pouvez rien construire.
- **Tier 2 (A faire juste-a-temps - avant d'implementer une fonctionnalite specifique) :** Etapes 1.6, 1.7, 1.8 - Analyser les mecaniques de jeu, systemes de statut et evenements uniquement quand vous etes sur le point de construire une fonctionnalite qui en a besoin. Par exemple, analyser le systeme d'inventaire juste avant de construire le InventoryHandler, pas des mois a l'avance.
- **Tier 3 (Quand c'est pertinent) :** Etapes 1.9, 1.10, 1.11 - Documentation, analyse de tutoriel. Les faire quand le projet est pret pour.

Cette approche juste-a-temps evite la surcharge d'information et signifie que vous analysez toujours avec un objectif specifique en tete.

#### 1.1 Vue d'ensemble de la structure (Tier 1 - Essentiel)

**Inventaire des namespaces :**
```
Grep pattern: ^namespace\s+
```
Categoriser en : UI/Menus, Gameplay, Audio, Entrees, Sauvegarde/Chargement, Reseau, Autre.

**Trouver les instances singleton :**
```
Grep pattern: static.*instance
Grep pattern: \.instance\.
```
Les singletons sont les principaux points d'acces au jeu. Tous les lister avec le nom de la classe, ce qu'ils gerent, les proprietes importantes.

#### 1.2 Systeme d'entrees (Tier 1 - Essentiel, CRITIQUE !)

**Trouver toutes les associations de touches :**
```
Grep pattern: KeyCode\.
Grep pattern: Input\.GetKey
Grep pattern: Input\.GetKeyDown
Grep pattern: Input\.GetKeyUp
```
Pour CHAQUE resultat, documenter : Fichier/ligne, quelle touche, ce qui se passe, dans quel contexte.

**Entrees souris :**
```
Grep pattern: Input\.GetMouseButton
Grep pattern: OnClick
Grep pattern: OnPointerClick
Grep pattern: OnPointerEnter
```

**Controleurs d'entrees :**
```
Grep pattern: class.*Input.*Controller
Grep pattern: class.*InputManager
```

**Resultat :** Creer la liste des touches NON utilisees par le jeu -> touches sures pour le mod.

**SORTIE OBLIGATOIRE - a faire MAINTENANT, pas plus tard :**
1. Ecrire TOUTES les associations de touches trouvees dans `docs/game-api.md` section "Game Key Bindings"
2. Ecrire la liste des touches sures pour le mod dans `docs/game-api.md` section "Safe Mod Keys"
3. Mettre a jour `project_status.md` - cocher les elements "Input system"

**Ne PAS passer a 1.3 tant que les deux sections ne sont pas ecrites dans game-api.md !** C'est la source la plus courante de bugs (touches du mod en conflit avec les controles du jeu) et l'etape la plus souvent sautee.

#### 1.3 Systeme d'UI (Tier 1 - Essentiel, CRITIQUE pour les mods d'accessibilite !)

**Pourquoi c'est l'etape d'analyse la plus importante :**
Les systemes d'UI sont le coeur des mods d'accessibilite. Comprendre comment le jeu construit ses menus, boutons et listes determine toute l'architecture du mod. Investissez du temps ici - cela paie pour chaque fonctionnalite par la suite.

**Classes de base UI :**
```
Grep pattern: class.*Form.*:
Grep pattern: class.*Panel.*:
Grep pattern: class.*Window.*:
Grep pattern: class.*Dialog.*:
Grep pattern: class.*Menu.*:
Grep pattern: class.*Screen.*:
Grep pattern: class.*Canvas.*:
```

Decouvrir : Classe de base commune ? Comment les fenetres sont-elles ouvertes/fermees ? Gestion centralisee de l'UI ?

**Affichage de texte :**
```
Grep pattern: \.text\s*=
Grep pattern: SetText\(
Grep pattern: TextMeshPro
```

**Infobulles :**
```
Grep pattern: Tooltip
Grep pattern: hover
Grep pattern: description
```

**IMPORTANT - Verifier les champs prives (Unity) :**

De nombreux jeux Unity utilisent ce patron :
```csharp
[SerializeField]
private TextMeshProUGUI title;
```

Cela signifie : Le texte n'est PAS accessible via des proprietes publiques ou des chemins UI !

**Rechercher ce patron :**
```
Grep pattern: \[SerializeField\]
Grep pattern: private.*Text
Grep pattern: private.*TMP
Grep pattern: private.*Button
```

**Si de nombreux champs prives sont trouves :**
- Les donnees UI doivent etre accedees via la Reflexion
- Voir `docs/unity-reflection-guide.md` pour les patrons et solutions
- Prevoir de creer une classe utilitaire `ReflectionHelper` tot

**Documenter les resultats UI dans game-api.md :**
- Lister toutes les classes de base UI avec leur methode d'acces au texte
- Noter quels champs sont prives (necessitent la Reflexion)
- Documenter la convention de nommage (m_PascalCase ou camelCase)
- Creer des exemples de code pour les patrons d'acces courants

**Resultat de l'analyse UI :**

Apres cette etape, vous devriez savoir :
1. Comment obtenir le texte de n'importe quel element UI (propriete publique, methode ou Reflexion)
2. Comment la navigation/selection fonctionne (Systeme de focus ? Evenements de surlignage ?)
3. Quelles classes de base existent et comment elles sont reliees
4. Si vous avez besoin de ReflectionHelper (si beaucoup de champs prives)

#### 1.4 Decision de gestion d'etat (Tier 1 - Essentiel)

Sur la base des resultats de 1.2 (Entrees) et 1.3 (UI), evaluer :

**Combien de handlers partageront les memes touches ?**

Compter les ecrans/fonctionnalites de l'analyse UI ou les memes touches (surtout les fleches, Entree, Echap) doivent faire des choses differentes. Exemples :
- Touches flechees : navigation de menu vs. deplacement sur la carte du monde vs. parcours de l'inventaire
- Entree : confirmer un element de menu vs. interagir avec un objet vs. avancer le dialogue
- Echap : fermer l'inventaire vs. fermer la boutique vs. ouvrir le menu pause

**Decision :**
- **3+ handlers partageant des touches** -> Utiliser `AccessStateManager` (creer depuis `templates/AccessStateManager.cs.template` en Phase 2)
- **1-2 handlers** -> De simples drapeaux booleens suffisent (voir `state-management-guide.md`)

**Documenter la decision** dans `project_status.md` sous "Architecture Decisions" avec le raisonnement.

#### 1.5 Systeme de localisation (Tier 1 - Si multilingue)

**Sauter cette etape si le mod ne supportera qu'une seule langue.** Loc.cs est quand meme cree en Phase 2 (avoir toutes les chaines au meme endroit est toujours une bonne pratique), mais vous n'avez pas besoin d'analyser le systeme de langues du jeu.

**Si le mod va supporter plusieurs langues (decide a l'Etape 8) :**

La detection de langue du jeu doit etre comprise AVANT de construire Loc.cs, pour que le mod puisse detecter automatiquement quelle langue utiliser.

```
Grep pattern: Locali
Grep pattern: Language
Grep pattern: Translate
Grep pattern: GetString
Grep pattern: currentLanguage
Grep pattern: getAlias
```

**Ce qu'il faut trouver :**
- Comment le jeu stocke/detecte-t-il sa langue actuelle ?
- Y a-t-il un singleton ou une propriete statique pour la langue actuelle ? (par ex. `LocalizationManager.CurrentLanguage`)
- Quel est le format des codes de langue ? (par ex. "en", "de", "English", "German")
- Ou sont les fichiers de traduction du jeu ? (pour reutiliser les termes du jeu comme les noms d'objets)

**Documenter dans game-api.md** section "Localization" : la classe/propriete pour la langue actuelle et le format du code de langue.

Voir `docs/localization-guide.md` pour les instructions completes de construction d'un Loc.cs multilingue.

---

### PORTE DE COMPLETION DU TIER 1

**STOP ! Avant de passer au Tier 2 ou a la Phase 1.5, verifier que TOUT ceci est fait :**

1. `docs/game-api.md` a une section "Game Key Bindings" complete avec TOUTES les touches utilisees par le jeu
2. `docs/game-api.md` a une section "Safe Mod Keys" listant les touches que le mod peut utiliser en toute securite
3. `docs/game-api.md` a les classes de base UI et les patrons d'acces au texte documentes
4. `project_status.md` a toutes les cases du Tier 1 cochees
5. La section "Game Key Bindings (Original)" de `project_status.md` est remplie
6. La decision de gestion d'etat est documentee dans `project_status.md` "Architecture Decisions"
7. Si multilingue : la detection de langue du jeu est documentee dans `docs/game-api.md`

**Si l'un de ces points manque, revenir en arriere et le faire maintenant.** Chaque bug de mod cause par des conflits de touches aurait pu etre evite en completant correctement cette porte.

---

#### 1.6 Mecaniques de jeu (Tier 2 - Analyser avant d'implementer les fonctionnalites associees)

**Classe joueur :**
```
Grep pattern: class.*Player
Grep pattern: class.*Character
Grep pattern: class.*Controller.*:.*MonoBehaviour
```

**Inventaire :**
```
Grep pattern: class.*Inventory
Grep pattern: class.*Item
Grep pattern: class.*Slot
```

**Interaction :**
```
Grep pattern: Interact
Grep pattern: OnUse
Grep pattern: IInteractable
```

**Autres systemes (selon le jeu) :**
- Quetes : `class.*Quest`, `class.*Mission`
- Dialogues : `class.*Dialog`, `class.*Conversation`, `class.*NPC`
- Combat : `class.*Combat`, `class.*Attack`, `class.*Health`
- Artisanat : `class.*Craft`, `class.*Recipe`
- Ressources : `class.*Currency`, `Gold`, `Coins`

#### 1.7 Statut et retour d'information (Tier 2 - Analyser avant d'implementer les annonces de statut)

**Statut du joueur :**
```
Grep pattern: Health
Grep pattern: Stamina
Grep pattern: Mana
Grep pattern: Energy
```

**Notifications :**
```
Grep pattern: Notification
Grep pattern: Message
Grep pattern: Toast
Grep pattern: Popup
```

#### 1.8 Systeme d'evenements (Tier 2 - Analyser avant d'implementer les patches Harmony)

**Trouver les evenements :**
```
Grep pattern: delegate\s+
Grep pattern: event\s+
Grep pattern: Action<
Grep pattern: UnityEvent
Grep pattern: \.Invoke\(
```

**Bons points de patch :**
```
Grep pattern: OnOpen
Grep pattern: OnClose
Grep pattern: OnShow
Grep pattern: OnHide
Grep pattern: OnSelect
```

#### 1.9 Documenter les resultats (Continu - mettre a jour apres chaque analyse)

Apres l'analyse, `docs/game-api.md` devrait contenir :
1. Vue d'ensemble - Description du jeu, version du moteur
2. Points d'acces singleton
3. Associations de touches du jeu (TOUTES !)
4. Touches sures pour le mod
5. **Systeme d'UI (detaille !) :**
   - Toutes les classes de base UI et leur hierarchie
   - Comment acceder au texte (propriete publique, methode ou nom de champ par Reflexion)
   - Convention de nommage utilisee (m_PascalCase ou camelCase)
   - Exemples de code pour les patrons d'acces UI courants
   - Quelles classes necessitent ReflectionHelper
6. Mecaniques de jeu
7. Systemes de statut
8. Hooks d'evenements pour Harmony

**Pourquoi une documentation UI detaillee est importante :**
Chaque fonctionnalite de menu devra lire du texte depuis des elements UI. Si vous documentez le patron d'acces une fois, vous (et Claude Code) pouvez le reutiliser partout sans re-analyser a chaque fois.

#### 1.10 Rechercher et analyser le tutoriel (Tier 3 - Lors de la planification de l'accessibilite du tutoriel)

**Pourquoi le tutoriel est important :**
- Les tutoriels expliquent les mecaniques de jeu etape par etape - ideal pour comprendre ce qui doit etre rendu accessible
- Souvent une structure plus simple que le reste du jeu - bon point d'entree pour le developpement du mod
- Si le tutoriel est accessible, les joueurs aveugles peuvent effectivement apprendre le jeu en premier lieu
- Le code du tutoriel revele souvent quels elements UI et interactions existent

**Rechercher dans le code decompile :**
```
Grep pattern: Tutorial
Grep pattern: class.*Tutorial
Grep pattern: FirstTime
Grep pattern: Introduction
Grep pattern: HowToPlay
Grep pattern: Onboarding
```

**Rechercher dans le repertoire du jeu :**
- Des fichiers avec "tutorial", "intro", "howto" dans le nom
- Souvent organise en scenes ou niveaux separes

**Questions d'analyse :**
1. Y a-t-il un tutoriel ? Si oui, comment est-il lance ?
2. Quelles mecaniques de jeu sont introduites dans le tutoriel ?
3. Comment les instructions sont-elles affichees (texte, popups, sortie vocale) ?
4. Y a-t-il des elements interactifs qui doivent etre rendus accessibles ?
5. Le tutoriel peut-il etre saute ?

**Resultat :**
- Documenter l'existence du tutoriel et la methode de demarrage dans game-api.md
- Mettre le tutoriel sur la liste des fonctionnalites (generalement haute priorite)
- Utiliser les mecaniques reconnues comme base pour les fonctionnalites suivantes

### Phase 1.5 : Creer le plan de fonctionnalites

**Creer un plan structure avant de coder :**

Sur la base de l'analyse du code source et des resultats du tutoriel, creer une liste de fonctionnalites.

**Structure du plan :**

Fonctionnalites les plus importantes (documenter en detail) :
- Que doit faire exactement la fonctionnalite ?
- Quelles classes/methodes du jeu sont utilisees ?
- Quelles touches sont necessaires ?
- Dependances avec d'autres fonctionnalites ?
- Defis connus ?

Exemple pour une fonctionnalite detaillee :
```
Fonctionnalite : Navigation du menu principal
- Objectif : Tous les elements de menu navigables avec les fleches, annoncer la selection actuelle
- Classes : MainMenu, MenuButton (de l'Analyse 1.3)
- Hook Harmony : MainMenu.OnOpen() pour l'initialisation
- Touches : Touches flechees (deja utilisees par le jeu), Entree (confirmer)
- Dependances : Aucune (premiere fonctionnalite)
- Defi : Les elements de menu n'ont pas de propriete de texte uniforme
```

Fonctionnalites moins importantes (documenter grossierement) :
- Breve description en 1-2 phrases
- Complexite estimee (simple/moyenne/complexe)
- Dependances le cas echeant

Exemple pour une fonctionnalite grossiere :
```
Fonctionnalite : Annonces de succes
- Resume : Intercepter les popups de succes et les lire a voix haute
- Complexite : Simple
- Depend de : Systeme d'annonces de base
```

**Definir les priorites :**

Question a l'utilisateur : Par quelle fonctionnalite devons-nous commencer ?

Principe directeur : Il vaut mieux commencer par les choses avec lesquelles on interagit en premier dans le jeu. Cela permet des tests precoces et le joueur peut vivre le jeu des le debut.

Ordre typique (a adapter selon le contexte !) :
1. Menu principal - Generalement le premier contact avec le jeu
2. Annonces de statut de base - Sante, ressources, etc.
3. Tutoriel (si present) - Introduit les mecaniques de jeu
4. Navigation de gameplay principal
5. Inventaire et sous-menus
6. Fonctionnalites speciales (Artisanat, Commerce, etc.)
7. Fonctionnalites optionnelles (Succes, Statistiques)

Cet ordre n'est qu'une suggestion. Selon le jeu, il peut etre judicieux de prioriser differemment :
- Certains jeux demarrent directement dans le gameplay sans menu principal
- Dans certains jeux le tutoriel est obligatoire et precede tout le reste
- Les annonces de statut peuvent aussi etre developpees en parallele d'autres fonctionnalites

**Avantages d'un plan bien reflechi :**
- Les dependances sont reconnues tot
- Les classes utilitaires communes peuvent etre identifiees
- Les decisions d'architecture sont prises une fois au lieu d'etre ad-hoc
- Meilleure vue d'ensemble du perimetre total

**Note :** Le plan peut et va changer. Certaines fonctionnalites s'averent plus faciles ou plus difficiles que prevu.

**Si AccessStateManager a ete decide a l'Etape 1.4 :** Utiliser le plan de fonctionnalites pour definir les entrees de l'enum State. Chaque fonctionnalite qui a besoin d'entrees exclusives obtient une valeur d'enum.

### Phase 2 : Framework de base

**PREREQUIS : La porte de completion du Tier 1 DOIT etre franchie !** (Voir ci-dessus)

1. Creer un projet C# avec les references du mod loader (MelonLoader ou BepInEx - voir `technical-reference.md` pour les deux)
2. Integrer Tolk pour la sortie lecteur d'ecran (ScreenReader.cs)
3. Creer le systeme de localisation (Loc.cs) - ceci fait partie du framework de base, PAS un ajout ulterieur. Si multilingue : utiliser la detection de langue du jeu analysee a l'Etape 1.5.
4. Si AccessStateManager a ete decide a l'Etape 1.4 : Creer depuis `templates/AccessStateManager.cs.template`
5. Creer un mod de base qui annonce `Loc.Get("mod_loaded")` au demarrage
6. Tester si le framework de base fonctionne

#### Flux de travail compilation-test

**IMPORTANT : Expliquer ce flux de travail a l'utilisateur la premiere fois qu'un cycle de compilation-test se produit (generalement pendant la Phase 2 lors du test de l'annonce basique "Mod charge"). C'est le cycle fondamental qui sera repete des centaines de fois tout au long du projet.**

Le flux de travail de developpement pour tester les modifications du mod :

1. **Ecrire/modifier le code** - Claude ecrit ou modifie le code source du mod
2. **Compiler** - Executer `dotnet build [NomDuMod].csproj` pour compiler le mod en DLL
3. **Copie automatique** - La DLL est automatiquement copiee dans le dossier de mods du jeu : `Mods/` pour MelonLoader ou `BepInEx/plugins/` pour BepInEx (si la cible CopyToMods est configuree dans le csproj)
4. **Demarrer le jeu** - Lancer le jeu normalement (le mod loader charge le mod automatiquement)
5. **Tester** - Verifier si la nouvelle fonctionnalite fonctionne comme prevu
6. **Fermer le jeu** - **Toujours fermer le jeu completement avant la prochaine compilation !** Le fichier DLL est verrouille tant que le jeu tourne.
7. **Rapporter** - Dire a Claude ce qui a fonctionne et ce qui n'a pas fonctionne. Etre specifique : "Ca dit X mais devrait dire Y" ou "Rien ne se passe quand j'appuie sur F2"
8. **Repeter** - Claude corrige les problemes selon vos retours, puis compiler et tester a nouveau

**Notes importantes pour l'utilisateur :**
- Vous devrez fermer et redemarrer le jeu pour chaque changement de code - il n'y a pas de "rechargement a chaud"
- Si le mod ne semble pas se charger du tout, verifier le log pour les erreurs : `MelonLoader/Latest.log` (MelonLoader) ou `BepInEx/LogOutput.log` (BepInEx)
- Si vous n'entendez rien du lecteur d'ecran mais que le log montre que le mod s'est charge : Verifier si les DLL Tolk sont au bon endroit et correspondent a l'architecture
- Les erreurs de compilation (echecs de compilation) sont affichees dans le terminal - Claude peut les lire et les corriger directement
- Les erreurs d'execution (crashs pendant le gameplay) apparaissent dans le log de MelonLoader

Pour les debutants : Pensez-y comme editer un document et l'imprimer. Vous faites des modifications, "imprimez" (compilez), puis verifiez l'impression (testez en jeu). Si quelque chose ne va pas, vous revenez editer a nouveau.

**Note :** La premiere compilation utilise `dotnet build` directement. Apres la Phase 2.5, des scripts de compilation/deploiement sont crees - a partir de ce moment, toujours utiliser les scripts.

### Phase 2.5 : Scripts de compilation/deploiement et mise a jour de CLAUDE.md (apres la premiere compilation reussie)

Apres la premiere compilation manuelle reussie, creer des scripts PowerShell pour que la compilation et le deploiement soient toujours a une commande. Puis mettre a jour CLAUDE.md pour referencer ces scripts.

#### Etape 1 : Creer les scripts de compilation/deploiement

Creer ces scripts dans le repertoire `scripts/` :

**`scripts/Build-Mod.ps1`** -- Compile le mod :
- Execute `dotnet build [NomDuMod].csproj`
- Rapporte le succes/echec clairement
- Affiche le chemin de la DLL de sortie

**`scripts/Deploy-Mod.ps1`** -- Compile et copie dans le repertoire du jeu :
- Appelle `Build-Mod.ps1`
- Copie la DLL de sortie dans le dossier de mods du jeu (`Mods/` pour MelonLoader, `BepInEx/plugins/` pour BepInEx)
- Copie optionnellement les fichiers supplementaires (par ex. fichiers de localisation, fichiers de configuration)
- Rapporte ce qui a ete copie et ou

**Exigences des scripts :**
- Utiliser des parametres pour les chemins afin que les scripts fonctionnent sans valeurs codees en dur (par ex. `-GamePath`, `-Configuration Debug/Release`)
- Les valeurs par defaut doivent correspondre a la configuration du projet pour que l'utilisateur puisse simplement executer `.\scripts\Deploy-Mod.ps1` sans arguments
- Inclure la gestion d'erreurs : si la compilation echoue, ne pas copier. Si le repertoire du jeu n'existe pas, avertir clairement.
- Garder les scripts simples - pas de sur-ingenierie. Ce sont des enveloppes de commodite.

**Exemple de structure pour Deploy-Mod.ps1 :**
```powershell
param(
    [string]$Configuration = "Debug",
    [string]$GamePath = "C:\Chemin\vers\Jeu"  # Remplir pendant la configuration
)

# Compiler
& "$PSScriptRoot\Build-Mod.ps1" -Configuration $Configuration
if ($LASTEXITCODE -ne 0) {
    Write-Error "La compilation a echoue."
    exit 1
}

# Copier la DLL dans le jeu
$dllPath = "bin\$Configuration\net472\NomDuMod.dll"
$targetDir = "$GamePath\Mods"  # Ajuster pour BepInEx : BepInEx\plugins

Copy-Item $dllPath $targetDir -Force
Write-Host "Deploye vers $targetDir"
```

#### Etape 2 : Mettre a jour CLAUDE.md

Mettre a jour la section "Environment" avec :
- Le chemin du repertoire du jeu
- L'architecture (32-bit/64-bit)
- Le mod loader (MelonLoader ou BepInEx)

**Remplacer le placeholder `Build` dans la section Coding Rules** par une reference aux scripts :

```markdown
## Build & Deploy

- Compiler : `.\scripts\Build-Mod.ps1`
- Compiler + copier dans le jeu : `.\scripts\Deploy-Mod.ps1`
```

**Ne PAS mettre de commandes `dotnet build` brutes dans CLAUDE.md.** Toujours utiliser les scripts - ils sont la source unique de verite pour la compilation et le deploiement.

Ajouter les notes specifiques au projet :
- Version du moteur (par ex. Unity 2021.3)
- Considerations speciales pour ce jeu
- Deviations par rapport aux patrons du template
- Particularites ou solutions de contournement connues

**Garder CLAUDE.md court et concis** - c'est uniquement pour Claude Code, pas de la documentation.

Exemple d'ajout :
```markdown
## Build & Deploy

- Compiler : `.\scripts\Build-Mod.ps1`
- Compiler + copier dans le jeu : `.\scripts\Deploy-Mod.ps1`

## Notes

- Unity 2021.3.5f1
- Utilise le systeme d'entrees legacy
- MainMenu n'a pas de classe de base, acces via MainMenuManager.instance
```

### Phase 3 : Developpement des fonctionnalites

**AVANT chaque nouvelle fonctionnalite :**
1. Consulter `docs/game-api.md` :
   - Verifier les associations de touches du jeu (pas de conflits !)
   - Utiliser les classes/methodes deja documentees
   - Reutiliser les patrons connus
   - **Verifier la section Analyse UI** - Comment acceder au texte pour ce type d'UI ?
2. Verifier l'entree du plan de fonctionnalites (dependances remplies ?)
3. Pour les menus : Parcourir `menu-accessibility-checklist.md`
4. **Pour les fonctionnalites UI :** Verifier si la Reflexion est necessaire (voir `docs/unity-reflection-guide.md`)
5. **Pour 3+ handlers sur les memes touches :** Considerer la gestion d'etat (voir `docs/state-management-guide.md`)

**Pourquoi la documentation API d'abord ?**
- Previent les conflits de touches avec le jeu
- Evite le travail en double (ne pas rechercher les methodes a nouveau)
- La coherence entre les fonctionnalites est maintenue
- Les patrons documentes peuvent etre directement reutilises
- **Les patrons d'acces UI sont deja resolus** - ne pas reinventer la roue

Voir `ACCESSIBILITY_MODDING_GUIDE.md` pour les patrons de code.

**Ordre des fonctionnalites :** Construire les fonctionnalites d'accessibilite dans l'ordre ou un joueur les rencontre dans le jeu :

1. **Menu principal** - Premier contact avec le jeu, navigation de base
2. **Menu des parametres** - Si accessible depuis le menu principal
3. **Annonces de statut generales** - Sante, argent, temps, etc.
4. **Tutoriel / Zone de depart** - Premiere experience de jeu
5. **Gameplay principal** - Les actions les plus frequentes
6. **Inventaire / Menus en jeu** - Menu pause, inventaire, carte
7. **Fonctionnalites speciales** - Artisanat, commerce, dialogues
8. **Endgame / Optionnel** - Succes, statistiques

---

## Scripts utilitaires

### Get-MelonLoaderInfo.ps1

Lit le log de MelonLoader et extrait toutes les valeurs importantes :
- Nom du jeu et Developpeur (pour l'attribut MelonGame)
- Type de runtime (pour le TargetFramework)
- Version Unity

**Utilisation :**
```powershell
.\scripts\Get-MelonLoaderInfo.ps1 -GamePath "C:\Chemin\vers\Jeu"
```

**Sortie :** Extraits de code prets a copier.

### Test-ModSetup.ps1

Verifie si tout est correctement configure :
- Installation du mod loader (MelonLoader ou BepInEx)
- DLL Tolk (verifie aussi la bonne architecture !)
- Fichier projet et references
- Attributs du mod loader (MelonGame ou BepInPlugin)
- Repertoire decompile

**Utilisation :**
```powershell
.\scripts\Test-ModSetup.ps1 -GamePath "C:\Chemin\vers\Jeu" -Architecture x64
```

Le parametre `-Architecture` peut etre `x64` ou `x86`.

**Sortie :** Liste de toutes les verifications avec OK, AVERTISSEMENT ou ERREUR, plus des suggestions de solution.

---

## Liens importants

- MelonLoader GitHub : https://github.com/LavaGang/MelonLoader
- MelonLoader Installer : https://github.com/LavaGang/MelonLoader.Installer/releases
- BepInEx GitHub : https://github.com/BepInEx/BepInEx
- BepInEx Releases : https://github.com/BepInEx/BepInEx/releases
- Tolk (lecteur d'ecran) : https://github.com/ndarilek/tolk/releases
- dnSpy (Decompilateur) : https://github.com/dnSpy/dnSpy/releases
- SDK .NET : https://dotnet.microsoft.com/download
