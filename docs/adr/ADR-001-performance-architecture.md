# ADR-001: Performance-Architektur

**Status:** accepted  
**Datum:** 2026-05-19

## Kontext

CityBuilder simuliert eine Stadt mit potenziell Tausenden von Gebäuden, Einwohnern und Netzwerken (Strom, Wasser, Verkehr). Die Simulation muss auf Web (Flutter Web / CanvasKit) und Android flüssig laufen.

Engpässe entstehen durch:
- Tick-Berechnungen (Wirtschaft, Nachfrage, Netzwerke) auf dem UI-Thread
- Render-Overhead durch viele Tile-Sprites
- GC-Druck durch viele kurzlebige Objekte

## Entscheidung

### Thread-Modell

| Berechnung | Thread | Begründung |
|------------|--------|------------|
| Simulation-Tick (Wirtschaft, Bevölkerung) | Dart Isolate | rechenintensiv, kein UI-Zugriff nötig |
| Netzwerk-Flood-Fill (Strom, Wasser) | Dart Isolate | O(n) über Karte, blockiert UI bei großen Karten |
| Verkehrs-Heatmap | Dart Isolate | aggregierte Berechnung, kein Frame-Sync nötig |
| Flame-Rendering | UI-Thread (main isolate) | Flame läuft zwingend im UI-Thread |
| Riverpod State Updates | UI-Thread | minimale Arbeit, nur Ergebnisse aus Isolate übertragen |

### Tick-Rate

- **Simulation:** 1 Hz (1 Tick/Sekunde) — entkoppelt von Framerate
- **Rendering:** unabhängig, Ziel ≥ 30 FPS im Browser
- **Isolate-Kommunikation:** Ergebnis-Snapshots per `SendPort`, kein Shared State

### Render-Budget

- **Frame-Budget:** 16 ms (60 FPS) / 33 ms (30 FPS)
- **Tile-Culling:** nur sichtbare Kacheln rendern (Viewport + 1-Tile-Puffer)
- **Sprite-Batching:** Flame SpriteBatch für gleichartige Tiles
- **Overlay-Rendering:** Overlays als separate Layer, nur bei aktivem Overlay gezeichnet

### Karten-Größe vs. Performance

| Kartengröße | Tiles gesamt | Sichtbar (1080p ca.) | Erwartete FPS |
|-------------|-------------|----------------------|---------------|
| 64 × 64     | 4.096        | ~500                 | ≥ 60          |
| 128 × 128   | 16.384       | ~500                 | ≥ 30          |
| 256 × 256   | 65.536       | ~500                 | ≥ 30*         |

*Mit Culling skaliert Render-Last mit Viewport, nicht Kartengröße.

## Konsequenzen

- Alle Simulation-Systeme (DemandSystem, PowerGridSystem, WaterGridSystem, TrafficSystem) werden als Isolate-Worker implementiert.
- `GameModel` ist ein unveränderlicher Snapshot (immutable), der nach jedem Tick vom Isolate erzeugt und via Riverpod ins UI gepusht wird.
- Kein direkter Zugriff auf Flutter-/Flame-Objekte aus Isolates — nur serialisierbare Datenstrukturen.
- Tests können Simulation-Logik ohne Flutter-Kontext testen (reiner Dart-Test).
