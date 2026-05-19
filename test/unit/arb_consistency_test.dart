import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ARB key consistency', () {
    late Map<String, dynamic> de;
    late Map<String, dynamic> en;

    setUpAll(() async {
      final deContent = await rootBundle.loadString('lib/l10n/app_de.arb');
      final enContent = await rootBundle.loadString('lib/l10n/app_en.arb');
      de = jsonDecode(deContent) as Map<String, dynamic>;
      en = jsonDecode(enContent) as Map<String, dynamic>;
    });

    test('DE has at least as many keys as EN', () {
      final deKeys = de.keys.where((k) => !k.startsWith('@')).toSet();
      final enKeys = en.keys.where((k) => !k.startsWith('@')).toSet();
      final missing = enKeys.difference(deKeys);
      expect(missing, isEmpty, reason: 'DE is missing keys: $missing');
    });

    test('EN has all DE keys', () {
      final deKeys = de.keys.where((k) => !k.startsWith('@')).toSet();
      final enKeys = en.keys.where((k) => !k.startsWith('@')).toSet();
      final missing = deKeys.difference(enKeys);
      expect(missing, isEmpty, reason: 'EN is missing keys: $missing');
    });
  });
}
