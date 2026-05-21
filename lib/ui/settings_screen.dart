import 'package:city_builder/core/accessibility.dart';
import 'package:city_builder/core/audio_manager.dart';
import 'package:city_builder/features/locale_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audio = ref.watch(audioProvider);
    final accessibility = ref.watch(accessibilityProvider);
    final locale = ref.watch(localeProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0d0d1a),
        title: const Text('Einstellungen', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionHeader(label: 'Sprache / Language'),
          _SettingsCard(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Text('Sprache / Language',
                        style: TextStyle(color: Colors.white70, fontSize: 14)),
                    const Spacer(),
                    _LangButton(
                      code: 'de',
                      label: '🇩🇪 DE',
                      selected: locale.languageCode == 'de',
                      onTap: () => ref
                          .read(localeProvider.notifier)
                          .setLocale(const Locale('de')),
                    ),
                    const SizedBox(width: 8),
                    _LangButton(
                      code: 'en',
                      label: '🇬🇧 EN',
                      selected: locale.languageCode == 'en',
                      onTap: () => ref
                          .read(localeProvider.notifier)
                          .setLocale(const Locale('en')),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SectionHeader(label: 'Schriftgröße / Font Size'),
          _SettingsCard(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Skalierung: ${(accessibility.fontSize * 100).toInt()}%',
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 13),
                    ),
                    Slider(
                      value: accessibility.fontSize,
                      min: 0.8,
                      max: 1.4,
                      divisions: 6,
                      label:
                          '${(accessibility.fontSize * 100).toInt()}%',
                      onChanged: (v) => ref
                          .read(accessibilityProvider.notifier)
                          .setFontSize(v),
                      activeColor: const Color(0xFF4CAF50),
                      inactiveColor: Colors.white12,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SectionHeader(label: 'Audio'),
          _SettingsCard(
            children: [
              SwitchListTile(
                title: const Text('Stummschalten', style: TextStyle(color: Colors.white)),
                value: audio.muted,
                onChanged: (_) => ref.read(audioProvider.notifier).toggleMute(),
                activeColor: const Color(0xFF4CAF50),
              ),
              const Divider(color: Colors.white12),
              _VolumeSlider(
                label: 'Musik',
                icon: Icons.music_note_outlined,
                value: audio.musicVolume,
                enabled: !audio.muted,
                onChanged: (v) => ref.read(audioProvider.notifier).setMusicVolume(v),
              ),
              const SizedBox(height: 8),
              _VolumeSlider(
                label: 'Soundeffekte',
                icon: Icons.volume_up_outlined,
                value: audio.sfxVolume,
                enabled: !audio.muted,
                onChanged: (v) => ref.read(audioProvider.notifier).setSfxVolume(v),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SectionHeader(label: 'Barrierefreiheit'),
          _SettingsCard(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Farbblindheit', style: TextStyle(color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 8),
                    ...ColorBlindMode.values.map((mode) => RadioListTile<ColorBlindMode>(
                          title: Text(mode.label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                          value: mode,
                          groupValue: accessibility.colorBlindMode,
                          onChanged: (v) => ref.read(accessibilityProvider.notifier).setColorBlindMode(v!),
                          activeColor: const Color(0xFF4CAF50),
                          dense: true,
                        )),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SectionHeader(label: 'Über'),
          _SettingsCard(
            children: [
              const ListTile(
                title: Text('Version', style: TextStyle(color: Colors.white70)),
                trailing: Text('0.1.0', style: TextStyle(color: Colors.white38)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF4CAF50),
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0d0d1a),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(children: children),
    );
  }
}

class _LangButton extends StatelessWidget {
  const _LangButton({
    required this.code,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String code;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFF4CAF50).withValues(alpha: 0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: selected
                  ? const Color(0xFF4CAF50)
                  : Colors.white24,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? const Color(0xFF4CAF50) : Colors.white54,
              fontSize: 13,
              fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
            ),
          ),
        ),
      );
}

class _VolumeSlider extends StatelessWidget {
  const _VolumeSlider({
    required this.label,
    required this.icon,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final String label;
  final IconData icon;
  final double value;
  final bool enabled;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: enabled ? Colors.white70 : Colors.white24),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                color: enabled ? Colors.white70 : Colors.white24,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Slider(
              value: value,
              onChanged: enabled ? onChanged : null,
              activeColor: const Color(0xFF4CAF50),
              inactiveColor: Colors.white12,
            ),
          ),
          SizedBox(
            width: 32,
            child: Text(
              '${(value * 100).toInt()}%',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: enabled ? Colors.white38 : Colors.white12,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
