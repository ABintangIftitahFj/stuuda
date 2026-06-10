// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stundaa/services/auth.dart';
import 'package:stundaa/services/utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Auth Service Tests', () {
    setUp(() async {
      authToken = '';
      userInfo = {};
      sharedPreferencesCache = null;
      SharedPreferences.setMockInitialValues({
        'authToken': 'initial-token',
        'userInfo': jsonEncode([{'name': 'Initial User'}])
      });
      await fetchAuthInfo();
    });

    test('isLoggedIn reflects token state', () async {
      expect(isLoggedIn(), isTrue);
      authToken = ''; // Manually clear global variable for test
      sharedPreferencesCache!.setString('authToken', '');
      expect(isLoggedIn(), isFalse);
    });

    test('storeUserInfo updates local data', () async {
      await storeUserInfo([{'name': 'New User'}], vendorUid: 'v-1', uuid: 'u-1');
      expect(getAuthInfo('name'), 'New User');
      expect(getAuthInfo('vendor_uid'), 'v-1');
    });

    test('logout clears credentials', () async {
      await logout();
      expect(isLoggedIn(), isFalse);
      expect(getAuthToken(), '');
    });

    test('getAuthInfo returns full map when no key provided', () async {
      await Future.delayed(Duration.zero);
      final info = getAuthInfo();
      print('DEBUG: userInfo content: $info');
      expect(info, isA<Map>());
      expect(info['name'], 'Initial User');
    });
  });
}
