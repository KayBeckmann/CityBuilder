import 'package:city_builder/game/city_game.dart';
import 'package:city_builder/ui/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ProviderScope(
      child: CityBuilderApp(game: CityGame()),
    ),
  );
}
