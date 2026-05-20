import 'package:flutter_riverpod/flutter_riverpod.dart';

enum GameSpeed { paused, normal, fast, veryFast }

extension GameSpeedExt on GameSpeed {
  String get label => switch (this) {
        GameSpeed.paused => '⏸',
        GameSpeed.normal => '▶ ×1',
        GameSpeed.fast => '⏩ ×2',
        GameSpeed.veryFast => '⏭ ×4',
      };

  /// Millisekunden zwischen zwei Ticks (null = pausiert)
  int? get intervalMs => switch (this) {
        GameSpeed.paused => null,
        GameSpeed.normal => 2000,
        GameSpeed.fast => 1000,
        GameSpeed.veryFast => 500,
      };

  bool get isPaused => this == GameSpeed.paused;
}

class TimeNotifier extends Notifier<GameSpeed> {
  @override
  GameSpeed build() => GameSpeed.paused;

  void setSpeed(GameSpeed speed) => state = speed;

  void togglePause() {
    state = state == GameSpeed.paused ? GameSpeed.normal : GameSpeed.paused;
  }
}

final timeProvider = NotifierProvider<TimeNotifier, GameSpeed>(TimeNotifier.new);
