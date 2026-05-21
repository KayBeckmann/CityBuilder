import 'package:city_builder/core/tech_tree.dart';
import 'package:city_builder/features/game_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TechPanel extends ConsumerWidget {
  const TechPanel({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final model = ref.watch(gameProvider);
    final techTree = model.techTree;
    final population = model.population.total;

    return Container(
      constraints: const BoxConstraints(maxWidth: 400, maxHeight: 460),
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
                const Icon(Icons.science_outlined,
                    color: Colors.purpleAccent, size: 16),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    'Forschung',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${techTree.researchPoints.toStringAsFixed(0)} RP',
                      style: const TextStyle(
                          color: Colors.purpleAccent, fontSize: 12),
                    ),
                    Text(
                      '${techTree.progress.length} aktiv',
                      style: const TextStyle(
                          color: Colors.white38, fontSize: 10),
                    ),
                  ],
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
            child: ListView(
              padding: const EdgeInsets.all(8),
              children: TechNode.values
                  .map((node) => _TechNodeCard(
                        node: node,
                        techTree: techTree,
                        population: population,
                        onStartResearch: () =>
                            ref.read(gameProvider.notifier).researchTech(node),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _TechNodeCard extends StatelessWidget {
  const _TechNodeCard({
    required this.node,
    required this.techTree,
    required this.population,
    required this.onStartResearch,
  });

  final TechNode node;
  final TechTreeState techTree;
  final int population;
  final VoidCallback onStartResearch;

  @override
  Widget build(BuildContext context) {
    final isResearched = techTree.isResearched(node);
    final inProgress = techTree.progress.containsKey(node);
    final canResearch = techTree.canResearch(node, population);
    final progressPct = inProgress
        ? (techTree.progress[node]! / node.researchCost).clamp(0.0, 1.0)
        : 0.0;

    final Color statusColor;
    final IconData statusIcon;
    if (isResearched) {
      statusColor = Colors.greenAccent;
      statusIcon = Icons.check_circle_outline;
    } else if (inProgress) {
      statusColor = Colors.purpleAccent;
      statusIcon = Icons.hourglass_bottom_outlined;
    } else if (canResearch) {
      statusColor = Colors.lightBlueAccent;
      statusIcon = Icons.radio_button_unchecked;
    } else {
      statusColor = Colors.white24;
      statusIcon = Icons.lock_outline;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isResearched
              ? Colors.greenAccent.withValues(alpha: 0.3)
              : Colors.white12,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(statusIcon, color: statusColor, size: 14),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _labelFor(node),
                  style: TextStyle(
                    color: isResearched ? Colors.greenAccent : Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              Text(
                '${node.researchCost} RP',
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
              if (canResearch && !inProgress) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onStartResearch,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color:
                          Colors.purpleAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.purpleAccent),
                    ),
                    child: const Text(
                      'Start',
                      style: TextStyle(
                          color: Colors.purpleAccent, fontSize: 11),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 3),
          Text(
            _effectFor(node),
            style: TextStyle(
              color: isResearched ? Colors.greenAccent.withValues(alpha: 0.7) : Colors.white38,
              fontSize: 10,
            ),
          ),
          if (inProgress) ...[
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: progressPct,
                backgroundColor: Colors.white12,
                valueColor: const AlwaysStoppedAnimation<Color>(
                    Colors.purpleAccent),
                minHeight: 4,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${(progressPct * 100).toInt()}%  –  '
              '${techTree.progress[node]!.toStringAsFixed(0)} / ${node.researchCost} RP',
              style:
                  const TextStyle(color: Colors.white38, fontSize: 10),
            ),
          ],
          if (node.minPopulation > 0 || node.dependencies.isNotEmpty) ...[
            const SizedBox(height: 5),
            Wrap(
              spacing: 4,
              runSpacing: 3,
              children: [
                if (node.minPopulation > 0)
                  _Chip(
                    '≥ ${node.minPopulation} Einw.',
                    population >= node.minPopulation
                        ? Colors.greenAccent
                        : Colors.orangeAccent,
                  ),
                ...node.dependencies.map(
                  (dep) => _Chip(
                    _labelFor(dep),
                    techTree.isResearched(dep)
                        ? Colors.greenAccent
                        : Colors.white38,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  static String _labelFor(TechNode node) => switch (node) {
        TechNode.solarPower => 'Solarenergie',
        TechNode.asphaltRoads => 'Asphaltstraßen',
        TechNode.school => 'Bildungsreform',
        TechNode.nuclearPower => 'Kernkraft',
        TechNode.university => 'Universität',
        TechNode.railSignaling => 'Schienensignaltechnik',
        TechNode.spaceportPrep => 'Raumfahrtbasis',
        TechNode.hightechIndustry => 'Hightech-Industrie',
        TechNode.subway => 'U-Bahn',
      };

  static String _effectFor(TechNode node) => switch (node) {
        TechNode.solarPower => '+3% Services',
        TechNode.asphaltRoads => '+5% Wohnen',
        TechNode.school => 'Forschungspunkte +',
        TechNode.nuclearPower => '+8% Beschäftigung',
        TechNode.university => 'Uni-Gebäude (\$15k) + 50% FP/Uni',
        TechNode.railSignaling => 'Gleis-Infrastruktur',
        TechNode.spaceportPrep => 'Raumhafen-Gebäude (\$50k)',
        TechNode.hightechIndustry => '+5% Steuereinnahmen',
        TechNode.subway => '+5% Wohnen',
      };
}

class _Chip extends StatelessWidget {
  const _Chip(this.label, this.color);

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Text(
          label,
          style: TextStyle(color: color, fontSize: 9),
        ),
      );
}
