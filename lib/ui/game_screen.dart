import 'package:city_builder/features/game_providers.dart';
import 'package:city_builder/game/city_game.dart';
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

    return Scaffold(
      body: Stack(
        children: [
          GameWidget(game: widget.game),
          _HudOverlay(budget: budget, tick: tick),
        ],
      ),
    );
  }
}

class _HudOverlay extends StatelessWidget {
  const _HudOverlay({required this.budget, required this.tick});

  final double budget;
  final int tick;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _HudBar(budget: budget, tick: tick),
        ],
      ),
    );
  }
}

class _HudBar extends StatelessWidget {
  const _HudBar({required this.budget, required this.tick});

  final double budget;
  final int tick;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.account_balance_wallet, color: Colors.greenAccent, size: 16),
          const SizedBox(width: 6),
          Text(
            '\$${budget.toStringAsFixed(0)}',
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
          const SizedBox(width: 16),
          const Icon(Icons.access_time, color: Colors.white54, size: 16),
          const SizedBox(width: 4),
          Text(
            'Tick $tick',
            style: const TextStyle(color: Colors.white54, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
