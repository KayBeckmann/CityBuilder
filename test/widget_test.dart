import 'package:city_builder/game/city_game.dart';
import 'package:city_builder/game/sprite_registry.dart';
import 'package:city_builder/ui/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    // Disable sprite loading in tests — assets are not available in test runner
    SpriteRegistry.I.disableForTest();
  });

  testWidgets('App starts without exception', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: CityBuilderApp(game: CityGame()),
      ),
    );
    expect(find.byType(CityBuilderApp), findsOneWidget);
  });
}
