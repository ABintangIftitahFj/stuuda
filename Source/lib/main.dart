import 'dart:ui';

import 'package:stundaa/provider/contacts_provider.dart';
import 'package:stundaa/screens/whatsapp/controller/chatbox_controller.dart';
import 'package:stundaa/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stundaa/l10n/app_localizations.dart';
import 'package:stundaa/services/locale_model.dart';
import 'package:stundaa/services/utils.dart';
import 'package:stundaa/screens/landing.dart';
import 'package:stundaa/support/app_theme.dart' as app_theme;
import 'package:provider/provider.dart';
import 'package:stundaa/support/app_locales.dart';

// list of available locales
List<Locale> supportedLocales = <Locale>[
  const Locale('en'),
  const Locale('it'),
];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Tambahkan error handler untuk menangkap crash saat startup
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint("Startup Error: ${details.exception}");
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint("Uncaught Startup Error: $error");
    debugPrintStack(stackTrace: stack);
    return true;
  };

  try {
    await initPreferences();
    if (appLocales.isNotEmpty) {
      for (var element in appLocales) {
        supportedLocales.add(Locale(element['code']));
      }
    }
  } catch (e) {
    debugPrint("Initialization Error: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ContactProvider()),
        ChangeNotifierProvider(create: (_) => ChatboxController()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LocaleModel(),
      child: Consumer<LocaleModel>(
        builder: (context, localeModel, child) {
          final baseTheme = ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          );
          final textTheme = GoogleFonts.plusJakartaSansTextTheme(
            baseTheme.textTheme,
          ).copyWith(
            displayLarge: GoogleFonts.spaceGrotesk(
              color: app_theme.lavenderWhite,
              fontWeight: FontWeight.w700,
              letterSpacing: -1.8,
            ),
            displayMedium: GoogleFonts.spaceGrotesk(
              color: app_theme.lavenderWhite,
              fontWeight: FontWeight.w700,
              letterSpacing: -1.4,
            ),
            headlineMedium: GoogleFonts.spaceGrotesk(
              color: app_theme.lavenderWhite,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.9,
            ),
            titleLarge: GoogleFonts.plusJakartaSans(
              color: app_theme.lavenderWhite,
              fontWeight: FontWeight.w700,
            ),
            titleMedium: GoogleFonts.plusJakartaSans(
              color: app_theme.lavenderWhite,
              fontWeight: FontWeight.w600,
            ),
            bodyLarge: GoogleFonts.plusJakartaSans(
              color: app_theme.lavenderWhite,
              fontWeight: FontWeight.w500,
            ),
            bodyMedium: GoogleFonts.plusJakartaSans(
              color: app_theme.secondary,
              fontWeight: FontWeight.w500,
            ),
            labelLarge: GoogleFonts.plusJakartaSans(
              color: app_theme.black,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          );

          return MaterialApp(
            title: 'STUNDAA',
            theme: baseTheme.copyWith(
              scaffoldBackgroundColor: app_theme.backgroundColor,
              canvasColor: app_theme.backgroundColor,
              primaryColor: app_theme.primary,
              colorScheme: const ColorScheme.dark(
                primary: app_theme.primary,
                onPrimary: app_theme.black,
                secondary: app_theme.cyanGlow,
                onSecondary: app_theme.black,
                surface: app_theme.surface,
                onSurface: app_theme.lavenderWhite,
                error: app_theme.error,
                onError: Colors.white,
              ),
              appBarTheme: AppBarTheme(
                backgroundColor: Colors.transparent,
                foregroundColor: app_theme.lavenderWhite,
                elevation: 0,
                centerTitle: false,
                titleTextStyle: GoogleFonts.plusJakartaSans(
                  color: app_theme.lavenderWhite,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              cardColor: app_theme.surface,
              dividerColor: app_theme.outlineSoft,
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: const Color.fromRGBO(255, 255, 255, 0.06),
                labelStyle: GoogleFonts.plusJakartaSans(
                  color: app_theme.iceBlue,
                  fontWeight: FontWeight.w500,
                ),
                hintStyle: GoogleFonts.plusJakartaSans(
                  color: app_theme.secondary.withValues(alpha: 0.78),
                  fontWeight: FontWeight.w500,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(
                    color: Color.fromRGBO(167, 223, 255, 0.20),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(
                    color: app_theme.cyanGlow,
                    width: 1.5,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(color: app_theme.error),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide:
                      const BorderSide(color: app_theme.error, width: 1.5),
                ),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: app_theme.primary,
                  foregroundColor: app_theme.black,
                  minimumSize: const Size.fromHeight(56),
                  textStyle: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
              textTheme: textTheme,
            ),
          home: const HomePage(),
          navigatorObservers: [FlutterSmartDialog.observer],
          builder: FlutterSmartDialog.init(),
          initialRoute: '/home',
          debugShowCheckedModeBanner: false,
          routes: <String, WidgetBuilder>{
            "/landing": (BuildContext context) => const LandingPage(),
            "/home": (BuildContext context) => const HomePage(),
          },
          // ...
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          // supportedLocales: AppLocalizations.supportedLocales,
          supportedLocales: supportedLocales,
          locale: (getPreferences('locale') != null)
              ? Locale(getPreferences('locale'))
              : Locale(
                  configItem('default_language_code', fallbackValue: 'en')),
          );
        },
      ),
    );
  }
}
