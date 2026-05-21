import 'package:flame_audio/flame_audio.dart';
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
  MusicTrack? _currentTrack;
  bool _bgmInitialized = false;

  @override
  AudioSettings build() => const AudioSettings();

  void setMusicVolume(double volume) {
    state = state.copyWith(musicVolume: volume.clamp(0, 1));
    _applyMusicVolume();
  }

  void setSfxVolume(double volume) {
    state = state.copyWith(sfxVolume: volume.clamp(0, 1));
  }

  void toggleMute() {
    state = state.copyWith(muted: !state.muted);
    _applyMusicVolume();
  }

  void setMute(bool muted) {
    state = state.copyWith(muted: muted);
    _applyMusicVolume();
  }

  MusicTrack trackForPopulation(int population) {
    if (population >= 50000) return MusicTrack.spaceAge;
    if (population >= 5000) return MusicTrack.metropolis;
    return MusicTrack.earlyCity;
  }

  Future<void> playMusic(MusicTrack track) async {
    if (_currentTrack == track) return;
    _currentTrack = track;
    try {
      _bgmInitialized = true;
      await FlameAudio.bgm.stop();
      if (state.isMusicAudible) {
        await FlameAudio.bgm.play(track.filename, volume: state.musicVolume);
      }
    } catch (_) {}
  }

  Future<void> stopMusic() async {
    _currentTrack = null;
    try {
      await FlameAudio.bgm.stop();
    } catch (_) {}
  }

  void playSfx(SoundEffect effect) {
    if (!state.isSfxAudible) return;
    try {
      FlameAudio.play(effect.filename, volume: state.sfxVolume);
    } catch (_) {}
  }

  void _applyMusicVolume() {
    if (!_bgmInitialized) return;
    try {
      final player = FlameAudio.bgm.audioPlayer;
      if (player == null) return;
      player.setVolume(state.isMusicAudible ? state.musicVolume : 0);
    } catch (_) {}
  }
}

final audioProvider =
    NotifierProvider<AudioManager, AudioSettings>(AudioManager.new);
