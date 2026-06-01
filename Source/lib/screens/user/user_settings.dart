import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:form_validator/form_validator.dart';
import '../../components/AppBar.dart';
import '../../components/input_field.dart';
import '../../services/auth.dart' as auth;
import '../../services/locale_model.dart';
import '../../services/utils.dart';
import '../../common/widgets/common.dart';
import '../../services/data_transport.dart' as data_transport;
import '../../support/app_locales.dart';
import '../../support/app_theme.dart' as app_theme;
import '../landing.dart';

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
      appBar: innerAppBar(
        title: context.lwTranslate.settings,
        context: context,
      ),
      body: Padding(
        padding: const EdgeInsets.only(
          left: 32,
          right: 32,
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 30),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Column(
                      children: [
                        Text(context.lwTranslate.selectLanguage),
                        SizedBox(height: 10,),
                        Consumer<LocaleModel>(
                          builder: (context, localeModel, child) => Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.all(Radius.circular(5)),
                              border: Border(
                                bottom: BorderSide(color: Color.fromRGBO(212, 212, 212, 1)),
                                top: BorderSide(color: Color.fromRGBO(212, 212, 212, 1)),
                                right: BorderSide(color: Color.fromRGBO(212, 212, 212, 1)),
                                left: BorderSide(color: Color.fromRGBO(212, 212, 212, 1)),
                              ),
                            ),
                            padding: EdgeInsets.only(left: 5),

                            child: DropdownButton(
                              underline: SizedBox(),
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          foregroundColor: app_theme.white,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          context.lwTranslate.goBack,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black,
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
    );
  }
}
