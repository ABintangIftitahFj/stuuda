import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:progress_loading_button/progress_loading_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stundaa/l10n/app_localizations.dart';
import 'package:stundaa/screens/myprofile.dart';
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
          'first_name': 'Dummy',
          'last_name': 'User',
          'mobile_number': '812345678',
          'email': 'dummy@example.com',
        }
      ]),
    });
    await auth.fetchAuthInfo();
  });

  testWidgets('profile name update sends user profile payload', (tester) async {
    Map<String, dynamic>? sentPayload;
    String? requestedPath;
    data_transport.httpClient = MockClient((request) async {
      requestedPath = request.url.path;
      sentPayload = jsonDecode(request.body) as Map<String, dynamic>;
      return http.Response(
        jsonEncode({
          'reaction': 1,
          'data': {'message': 'Updated'}
        }),
        200,
      );
    });

    await pumpMyProfile(tester);
    await tester.tap(find.text('Edit'));
    await tester.pump();

    final fields = find.byType(TextFormField);
    expect(fields, findsNWidgets(4));

    await tester.enterText(fields.at(0), 'Test');
    await tester.enterText(fields.at(1), 'Account');
    await tester.enterText(fields.at(2), '899999999');
    await tester.enterText(fields.at(3), 'test.account@example.com');
    await submitMyProfile(tester);

    expect(requestedPath, endsWith('/api/user/profile-update'));
    expect(sentPayload?['first_name'], 'Test');
    expect(sentPayload?['last_name'], 'Account');
    expect(sentPayload?['mobile_number'], '899999999');
    expect(sentPayload?['email'], 'test.account@example.com');
  });

  testWidgets('one character profile name blocks profile update request',
      (tester) async {
    var requestCount = 0;
    data_transport.httpClient = MockClient((request) async {
      requestCount += 1;
      return http.Response(jsonEncode({'reaction': 1}), 200);
    });

    await pumpMyProfile(tester);
    await tester.tap(find.text('Edit'));
    await tester.pump();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'T');
    await submitMyProfile(tester);

    expect(requestCount, 0);
    expect(
      find.textContaining('2'),
      findsWidgets,
    );
  });
}

Future<void> pumpMyProfile(WidgetTester tester) async {
  await tester.pumpWidget(
    const MaterialApp(
      locale: Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MyProfile(),
    ),
  );
  await tester.pump();
}

Future<void> submitMyProfile(WidgetTester tester) async {
  final button = find.byType(LoadingButton);
  await tester.ensureVisible(button);
  await tester.tap(button);
  await tester.pump(const Duration(milliseconds: 100));
}
