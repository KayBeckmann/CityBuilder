# CityBuilder

A SimCity-2000-inspired city-building simulation game built with Flutter and Flame. Play in the browser or on Android — no install required.

## Features (Roadmap)

| Milestone | What's in it |
|-----------|-------------|
| **M0** — Foundation | Flutter/Flame scaffold, Docker web delivery ✅ |
| **M1** — World Grid | Isometric tile map, camera controls |
| **M2** — Procedural Map | Noise-based generation, terrain editing |
| **M3** — Zones & Economy | Residential/Commercial/Industrial zones, taxes, budget |
| **M4** — Population | Residents, satisfaction, land value |
| **M5** — Power Grid | Power plants, grid simulation, blackouts |
| **M6** — Water | Water network, sewage |
| **M7** — Roads & Traffic | Road builder, congestion heatmap |
| **M8** — Resources | Mining, processing chains, export market |
| **M9** — Rail & Freight | Train network, visible trains |
| **M10** — Services | Police, fire, hospital; crime, pollution, education |
| **M11** — Transit & Overlays | Bus/subway, full overlay system |
| **M12** — Game Loop | Save/load, win/loss, events |
| **M13** — Tech Tree | Research unlocks new buildings |
| **M14** — Space | Spaceport, off-world resources |
| **M15** — Audio | Music, ambience, SFX |
| **M16** — Final Art | Pixel-art assets replace placeholders |
| **M17** — i18n / a11y | DE/EN localisation, colour-blind modes |
| **M18** — Release | Performance polish, release build |

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
