import 'package:flutter/material.dart';

enum GameOverReason { bankrupt, approvalTooLow }

class GameOverScreen extends StatelessWidget {
  const GameOverScreen({
    super.key,
    required this.reason,
    required this.tick,
    required this.population,
    required this.onNewGame,
  });

  final GameOverReason reason;
  final int tick;
  final int population;
  final VoidCallback onNewGame;

  String get _headline => switch (reason) {
        GameOverReason.bankrupt => 'Insolvenz!',
        GameOverReason.approvalTooLow => 'Abgewählt!',
      };

  String get _subtitle => switch (reason) {
        GameOverReason.bankrupt =>
          'Die Stadt ist pleite. Kein Geld mehr im Stadtsäckel.',
        GameOverReason.approvalTooLow =>
          'Die Bürger haben Sie aus dem Amt gewählt.',
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withAlpha(200),
      child: Center(
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFF1a1a2e),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: Colors.red, size: 48),
              const SizedBox(height: 12),
              Text(
                _headline,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 24),
              _StatRow(label: 'Gespielt', value: '$tick Ticks'),
              _StatRow(label: 'Einwohner', value: '$population'),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onNewGame,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 44),
                ),
                icon: const Icon(Icons.replay),
                label: const Text('Neues Spiel',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(label,
              style: const TextStyle(color: Colors.white38, fontSize: 13)),
          const Spacer(),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
