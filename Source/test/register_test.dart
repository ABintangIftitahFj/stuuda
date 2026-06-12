import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stundaa/l10n/app_localizations.dart';
import 'package:stundaa/screens/user/register.dart';
import 'package:stundaa/services/auth.dart' as auth;
import 'package:stundaa/services/data_transport.dart' as data_transport;
import 'package:stundaa/services/utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    auth.authToken = '';
    auth.userInfo = {};
    sharedPreferencesCache = null;
    SharedPreferences.setMockInitialValues({});
    await auth.fetchAuthInfo();
  });

  group('Register payload scenarios', () {
    test('buildRegisterInputData accepts two character username', () {
      final payload = buildRegisterInputData(
        vendorTitle: 'Stundaa Test',
        username: 'jo',
        firstName: 'Jo',
        lastName: 'Tester',
        mobileNumber: '812345678',
        email: 'jo@example.com',
        password: 'password123',
        passwordConfirmation: 'password123',
        termsAccepted: true,
      );

      expect(payload['username'], 'jo');
      expect(payload['terms_and_conditions'], 'on');
    });

    test('buildRegisterInputData uses the latest username value', () {
      var username = 'hiangker';
      username = 'jo';

      final payload = buildRegisterInputData(
        vendorTitle: 'Stundaa Test',
        username: username,
        firstName: 'Jo',
        lastName: 'Tester',
        mobileNumber: '812345678',
        email: 'jo@example.com',
        password: 'password123',
        passwordConfirmation: 'password123',
        termsAccepted: true,
      );

      expect(payload['username'], 'jo');
    });

    test('buildRegisterInputData trims text fields but keeps passwords intact',
        () {
      final payload = buildRegisterInputData(
        vendorTitle: '  Stundaa Test  ',
        username: '  jo  ',
        firstName: '  Jo  ',
        lastName: '  Tester  ',
        mobileNumber: '  812345678  ',
        email: '  jo@example.com  ',
        password: ' password123 ',
        passwordConfirmation: ' password123 ',
        termsAccepted: false,
      );

      expect(payload['vendor_title'], 'Stundaa Test');
      expect(payload['username'], 'jo');
      expect(payload['first_name'], 'Jo');
      expect(payload['last_name'], 'Tester');
      expect(payload['mobile_number'], '812345678');
      expect(payload['email'], 'jo@example.com');
      expect(payload['password'], ' password123 ');
      expect(payload['password_confirmation'], ' password123 ');
      expect(payload['terms_and_conditions'], '');
    });

    test('buildRegisterInputData accepts username lengths 2, 3, 4, and 5', () {
      final twoCharPayload = buildRegisterInputData(
        vendorTitle: 'Stundaa Test',
        username: 'jo',
        firstName: 'Jo',
        lastName: 'Tester',
        mobileNumber: '812345678',
        email: 'jo@example.com',
        password: 'password123',
        passwordConfirmation: 'password123',
        termsAccepted: true,
      );
      final threeCharPayload = buildRegisterInputData(
        vendorTitle: 'Stundaa Test',
        username: 'joe',
        firstName: 'Jo',
        lastName: 'Tester',
        mobileNumber: '812345678',
        email: 'joe@example.com',
        password: 'password123',
        passwordConfirmation: 'password123',
        termsAccepted: true,
      );
      final fourCharPayload = buildRegisterInputData(
        vendorTitle: 'Stundaa Test',
        username: 'joey',
        firstName: 'Jo',
        lastName: 'Tester',
        mobileNumber: '812345678',
        email: 'joey@example.com',
        password: 'password123',
        passwordConfirmation: 'password123',
        termsAccepted: true,
      );
      final fiveCharPayload = buildRegisterInputData(
        vendorTitle: 'Stundaa Test',
        username: 'joeya',
        firstName: 'Jo',
        lastName: 'Tester',
        mobileNumber: '812345678',
        email: 'joeya@example.com',
        password: 'password123',
        passwordConfirmation: 'password123',
        termsAccepted: true,
      );

      expect(twoCharPayload['username'], 'jo');
      expect(threeCharPayload['username'], 'joe');
      expect(fourCharPayload['username'], 'joey');
      expect(fiveCharPayload['username'], 'joeya');
    });

    test('buildRegisterInputData uses latest username after 3, 4, 5, then 2',
        () {
      var username = 'joe';
      username = 'joey';
      username = 'joeya';
      username = 'jo';

      final payload = buildRegisterInputData(
        vendorTitle: 'Stundaa Test',
        username: username,
        firstName: 'Jo',
        lastName: 'Tester',
        mobileNumber: '812345678',
        email: 'jo@example.com',
        password: 'password123',
        passwordConfirmation: 'password123',
        termsAccepted: true,
      );

      expect(payload['username'], 'jo');
    });
  });

  group('Register form scenarios', () {
    for (final username in ['jo', 'joe', 'joey', 'joeya']) {
      testWidgets(
          '${username.length} character username sends account creation request',
          (tester) async {
        var requestCount = 0;
        String? requestedPath;
        data_transport.httpClient = MockClient((request) async {
          requestCount += 1;
          requestedPath = request.url.path;
          return http.Response(
            jsonEncode({
              'reaction': 2,
              'data': {'message': 'Mocked duplicate or server-side rejection'}
            }),
            200,
          );
        });

        await pumpRegisterPage(tester);
        await fillRegisterForm(tester, username: username);
        await submitRegisterForm(tester);

        expect(requestCount, 1);
        expect(requestedPath, endsWith('/api/register/vendor'));
        expect(requestedPath, isNot(contains('/activation')));
      });
    }

    testWidgets('one character username blocks account creation request',
        (tester) async {
      var requestCount = 0;
      data_transport.httpClient = MockClient((request) async {
        requestCount += 1;
        return http.Response(
          jsonEncode({
            'reaction': 1,
            'data': {'message': 'Created'}
          }),
          200,
        );
      });

      await pumpRegisterPage(tester);
      await fillRegisterForm(tester, username: 'j');
      await submitRegisterForm(tester);

      expect(requestCount, 0);
      expect(
        find.text('The field must be at least 2 character long'),
        findsWidgets,
      );
    });
  });
}

Future<void> pumpRegisterPage(WidgetTester tester) async {
  await tester.pumpWidget(
    const MaterialApp(
      locale: Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: RegisterPage(),
    ),
  );
  await tester.pump();
}

Future<void> fillRegisterForm(
  WidgetTester tester, {
  required String username,
}) async {
  final fields = find.byType(TextFormField);
  expect(fields, findsNWidgets(8));

  await tester.enterText(fields.at(0), 'Stundaa Test');
  await tester.enterText(fields.at(1), username);
  await tester.enterText(fields.at(2), 'Jo');
  await tester.enterText(fields.at(3), 'Tester');
  await tester.enterText(fields.at(4), '812345678');
  await tester.enterText(fields.at(5), '$username@example.com');
  await tester.enterText(fields.at(6), 'password123');
  await tester.enterText(fields.at(7), 'password123');
  await tester.ensureVisible(find.byType(Checkbox));
  await tester.tap(find.byType(Checkbox));
  await tester.pump();
}

Future<void> submitRegisterForm(WidgetTester tester) async {
  final createAccountButton = find.text('Create Account').last;
  await tester.ensureVisible(createAccountButton);
  await tester.tap(createAccountButton);
  await tester.pump(const Duration(milliseconds: 100));
}
