import 'package:city_builder/core/map_generator.dart';
import 'package:city_builder/features/game_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NewGameDialog extends ConsumerStatefulWidget {
  const NewGameDialog({super.key});

  static Future<void> show(BuildContext context) => showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const NewGameDialog(),
      );

  @override
  ConsumerState<NewGameDialog> createState() => _NewGameDialogState();
}

enum Difficulty {
  easy(200000, 'Einfach', '\$200.000 Start'),
  normal(100000, 'Normal', '\$100.000 Start'),
  hard(50000, 'Schwer', '\$50.000 Start');

  const Difficulty(this.budget, this.label, this.description);
  final double budget;
  final String label;
  final String description;
}

class _NewGameDialogState extends ConsumerState<NewGameDialog> {
  final _seedCtrl = TextEditingController(text: '42');
  MapSize _size = MapSize.medium;
  Difficulty _difficulty = Difficulty.normal;
  bool _generating = false;

  @override
  void dispose() {
    _seedCtrl.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    final seed = int.tryParse(_seedCtrl.text.trim()) ?? 42;
    setState(() => _generating = true);
    ref.read(gameProvider.notifier).newGame(
      seed: seed,
      size: _size,
      startingBudget: _difficulty.budget,
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1a1a2e),
      title: const Text(
        'Neues Spiel',
        style: TextStyle(color: Colors.white),
      ),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Label('Karten-Seed'),
            const SizedBox(height: 6),
            TextField(
              controller: _seedCtrl,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.casino_outlined,
                      color: Colors.white38, size: 18),
                  onPressed: () => _seedCtrl.text =
                      DateTime.now().millisecondsSinceEpoch.toString(),
                  tooltip: 'Zufällig',
                ),
              ),
            ),
            const SizedBox(height: 16),
            _Label('Schwierigkeitsgrad'),
            const SizedBox(height: 6),
            Row(children: Difficulty.values.map((d) {
              final isActive = _difficulty == d;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _difficulty = d),
                  child: Container(
                    margin: const EdgeInsets.only(right: 4),
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFF4CAF50).withAlpha(40)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isActive
                            ? const Color(0xFF4CAF50)
                            : Colors.white24,
                      ),
                    ),
                    child: Column(children: [
                      Text(d.label,
                          style: TextStyle(
                            color: isActive ? const Color(0xFF4CAF50) : Colors.white70,
                            fontSize: 12,
                            fontWeight: isActive ? FontWeight.w700 : FontWeight.normal,
                          )),
                      Text(d.description,
                          style: const TextStyle(
                              color: Colors.white38, fontSize: 9)),
                    ]),
                  ),
                ),
              );
            }).toList()),
            const SizedBox(height: 16),
            _Label('Kartengröße'),
            const SizedBox(height: 6),
            ...MapSize.values.map((size) => RadioListTile<MapSize>(
                  title: Text(
                    switch (size) {
                      MapSize.small => 'Klein (64×64)',
                      MapSize.medium => 'Mittel (128×128)',
                      MapSize.large => 'Groß (256×256)',
                    },
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  value: size,
                  groupValue: _size,
                  onChanged: (v) => setState(() => _size = v!),
                  activeColor: const Color(0xFF4CAF50),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                )),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _generating ? null : () => Navigator.of(context).pop(),
          child: const Text('Abbrechen',
              style: TextStyle(color: Colors.white38)),
        ),
        ElevatedButton.icon(
          onPressed: _generating ? null : _start,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4CAF50),
            foregroundColor: Colors.black,
          ),
          icon: _generating
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.play_arrow, size: 16),
          label: const Text('Spielen'),
        ),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          color: Colors.white38,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      );
}
