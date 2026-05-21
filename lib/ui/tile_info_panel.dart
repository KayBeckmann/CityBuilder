import 'package:city_builder/core/building_level.dart';
import 'package:city_builder/core/economy.dart';
import 'package:city_builder/core/resource_system.dart';
import 'package:city_builder/core/tile_map.dart';
import 'package:city_builder/core/world_position.dart';
import 'package:flutter/material.dart';

class TileInfoPanel extends StatelessWidget {
  const TileInfoPanel({
    super.key,
    required this.position,
    required this.data,
    required this.onClose,
    this.taxRates,
  });

  final WorldPosition position;
  final TileData data;
  final VoidCallback onClose;
  final TaxRates? taxRates;

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
          _InfoRow(label: 'Terrain', value: data.terrain.label),
          if (data.zone != null)
            _InfoRow(label: 'Zone', value: data.zone!.fullLabel),
          if (data.buildingLevel.hasBuilding)
            _InfoRow(label: 'Gebäude', value: data.buildingLevel.label),
          if (data.resource != null)
            _InfoRow(label: 'Rohstoff', value: data.resource!.name),
          if (data.zone != null)
            _InfoRow(
              label: 'Kapazität',
              value: '${data.buildingLevel.capacity} EW',
            ),
          if (data.zone != null && data.buildingLevel.hasBuilding && taxRates != null) ...[
            _InfoRow(
              label: 'Einkommen',
              value: '+\$${(data.buildingLevel.capacity * 5.0 * taxRates!.forZone(data.zone!)).toStringAsFixed(1)}/Tick',
              valueColor: Colors.greenAccent,
            ),
            _InfoRow(
              label: 'Betrieb',
              value: '-\$${data.buildingLevel.operatingCost.toStringAsFixed(1)}/Tick',
              valueColor: Colors.redAccent,
            ),
          ],
          if (data.zone != null && !data.buildingLevel.hasBuilding)
            const _DevHint('Benötigt Nachfrage > 50%'),
          if (data.zone != null &&
              data.buildingLevel == BuildingLevel.small &&
              !data.hasRoad)
            const _DevHint('Straße nötig für größere Gebäude'),
          const SizedBox(height: 4),
          _InfraRow(
            label: 'Straße',
            active: data.hasRoad,
            icon: Icons.add_road,
            activeColor: const Color(0xFF90A4AE),
          ),
          _InfraRow(
            label: 'Strom',
            active: data.hasPowerLine,
            icon: Icons.bolt_outlined,
            activeColor: const Color(0xFFFFEE58),
          ),
          _InfraRow(
            label: 'Wasser',
            active: data.hasPipe,
            icon: Icons.water_outlined,
            activeColor: const Color(0xFF42A5F5),
          ),
          if (data.hasPowerPlant)
            const _InfraRow(
              label: 'Kraftwerk',
              active: true,
              icon: Icons.power_outlined,
              activeColor: Color(0xFFFFCC02),
            ),
          if (data.hasWaterTower)
            const _InfraRow(
              label: 'Wasserturm',
              active: true,
              icon: Icons.water_damage_outlined,
              activeColor: Color(0xFF00BCD4),
            ),
          if (data.hasPoliceStation)
            const _InfraRow(
              label: 'Polizei',
              active: true,
              icon: Icons.local_police_outlined,
              activeColor: Color(0xFF1565C0),
            ),
          if (data.hasHospital)
            const _InfraRow(
              label: 'Krankenhaus',
              active: true,
              icon: Icons.local_hospital_outlined,
              activeColor: Color(0xFFE53935),
            ),
          if (data.hasSchool)
            const _InfraRow(
              label: 'Schule',
              active: true,
              icon: Icons.school_outlined,
              activeColor: Color(0xFFFF9800),
            ),
          if (data.hasFireStation)
            const _InfraRow(
              label: 'Feuerwehr',
              active: true,
              icon: Icons.local_fire_department_outlined,
              activeColor: Color(0xFFDD2C00),
            ),
          if (data.hasSpaceport)
            const _InfraRow(
              label: 'Raumhafen',
              active: true,
              icon: Icons.rocket_launch_outlined,
              activeColor: Color(0xFF7B1FA2),
            ),
          if (data.hasRailTrack)
            const _InfraRow(
              label: 'Gleis',
              active: true,
              icon: Icons.linear_scale_outlined,
              activeColor: Color(0xFF5D4037),
            ),
          if (data.hasStation)
            const _InfraRow(
              label: 'Bahnhof',
              active: true,
              icon: Icons.train_outlined,
              activeColor: Color(0xFF4E342E),
            ),
          if (data.hasExtractionBuilding)
            _InfraRow(
              label: data.extractionBuilding!.label,
              active: data.resourceRemaining > 0,
              icon: Icons.hardware_outlined,
              activeColor: const Color(0xFF8D6E63),
            ),
        ],
      ),
    );
  }
}

class _DevHint extends StatelessWidget {
  const _DevHint(this.message);
  final String message;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Row(
          children: [
            const Icon(Icons.info_outline,
                color: Colors.orangeAccent, size: 11),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.orangeAccent,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      );
}

class _InfraRow extends StatelessWidget {
  const _InfraRow({
    required this.label,
    required this.active,
    required this.icon,
    required this.activeColor,
  });

  final String label;
  final bool active;
  final IconData icon;
  final Color activeColor;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            SizedBox(
              width: 72,
              child: Text(label,
                  style: const TextStyle(color: Colors.white38, fontSize: 11)),
            ),
            Icon(icon, size: 12, color: active ? activeColor : Colors.white24),
            const SizedBox(width: 4),
            Text(
              active ? 'vorhanden' : 'fehlt',
              style: TextStyle(
                color: active ? activeColor : Colors.redAccent,
                fontSize: 11,
              ),
            ),
          ],
        ),
      );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

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
            style: TextStyle(
              color: valueColor ?? Colors.white70,
              fontSize: 11,
              fontWeight: valueColor != null ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
