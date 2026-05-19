# ADR-002: Art Style — flache 2D-Kacheln (Top-Down)

**Status:** accepted  
**Datum:** 2026-05-19

## Kontext

Die Roadmap lässt offen: isometrisch oder flache 2D-Top-Down-Ansicht?

**Optionen:**
1. Isometrisch (klassisch SimCity 2000)
2. Flach / Top-Down (SimCity 4, viele Indie-Citybuilder)

## Entscheidung

**Flache Top-Down-Ansicht** mit Pixel-Art-Tiles (32 × 32 px Basis).

Gründe:
- Einfachere Koordinaten-Konvertierung (keine isometrische Projektion nötig)
- Flame's `HasGridMovement` und Camera sind für kartesische Koordinaten optimiert
- Tile-Culling ist trivial (rechteckiger Viewport-Schnitt)
- Rendering-Performance besser (keine Tiefensortierung nötig)
- Leichtere Sprite-Erstellung (kein iso-Perspective-Winkel)
- Spätere Migration zu isometrisch möglich (nur Render-Layer, Simulation bleibt identisch)

## Kachelraster

- **Tile-Größe:** 32 × 32 px (Basiseinheit)
- **Standard-Kartengröße:** 128 × 128 Tiles
- **Weltkoordinate:** `(col, row)` integer-Index; `(0,0)` oben links
- **Screenkoordinate:** `worldToScreen(col, row) = Vector2(col * tileSize, row * tileSize)` (vor Kamera-Transform)

## Konsequenzen

- `WorldPosition` ist ein `(int col, int row)` Record; kein Float-Glitch bei Tile-Zugriff.
- `TileMapComponent` rendert Tiles in Rasterreihenfolge (row-major); Flame-Camera übernimmt Zoom/Pan.
- Isometrische Darstellung ist zu einem späteren Zeitpunkt als optionales Feature nachrüstbar.
