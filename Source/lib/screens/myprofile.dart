import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:form_validator/form_validator.dart';
import 'package:progress_loading_button/progress_loading_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stundaa/components/input_field.dart';
import 'package:stundaa/services/auth.dart' as auth;
import 'package:stundaa/support/app_theme.dart' as app_theme;
import 'package:stundaa/services/utils.dart';
import 'package:stundaa/common/widgets/common.dart';
import 'package:stundaa/services/data_transport.dart' as data_transport;

class MyProfile extends StatefulWidget {
  const MyProfile({super.key});

  @override
  State createState() => MyProfileState();
}

class MyProfileState extends State<MyProfile>
    with SingleTickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  bool isEditable = false;
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _mobileNumberController = TextEditingController();
  final _emailController = TextEditingController();
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    setState(() {
      _initializePrefs();
    });

    _firstNameController.text = auth.getAuthInfo('first_name') ?? '';
    _lastNameController.text = auth.getAuthInfo('last_name') ?? '';
    _mobileNumberController.text = auth.getAuthInfo('mobile_number') ?? '';
    _emailController.text = auth.getAuthInfo('email') ?? '';
  }

  Future<void> _initializePrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _loadProfileData();
  }

  Future<void> _saveProfileDataToPrefs() async {
    await _prefs.setString('first_name', _firstNameController.text);
    await _prefs.setString('last_name', _lastNameController.text);
    await _prefs.setString('mobile_number', _mobileNumberController.text);
    await _prefs.setString('email', _emailController.text);
  }

  Future<void> _loadProfileData() async {
    setState(() {
      _firstNameController.text = _prefs.getString('first_name') ??
          auth.getAuthInfo('first_name') ??
          '';
      _lastNameController.text =
          _prefs.getString('last_name') ?? auth.getAuthInfo('last_name') ?? '';
      _mobileNumberController.text = _prefs.getString('mobile_number') ??
          auth.getAuthInfo('mobile_number') ??
          '';
      _emailController.text =
          _prefs.getString('email') ?? auth.getAuthInfo('email') ?? '';
    });
  }

  Future<void> savePfofileUpdate() async {
    final Map<String, dynamic> payload = {
      'first_name': _firstNameController.text,
      'last_name': _lastNameController.text,
      'mobile_number': _mobileNumberController.text,
      'email': _emailController.text,
    };
    try {
      await data_transport.post(
        'user/profile-update',
        inputData: payload,
        context: context,
        onSuccess: (responseData) {
          _saveProfileDataToPrefs();
          // Navigator.pop(context);
        },
        onFailed: (responseData) {
          _saveProfileDataToPrefs();
        },
      );
    } catch (e) {
      pr("Profile update failed: $e");
    } finally {}
  }

  @override
  Future<void> dispose() async {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _mobileNumberController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: app_theme.backgroundColor,
      appBar: innerAppBar(
        title: context.lwTranslate.myProfile,
        context: context,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Personal workspace details',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: app_theme.iceBlue,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  if (!isEditable)
                    FilledButton.tonal(
                      style: FilledButton.styleFrom(
                        backgroundColor: app_theme.surfaceMuted,
                        foregroundColor: app_theme.iceBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          isEditable = true;
                        });
                      },
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(CupertinoIcons.pencil, size: 15),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              // User Information Container
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: app_theme.insetPanelDecoration(radius: 24).copyWith(
                  gradient: app_theme.cardGradient,
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: app_theme.surfaceMuted,
                        radius: 25,
                        child:
                            Icon(CupertinoIcons.person, color: app_theme.iceBlue),
                      ),
                      title: Text(
                        '${auth.getAuthInfo('username')}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: app_theme.lavenderWhite,
                        ),
                      ),
                      subtitle: Text(_emailController.text,
                          style: const TextStyle(
                            fontSize: 10,
                            color: app_theme.secondary,
                          )),
                      // subtitle: Text(auth.getAuthInfo('email'),
                      //     style: const TextStyle(fontSize: 10)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Editable Input Fields

              _buildProfileField(
                label: context.lwTranslate.firstName,
                // initialValue: auth.getAuthInfo('first_name'),
                controller: _firstNameController,
                // controller: auth.getAuthInfo('first_name')?? "",
                isEditable: isEditable,
              ),
              _buildProfileField(
                label: context.lwTranslate.lastName,
                // initialValue: auth.getAuthInfo('last_name'),
                controller: _lastNameController,
                isEditable: isEditable,
              ),
              _buildProfileField(
                  label: context.lwTranslate.mobileNumber,
                  // label: "Full Name",
                  // initialValue: auth.getAuthInfo('mobile_number'),
                  controller: _mobileNumberController,
                  isEditable: isEditable,
                  maxLength: 40,
                  keyboardType: TextInputType.phone),
              _buildProfileField(
                label: context.lwTranslate.email,
                // initialValue: auth.getAuthInfo('email'),
                controller: _emailController,
                isEditable: isEditable,
              ),
              if (isEditable)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: LoadingButton(
                    defaultWidget: Text(context.lwTranslate.save,
                        style: const TextStyle(color: app_theme.black)),
                    color: app_theme.cyanGlow,
                    width: MediaQuery.of(context).size.width,
                    onPressed: () async {
                      _formKey.currentState?.save();
                      if (_formKey.currentState!.validate()) {
                        savePfofileUpdate();
                        setState(() {
                          isEditable = false;
                        });
                      }
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileField({
    required String label,
    String? initialValue,
    bool isEditable = false,
    required TextEditingController controller,
    int? maxLength,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return InputField(
      focusborder: const OutlineInputBorder(
        borderSide: BorderSide(color: app_theme.primary),
        borderRadius: BorderRadius.all(Radius.circular(18)),
      ),
      unfocusborder: const OutlineInputBorder(
        borderSide: BorderSide(color: app_theme.outlineSoft),
        borderRadius: BorderRadius.all(Radius.circular(18)),
      ),
      labelText: label,
      controller: controller,
      initialValue: initialValue,
      readOnly: !isEditable,
      maxlength: maxLength,
      inputType: keyboardType,
      onSaved: (String? value) {},
      validation: ValidationBuilder().minLength(2).build(),
    );
  }
}
