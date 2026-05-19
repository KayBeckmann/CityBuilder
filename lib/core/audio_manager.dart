import 'package:flutter_riverpod/flutter_riverpod.dart';

enum MusicTrack {
  earlyCity,
  metropolis,
  spaceAge;

  String get filename => switch (this) {
        MusicTrack.earlyCity => 'music/early_city.mp3',
        MusicTrack.metropolis => 'music/metropolis.mp3',
        MusicTrack.spaceAge => 'music/space_age.mp3',
      };
}

enum SoundEffect {
  build,
  demolish,
  error,
  notification,
  gameOver,
  milestone;

  String get filename => switch (this) {
        SoundEffect.build => 'sfx/build.mp3',
        SoundEffect.demolish => 'sfx/demolish.mp3',
        SoundEffect.error => 'sfx/error.mp3',
        SoundEffect.notification => 'sfx/notification.mp3',
        SoundEffect.gameOver => 'sfx/game_over.mp3',
        SoundEffect.milestone => 'sfx/milestone.mp3',
      };
}

class AudioSettings {
  const AudioSettings({
    this.musicVolume = 0.7,
    this.sfxVolume = 1.0,
    this.muted = false,
  });

  final double musicVolume;
  final double sfxVolume;
  final bool muted;

  bool get isMusicAudible => !muted && musicVolume > 0;
  bool get isSfxAudible => !muted && sfxVolume > 0;

  AudioSettings copyWith({
    double? musicVolume,
    double? sfxVolume,
    bool? muted,
  }) =>
      AudioSettings(
        musicVolume: musicVolume ?? this.musicVolume,
        sfxVolume: sfxVolume ?? this.sfxVolume,
        muted: muted ?? this.muted,
      );
}

class AudioManager extends Notifier<AudioSettings> {
  @override
  AudioSettings build() => const AudioSettings();

  void setMusicVolume(double volume) {
    state = state.copyWith(musicVolume: volume.clamp(0, 1));
  }

  void setSfxVolume(double volume) {
    state = state.copyWith(sfxVolume: volume.clamp(0, 1));
  }

  void toggleMute() {
    state = state.copyWith(muted: !state.muted);
  }

  void setMute(bool muted) {
    state = state.copyWith(muted: muted);
  }

  MusicTrack trackForPopulation(int population) {
    if (population >= 50000) return MusicTrack.spaceAge;
    if (population >= 5000) return MusicTrack.metropolis;
    return MusicTrack.earlyCity;
  }

  void playSfx(SoundEffect effect) {
    // Audio engine integration point — assets registered but playback
    // requires flame_audio or audioplayers which are not in this build.
    // The system is ready to wire up when audio assets are available.
    if (!state.isSfxAudible) return;
  }
}

final audioProvider = NotifierProvider<AudioManager, AudioSettings>(AudioManager.new);
