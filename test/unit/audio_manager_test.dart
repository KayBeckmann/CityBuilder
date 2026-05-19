import 'package:city_builder/core/audio_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

ProviderContainer makeContainer() {
  final c = ProviderContainer();
  addTearDown(c.dispose);
  return c;
}

void main() {
  group('AudioManager', () {
    test('default state has correct values', () {
      final c = makeContainer();
      final s = c.read(audioProvider);
      expect(s.musicVolume, closeTo(0.7, 0.01));
      expect(s.sfxVolume, closeTo(1.0, 0.01));
      expect(s.muted, isFalse);
    });

    test('toggleMute flips muted state', () {
      final c = makeContainer();
      c.read(audioProvider.notifier).toggleMute();
      expect(c.read(audioProvider).muted, isTrue);
      c.read(audioProvider.notifier).toggleMute();
      expect(c.read(audioProvider).muted, isFalse);
    });

    test('setMusicVolume clamps to 0..1', () {
      final c = makeContainer();
      c.read(audioProvider.notifier).setMusicVolume(1.5);
      expect(c.read(audioProvider).musicVolume, closeTo(1.0, 0.01));
      c.read(audioProvider.notifier).setMusicVolume(-0.5);
      expect(c.read(audioProvider).musicVolume, closeTo(0.0, 0.01));
    });

    test('isMusicAudible is false when muted', () {
      final c = makeContainer();
      c.read(audioProvider.notifier).toggleMute();
      expect(c.read(audioProvider).isMusicAudible, isFalse);
    });

    test('trackForPopulation selects correct track', () {
      final c = makeContainer();
      final mgr = c.read(audioProvider.notifier);
      expect(mgr.trackForPopulation(0), MusicTrack.earlyCity);
      expect(mgr.trackForPopulation(5000), MusicTrack.metropolis);
      expect(mgr.trackForPopulation(50000), MusicTrack.spaceAge);
    });
  });
}
