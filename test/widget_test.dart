import 'package:city_builder/game/city_game.dart';
import 'package:city_builder/ui/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App starts without exception', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: CityBuilderApp(game: CityGame()),
      ),
    );
    expect(find.byType(CityBuilderApp), findsOneWidget);
  });
}
