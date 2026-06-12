import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:progress_loading_button/progress_loading_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stundaa/l10n/app_localizations.dart';
import 'package:stundaa/screens/user/change_password.dart';
import 'package:stundaa/services/auth.dart' as auth;
import 'package:stundaa/services/data_transport.dart' as data_transport;
import 'package:stundaa/services/utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    auth.authToken = '';
    auth.userInfo = {};
    sharedPreferencesCache = null;
    SharedPreferences.setMockInitialValues({
      'authToken': 'dummy-new-account-token',
      'userInfo': jsonEncode([
        {
          'username': 'dummy_user',
          'email': 'dummy@example.com',
        }
      ]),
    });
    await auth.fetchAuthInfo();
  });

  test('buildChangePasswordInputData uses dummy account password values', () {
    final payload = buildChangePasswordInputData(
      oldPassword: 'oldpass123',
      password: 'newpass123',
      passwordConfirmation: 'newpass123',
    );

    expect(payload['old_password'], 'oldpass123');
    expect(payload['password'], 'newpass123');
    expect(payload['password_confirmation'], 'newpass123');
  });

  testWidgets('valid change password form sends update-password request',
      (tester) async {
    var requestCount = 0;
    String? requestedPath;
    data_transport.httpClient = MockClient((request) async {
      requestCount += 1;
      requestedPath = request.url.path;
      return http.Response(
        jsonEncode({
          'reaction': 1,
          'data': {'message': 'Password updated'}
        }),
        200,
      );
    });

    await pumpChangePasswordPage(tester);
    await fillChangePasswordForm(
      tester,
      oldPassword: 'oldpass123',
      password: 'newpass123',
      passwordConfirmation: 'newpass123',
    );
    await submitChangePasswordForm(tester);

    expect(requestCount, 1);
    expect(requestedPath, endsWith('/api/update-password'));
  });

  testWidgets('mismatched confirmation blocks change password request',
      (tester) async {
    var requestCount = 0;
    data_transport.httpClient = MockClient((request) async {
      requestCount += 1;
      return http.Response(jsonEncode({'reaction': 1}), 200);
    });

    await pumpChangePasswordPage(tester);
    await fillChangePasswordForm(
      tester,
      oldPassword: 'oldpass123',
      password: 'newpass123',
      passwordConfirmation: 'otherpass123',
    );
    await submitChangePasswordForm(tester);

    expect(requestCount, 0);
    expect(
      find.text('The password confirmation does not match'),
      findsOneWidget,
    );
  });

  testWidgets('same old and new password blocks change password request',
      (tester) async {
    var requestCount = 0;
    data_transport.httpClient = MockClient((request) async {
      requestCount += 1;
      return http.Response(jsonEncode({'reaction': 1}), 200);
    });

    await pumpChangePasswordPage(tester);
    await fillChangePasswordForm(
      tester,
      oldPassword: 'samepass123',
      password: 'samepass123',
      passwordConfirmation: 'samepass123',
    );
    await submitChangePasswordForm(tester);

    expect(requestCount, 0);
    expect(
      find.text('New password must be different from current password'),
      findsOneWidget,
    );
  });
}

Future<void> pumpChangePasswordPage(WidgetTester tester) async {
  await tester.pumpWidget(
    const MaterialApp(
      locale: Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: ChangePasswordPage(),
    ),
  );
  await tester.pump();
}

Future<void> fillChangePasswordForm(
  WidgetTester tester, {
  required String oldPassword,
  required String password,
  required String passwordConfirmation,
}) async {
  final fields = find.byType(TextFormField);
  expect(fields, findsNWidgets(3));

  await tester.enterText(fields.at(0), oldPassword);
  await tester.enterText(fields.at(1), password);
  await tester.enterText(fields.at(2), passwordConfirmation);
}

Future<void> submitChangePasswordForm(WidgetTester tester) async {
  final button = find.byType(LoadingButton);
  await tester.ensureVisible(button);
  await tester.tap(button);
  await tester.pump(const Duration(milliseconds: 100));
}
