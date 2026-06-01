import 'dart:convert';
import 'package:flutter/material.dart';
import './../../screens/landing.dart';
import '../../screens/user/login.dart';
import 'utils.dart';
import 'data_transport.dart' as data_transport;

class AuthService {}

String authToken = '';
var userInfo = {};
// SharedPreferences? sharedPreferencesCache;

Future redirectIfUnauthenticated(BuildContext context) async {
  await fetchAuthInfo();
  await Future.delayed(Duration.zero, () {
    bool isUserLoggedIn = isLoggedIn();
    if (!isUserLoggedIn) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false);
    }
    return isUserLoggedIn;
  });
  return true;
}

void redirectIfAuthenticated(BuildContext context) {
  Future.delayed(Duration.zero, () {
    if (isLoggedIn() == true) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LandingPage()),
          (route) => false);
    }
  });
}

/// set auth token for the later user
void storeAuthToken(String authToken) async {
  // sharedPreferencesCache ??= await SharedPreferences.getInstance();
  sharedPreferencesCache!.setString('authToken', authToken);
  getAuthToken();
}

void createLoginSession(
  responseData,
  context,
) {
  final vendorUid = responseData['data']['auth_info']['vendor_uid'].toString();
  final uuid = responseData['data']['auth_info']['uuid'].toString();
  storeAuthToken(responseData['data']['access_token']);
  storeUserInfo(
    [responseData['data']['auth_info']['profile']],
    vendorUid: vendorUid,
    uuid: uuid,
  ).then(
    (userInfo) {
      // Navigator.pushAndRemoveUntil(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => LandingPage(
      //       initialNotificationCount: getItemValue(
      //         responseData,
      //         'data.auth_info.notifications.notificationCount',
      //         fallbackValue: 0,
      //       ),
      //     ),
      //   ),
      //       (Route<dynamic> route) => false, // This removes all previous routes
      // );

      navigatePage(
        context,
        LandingPage(
          initialNotificationCount: getItemValue(
            responseData,
            'data.auth_info.notifications.notificationCount',
            fallbackValue: 0,
          ),
          // skipMobileDialog: true,
        ),
      );
    },
  );
}

String getAuthToken() {
  fetchAuthInfo();
  return authToken;
}

bool isLoggedIn() {
  return getAuthToken() != '';
}

Future logout() async {
  storeAuthToken('');
  return await storeUserInfo({});
}

Future storeUserInfo(newUserInfo, {String? vendorUid, String? uuid}) async {
  // sharedPreferencesCache ??= await SharedPreferences.getInstance();
  if (vendorUid != null) {
    newUserInfo[0]['vendor_uid'] = vendorUid;
  }
  if (uuid != null) {
    newUserInfo[0]['uuid'] = uuid;
  }
  sharedPreferencesCache!.setString('userInfo', jsonEncode(newUserInfo));
  getAuthInfo();
}

Future fetchAuthInfo() async {
  // sharedPreferencesCache ??= await SharedPreferences.getInstance();
  authToken = sharedPreferencesCache!.getString('authToken') ?? '';
  var localAuthData = sharedPreferencesCache!.getString('userInfo');
  if (localAuthData != null) {
    userInfo = jsonDecode(localAuthData)[0] ?? {};
  }
  return userInfo;
}

dynamic getAuthInfo([String? itemKey, fallbackValue = '']) {
  fetchAuthInfo();
  if (itemKey != null) {
    return getItemValue(userInfo, itemKey, fallbackValue: fallbackValue);
  } else {
    return userInfo;
  }
}

Future setUserInfo(key, value) async {
  // sharedPreferencesCache ??= await SharedPreferences.getInstance();
  var authInfoData = getAuthInfo();
  authInfoData[key] = value;
  sharedPreferencesCache!.setString('userInfo', jsonEncode([authInfoData]));
  getAuthInfo();
}

// Add to your AuthService class or at the bottom of auth.dart
Future<void> checkAndHandleCSRFExpiry(dynamic error, BuildContext context) async {
  if (error.toString().contains('CSRF token') || error.toString().contains('419')) {
    // Clear session data
    authToken = '';
    userInfo = {};
    await sharedPreferencesCache!.remove('authToken');
    await sharedPreferencesCache!.remove('userInfo');

    // Redirect to login
    if (Navigator.canPop(context)) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
              (route) => false
      );
    }
  }
}

// Add to your AuthService class
 Future<void> simulateCSRFExpiration(BuildContext context) async {
// Clear session data
authToken = '';
userInfo = {};
await sharedPreferencesCache!.remove('authToken');
await sharedPreferencesCache!.remove('userInfo');

// Redirect to login
Navigator.of(context).pushAndRemoveUntil(
MaterialPageRoute(builder: (context) => const LoginPage()),
(route) => false
);
}


refreshUserInfo() async {
  await data_transport.post(
    'get-user-auth-info',
    // inputData: formInputData,
    // context: context,
    // secured: true,
    onSuccess: (responseData) {
      storeUserInfo([getItemValue(responseData, 'data.auth_info.profile')]);
    },
    onFailed: (responseData) {},
  );
  return userInfo;
}
