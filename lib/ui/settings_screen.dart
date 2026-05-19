import 'package:city_builder/core/audio_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audio = ref.watch(audioProvider);

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
          _SectionHeader(label: 'Spiel'),
          _SettingsCard(
            children: [
              ListTile(
                title: const Text('Version', style: TextStyle(color: Colors.white70)),
                trailing: const Text('0.1.0', style: TextStyle(color: Colors.white38)),
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
