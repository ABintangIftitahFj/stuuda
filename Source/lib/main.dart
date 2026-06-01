// main backup
import './provider/chatbox_provider.dart';
import './provider/contacts_provider.dart';
import './screens/whatsapp/controller/chatbox_controller.dart';
import '/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import './l10n/app_localizations.dart';
import 'services/locale_model.dart';
import 'services/utils.dart';
import './screens/landing.dart';
import '../support/app_theme.dart' as app_theme;
import 'package:provider/provider.dart';
import 'support/app_locales.dart';

// list of available locales
List<Locale> supportedLocales = <Locale>[
  const Locale('en'),
  const Locale('it'),
];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initPreferences();
  // List configLocales = configItem('locales', fallbackValue: []);
  if (appLocales.isNotEmpty) {
    for (var element in appLocales) {
      supportedLocales.add(Locale(element['code']));
    }
  }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ContactProvider()),
        ChangeNotifierProvider(create: (_) => ChatboxController()),
      ],
      child: const MyApp(),
    ),
    // ChangeNotifierProvider<ContactProvider>(
    //   create: (_) => ContactProvider(),
    //   child: const MyApp(),
    // ),
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
        builder: (context, localeModel, child) => MaterialApp(
          title: 'WhatsJet',
          theme: ThemeData(
            /// fontFamily: 'Poppins',
            useMaterial3: true,
            brightness: Brightness.light,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            canvasColor: Colors.white,
            primaryColor: app_theme.primary,
            colorScheme: ColorScheme.fromSwatch(
              backgroundColor: app_theme.backgroundColor,
              errorColor: Colors.red,
              brightness: Brightness.light,
              primarySwatch: createMaterialColor(
                app_theme.primary,
              ),
            ).copyWith(
                // surface: app_theme.backgroundColor,
                ),
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
              : Locale(configItem('default_language_code')),
        ),
      ),
    );
  }
}
