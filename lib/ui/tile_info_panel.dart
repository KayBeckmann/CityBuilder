import 'package:city_builder/core/tile_map.dart';
import 'package:city_builder/core/world_position.dart';
import 'package:flutter/material.dart';

class TileInfoPanel extends StatelessWidget {
  const TileInfoPanel({
    super.key,
    required this.position,
    required this.data,
    required this.onClose,
  });

  final WorldPosition position;
  final TileData data;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Kachel (${position.col}, ${position.row})',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onClose,
                child: const Icon(Icons.close, color: Colors.white38, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _InfoRow(label: 'Terrain', value: data.terrain.name),
          if (data.zone != null)
            _InfoRow(label: 'Zone', value: data.zone!.label),
          if (data.buildingLevel.hasBuilding)
            _InfoRow(label: 'Gebäude', value: data.buildingLevel.name),
          if (data.resource != null)
            _InfoRow(label: 'Rohstoff', value: data.resource!.name),
          if (data.zone != null)
            _InfoRow(
              label: 'Kapazität',
              value: '${data.buildingLevel.capacity} EW',
            ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white38, fontSize: 11),
            ),
          ),
          Text(
            value,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
