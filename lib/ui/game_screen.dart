import 'dart:async';

import 'package:city_builder/core/audio_manager.dart';
import 'package:city_builder/core/overlay_type.dart';
import 'package:city_builder/core/resource_system.dart';
import 'package:city_builder/core/world_position.dart';
import 'package:city_builder/features/game_providers.dart';
import 'package:city_builder/features/notification_provider.dart';
import 'package:city_builder/features/overlay_provider.dart';
import 'package:city_builder/features/time_provider.dart';
import 'package:city_builder/features/tool_provider.dart';
import 'package:city_builder/game/city_game.dart';
import 'package:city_builder/ui/budget_panel.dart';
import 'package:city_builder/ui/game_over_screen.dart';
import 'package:city_builder/ui/help_overlay.dart';
import 'package:city_builder/ui/minimap.dart';
import 'package:city_builder/ui/game_toolbar.dart';
import 'package:city_builder/ui/new_game_dialog.dart';
import 'package:city_builder/ui/save_load_dialog.dart';
import 'package:city_builder/ui/settings_screen.dart';
import 'package:city_builder/ui/tax_panel.dart';
import 'package:city_builder/ui/space_panel.dart';
import 'package:city_builder/ui/tech_panel.dart';
import 'package:city_builder/ui/tile_info_panel.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key, required this.game});

  final CityGame game;

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  Timer? _tickTimer;
  var _showBudget = false;
  var _showTaxPanel = false;
  var _showTechPanel = false;
  var _showSpacePanel = false;
  var _showTileInfo = false;
  var _tileInfoPos = (col: 0, row: 0);
  var _gameOver = false;
  var _showHelp = false;
  var _showMinimap = false;

  @override
  void initState() {
    super.initState();

    // Wire tile-tap callback into the game
    widget.game.onTileTapOverride = _handleTileTap;

    // Load initial map
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final model = ref.read(gameProvider);
      widget.game.loadMap(model.tileMap);
      // Show new-game dialog on first run
      if (mounted) NewGameDialog.show(context);
    });
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    super.dispose();
  }

  void _handleTileTap(WorldPosition tilePos) {
    final tool = ref.read(toolProvider);
    final notifier = ref.read(gameProvider.notifier);

    switch (tool) {
      case ToolType.inspect:
        setState(() {
          _showTileInfo = true;
          _tileInfoPos = tilePos;
        });
        return;

      case ToolType.zoneResidential:
      case ToolType.zoneCommercial:
      case ToolType.zoneIndustrial:
        final zone = tool.zone;
        if (zone != null) {
          final ok = notifier.setZone(tilePos, zone);
          if (!ok) _flashError('Nicht genug Budget!');
        }

      case ToolType.demolishZone:
        notifier.setZone(tilePos, null);

      case ToolType.demolishInfra:
        notifier.demolishInfra(tilePos);

      case ToolType.demolishAll:
        if (!notifier.demolishAll(tilePos)) {
          _flashError('Nicht genug Budget!');
        }

      case ToolType.park:
        if (!notifier.placePark(tilePos)) _flashError('Nicht genug Budget!');

      case ToolType.policeStation:
        if (!notifier.placePoliceStation(tilePos)) _flashError('Nicht genug Budget!');

      case ToolType.hospital:
        if (!notifier.placeHospital(tilePos)) _flashError('Nicht genug Budget!');

      case ToolType.school:
        if (!notifier.placeSchool(tilePos)) _flashError('Nicht genug Budget!');

      case ToolType.fireStation:
        if (!notifier.placeFireStation(tilePos)) _flashError('Nicht genug Budget!');

      case ToolType.powerPlant:
        if (!notifier.placePowerPlant(tilePos)) _flashError('Nicht genug Budget!');

      case ToolType.waterTower:
        if (!notifier.placeWaterTower(tilePos)) _flashError('Nicht genug Budget!');

      case ToolType.spaceport:
        if (!notifier.placeSpaceport(tilePos)) {
          _flashError('Nicht genug Budget oder Raumfahrtbasis nicht erforscht!');
        }

      case ToolType.railTrack:
        if (!notifier.placeRailTrack(tilePos)) _flashError('Nicht genug Budget!');

      case ToolType.station:
        if (!notifier.placeStation(tilePos)) _flashError('Nicht genug Budget!');

      case ToolType.mine:
        if (!notifier.placeExtractionBuilding(
            tilePos, ExtractionBuildingType.mine)) {
          _flashError('Nicht genug Budget!');
        }
      case ToolType.sawmill:
        if (!notifier.placeExtractionBuilding(
            tilePos, ExtractionBuildingType.sawmill)) {
          _flashError('Nicht genug Budget!');
        }
      case ToolType.oilPump:
        if (!notifier.placeExtractionBuilding(
            tilePos, ExtractionBuildingType.oilPump)) {
          _flashError('Nicht genug Budget!');
        }
      case ToolType.quarry:
        if (!notifier.placeExtractionBuilding(
            tilePos, ExtractionBuildingType.quarry)) {
          _flashError('Nicht genug Budget!');
        }

      case ToolType.road:
        if (!notifier.placeRoad(tilePos)) _flashError('Nicht genug Budget!');

      case ToolType.powerLine:
        if (!notifier.placePowerLine(tilePos)) _flashError('Nicht genug Budget!');

      case ToolType.pipe:
        if (!notifier.placePipe(tilePos)) _flashError('Nicht genug Budget!');

      case ToolType.terrainGrass:
      case ToolType.terrainForest:
      case ToolType.terrainHill:
      case ToolType.terrainWater:
        final terrain = tool.terrain;
        if (terrain != null) {
          if (!notifier.editTerrain(tilePos, terrain)) {
            _flashError('Nicht genug Budget!');
          }
        }
    }

    // Refresh overlay
    _refreshOverlay();
  }

  void _refreshOverlay() {
    final overlay = ref.read(overlayProvider);
    if (overlay != OverlayType.none) {
      final tileMap = ref.read(gameProvider).tileMap;
      widget.game.updateOverlay(overlay, computeOverlayValues(tileMap, overlay));
    }
  }

  void _flashError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.red[900],
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
      ),
    );
  }

  void _handleSpeedChange(GameSpeed speed) {
    if (_gameOver) return;
    ref.read(timeProvider.notifier).setSpeed(speed);
    _tickTimer?.cancel();
    final interval = speed.intervalMs;
    if (interval != null) {
      _tickTimer = Timer.periodic(
        Duration(milliseconds: interval),
        (_) {
          ref.read(gameProvider.notifier).tick();
          _refreshOverlay();
          _syncMapToGame();
          if (ref.read(gameProvider).isGameOver) {
            _tickTimer?.cancel();
            setState(() => _gameOver = true);
          }
        },
      );
    }
  }

  void _triggerNewGame() {
    _tickTimer?.cancel();
    setState(() => _gameOver = false);
    NewGameDialog.show(context);
  }

  void _syncMapToGame() {
    final model = ref.read(gameProvider);
    widget.game.loadMap(model.tileMap);
  }

  @override
  Widget build(BuildContext context) {
    final budget = ref.watch(gameProvider.select((m) => m.budget));
    final model = ref.watch(gameProvider);
    final population = model.population.total;
    final approval = model.approvalRating;
    final overlay = ref.watch(overlayProvider);
    final tool = ref.watch(toolProvider);
    final speed = ref.watch(timeProvider);
    final audioMuted = ref.watch(audioProvider.select((s) => s.muted));

    // Sync overlay changes to game
    ref.listen(overlayProvider, (_, next) {
      final tileMap = ref.read(gameProvider).tileMap;
      widget.game.updateOverlay(next, computeOverlayValues(tileMap, next));
    });

    // Sync new game map to Flame; reset game-over state on new game
    ref.listen(gameProvider.select((m) => m.tick), (prev, next) {
      if (next == 0) {
        setState(() => _gameOver = false);
        final m = ref.read(gameProvider);
        widget.game.loadMap(m.tileMap);
        ref.read(audioProvider.notifier).playMusic(MusicTrack.earlyCity);
      }
    });

    // Update background music when population crosses thresholds
    ref.listen(gameProvider.select((m) => m.population.total), (_, pop) {
      final track = ref.read(audioProvider.notifier).trackForPopulation(pop);
      ref.read(audioProvider.notifier).playMusic(track);
    });

    // Show city notifications
    ref.listen(notificationQueueProvider, (_, queue) {
      if (queue.isEmpty || !mounted) return;
      final drained = ref.read(notificationQueueProvider.notifier).drain();
      for (final n in drained) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(n.message),
            duration: const Duration(seconds: 3),
            backgroundColor:
                n.isWarning ? Colors.red[800] : const Color(0xFF1B5E20),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(bottom: 90, left: 16, right: 16),
          ),
        );
      }
    });

    // Stop timer on game over
    ref.listen(gameProvider.select((m) => m.isGameOver), (_, isOver) {
      if (isOver && !_gameOver) {
        _tickTimer?.cancel();
        ref.read(timeProvider.notifier).setSpeed(GameSpeed.paused);
        setState(() => _gameOver = true);
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          // ── Flame Canvas ──────────────────────────────────────────────
          GameWidget(game: widget.game),

          // ── HUD ──────────────────────────────────────────────────────
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top bar
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HudBar(
                      budget: budget,
                      year: model.year,
                      cityName: model.cityName,
                      population: population,
                      approval: approval,
                      onBudgetTap: () =>
                          setState(() => _showBudget = !_showBudget),
                    ),
                    const Spacer(),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 8, right: 8),
                      child: Row(children: [
                        _HudIconButton(
                          icon: Icons.add_circle_outline,
                          onTap: _triggerNewGame,
                          tooltip: 'Neues Spiel',
                        ),
                        const SizedBox(width: 4),
                        _HudIconButton(
                          icon: Icons.save_outlined,
                          onTap: () => showDialog<void>(
                            context: context,
                            builder: (_) => const SaveDialog(),
                          ),
                          tooltip: 'Spielstand speichern',
                        ),
                        const SizedBox(width: 4),
                        _HudIconButton(
                          icon: Icons.upload_file_outlined,
                          onTap: () => showDialog<void>(
                            context: context,
                            builder: (_) => const LoadDialog(),
                          ),
                          tooltip: 'Spielstand laden',
                        ),
                        const SizedBox(width: 4),
                        _HudIconButton(
                          icon: Icons.percent_outlined,
                          onTap: () => setState(() {
                            _showTaxPanel = !_showTaxPanel;
                            _showBudget = false;
                            _showTechPanel = false;
                          }),
                          tooltip: 'Steuersätze',
                        ),
                        const SizedBox(width: 4),
                        _HudIconButton(
                          icon: Icons.science_outlined,
                          onTap: () => setState(() {
                            _showTechPanel = !_showTechPanel;
                            _showTaxPanel = false;
                            _showBudget = false;
                            _showSpacePanel = false;
                          }),
                          tooltip: 'Forschung',
                        ),
                        const SizedBox(width: 4),
                        _HudIconButton(
                          icon: Icons.rocket_launch_outlined,
                          onTap: () => setState(() {
                            _showSpacePanel = !_showSpacePanel;
                            _showTechPanel = false;
                            _showTaxPanel = false;
                            _showBudget = false;
                          }),
                          tooltip: 'Raumfahrt',
                        ),
                        const SizedBox(width: 4),
                        _HudIconButton(
                          icon: audioMuted
                              ? Icons.volume_off
                              : Icons.volume_up_outlined,
                          onTap: () => ref
                              .read(audioProvider.notifier)
                              .toggleMute(),
                          tooltip: audioMuted ? 'Ton ein' : 'Stummschalten',
                        ),
                        const SizedBox(width: 4),
                        _HudIconButton(
                          icon: Icons.map_outlined,
                          onTap: () => setState(() => _showMinimap = !_showMinimap),
                          tooltip: 'Minimap',
                        ),
                        const SizedBox(width: 4),
                        _HudIconButton(
                          icon: Icons.help_outline,
                          onTap: () => setState(() => _showHelp = !_showHelp),
                          tooltip: 'Hilfe',
                        ),
                        const SizedBox(width: 4),
                        _HudIconButton(
                          icon: Icons.settings_outlined,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                                builder: (_) =>
                                    const SettingsScreen()),
                          ),
                          tooltip: 'Einstellungen',
                        ),
                      ]),
                    ),
                  ],
                ),

                // Budget panel (expandable)
                if (_showBudget)
                  BudgetPanel(
                    model: model,
                    onClose: () => setState(() => _showBudget = false),
                  ),

                // Tax panel
                if (_showTaxPanel)
                  TaxPanel(
                    onClose: () =>
                        setState(() => _showTaxPanel = false),
                  ),

                // Tech panel
                if (_showTechPanel)
                  TechPanel(
                    onClose: () =>
                        setState(() => _showTechPanel = false),
                  ),

                // Space panel
                if (_showSpacePanel)
                  SpacePanel(
                    onClose: () =>
                        setState(() => _showSpacePanel = false),
                  ),

                // Tile info (inspect tool)
                if (_showTileInfo) ...[
                  TileInfoPanel(
                    position: _tileInfoPos,
                    data: model.tileMap.getData(_tileInfoPos),
                    onClose: () =>
                        setState(() => _showTileInfo = false),
                    taxRates: model.taxRates,
                  ),
                ],

                const Spacer(),

                // Overlay toolbar
                _OverlayToolbar(
                  active: overlay,
                  onChanged: (type) =>
                      ref.read(overlayProvider.notifier).toggle(type),
                ),
                if (overlay != OverlayType.none)
                  _OverlayLegend(overlay: overlay),
              ],
            ),
          ),

          // ── Minimap ───────────────────────────────────────────────────
          if (_showMinimap)
            Positioned(
              bottom: 90,
              left: 0,
              child: Minimap(
                tileMap: model.tileMap,
                onClose: () => setState(() => _showMinimap = false),
              ),
            ),

          // ── Help overlay ──────────────────────────────────────────────
          if (_showHelp)
            HelpOverlay(onClose: () => setState(() => _showHelp = false)),

          // ── Game Over overlay ─────────────────────────────────────────
          if (_gameOver)
            GameOverScreen(
              reason: model.isBankrupt
                  ? GameOverReason.bankrupt
                  : GameOverReason.approvalTooLow,
              tick: model.tick,
              year: model.year,
              population: model.population.total,
              cityName: model.cityName,
              onNewGame: _triggerNewGame,
            ),

          // ── Bottom chrome ─────────────────────────────────────────────
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Demand indicator
                  _DemandBar(
                    demandR: model.demandR,
                    demandC: model.demandC,
                    demandI: model.demandI,
                  ),
                  // Time controls
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8, bottom: 4),
                      child: TimeControls(
                        speed: speed,
                        onSpeedChanged: _handleSpeedChange,
                      ),
                    ),
                  ),
                  // Tool palette
                  ToolPalette(
                    activeTool: tool,
                    onToolSelected: (t) {
                      ref.read(toolProvider.notifier).select(t);
                      setState(() => _showTileInfo = false);
                    },
                    budget: budget,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── HUD widgets ───────────────────────────────────────────────────────────────

class _HudBar extends StatelessWidget {
  const _HudBar({
    required this.budget,
    required this.year,
    required this.cityName,
    required this.population,
    required this.approval,
    required this.onBudgetTap,
  });

  final double budget;
  final int year;
  final String cityName;
  final int population;
  final double approval;
  final VoidCallback onBudgetTap;

  @override
  Widget build(BuildContext context) {
    final approvalColor = approval > 0.6
        ? Colors.greenAccent
        : approval > 0.35
            ? Colors.orangeAccent
            : Colors.redAccent;

    return GestureDetector(
      onTap: onBudgetTap,
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.account_balance_wallet,
                color: Colors.greenAccent, size: 14),
            const SizedBox(width: 4),
            Text('\$${budget.toStringAsFixed(0)}',
                style: const TextStyle(color: Colors.white, fontSize: 13)),
            const SizedBox(width: 12),
            const Icon(Icons.people,
                color: Colors.lightBlueAccent, size: 14),
            const SizedBox(width: 4),
            Text('$population',
                style: const TextStyle(color: Colors.white, fontSize: 13)),
            const SizedBox(width: 12),
            Icon(Icons.thumb_up_outlined,
                color: approvalColor, size: 14),
            const SizedBox(width: 4),
            Text('${(approval * 100).toInt()}%',
                style: TextStyle(color: approvalColor, fontSize: 13)),
            const SizedBox(width: 12),
            const Icon(Icons.access_time,
                color: Colors.white38, size: 14),
            const SizedBox(width: 4),
            Text('J$year',
                style: const TextStyle(
                    color: Colors.white38, fontSize: 13)),
            const SizedBox(width: 4),
            Text(cityName,
                style: const TextStyle(
                    color: Colors.white24, fontSize: 11,
                    fontStyle: FontStyle.italic)),
          ],
        ),
      ),
    );
  }
}

class _HudIconButton extends StatelessWidget {
  const _HudIconButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) => Tooltip(
        message: tooltip,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: Colors.white70, size: 16),
          ),
        ),
      );
}

class _OverlayToolbar extends StatelessWidget {
  const _OverlayToolbar({required this.active, required this.onChanged});

  final OverlayType active;
  final ValueChanged<OverlayType> onChanged;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Wrap(
          spacing: 4,
          runSpacing: 4,
          children: OverlayType.values.map((type) {
            final isActive = active == type;
            return GestureDetector(
              onTap: () => onChanged(type),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isActive ? Colors.white : Colors.black54,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                      color: isActive ? Colors.white : Colors.white30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(type.icon,
                        size: 11,
                        color: isActive ? Colors.black : Colors.white70),
                    const SizedBox(width: 3),
                    Text(type.label,
                        style: TextStyle(
                          fontSize: 10,
                          color: isActive ? Colors.black : Colors.white70,
                          fontWeight: isActive
                              ? FontWeight.w700
                              : FontWeight.normal,
                        )),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      );
}

class _OverlayLegend extends StatelessWidget {
  const _OverlayLegend({required this.overlay});

  final OverlayType overlay;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(overlay.label,
                style: const TextStyle(
                    color: Colors.white70, fontSize: 10)),
            const SizedBox(width: 6),
            Container(
              width: 50,
              height: 6,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [overlay.lowColor, overlay.highColor]),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ],
        ),
      );
}

class _DemandBar extends StatelessWidget {
  const _DemandBar({
    required this.demandR,
    required this.demandC,
    required this.demandI,
  });

  final double demandR;
  final double demandC;
  final double demandI;

  @override
  Widget build(BuildContext context) {
    if (demandR == 0 && demandC == 0 && demandI == 0) return const SizedBox.shrink();
    return Container(
      color: Colors.black87,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Nachfrage: ',
              style: TextStyle(color: Colors.white38, fontSize: 10)),
          _DemandChip('W', demandR, const Color(0xFF4CAF50)),
          const SizedBox(width: 8),
          _DemandChip('G', demandC, const Color(0xFF2196F3)),
          const SizedBox(width: 8),
          _DemandChip('I', demandI, const Color(0xFFFF9800)),
        ],
      ),
    );
  }
}

class _DemandChip extends StatelessWidget {
  const _DemandChip(this.label, this.value, this.color);
  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final pct = (value / 5.0).clamp(0.0, 1.0);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$label ', style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700)),
        SizedBox(
          width: 40,
          height: 6,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
      ],
    );
  }
}
