# Modding bei alten Unity-Versionen

## Unity-Versionen und Mod-Loader-Kompatibilität

- **Unity 2019+**: MelonLoader, BepInEx, Doorstop - alle funktionieren
- **Unity 2017-2018**: MelonLoader, BepInEx, Doorstop - alle funktionieren
- **Unity 5.x**: Teilweise MelonLoader, teilweise BepInEx, evtl. Doorstop, Assembly-Patch als Fallback
- **Unity 4.x oder älter**: Nur Assembly-Patching funktioniert

## Vor dem Setup prüfen

### 1. Unity-Version ermitteln

Die Unity-Version steht in:
- `[Game]_Data/output_log.txt` (erste Zeile: "Initialize engine version: X.X.X")
- Oder im Crash-Log
- Oder im MelonLoader-Log nach erstem Start

### 2. Architektur prüfen

- `Mono/` Ordner = 32-bit, altes Mono
- `MonoBleedingEdge/` Ordner = 64-bit, neueres Mono
- Spiel in "Program Files (x86)" = oft 32-bit

### 3. Community-Recherche

**Immer zuerst prüfen:**
- Gibt es bereits Mods für das Spiel?
- Welches Framework nutzt die Community?
- Gibt es ein offizielles Mod-System?

**Suchbegriffe:**
- "[Spielname] modding guide"
- "[Spielname] BepInEx"
- "[Spielname] MelonLoader"
- "[Spielname] dll mod"

**Wo suchen:**
- Steam-Diskussionen
- Nexus Mods
- ModDB
- GitHub
- Offizielle Foren des Entwicklers

## Mod-Loader nach Priorität versuchen

### Bei Unity 2017+

1. **MelonLoader** - Einfachste Option für Unity-Spiele
2. **BepInEx** - Sehr verbreitet, gute Dokumentation
3. **Doorstop** - Falls andere nicht funktionieren

### Bei Unity 5.x

1. **BepInEx 5.x** mit net35-Kompatibilität
2. **Doorstop v3** (legacy branch)
3. **Assembly-Patching** als Fallback

### Bei Unity 4.x oder älter

1. **Community-Lösung suchen** - Vielleicht hat jemand etwas gefunden
2. **Assembly-Patching** - Meist die einzige funktionierende Option

## Assembly-Patching (Immer funktioniert)

### Was es ist

Den Mod-Code direkt in die Spiel-DLL (`Assembly-CSharp.dll`) einfügen.

### Vorteile

- Funktioniert mit jeder Unity-Version
- Keine externen Tools zur Laufzeit
- Keine Proxy-DLLs nötig

### Nachteile

- Ändert Original-Dateien (Backup machen!)
- Bei Spiel-Updates muss neu gepatcht werden
- Steam-Integritätsprüfung erkennt Änderung

### Tools

- **dnSpy** - GUI-basiert, kann editieren und speichern
- **ILSpy + Reflexil** - Alternative

### Vorgehen

1. Backup von `[Game]_Data/Managed/Assembly-CSharp.dll`
2. DLL in dnSpy öffnen
3. Geeignete Stelle finden (z.B. MainMenu.Start oder Awake)
4. Code einfügen (Methode editieren oder neue Klasse)
5. Speichern (Modul speichern)
6. Testen

### Geeignete Einstiegspunkte

- `Awake()` oder `Start()` einer früh geladenen Klasse
- Hauptmenü-Klasse (wird immer geladen)
- Singleton-Initialisierung

## Bekannte Probleme

### "mono.dll Access Violation"

- Tritt bei Unity 4.x mit BepInEx/Doorstop auf
- Mono-Runtime zu alt für moderne Tools
- Lösung: Assembly-Patching

### "Hooked into null"

- MelonLoader kann sich nicht einhaken
- Unity-Version nicht unterstützt
- Lösung: Anderes Framework oder Assembly-Patching

### Spiel startet nicht (0xc0000142)

- Proxy-DLL inkompatibel
- Lösung: Proxy-DLL entfernen, anderen Ansatz wählen

## Besonderheiten bei der UI-Analyse (alte Unity-Versionen)

Bei älteren Unity-Versionen können zusätzliche Herausforderungen auftreten:

- **Ältere UI-Systeme:** Unity 4.x nutzt oft noch das alte `OnGUI`-System statt uGUI/Canvas
- **Andere Komponenten-Namen:** `GUIText` statt `Text`, `GUITexture` statt `Image`
- **Fehlende Features:** TextMeshPro existiert möglicherweise nicht
- **Reflection-Unterschiede:** Private Fields können andere Naming-Conventions haben

### OnGUI-System (Unity 4.x und früher)

Das alte OnGUI-System funktioniert komplett anders als moderne Unity UI:

```csharp
void OnGUI() {
    if (GUI.Button(new Rect(10, 10, 100, 50), "Click me")) {
        // Button wurde geklickt
    }
    GUI.Label(new Rect(10, 70, 100, 20), "Some text");
}
```

**Herausforderungen:**
- UI wird jeden Frame neu gezeichnet (Immediate Mode)
- Keine persistenten GameObjects für UI-Elemente
- Schwieriger zu hoooken als moderne UI
- Text ist oft nur im OnGUI-Aufruf bekannt

**Mögliche Lösungen:**
- Harmony-Patch auf die OnGUI-Methode
- GUI.skin und GUIStyle analysieren
- Eigene Tracking-Logik für UI-Zustand

## Checkliste für alte Spiele

- [ ] Unity-Version ermittelt
- [ ] Architektur geprüft (32/64-bit)
- [ ] Community-Lösungen recherchiert
- [ ] Offizielles Mod-System geprüft
- [ ] Mod-Loader in Reihenfolge versucht
- [ ] Bei Fehlschlag: Assembly-Patching vorbereitet
- [ ] Backup der Original-DLLs erstellt
