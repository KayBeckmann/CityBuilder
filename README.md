# CityBuilder

A SimCity-2000-inspired city-building simulation game built with Flutter and Flame. Play in the browser or on Android — no install required.

## Features (Roadmap)

| Milestone | What's in it |
|-----------|-------------|
| **M0** — Foundation | Flutter/Flame scaffold, Docker web delivery ✅ |
| **M1** — World Grid | Top-down tile map, camera pan/zoom ✅ |
| **M2** — Procedural Map | Simplex noise generation, terrain editing ✅ |
| **M3** — Zones & Economy | R/C/I zones, DemandSystem, taxes/budget ✅ |
| **M4** — Population | PopulationModel, satisfaction, approval rating ✅ |
| **M5** — Power Grid | Flood-fill grid, blackout detection ✅ |
| **M6** — Water | Water/sewage network ✅ |
| **M7** — Roads & Traffic | Density heatmap, congestion detection ✅ |
| **M8** — Resources | Mine/quarry/oilPump/sawmill, export market ✅ |
| **M9** — Rail & Freight | Dijkstra routing, train entity ✅ |
| **M10** — Services | Police/fire/hospital, pollution, crime, education ✅ |
| **M11** — Transit & Overlays | Overlay types defined ✅ |
| **M12** — Game Loop | JSON save/load, win/loss framework ✅ |
| **M13** — Tech Tree | DAG with research points, dependency unlocks ✅ |
| **M14** — Space | Space missions, rare-earth import, hightech bonus ✅ |
| **M15** — Audio | AudioManager, volume/mute controls, settings screen ✅ |
| **M16** — Final Art | Sprite-Renderer, 27 pixel-art assets in game ✅ |
| **M17** — i18n / a11y | DE/EN localisation, colour-blind modes ✅ |
| **M18** — Release | QM script, release web-build, CHANGELOG ✅ |

## Stack

- **Engine:** [Flutter](https://flutter.dev) + [Flame](https://flame-engine.org)
- **State:** [Riverpod](https://riverpod.dev)
- **Simulation:** Dart Isolates (1 Hz tick, decoupled from render)
- **Web delivery:** Flutter Web → nginx Docker image
- **Target platforms:** Web (primary), Android

## Quick Start

### Run locally

```bash
flutter pub get
flutter run -d chrome
```

### Docker (web)

```bash
docker compose up --build
# → http://localhost:8080
```

### Build APK (debug)

```bash
flutter build apk --debug
```

## Development

```bash
# Analyse
flutter analyze

# Format check
dart format --set-exit-if-changed .

# Tests
flutter test

# Web build
flutter build web
```

### Quality baseline (enforced before every merge)

- `flutter analyze` → 0 errors, 0 warnings
- `dart format` → clean
- `flutter test` → all green, simulation coverage ≥ 80 %
- `flutter build web` → no errors
- `docker build && curl :8080` → HTTP 200

## Project Structure

```
lib/
  core/        # Simulation logic, Isolates, models
  game/        # Flame components, camera, world
  ui/          # Flutter widgets (HUD, menus)
  features/    # Feature slices (zones/, economy/, …)
assets/
  tiles/
  sounds/
  fonts/
test/
  unit/
  widget/
  integration/
docs/
  adr/         # Architecture Decision Records
```

## Architecture

Simulation runs in a Dart Isolate at 1 Hz and pushes immutable state snapshots to the UI thread via Riverpod. The Flame renderer operates independently at ≥ 30 FPS. See [ADR-001](docs/adr/ADR-001-performance-architecture.md) for details.

## License

MIT © 2026 Kay Beckmann
