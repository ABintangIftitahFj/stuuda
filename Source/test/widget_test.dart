import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stundaa/main.dart';
import 'package:stundaa/services/utils.dart';

void main() {
  test('configItem returns its fallback when a key is missing', () {
    expect(configItem('missing_key', fallbackValue: 'fallback'), 'fallback');
  });

  testWidgets('STUNDAA app renders with the default locale fallback',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.title, 'STUNDAA');
  });
}
