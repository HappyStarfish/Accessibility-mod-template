# [SPIELNAME] - Game API Documentation

## Übersicht

- **Spiel:** [SPIELNAME]
- **Engine:** Unity [VERSION]
- **Runtime:** [net35/net6 - aus MelonLoader-Log]
- **Architektur:** [32-Bit/64-Bit]
- **Entwickler:** [ENTWICKLERNAME - EXAKT aus MelonLoader-Log]

---

## 1. Singleton-Zugangspunkte

Die wichtigsten statischen Instanzen zum Zugriff auf Spielsysteme.

### Haupt-Controller

- `[Klassenname].instance` - [Beschreibung]
  - Wichtige Properties: [Liste]
  - Wichtige Methoden: [Liste]

### UI-Management

- `[UIManager].instance` - [Beschreibung]

### Spieler

- `[Player].instance` - [Beschreibung]

### [Weitere Kategorien nach Bedarf]

---

## 2. Spiel-Tastenbelegungen (NICHT im Mod überschreiben!)

**KRITISCH: Diese Tasten werden vom Spiel verwendet. Der Mod darf sie NICHT anderweitig belegen!**

### Bewegung

- **[Taste]**: [Funktion] (Datei.cs:Zeile)

### Aktionen

- **[Taste]**: [Funktion] (Datei.cs:Zeile)

### Menü-Navigation

- **[Taste]**: [Funktion] (Datei.cs:Zeile)

### Kamera

- **[Taste]**: [Funktion] (Datei.cs:Zeile)

### Maussteuerung

- **Linke Maustaste**: [Funktion]
- **Rechte Maustaste**: [Funktion]
- **Mittlere Maustaste**: [Funktion]
- **Mausrad**: [Funktion]

### Debug/Entwickler-Tasten

- **[Taste]**: [Funktion] - nur wenn [Bedingung]

---

## 3. Sichere Tasten für den Mod

Diese Tasten sind im Spiel NICHT belegt und können für Mod-Funktionen genutzt werden.

### Reserviert für Accessibility-Mod

- **Tab**: Navigation zwischen UI-Elementen
- **Enter**: Aktivieren/Bestätigen
- **Escape**: [Bereits vom Spiel genutzt? Dann NICHT hier listen]

### Frei verfügbar

- **F1**: Hilfe anzeigen
- **F2-F12**: [Liste der freien F-Tasten]
- **Ziffernblock 0-9**: Quick-Actions
- **[Weitere freie Tasten]**

### Mit Vorsicht verwenden

- **[Taste]**: [Grund zur Vorsicht]

---

## 4. UI-System

### UI-Basisklassen

- `[BasisKlasse]` - Gemeinsame Basisklasse für UI-Fenster
  - Öffnen: `[Methode]`
  - Schließen: `[Methode]`
  - Sichtbarkeit prüfen: `[Property/Methode]`

### Alle UI-Fenster

**Hauptmenü**
- Klasse: `[Klassenname]`
- Öffnen: `[Wie wird es geöffnet]`
- Wichtige Elemente: [Buttons, Listen, etc.]
- Besonderheiten: [Falls relevant]

**Inventar**
- Klasse: `[Klassenname]`
- Öffnen: `[Taste oder Methode]`
- Wichtige Elemente:
  - Item-Slots: `[Klassenname für Slots]`
  - Kategorien: [Falls vorhanden]
- Besonderheiten: [Falls relevant]

**Einstellungen**
- Klasse: `[Klassenname]`
- Öffnen: `[Wie]`
- Wichtige Elemente: [Slider, Toggles, etc.]

**[Weitere Fenster nach Bedarf...]**

### UI-Navigation

- Zurück-Navigation: `[Wie funktioniert Zurück?]`
- Fenster-Stack: `[Gibt es einen Stack?]`
- Modale Dialoge: `[Wie werden Dialoge angezeigt?]`

### Text-Komponenten

- Haupt-Text-Klasse: `[Text/TextMeshProUGUI/etc.]`
- Text setzen: `[Methode]`
- Tooltips: `[Klasse und Zugriff]`

---

## 5. Spielmechaniken - Feature-Katalog

### Spieler-Charakter

**Bewegung**
- Klasse: `[Controller-Klasse]`
- Steuerung: [WASD, Klick, etc.]
- Besonderheiten: [Sprint, Schleichen, etc.]

**Aktionen**
- Interagieren: `[Methode/Taste]`
- Angreifen: `[Methode/Taste]`
- [Weitere Aktionen]

**Status-Werte**
- Gesundheit: `[Property-Pfad]` - Min/Max: [Werte]
- [Weitere Status-Werte]

### Inventar-System

**Item-Struktur**
- Basisklasse: `[Klassenname]`
- Name: `[Property]`
- Beschreibung: `[Property]`
- Icon: `[Property]`
- Stapelbar: `[Property]`
- [Weitere Item-Eigenschaften]

**Inventar-Zugriff**
- Alle Items: `[Wie auf Items zugreifen]`
- Item hinzufügen: `[Methode]`
- Item entfernen: `[Methode]`
- Item verwenden: `[Methode]`

### Interaktions-System

- Interface: `[IInteractable oder ähnlich]`
- Interaktive Objekte finden: `[Methode]`
- Interaktion auslösen: `[Methode]`
- Interaktions-Reichweite: `[Property]`

### Quest/Aufgaben-System

- Aktive Quests: `[Zugriff]`
- Quest-Ziele: `[Struktur]`
- Quest-Fortschritt: `[Property]`
- Quest-Belohnungen: `[Zugriff]`

### Crafting/Bauen

- Rezepte: `[Zugriff auf alle Rezepte]`
- Rezept-Struktur:
  - Benötigte Items: `[Property]`
  - Ergebnis: `[Property]`
  - Kann hergestellt werden: `[Methode]`
- Crafting auslösen: `[Methode]`

### Kampf-System

- Angriff: `[Methode]`
- Schaden berechnen: `[Methode]`
- Ziel auswählen: `[Methode]`
- Aktuelle Waffe: `[Property]`

### Dialog-System

- Dialog starten: `[Methode]`
- Aktueller Dialog-Text: `[Property]`
- Dialog-Optionen: `[Zugriff]`
- Option auswählen: `[Methode]`

### Handel/Shop-System

- Shop öffnen: `[Methode]`
- Verfügbare Waren: `[Zugriff]`
- Kaufen: `[Methode]`
- Verkaufen: `[Methode]`
- Spieler-Währung: `[Zugriff]`

### Karten/Map-System

- Karte öffnen: `[Methode]`
- Aktuelle Position: `[Property]`
- Wegpunkte/Marker: `[Zugriff]`
- Schnellreise: `[Methode]`

### Fähigkeiten/Skills

- Skill-Liste: `[Zugriff]`
- Skill-Level: `[Property]`
- Skill verwenden: `[Methode]`
- Skill-Punkte: `[Property]`

### [Weitere spielspezifische Systeme...]

---

## 6. Status und Benachrichtigungen

### Spieler-Status

- Gesundheit: `[Zugriff]`
- [Weitere Status-Werte mit Zugriffspfad]

### Benachrichtigungs-System

- Nachricht anzeigen: `[Methode]`
- Nachricht-Typen: [Info, Warnung, Fehler, etc.]
- Aktive Nachrichten lesen: `[Zugriff]`

### Tooltips

- Tooltip-Klasse: `[Klassenname]`
- Aktueller Tooltip-Text: `[Property]`
- Tooltip für Item: `[Methode]`

---

## 7. Audio-System

- Haupt-AudioManager: `[Zugriff]`
- Sound abspielen: `[Methode]`
- Lautstärke-Einstellungen: `[Zugriff]`
- [Relevante Sound-Events für Feedback]

---

## 8. Speichern und Laden

- Speichern: `[Methode]`
- Laden: `[Methode]`
- Spielstand-Pfad: `[Falls bekannt]`
- Einstellungen speichern: `[Für Mod-Einstellungen relevant]`

---

## 9. Event-Hooks für Harmony-Patches

### UI-Events (beste Patch-Punkte)

**Fenster öffnen**
- `[Klasse].[Methode]` - Wird aufgerufen wenn [Beschreibung]
- Prefix/Postfix empfohlen: [Empfehlung]

**Fenster schließen**
- `[Klasse].[Methode]` - [Beschreibung]

**Selection ändern**
- `[Klasse].[Methode]` - Wird aufgerufen wenn Auswahl sich ändert

### Gameplay-Events

**Item aufnehmen**
- `[Klasse].[Methode]`

**Quest abschließen**
- `[Klasse].[Methode]`

**[Weitere relevante Events...]**

### Update-Loops

- `[Klasse].Update()` - [Was passiert dort, wann patchen?]
- `[Klasse].LateUpdate()` - [Beschreibung]

---

## 10. Lokalisierung

- Übersetzungs-Methode: `[Methode zum Abrufen von übersetztem Text]`
- Sprach-Dateien: `[Pfad/Format]`
- Fallback-Verhalten: `[Was passiert wenn Key nicht gefunden?]`

---

## 11. Code-Beispiele

### UI-Fenster prüfen

```csharp
// Prüfen ob ein bestimmtes Fenster offen ist
if ([UIManager].instance.[window].activeSelf)
{
    // Fenster ist offen
}
```

### Auf Spieler-Daten zugreifen

```csharp
var player = [Player].instance;
string health = $"Gesundheit: {player.[health]}/{player.[maxHealth]}";
```

### Items im Inventar durchgehen

```csharp
foreach (var item in [Inventory].instance.[items])
{
    string info = $"{item.[name]}: {item.[count]}";
}
```

### Interaktive Objekte finden

```csharp
// [Beispiel für das spezifische Spiel]
```

### Harmony-Patch Beispiel

```csharp
[HarmonyPatch(typeof([Klasse]), "[Methode]")]
class [Name]Patch
{
    static void Postfix([Parameter])
    {
        // Nach Original-Methode ausführen
    }
}
```

---

## 12. Bekannte Probleme und Workarounds

- **[Problem 1]**: [Beschreibung und Lösung]
- **[Problem 2]**: [Beschreibung und Lösung]

---

## 13. Noch nicht analysiert

Bereiche die noch untersucht werden müssen:

- [ ] [Bereich 1]
- [ ] [Bereich 2]
- [ ] [Bereich 3]

---

## Änderungshistorie

- **[Datum]**: Initiale Analyse
- **[Datum]**: [Was wurde hinzugefügt/geändert]
