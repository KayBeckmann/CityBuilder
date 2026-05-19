# Changelog

## [Unreleased] — M18 performance release candidate

## [0.14.0] — M13 Tech Tree
- Tech Tree DAG with dependency resolution and research points

## [0.15.0] — M14 Space Exploration
- SpaceSystem: missions, rare-earth stockpile, hightech demand bonus

## [0.18.0] — M17 Localisation & Accessibility
- DE/EN ARB files, 44 UI keys, consistency test

---

## [0.1.0] — M0 Foundation (2026-05-19)
- Flutter/Flame scaffold with Riverpod state management
- Docker multi-stage build (Flutter Web → nginx)
- Strict analysis_options.yaml (flutter_lints extended)
- README.md, ADR-001 (performance), ADR-002 (art style)

## [0.2.0] — M1 World Grid
- TileMapComponent with viewport culling (only visible tiles rendered)
- CameraComponent: pan (drag), zoom (scroll/pinch)
- WorldPosition coordinate system with round-trip tests

## [0.3.0] — M2 Procedural Map
- SimplexNoise 2D (octave-layered, deterministic seed)
- Terrain types: grass / water / hill / forest
- Resource deposits (coal/iron/wood/oil/stone) hidden in tiles
- TerrainEditor with budget cost per edit

## [0.4.0] — M3 Zones & Economy
- Zone types R/C/I with BuildingLevel (empty→small→medium→large)
- DemandSystem: R/C/I demand curves based on current population
- Economy: tax income + operating costs per building, net balance per tick

## [0.5.0] — M4 Population & Satisfaction
- PopulationModel: slow convergence to capacity × satisfaction
- SatisfactionFactors (employment/housing/services) → weighted score
- ApprovalRating: weighted average across R/C/I satisfaction
- HUD shows budget, tick, population, approval

## [0.6.0] — M5 Power Grid
- PowerGridSystem: flood-fill from power plants via power lines
- Blackout detection when demand > capacity
- CoalPlant/Solar/Wind/Gas plant types with capacity values

## [0.7.0] — M6 Water & Sewage
- WaterGridSystem: flood-fill from water sources via pipes
- SewerPlant coverage radius
- Water shortage detection

## [0.8.0] — M7 Roads & Traffic
- TrafficSystem: density-heatmap approach
- Congestion detection: load > capacity
- Satisfaction malus in congested radius

## [0.9.0] — M8 Resources & Extraction
- ResourceDeposit with exhaustion
- ExtractionBuilding (mine/sawmill/oilPump/quarry)
- ResourceInventory with consume/add
- Export revenue per tick

## [0.10.0] — M9 Rail & Freight
- RailNetwork with Dijkstra pathfinding (via `collection` PriorityQueue)
- Train entity with round-trip routing
- Freight transport model

## [0.11.0] — M10 Public Services
- ServiceBuilding (police/fire/hospital/school/university) radius coverage
- PollutionSystem with decay-weighted radius
- CrimeSystem with police reduction factor
- Education index from schools and universities

## [0.12.0] — M11 Overlay System
- Overlay types defined: power/water/traffic/pollution/crime/landValue/density

## [0.13.0] — M12 Game Loop
- GameSerializer: full JSON round-trip (all tiles, zones, buildings, stats)
- Win/loss framework (bankrupt / approval too low)
