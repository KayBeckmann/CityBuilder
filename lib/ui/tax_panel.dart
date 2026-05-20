import 'package:city_builder/features/game_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TaxPanel extends ConsumerWidget {
  const TaxPanel({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rates = ref.watch(gameProvider.select((m) => m.taxRates));

    return Container(
      width: 260,
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
              const Text('Steuersätze',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13)),
              const Spacer(),
              GestureDetector(
                onTap: onClose,
                child: const Icon(Icons.close,
                    color: Colors.white38, size: 14),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _TaxSlider(
            label: 'Wohngebiet',
            color: const Color(0xFF4CAF50),
            value: rates.residential,
            onChanged: (v) => ref.read(gameProvider.notifier).updateTaxRates(
                  rates.copyWith(residential: v),
                ),
          ),
          _TaxSlider(
            label: 'Gewerbe',
            color: const Color(0xFF2196F3),
            value: rates.commercial,
            onChanged: (v) => ref.read(gameProvider.notifier).updateTaxRates(
                  rates.copyWith(commercial: v),
                ),
          ),
          _TaxSlider(
            label: 'Industrie',
            color: const Color(0xFFFF9800),
            value: rates.industrial,
            onChanged: (v) => ref.read(gameProvider.notifier).updateTaxRates(
                  rates.copyWith(industrial: v),
                ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Hohe Steuern → mehr Einnahmen, weniger Wachstum',
            style: TextStyle(color: Colors.white24, fontSize: 9),
          ),
        ],
      ),
    );
  }
}

class _TaxSlider extends StatelessWidget {
  const _TaxSlider({
    required this.label,
    required this.color,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final Color color;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            child: Text(label,
                style:
                    const TextStyle(color: Colors.white54, fontSize: 11)),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: color,
                thumbColor: color,
                inactiveTrackColor: Colors.white12,
                overlayColor: color.withAlpha(40),
                trackHeight: 2,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              ),
              child: Slider(
                value: value,
                max: 0.25,
                divisions: 25,
                onChanged: onChanged,
              ),
            ),
          ),
          SizedBox(
            width: 36,
            child: Text(
              '${(value * 100).toInt()}%',
              textAlign: TextAlign.right,
              style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
