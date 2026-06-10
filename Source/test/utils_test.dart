import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stundaa/services/utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Utils Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await initPreferences();
    });

    test('getItemValue handles nested keys', () {
      final data = {
        'user': {
          'profile': {'name': 'Bintang'}
        }
      };
      expect(getItemValue(data, 'user.profile.name'), 'Bintang');
      expect(getItemValue(data, 'user.missing'), isNull);
      expect(getItemValue(data, 'user.missing', fallbackValue: 'Default'), 'Default');
    });

    test('getItemValue handles json string input', () {
      const jsonStr = '{"id": 123}';
      expect(getItemValue(jsonStr, 'id'), 123);
    });

    test('apiUrl builds correct Uri with query params', () {
      final uri = apiUrl('test-path', queryParameters: {'q': 'search'});
      expect(uri.path, contains('test-path'));
      expect(uri.queryParameters['q'], 'search');
    });

    test('setPreferences and getPreferences work', () async {
      await setPreferences('test_key', 'test_value');
      expect(getPreferences('test_key'), 'test_value');
    });

    test('localizedJustNowLabel returns correct string for locale', () async {
      await setPreferences('locale', 'en');
      expect(localizedJustNowLabel(), 'Just Now');
      await setPreferences('locale', 'it');
      expect(localizedJustNowLabel(), 'Proprio adesso');
    });
    
    test('createMaterialColor generates valid swatch', () {
      final color = createMaterialColor(Colors.blue);
      expect(color.shade50, isNotNull);
      expect(color.shade500.toARGB32(), Colors.blue.toARGB32());
    });
  });
}
