import 'dart:convert';
import 'dart:developer';
import 'package:universal_io/io.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:stundaa/components/slide_page_route.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stundaa/l10n/app_localizations.dart';
import 'package:stundaa/support/app_theme.dart' as app_theme;
import 'package:stundaa/support/app_config.dart' as app_config;

SharedPreferences? sharedPreferencesCache;
String? userMobileNumber;

/// Top-level delegate functions for backwards compatibility.
dynamic configItem(String itemRequested, {fallbackValue}) =>
    AppUtils.configItem(itemRequested, fallbackValue: fallbackValue);

void pr(dynamic params, {int lineNumber = 1}) =>
    AppUtils.pr(params, lineNumber: lineNumber);

void printLongString(String text) => AppUtils.printLongString(text);

void dd(dynamic params) => AppUtils.dd(params);

dynamic getItemValue(sourceItem, String keyToAccess, {dynamic fallbackValue}) =>
    AppUtils.getItemValue(sourceItem, keyToAccess, fallbackValue: fallbackValue);

void showSuccessMessage(BuildContext context, String? message) =>
    AppUtils.showSuccessMessage(context, message);

void showErrorMessage(BuildContext context, String? message) =>
    AppUtils.showErrorMessage(context, message);

Future<void> clearDemoPhoneNumbers() => AppUtils.clearDemoPhoneNumbers();

void showToastMessage(BuildContext context, String message, {String type = 'message'}) =>
    AppUtils.showToastMessage(context, message, type: type);

Uri apiUrl(String url, {Map<String, dynamic>? queryParameters, BuildContext? context, bool useApiUrl = true}) =>
    AppUtils.apiUrl(url, queryParameters: queryParameters, context: context, useApiUrl: useApiUrl);

void navigatePage(BuildContext context, pageClass) =>
    AppUtils.navigatePage(context, pageClass);

void jsdd(response) => AppUtils.jsdd(response);

bool isIOSPlatform() => AppUtils.isIOSPlatform();

MaterialColor createMaterialColor(Color color) => AppUtils.createMaterialColor(color);

Future<void> initPreferences() => AppUtils.initPreferences();

dynamic getPreferences(key, {defaultValue}) =>
    AppUtils.getPreferences(key, defaultValue: defaultValue);

getCurrentLocale() => AppUtils.getCurrentLocale();

String geUpdatedMobileNumber() => AppUtils.geUpdatedMobileNumber();

Future<bool?> setPreferences(key, value) => AppUtils.setPreferences(key, value);

/// Structured class containing all utility helpers.
class AppUtils {
  /// get configuration settings from app_config file
  static dynamic configItem(String itemRequested, {fallbackValue}) {
    return getItemValue(app_config.configItems, itemRequested,
        fallbackValue: fallbackValue);
  }

  /// print debug messages
  static void pr(dynamic params, {int lineNumber = 1}) {
    if (app_config.debug == true) {
      List lines = StackTrace.current.toString().trimRight().split('\n');
      printLongString('\x1B[34m$params\x1B[0m');
      printLongString(
          // ignore: prefer_interpolation_to_compose_strings
          '\x1B[36mRef#----------------------------------------------------------------------${DateTime.now()} -' +
              lines[lineNumber] +
              '\x1B[0m');
    }
  }

  /// Print Long String
  static void printLongString(String text) {
    final RegExp pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
    pattern
        .allMatches(text)
        .forEach((RegExpMatch match) => log(
              match.group(0) ?? '',
            ));
  }

  // print message with exit for debug
  static void dd(dynamic params) {
    if (app_config.debug == true) {
      List lines = StackTrace.current.toString().trimRight().split('\n');
      printLongString('\x1B[34m$params\x1B[0m');
      printLongString(
          // ignore: prefer_interpolation_to_compose_strings
          '\x1B[36m-----------------------------------------------------------------------------------' +
              lines[1] +
              '\x1B[0m');
      throw '_______ dd';
    }
  }

  /// access the array/map values using . notation
  static dynamic getItemValue(sourceItem, String keyToAccess, {dynamic fallbackValue}) {
    if (sourceItem == null) {
      return fallbackValue;
    }
    if (sourceItem is String) {
      sourceItem = jsonDecode(sourceItem);
    }
    var keyArray = keyToAccess.split('.');
    var valueToReturn = sourceItem;
    for (var element in keyArray) {
      try {
        valueToReturn = valueToReturn[element];
      } catch (e) {
        return fallbackValue;
      }
    }
    return valueToReturn ?? fallbackValue;
  }

  /// show success toast message
  static void showSuccessMessage(BuildContext context, String? message) {
    if ((message != '') && (message != null)) {
      showToastMessage(context, message, type: 'success');
    }
  }

  /// show error message
  static void showErrorMessage(BuildContext context, String? message) {
    if ((message != '') && (message != null)) {
      showToastMessage(context, message, type: 'error');
    }
  }

  static Future<void> clearDemoPhoneNumbers() async {
    userMobileNumber = null;
    sharedPreferencesCache?.remove('user_mobile_number');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_mobile_number');
    await prefs.remove('first_name');
    await prefs.remove('last_name');
    await prefs.remove('email');
  }

  /// show toast message
  static void showToastMessage(
    BuildContext context,
    String message, {
    String type = 'message',
  }) {
    final snackBar = SnackBar(
      content: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
        ),
      ),
      backgroundColor: type == 'success'
          ? app_theme.success
          : ((type == 'error') ? app_theme.error : app_theme.black),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // build api url using config base api url and sent path
  static Uri apiUrl(
    String url, {
    Map<String, dynamic>? queryParameters,
    BuildContext? context,
    bool useApiUrl = true,
  }) {
    String processedUrl = url;
    if (!url.startsWith('http')) {
      processedUrl =
          useApiUrl ? app_config.baseApiUrl + url : app_config.baseUrl + url;
    }

    queryParameters ??= {};
    if (configItem('demoMode', fallbackValue: false) == true) {
      queryParameters.addAll({
        'lang': getCurrentLocale().languageCode,
        'demo_phone_numbers': geUpdatedMobileNumber()
      });
    } else {
      queryParameters.addAll({'lang': getCurrentLocale().languageCode});
    }

    String queryString = '';
    queryParameters.forEach((key, value) {
      if (value is List) {
        for (int i = 0; i < value.length; i++) {
          var elementValue = value[i];
          if (elementValue is String ||
              elementValue is int ||
              elementValue is double) {
            queryString += '$key[$elementValue]=$elementValue&';
          } else {
            queryString += '$key[]=$elementValue&';
          }
        }
      } else {
        queryString += '$key=$value&';
      }
    });
    if (queryString != '') {
      processedUrl = processedUrl.contains('?')
          ? '$processedUrl&$queryString'
          : '$processedUrl?$queryString';
    }
    return Uri.parse(processedUrl);
  }

  // Navigate page helper
  static void navigatePage(BuildContext context, pageClass) {
    Navigator.push(
      context,
      SlideLeftRoute(page: pageClass),
    );
  }

  // response debug messages print from server
  static void jsdd(response) {
    if (app_config.debug) {
      bool ddExecuted = false;
      bool prExecuted = false;
      bool clogExecuted = false;
      if ((response['__dd'] == true) && (!response['__pr'].isEmpty)) {
        if (!prExecuted) {
          int prCount = 1;
          for (var prValue in response['__pr']) {
            String debugBacktrace = '';
            printLongString(
                "Server __pr $prCount --------------------------------------------------");
            for (String key in prValue.keys) {
              var value = prValue[key];
              if (key != 'debug_backtrace') {
                printLongString(value);
              } else {
                debugBacktrace = value;
              }
            }
            printLongString(
                'Reference  --------------------------------------------------');
            printLongString(debugBacktrace);
            prCount++;
          }
          prExecuted = true;
          printLongString(
              "------------------------------------------------------------ __pr end");
        }
      }
      if ((response['__dd'] == '__dd') && (response['__clog'] == '__clog')) {
        if (!clogExecuted) {
          printLongString(response);
          clogExecuted = true;
        }
      }

      if (response['__dd'] == '__dd') {
        if (!ddExecuted) {
          printLongString(
              'Server __dd  --------------------------------------------------');
          for (String key in response['data'].keys) {
            var value = response['data'][key];
            if (key != 'debug_backtrace') {
              printLongString(value);
            } else {
              printLongString(
                  "Reference  --------------------------------------------------");
              printLongString(value);
            }
          }
          ddExecuted = true;
        }
        throw '------------------------------------------------------------ __dd end.';
      }
    }
  }

  // check if ios platform
  static bool isIOSPlatform() {
    if (kIsWeb) return false;
    return Platform.isIOS;
  }

  // material color swatch generator
  static MaterialColor createMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map<int, Color> swatch = {};
    final int r = (color.r * 255).round().clamp(0, 255),
        g = (color.g * 255).round().clamp(0, 255),
        b = (color.b * 255).round().clamp(0, 255);

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.toARGB32(), swatch);
  }

  static Future<void> initPreferences() async {
    sharedPreferencesCache ??= await SharedPreferences.getInstance();
  }

  static dynamic getPreferences(key, {defaultValue}) {
    return sharedPreferencesCache?.get(key) ?? defaultValue;
  }

  static Locale getCurrentLocale() {
    String? defaultLocale = 'en';
    if (!kIsWeb) {
      defaultLocale = Platform.localeName.split('_')[0];
    }
    return Locale(getPreferences('locale') ??
        configItem('default_language_code') ??
        defaultLocale);
  }

  static String geUpdatedMobileNumber() {
    String? mobileNumber =
        userMobileNumber ?? getPreferences('user_mobile_number');
    pr("user_mobile_number $mobileNumber");
    return mobileNumber ?? '';
  }

  static Future<bool?> setPreferences(key, value) async {
    if (key == 'user_mobile_number') {
      userMobileNumber = value.toString();
    }
    final result = await sharedPreferencesCache?.setString(key, value.toString());
    return result;
  }
}

extension BuildContextTranslateExt on BuildContext {
  AppLocalizations get lwTranslate => AppLocalizations.of(this);
}
