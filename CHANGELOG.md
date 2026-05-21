# Changelog

All notable changes to CityBuilder are documented here.

## [Unreleased] — M18 Release Candidate

### Performance
- `TileMap._version` counter: increments on every mutation; minimap now skips
  repaints when map version has not changed (was: always repaint every frame)
- `TileMap.computePoweredTiles()` / `computeWateredTiles()`: flood-fill results
  cached per version; only recomputed after a map mutation
- Service building sprites (police, school, fire, hospital, spaceport) render
  via `SpriteRegistry.namedSprite()` with canvas fallback

### Build
- `CHANGELOG.md` added
- `flutter test` — 130 tests passing, 0 failures

---

## M9 — Rail Network

- `hasRailTrack` + `hasStation` tile flags; `TileMap.setRailTrack()` / `setStation()`
- Rail track ($400) and station ($8k) ToolTypes with icons and colors
- `GameNotifier.placeRailTrack()` / `placeStation()`
- Satisfaction bonus: +0.04 per station (max +0.10 to services)
- Rendering: `rail_h.png` / `rail_v.png` sprites with horizontal neighbor detection; canvas fallback
- Station fallback: brown building with roof triangle
- Serializer: 'rt' / 'st' tile flags
- Tool palette updated with rail group

---

## M8 — Resource Extraction

- `extractionBuilding` + `resourceRemaining` tile fields
- Mine ($5k), Sawmill ($4k), OilPump ($6k), Quarry ($3.5k) tools
- `GameNotifier.placeExtractionBuilding()` + `demolishInfra()` removes extraction
- Each tick: extracts per-building output, sells all inventory at market prices
- Market: coal $20, iron $15, wood $10, oil $30, stone $8
- `ResourceInventory` in `GameModel`; serialized as JSON map
- Depletion overlay: tile darkens when < 200 units remain
- Tile inspector shows extraction buildings with depletion state
- `ExtractionBuildingType.label` getter for German display names

---

## M17 — Accessibility & Localization

- `LocaleNotifier`/`localeProvider` Riverpod notifier for runtime locale switching
- DE/EN language buttons wired in Settings screen
- Font-size slider (80–140%) in Settings screen
- `CityBuilderApp` converted to `ConsumerWidget`; locale from Riverpod
- ARB files (`app_de.arb` + `app_en.arb`) — 48 localized string keys

---

## M16 — Graphics

- Service building PNG sprites rendered on the game map (canvas fallback)
- Spaceport sprite rendered via `namedSprite`
- `SpriteRegistry.namedSprite(path)` public accessor

---

## M15 — Audio

- `flame_audio ^2.10.0`; `AudioManager` uses `FlameAudio.bgm` + `FlameAudio.play`
- Silent placeholder MP3 files for 3 music tracks and 6 SFX
- Music auto-changes with population thresholds (5k → metropolis, 50k → space_age)
- SFX: build, demolish, milestone

---

## M14 — Space Exploration

- `SpacePhaseState` in `GameModel`; serialized; `hasSpaceport` tile flag
- `ToolType.spaceport` ($50k, requires spaceportPrep research)
- `GameNotifier.launchMission()` queues missions by tick count
- Space trigger: pop ≥ 500k + spaceport built + spaceportPrep researched
- Rare-earth income bonus (+$200/point/tick)
- `SpacePanel` widget + HUD rocket button

---

## M13 — Tech Tree

- `TechTreeState` persisted in `GameModel.copyWith` + serializer
- Research generates points from schools each tick
- `asphaltRoads`: +0.05 housing satisfaction; `hightechIndustry`: +5% tax income
- `TechPanel` widget with progress bars, dep chips, Start buttons + HUD button

---

## [1.0.0] — M18 Release Candidate (2026-05-19)

### Performance & Infrastruktur
- QM-Skript `scripts/check_quality.sh` (analyze → format → test → web-build)
- Release-Web-Build: `flutter build web --release` ✓ (main.dart.js 2.4 MB)
- Android Release-Build: `flutter build apk --debug` ✓ via Gradle 8.13 / AGP 8.11

---

## [0.18.0] — M17 Lokalisierung & Accessibility (2026-05-19)

- `flutter_localizations` + `intl` integriert
- `l10n.yaml` + `flutter gen-l10n`: `AppLocalizations` aus DE/EN-ARB generiert
- `CityBuilderApp`: `localizationsDelegates` + `supportedLocales`
- `AccessibilitySettings`: ColorBlindMode (none/deuteranopia/protanopia), fontSize-Scale
- `AccessibilityNotifier`: `adaptColor()` via HSL-Hue-Shift
- `SettingsScreen`: Farbblindheits-Radio-Gruppe

---

## [0.17.0] — M16 Finale Pixel-Art (2026-05-19)

- `SpriteRegistry` Singleton: 27 Sprites aus `assets/tiles/` per Lazy-Loading
- `TileMapComponent`: Terrain- und Gebäude-Sprites; Fallback auf debugColor
- `disableForTest()`: verhindert Asset-Loading im Test-Kontext

---

## [0.16.0] — M15 Audio-System (2026-05-19)

- `AudioManager`: musicVolume, sfxVolume, muted (Riverpod NotifierProvider)
- 3 Music-Tracks (earlyCity/metropolis/spaceAge), 6 SFX-Slots
- `trackForPopulation()`: Track-Wahl nach Stadtgröße
- `SettingsScreen`: Volume-Slider (Musik + SFX), Mute-Toggle
- HUD: Mute-Button + Settings-Icon

---

## [0.15.0] — M11 Overlay-System & Transit (2026-05-19)

- `OverlayType` enum (8 Typen): none/power/water/traffic/pollution/crime/landValue/populationDensity
- `computeOverlayValues()`: Heatmap aus GameModel
- `TileMapComponent`: Overlay-Heatmap (Color.lerp low→high) + Zone-Tint im Normal-Modus
- Overlay-Toolbar (Wrap mit Toggle-Chips) + Legende (Gradient-Bar)
- HUD erweitert: Einwohnerzahl + Approval-Rating (farbcodiert) + Takt
- `CityGame.updateOverlay()` Bridge Flutter→Flame

---

## [0.14.0] — M13 Tech Tree (2026-05-19)

- `TechTreeState` DAG mit Abhängigkeiten, Forschungspunkten, Population-Voraussetzungen

---

## [0.13.0] — M12 Spiellogik (2026-05-19)

- `GameSerializer`: vollständiger JSON-Round-Trip (Tiles, Zonen, Budget, Population)

---

## [0.12.0] — M11 Overlay-Typen definiert (2026-05-19)

- Overlay-Typen als Enum angelegt (Implementierung in v0.15.0)

---

## [0.11.0] — M10 Services & Simulation (2026-05-19)

- `ServicesSystem` (Polizei/Feuerwehr/Krankenhaus, Bildungsindex)
- `PollutionSystem` (Decay-Radius)
- `CrimeSystem` (Polizei-Reduktionsfaktor)

---

## [0.10.0] — M9 Schienennetz & Güter (2026-05-19)

- `RailNetwork` mit Dijkstra-Routing (collection PriorityQueue)
- `Train`-Entity mit Rundreis-Routing

---

## [0.9.0] — M8 Rohstoffabbau & Export (2026-05-19)

- `ResourceSystem`: Mine/Sägewerk/Ölpumpe/Steinbruch, Erschöpfung, Export-Erlös
- `ResourceInventory`: add/consume

---

## [0.8.0] — M7 Straßen & Verkehr (2026-05-19)

- `TrafficSystem`: Dichte-Heatmap, Stau-Erkennung, Satisfaction-Malus

---

## [0.7.0] — M6 Wasser & Abwasser (2026-05-19)

- `WaterGridSystem`: Flood-Fill + Sewage-Coverage-Radius

---

## [0.6.0] — M5 Stromnetz (2026-05-19)

- `PowerGridSystem`: Flood-Fill von Kraftwerken via Stromleitungen, Blackout-Erkennung

---

## [0.5.0] — M4 Einwohner & Zufriedenheit (2026-05-19)

- `PopulationModel`: langsame Konvergenz zu Kapazität × Satisfaction
- `SatisfactionFactors` (employment/housing/services), Approval-Rating

---

## [0.4.0] — M3 Zonen & Grundwirtschaft (2026-05-19)

- Zonen R/C/I mit `BuildingLevel` (empty→small→medium→large)
- `DemandSystem`: Nachfragekurven nach Stadtgröße
- Wirtschaft: Steuereinnahmen + Betriebskosten pro Tick

---

## [0.3.0] — M2 Prozedurale Karte (2026-05-19)

- `SimplexNoise` (deterministisch per Seed, Octaves)
- Terrain: grass/water/hill/forest; Rohstoffvorkommen
- `TerrainEditor` mit Budget-Kosten

---

## [0.2.0] — M1 Spielwelt (2026-05-19)

- `TileMapComponent` mit Viewport-Culling
- `CameraComponent`: Pan (Drag), Zoom (Scroll/Pinch)
- `WorldPosition` Koordinatensystem

---

## [0.1.0] — M0 Projektfundament (2026-05-19)

- Flutter/Flame-Grundgerüst, Riverpod State Management
- Docker-Compose (Flutter Web → nginx, multi-stage Build)
- Strenge `analysis_options.yaml`, README, ADR-001/002
