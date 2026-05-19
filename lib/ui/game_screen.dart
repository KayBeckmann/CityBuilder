import 'package:city_builder/core/audio_manager.dart';
import 'package:city_builder/core/overlay_type.dart';
import 'package:city_builder/features/game_providers.dart';
import 'package:city_builder/features/overlay_provider.dart';
import 'package:city_builder/game/city_game.dart';
import 'package:city_builder/ui/settings_screen.dart';
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
  @override
  void initState() {
    super.initState();
    final model = ref.read(gameProvider);
    widget.game.loadMap(model.tileMap);
  }

  @override
  Widget build(BuildContext context) {
    final budget = ref.watch(gameProvider.select((m) => m.budget));
    final tick = ref.watch(gameProvider.select((m) => m.tick));
    final population = ref.watch(gameProvider.select((m) => m.population.total));
    final approval = ref.watch(gameProvider.select((m) => m.approvalRating));
    final overlay = ref.watch(overlayProvider);
    final audioMuted = ref.watch(audioProvider.select((s) => s.muted));

    ref.listen(overlayProvider, (_, next) {
      final tileMap = ref.read(gameProvider).tileMap;
      final values = computeOverlayValues(tileMap, next);
      widget.game.updateOverlay(next, values);
    });

    return Scaffold(
      body: Stack(
        children: [
          GameWidget(game: widget.game),
          _HudOverlay(
            budget: budget,
            tick: tick,
            population: population,
            approval: approval,
            activeOverlay: overlay,
            audioMuted: audioMuted,
            onOverlayChanged: (type) => ref.read(overlayProvider.notifier).toggle(type),
            onMuteToggle: () => ref.read(audioProvider.notifier).toggleMute(),
            onSettingsTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

// ── HUD ──────────────────────────────────────────────────────────────────────

class _HudOverlay extends StatelessWidget {
  const _HudOverlay({
    required this.budget,
    required this.tick,
    required this.population,
    required this.approval,
    required this.activeOverlay,
    required this.audioMuted,
    required this.onOverlayChanged,
    required this.onMuteToggle,
    required this.onSettingsTap,
  });

  final double budget;
  final int tick;
  final int population;
  final double approval;
  final OverlayType activeOverlay;
  final bool audioMuted;
  final ValueChanged<OverlayType> onOverlayChanged;
  final VoidCallback onMuteToggle;
  final VoidCallback onSettingsTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HudBar(budget: budget, tick: tick, population: population, approval: approval),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(top: 8, right: 8),
                child: Row(
                  children: [
                    _HudIconButton(
                      icon: audioMuted ? Icons.volume_off : Icons.volume_up_outlined,
                      onTap: onMuteToggle,
                      tooltip: audioMuted ? 'Ton ein' : 'Stummschalten',
                    ),
                    const SizedBox(width: 4),
                    _HudIconButton(
                      icon: Icons.settings_outlined,
                      onTap: onSettingsTap,
                      tooltip: 'Einstellungen',
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          _OverlayToolbar(active: activeOverlay, onChanged: onOverlayChanged),

          if (activeOverlay != OverlayType.none)
            _OverlayLegend(overlay: activeOverlay),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ── HUD Icon Button ───────────────────────────────────────────────────────────

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
  Widget build(BuildContext context) {
    return Tooltip(
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
}

// ── Top HUD Bar ───────────────────────────────────────────────────────────────

class _HudBar extends StatelessWidget {
  const _HudBar({
    required this.budget,
    required this.tick,
    required this.population,
    required this.approval,
  });

  final double budget;
  final int tick;
  final int population;
  final double approval;

  @override
  Widget build(BuildContext context) {
    final approvalColor = approval > 0.6
        ? Colors.greenAccent
        : approval > 0.35
            ? Colors.orangeAccent
            : Colors.redAccent;

    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.account_balance_wallet, color: Colors.greenAccent, size: 14),
          const SizedBox(width: 4),
          Text('\$${budget.toStringAsFixed(0)}',
              style: const TextStyle(color: Colors.white, fontSize: 13)),
          const SizedBox(width: 12),
          const Icon(Icons.people, color: Colors.lightBlueAccent, size: 14),
          const SizedBox(width: 4),
          Text('$population',
              style: const TextStyle(color: Colors.white, fontSize: 13)),
          const SizedBox(width: 12),
          Icon(Icons.thumb_up_outlined, color: approvalColor, size: 14),
          const SizedBox(width: 4),
          Text('${(approval * 100).toInt()}%',
              style: TextStyle(color: approvalColor, fontSize: 13)),
          const SizedBox(width: 12),
          const Icon(Icons.access_time, color: Colors.white38, size: 14),
          const SizedBox(width: 4),
          Text('T$tick',
              style: const TextStyle(color: Colors.white38, fontSize: 13)),
        ],
      ),
    );
  }
}

// ── Overlay Toolbar ───────────────────────────────────────────────────────────

class _OverlayToolbar extends StatelessWidget {
  const _OverlayToolbar({required this.active, required this.onChanged});

  final OverlayType active;
  final ValueChanged<OverlayType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Wrap(
        spacing: 4,
        children: OverlayType.values.map((type) {
          final isActive = active == type;
          return GestureDetector(
            onTap: () => onChanged(type),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: isActive ? Colors.white : Colors.black54,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isActive ? Colors.white : Colors.white30,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(type.icon,
                      size: 12,
                      color: isActive ? Colors.black : Colors.white70),
                  const SizedBox(width: 4),
                  Text(
                    type.label,
                    style: TextStyle(
                      fontSize: 11,
                      color: isActive ? Colors.black : Colors.white70,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Overlay Legend ────────────────────────────────────────────────────────────

class _OverlayLegend extends StatelessWidget {
  const _OverlayLegend({required this.overlay});

  final OverlayType overlay;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(overlay.label,
              style: const TextStyle(color: Colors.white70, fontSize: 11)),
          const SizedBox(width: 8),
          _GradientBar(from: overlay.lowColor, to: overlay.highColor),
          const SizedBox(width: 4),
          const Text('niedrig → hoch',
              style: TextStyle(color: Colors.white38, fontSize: 10)),
        ],
      ),
    );
  }
}

class _GradientBar extends StatelessWidget {
  const _GradientBar({required this.from, required this.to});

  final Color from;
  final Color to;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 8,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [from, to]),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white24),
      ),
    );
  }
}
