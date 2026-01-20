MENÜ-ACCESSIBILITY CHECKLISTE
==============================

VOR der Implementierung von Tastaturnavigation für ein Menü IMMER diese Schritte durchführen:


1. STRUKTUR VERSTEHEN
---------------------
- Wie ist das Menü aufgebaut? (Linear, Grid, hierarchisch)
- Welche Elemente gibt es? (Buttons, Auswahlboxen, Slider, Eingabefelder)
- Welche Eltern-Kind-Beziehungen existieren?


2. INTERAKTIONSMUSTER ANALYSIEREN
---------------------------------
- Wie wird jedes Element aktiviert? (Klick, Doppelklick, Hover)
- Wie werden Werte geändert? (scrollBy, increment, toggle)
- Welche Events/Handler existieren bereits? (clickReleased, scrollBy, keyPressed)

WICHTIG: Bestehende Methoden wiederverwenden, nicht neu erfinden!


3. BESTEHENDE ACCESSIBILITY-SYSTEME PRÜFEN
------------------------------------------
- Gibt es bereits FocusManager, IFocusable, oder ähnliches?
- Welche Elemente sind schon registriert?
- Wie werden Ansagen bereits gemacht? (ScreenReader-Klasse)


4. NAVIGATIONSKONZEPT FESTLEGEN
-------------------------------
- Hoch/Runter: zwischen Elementen navigieren
- Links/Rechts: Werte ändern (bei Auswahlboxen) oder innerhalb von Gruppen navigieren
- Enter: Aktivieren/Öffnen
- Escape: Zurück/Schließen


5. ANSAGETEXTE PRÜFEN
---------------------
- Sind alle Labels sinnvolle natürlichsprachliche Ausdrücke?
- Nicht leer, nicht "item123", nicht kontextfremd
- Enthält die Ansage den aktuellen Wert/Zustand?


6. INKREMENTELL TESTEN
----------------------
- Nach jeder Änderung testen, nicht alles auf einmal
- Erst ein Element vollständig funktionsfähig machen, dann das nächste


BEISPIEL-WORKFLOW
=================

Angenommen, ein Menü hat folgende Elemente:
- 3 Buttons (Start, Optionen, Beenden)
- 1 Auswahlbox für Schwierigkeit (Leicht, Mittel, Schwer)
- 1 Slider für Lautstärke

Schritt 1: Code analysieren
- Buttons nutzen clickReleased() für Aktivierung
- Auswahlbox nutzt scrollBy() für Wertwechsel
- Slider nutzt setValue() mit Mausposition

Schritt 2: Bestehende Systeme finden
- FocusManager existiert bereits
- IFocusable Interface vorhanden
- ScreenReader::speakInterruptible() für Ansagen

Schritt 3: Implementieren
- Buttons: IFocusable implementieren, simulateClick() ruft clickReleased() auf
- Auswahlbox: onArrowKey() ruft scrollBy() auf
- Slider: onArrowKey() ruft setValue() mit +/- 10% auf

Schritt 4: Testen
- Jeden Button einzeln testen
- Auswahlbox: Links/Rechts ändert Wert?
- Slider: Links/Rechts ändert Wert?
- Ansagen korrekt?
