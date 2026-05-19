import 'package:city_builder/game/city_game.dart';
import 'package:city_builder/ui/game_screen.dart';
import 'package:flutter/material.dart';

class CityBuilderApp extends StatelessWidget {
  const CityBuilderApp({super.key, required this.game});

  final CityGame game;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CityBuilder',
      debugShowCheckedModeBanner: false,
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
