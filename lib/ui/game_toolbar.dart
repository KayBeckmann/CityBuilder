import 'package:city_builder/features/time_provider.dart';
import 'package:city_builder/features/tool_provider.dart';
import 'package:flutter/material.dart';

// ── Tool Palette ──────────────────────────────────────────────────────────────

class ToolPalette extends StatelessWidget {
  const ToolPalette({
    super.key,
    required this.activeTool,
    required this.onToolSelected,
    required this.budget,
  });

  final ToolType activeTool;
  final ValueChanged<ToolType> onToolSelected;
  final double budget;

  static const _groups = [
    [ToolType.inspect],
    [
      ToolType.zoneResidential,
      ToolType.zoneCommercial,
      ToolType.zoneIndustrial,
    ],
    [ToolType.park, ToolType.demolishZone, ToolType.demolishInfra, ToolType.demolishAll],
    [
      ToolType.powerPlant,
      ToolType.waterTower,
      ToolType.road,
      ToolType.powerLine,
      ToolType.pipe,
    ],
    [
      ToolType.terrainGrass,
      ToolType.terrainForest,
      ToolType.terrainHill,
      ToolType.terrainWater,
    ],
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (var i = 0; i < _groups.length; i++) ...[
                    if (i > 0)
                      Container(
                        width: 1,
                        height: 28,
                        color: Colors.white12,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                      ),
                    ..._groups[i].map((tool) => _ToolButton(
                          tool: tool,
                          isActive: activeTool == tool,
                          onTap: () => onToolSelected(tool),
                          canAfford: budget >= tool.costPerTile,
                        )),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.tool,
    required this.isActive,
    required this.onTap,
    required this.canAfford,
  });

  final ToolType tool;
  final bool isActive;
  final VoidCallback onTap;
  final bool canAfford;

  @override
  Widget build(BuildContext context) {
    final color = canAfford ? tool.color : tool.color.withAlpha(100);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Tooltip(
        message: tool.costPerTile > 0
            ? '${tool.label} (\$${tool.costPerTile.toInt()}/Kachel)'
            : tool.label,
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isActive ? color.withAlpha(40) : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isActive ? color : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(tool.icon, size: 18, color: color),
                const SizedBox(height: 2),
                Text(
                  tool.label,
                  style: TextStyle(
                    color: color,
                    fontSize: 9,
                    fontWeight:
                        isActive ? FontWeight.w700 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Time Controls ─────────────────────────────────────────────────────────────

class TimeControls extends StatelessWidget {
  const TimeControls({
    super.key,
    required this.speed,
    required this.onSpeedChanged,
  });

  final GameSpeed speed;
  final ValueChanged<GameSpeed> onSpeedChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      color: Colors.black87,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: GameSpeed.values.map((s) {
          final isActive = speed == s;
          return GestureDetector(
            onTap: () => onSpeedChanged(s),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isActive ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(5),
                border:
                    Border.all(color: isActive ? Colors.white : Colors.white24),
              ),
              child: Text(
                s.label,
                style: TextStyle(
                  color: isActive ? Colors.black : Colors.white54,
                  fontSize: 12,
                  fontWeight:
                      isActive ? FontWeight.w700 : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
