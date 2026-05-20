import 'package:city_builder/core/space_phase.dart';
import 'package:city_builder/core/tech_tree.dart';
import 'package:city_builder/core/tile_map.dart';
import 'package:city_builder/features/game_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SpacePanel extends ConsumerWidget {
  const SpacePanel({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final model = ref.watch(gameProvider);
    final space = model.spacePhase;

    return Container(
      constraints: const BoxConstraints(maxWidth: 400, maxHeight: 420),
      margin: const EdgeInsets.only(top: 4, left: 8, right: 8),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 8, 8),
            child: Row(
              children: [
                Icon(
                  Icons.rocket_launch_outlined,
                  color: space.spacePhaseActive
                      ? Colors.cyanAccent
                      : Colors.white38,
                  size: 16,
                ),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    'Raumfahrt',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (space.spacePhaseActive)
                  Text(
                    '${space.rareEarthStockpile.toStringAsFixed(0)} RE',
                    style: const TextStyle(
                        color: Colors.cyanAccent, fontSize: 12),
                  ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onClose,
                  child: const Icon(Icons.close,
                      color: Colors.white54, size: 16),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white12, height: 1),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: space.spacePhaseActive
                  ? _ActiveSpaceView(space: space, ref: ref)
                  : _InactiveSpaceView(
                      population: model.population.total,
                      researchedSpaceport: model.techTree
                          .isResearched(TechNode.spaceportPrep),
                      spaceportBuilt: _hasSpaceport(model.tileMap),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  static bool _hasSpaceport(TileMap tileMap) {
    for (var row = 0; row < tileMap.height; row++) {
      for (var col = 0; col < tileMap.width; col++) {
        if (tileMap.getData((col: col, row: row)).hasSpaceport) return true;
      }
    }
    return false;
  }
}

// ── Inactive view: shows trigger conditions ────────────────────────────────

class _InactiveSpaceView extends StatelessWidget {
  const _InactiveSpaceView({
    required this.population,
    required this.researchedSpaceport,
    required this.spaceportBuilt,
  });

  final int population;
  final bool researchedSpaceport;
  final bool spaceportBuilt;

  @override
  Widget build(BuildContext context) {
    final popOk = population >= kSpacePhaseMinPopulation;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bedingungen für Space-Phase:',
          style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
              fontSize: 13),
        ),
        const SizedBox(height: 10),
        _Condition(
          'Bevölkerung ≥ ${kSpacePhaseMinPopulation ~/ 1000}k',
          popOk,
          subtitle: '${(population / 1000).toStringAsFixed(0)}k / '
              '${kSpacePhaseMinPopulation ~/ 1000}k',
        ),
        const SizedBox(height: 6),
        _Condition('Raumfahrtbasis erforscht', researchedSpaceport),
        const SizedBox(height: 6),
        _Condition('Raumhafen gebaut (\$50.000)', spaceportBuilt),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white12),
          ),
          child: const Text(
            'Erforsche "Raumfahrtbasis" im Tech-Tree, baue einen Raumhafen '
            '(Werkzeug: Raumhafen, \$50.000) und erreiche 500.000 Einwohner.',
            style: TextStyle(color: Colors.white54, fontSize: 11),
          ),
        ),
      ],
    );
  }
}

// ── Active view: missions + stockpile ─────────────────────────────────────

class _ActiveSpaceView extends StatelessWidget {
  const _ActiveSpaceView({required this.space, required this.ref});

  final SpacePhaseState space;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StockpileRow(
              'Seltene Erden', space.rareEarthStockpile, Colors.cyanAccent),
          _StockpileRow(
              'Kolonie-Bev.', space.colonyPopulation.toDouble(), Colors.greenAccent),
          const SizedBox(height: 12),
          if (space.activeMissions.isNotEmpty) ...[
            const Text(
              'Aktive Missionen:',
              style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                  fontSize: 12),
            ),
            const SizedBox(height: 6),
            ...space.activeMissions.map((m) => _MissionCard(mission: m)),
            const SizedBox(height: 12),
          ],
          const Text(
            'Mission starten:',
            style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w600,
                fontSize: 12),
          ),
          const SizedBox(height: 6),
          ...SpaceMissionType.values.map(
            (type) => _LaunchButton(
              type: type,
              onLaunch: () =>
                  ref.read(gameProvider.notifier).launchMission(type),
            ),
          ),
        ],
      );
}

// ── Supporting widgets ─────────────────────────────────────────────────────

class _StockpileRow extends StatelessWidget {
  const _StockpileRow(this.label, this.value, this.color);
  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          children: [
            Text(label,
                style:
                    const TextStyle(color: Colors.white54, fontSize: 12)),
            const SizedBox(width: 8),
            Text(
              value.toStringAsFixed(0),
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 13),
            ),
          ],
        ),
      );
}

class _MissionCard extends StatelessWidget {
  const _MissionCard({required this.mission});
  final SpaceMission mission;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.cyanAccent.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
              color: Colors.cyanAccent.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.rocket_launch_outlined,
                color: Colors.cyanAccent, size: 12),
            const SizedBox(width: 6),
            Text(
              _missionLabel(mission.type),
              style: const TextStyle(
                  color: Colors.cyanAccent, fontSize: 12),
            ),
            const Spacer(),
            Text(
              '+${mission.type.rareEarthYield.toStringAsFixed(0)} RE',
              style: const TextStyle(
                  color: Colors.white38, fontSize: 10),
            ),
          ],
        ),
      );

  static String _missionLabel(SpaceMissionType type) => switch (type) {
        SpaceMissionType.rareEarthMining => 'Seltenerd-Bergbau',
        SpaceMissionType.satelliteNetwork => 'Satellitennetz',
        SpaceMissionType.colonySurvey => 'Kolonievermessung',
      };
}

class _LaunchButton extends StatelessWidget {
  const _LaunchButton({required this.type, required this.onLaunch});
  final SpaceMissionType type;
  final VoidCallback onLaunch;

  @override
  Widget build(BuildContext context) {
    final label = switch (type) {
      SpaceMissionType.rareEarthMining => 'Seltenerd-Bergbau',
      SpaceMissionType.satelliteNetwork => 'Satellitennetz',
      SpaceMissionType.colonySurvey => 'Kolonievermessung',
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 12)),
                Text(
                  '\$${type.cost.toStringAsFixed(0)}  ·  '
                  '${type.duration.inSeconds}t  ·  '
                  '+${type.rareEarthYield.toStringAsFixed(0)} RE',
                  style: const TextStyle(
                      color: Colors.white38, fontSize: 10),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onLaunch,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.cyanAccent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.cyanAccent),
              ),
              child: const Text('Start',
                  style: TextStyle(
                      color: Colors.cyanAccent, fontSize: 11)),
            ),
          ),
        ],
      ),
    );
  }
}

class _Condition extends StatelessWidget {
  const _Condition(this.label, this.met, {this.subtitle});
  final String label;
  final bool met;
  final String? subtitle;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            met
                ? Icons.check_circle_outline
                : Icons.radio_button_unchecked,
            color: met ? Colors.greenAccent : Colors.white38,
            size: 14,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                      color: met ? Colors.greenAccent : Colors.white70,
                      fontSize: 12),
                ),
                if (subtitle != null)
                  Text(subtitle!,
                      style: const TextStyle(
                          color: Colors.white38, fontSize: 10)),
              ],
            ),
          ),
        ],
      );
}
