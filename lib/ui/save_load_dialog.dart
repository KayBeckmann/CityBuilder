import 'package:city_builder/features/game_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SaveDialog extends ConsumerWidget {
  const SaveDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final json = ref.read(gameProvider.notifier).saveToJson();

    return AlertDialog(
      backgroundColor: const Color(0xFF1a1a2e),
      title: const Text('Spielstand speichern',
          style: TextStyle(color: Colors.white)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kopiere diesen JSON-String und bewahre ihn auf:',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Container(
            height: 120,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(6),
            ),
            child: SingleChildScrollView(
              child: SelectableText(
                json.length > 500
                    ? '${json.substring(0, 500)}…'
                    : json,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 9,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton.icon(
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: json));
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('In Zwischenablage kopiert'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
          icon: const Icon(Icons.copy, size: 16),
          label: const Text('Kopieren',
              style: TextStyle(color: Colors.white70)),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4CAF50),
            foregroundColor: Colors.black,
          ),
          child: const Text('OK'),
        ),
      ],
    );
  }
}

class LoadDialog extends ConsumerStatefulWidget {
  const LoadDialog({super.key});

  @override
  ConsumerState<LoadDialog> createState() => _LoadDialogState();
}

class _LoadDialogState extends ConsumerState<LoadDialog> {
  final _ctrl = TextEditingController();
  bool _hasError = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1a1a2e),
      title: const Text('Spielstand laden',
          style: TextStyle(color: Colors.white)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Füge den gespeicherten JSON-String ein:',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _ctrl,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
            maxLines: 5,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.black45,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(
                  color: _hasError ? Colors.red : Colors.transparent,
                ),
              ),
              hintText: 'JSON hier einfügen…',
              hintStyle: const TextStyle(color: Colors.white24),
              errorText: _hasError ? 'Ungültiger Spielstand' : null,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Abbrechen',
              style: TextStyle(color: Colors.white38)),
        ),
        ElevatedButton(
          onPressed: () {
            try {
              ref
                  .read(gameProvider.notifier)
                  .loadFromJson(_ctrl.text.trim());
              Navigator.of(context).pop();
            } catch (_) {
              setState(() => _hasError = true);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2196F3),
            foregroundColor: Colors.white,
          ),
          child: const Text('Laden'),
        ),
      ],
    );
  }
}
