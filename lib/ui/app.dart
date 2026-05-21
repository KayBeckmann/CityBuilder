import 'package:city_builder/features/locale_provider.dart';
import 'package:city_builder/game/city_game.dart';
import 'package:city_builder/l10n/app_localizations.dart';
import 'package:city_builder/ui/game_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CityBuilderApp extends ConsumerWidget {
  const CityBuilderApp({super.key, required this.game});

  final CityGame game;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      title: 'CityBuilder',
      debugShowCheckedModeBanner: false,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF4CAF50),
          secondary: Color(0xFF2196F3),
          surface: Color(0xFF1a1a2e),
        ),
      ),
      home: GameScreen(game: game),
    );
  }
}
