import 'package:flutter_test/flutter_test.dart';
import 'package:stundaa/l10n/app_localizations.dart';
import 'package:stundaa/support/app_locales.dart';

void main() {
  test('Indonesian locale is available in app language settings', () {
    expect(appLocales.any((locale) => locale['code'] == 'id'), isTrue);
    expect(
      AppLocalizations.supportedLocales
          .any((locale) => locale.languageCode == 'id'),
      isTrue,
    );
  });
}
