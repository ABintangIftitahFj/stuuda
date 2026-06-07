import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stundaa/common/widgets/common.dart';
import 'package:stundaa/services/locale_model.dart';
import 'package:stundaa/services/utils.dart';
import 'package:stundaa/support/app_locales.dart';
import 'package:stundaa/support/app_theme.dart' as app_theme;
import 'package:stundaa/screens/landing.dart';

class UserSettingsPage extends StatefulWidget {
  const UserSettingsPage({
    super.key,
  });
  @override
  State<UserSettingsPage> createState() => _UserSettingsPageState();
}

class _UserSettingsPageState extends State<UserSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  bool isLoadingInProcess = true;
  Map mobileNumberOptions = {};
  Map<String, dynamic> formInputData = {};
  Map<String, dynamic> accountDeleteInputData = {};
  List<DropdownMenuItem<String>> localesDropdownItems =
      <DropdownMenuItem<String>>[];
  String selectedLocale = getCurrentLocale().toString();
  List availableLocales = [];

  @override
  initState() {
    // data_transport.get(
    //   'notification/get-setting-data',
    //   onSuccess: (responseData) {
    //     setState(() {
    //       formInputData = getItemValue(responseData, 'data.userSettingData');
    //       mobileNumberOptions = getItemValue(responseData,
    //           'data.userSettingData.user_choice_display_mobile_number');
    //       isLoadingInProcess = false;
    //     });
    //   },
    // );

    if (appLocales.isNotEmpty) {
      for (var element in appLocales) {
        localesDropdownItems.add(
          DropdownMenuItem(
            value: element['code'],
            child: Text(element['name']),
          ),
        );
        availableLocales.add(element['code']);
      }
      if (!availableLocales.contains(selectedLocale)) {
        selectedLocale = configItem('default_language_code');
      }
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: app_theme.backgroundColor,
      appBar: innerAppBar(
        title: context.lwTranslate.settings,
        context: context,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Padding(
          padding: const EdgeInsets.only(top: 30),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: app_theme.insetPanelDecoration(radius: 24).copyWith(
                  gradient: app_theme.cardGradient,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: app_theme.surfaceMuted,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            CupertinoIcons.globe,
                            color: app_theme.iceBlue,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.lwTranslate.settings,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Language and regional preferences',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: app_theme.iceBlue),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.lwTranslate.selectLanguage,
                            style: const TextStyle(
                              color: app_theme.lavenderWhite,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Consumer<LocaleModel>(
                            builder: (context, localeModel, child) => Container(
                              decoration:
                                  app_theme.insetPanelDecoration(radius: 18),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: DropdownButton(
                                dropdownColor: app_theme.surface,
                                style: const TextStyle(
                                    color: app_theme.lavenderWhite),
                                iconEnabledColor: app_theme.iceBlue,
                                underline: const SizedBox(),
                                isExpanded: true,
                                value: selectedLocale,
                                items: localesDropdownItems,
                                onChanged: (String? value) {
                                  if (value != null) {
                                    localeModel.set(Locale(value));
                                    Navigator.of(context).pushAndRemoveUntil(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const LandingPage(
                                                  skipMobileDialog: true,
                                                )),
                                        (route) => false);
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: app_theme.surfaceMuted,
                            foregroundColor: app_theme.lavenderWhite,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            context.lwTranslate.goBack,
                            style: const TextStyle(
                              fontSize: 14,
                              color: app_theme.lavenderWhite,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
