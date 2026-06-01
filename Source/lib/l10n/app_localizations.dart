import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('it')
  ];

  /// No description provided for @menuChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get menuChangePassword;

  /// No description provided for @menuChangeEmail.
  ///
  /// In en, this message translates to:
  /// **'Change Email'**
  String get menuChangeEmail;

  /// No description provided for @menuSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get menuSettings;

  /// No description provided for @menuLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get menuLogout;

  /// No description provided for @areYouSure.
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get areYouSure;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @find.
  ///
  /// In en, this message translates to:
  /// **'Find'**
  String get find;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @failed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get failed;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @noResultFound.
  ///
  /// In en, this message translates to:
  /// **'no result found'**
  String get noResultFound;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @mobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number'**
  String get mobileNumber;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @selectCountryCode.
  ///
  /// In en, this message translates to:
  /// **'Select Country Code'**
  String get selectCountryCode;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @birthday.
  ///
  /// In en, this message translates to:
  /// **'Birthday'**
  String get birthday;

  /// No description provided for @countryPhoneCode.
  ///
  /// In en, this message translates to:
  /// **'Country Phone Code'**
  String get countryPhoneCode;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get goBack;

  /// No description provided for @changeEmail.
  ///
  /// In en, this message translates to:
  /// **'Change Email'**
  String get changeEmail;

  /// No description provided for @activateYourNewEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Activate your new email address'**
  String get activateYourNewEmailAddress;

  /// No description provided for @almostFinishedYouNeedToConfirmYourEmailAddressTo.
  ///
  /// In en, this message translates to:
  /// **'Almost finished... You need to confirm your email address. To complete the activation process, please click the link in the email we just sent you.'**
  String get almostFinishedYouNeedToConfirmYourEmailAddressTo;

  /// No description provided for @currentEmail.
  ///
  /// In en, this message translates to:
  /// **'Current Email'**
  String get currentEmail;

  /// No description provided for @newEmail.
  ///
  /// In en, this message translates to:
  /// **'New Email'**
  String get newEmail;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'error ...'**
  String get error;

  /// No description provided for @doYouWantToDeleteAllTheChatMessageOf.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear chat history for this contact?'**
  String get doYouWantToDeleteAllTheChatMessageOf;

  /// No description provided for @onlyChatHistory.
  ///
  /// In en, this message translates to:
  /// **'Only chat history will be deleted permanently, it won\'t delete campaign messages.'**
  String get onlyChatHistory;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @deleteAllChatHistory.
  ///
  /// In en, this message translates to:
  /// **'Delete All Chat History'**
  String get deleteAllChatHistory;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'loading ...'**
  String get loading;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @emailOrUsername.
  ///
  /// In en, this message translates to:
  /// **'Email or Username'**
  String get emailOrUsername;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @iAcceptAllThe.
  ///
  /// In en, this message translates to:
  /// **'I accept all the '**
  String get iAcceptAllThe;

  /// No description provided for @and.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get and;

  /// No description provided for @termsConditions.
  ///
  /// In en, this message translates to:
  /// **'terms & conditions'**
  String get termsConditions;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'privacy policy'**
  String get privacyPolicy;

  /// No description provided for @accountCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Account Created Successfully'**
  String get accountCreatedSuccessfully;

  /// No description provided for @goToLoginNow.
  ///
  /// In en, this message translates to:
  /// **'Go to login now'**
  String get goToLoginNow;

  /// No description provided for @signInWithFacebook.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Facebook'**
  String get signInWithFacebook;

  /// No description provided for @signInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signInWithGoogle;

  /// No description provided for @yourEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Your email address'**
  String get yourEmailAddress;

  /// No description provided for @sendEmailOtp.
  ///
  /// In en, this message translates to:
  /// **'Send Email OTP'**
  String get sendEmailOtp;

  /// No description provided for @emailOtp.
  ///
  /// In en, this message translates to:
  /// **'Email OTP'**
  String get emailOtp;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPassword;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @dontHaveAnAcc.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAnAcc;

  /// Filter option to show only user's items
  ///
  /// In en, this message translates to:
  /// **'Mine'**
  String get mineFilter;

  /// Filter option to show unassigned items
  ///
  /// In en, this message translates to:
  /// **'Unassigned'**
  String get unassignedFilter;

  /// Option to send media files in chat
  ///
  /// In en, this message translates to:
  /// **'Send Media'**
  String get sendMedia;

  /// No description provided for @captionText.
  ///
  /// In en, this message translates to:
  /// **'Caption/Text'**
  String get captionText;

  /// No description provided for @userInformation.
  ///
  /// In en, this message translates to:
  /// **'User Information'**
  String get userInformation;

  /// No description provided for @agree.
  ///
  /// In en, this message translates to:
  /// **'Agree'**
  String get agree;

  /// No description provided for @noRecent.
  ///
  /// In en, this message translates to:
  /// **'No Recent'**
  String get noRecent;

  /// No description provided for @tempVideo.
  ///
  /// In en, this message translates to:
  /// **'Temp Video'**
  String get tempVideo;

  /// No description provided for @uploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading...'**
  String get uploading;

  /// No description provided for @uploadComplete.
  ///
  /// In en, this message translates to:
  /// **'Upload\nComplete'**
  String get uploadComplete;

  /// No description provided for @clearChatHistory.
  ///
  /// In en, this message translates to:
  /// **'Clear Chat History'**
  String get clearChatHistory;

  /// No description provided for @pleaseUploadFile.
  ///
  /// In en, this message translates to:
  /// **'Please upload a file'**
  String get pleaseUploadFile;

  /// No description provided for @uploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Upload Failed'**
  String get uploadFailed;

  /// No description provided for @document.
  ///
  /// In en, this message translates to:
  /// **'document'**
  String get document;

  /// No description provided for @openDocument.
  ///
  /// In en, this message translates to:
  /// **'Open Document'**
  String get openDocument;

  /// No description provided for @errorDetaila.
  ///
  /// In en, this message translates to:
  /// **'Error Details'**
  String get errorDetaila;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @notesDot.
  ///
  /// In en, this message translates to:
  /// **'notes...'**
  String get notesDot;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @lablesTags.
  ///
  /// In en, this message translates to:
  /// **'Labels / Tags'**
  String get lablesTags;

  /// No description provided for @assignTeamAndLables.
  ///
  /// In en, this message translates to:
  /// **'Assign Team Member and Labels/Tags'**
  String get assignTeamAndLables;

  /// No description provided for @assignTeamMember.
  ///
  /// In en, this message translates to:
  /// **'Assign Team Member'**
  String get assignTeamMember;

  /// No description provided for @teamMember.
  ///
  /// In en, this message translates to:
  /// **'Team Member'**
  String get teamMember;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @plsAcceptTermsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Please accept terms & conditions to proceed'**
  String get plsAcceptTermsAndConditions;

  /// No description provided for @errorLoadingData.
  ///
  /// In en, this message translates to:
  /// **'Error loading data'**
  String get errorLoadingData;

  /// No description provided for @alreadyHaveAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAnAccount;

  /// No description provided for @loginNow.
  ///
  /// In en, this message translates to:
  /// **'Login now'**
  String get loginNow;

  /// No description provided for @areYouSureToLogout.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get areYouSureToLogout;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @enterValidAddress.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get enterValidAddress;

  /// No description provided for @subject.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get subject;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// No description provided for @messagee.
  ///
  /// In en, this message translates to:
  /// **'Message...'**
  String get messagee;

  /// No description provided for @image.
  ///
  /// In en, this message translates to:
  /// **'image'**
  String get image;

  /// No description provided for @video.
  ///
  /// In en, this message translates to:
  /// **'video'**
  String get video;

  /// No description provided for @audio.
  ///
  /// In en, this message translates to:
  /// **'audio'**
  String get audio;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @addNumberForTest.
  ///
  /// In en, this message translates to:
  /// **'Add Numbers for Test'**
  String get addNumberForTest;

  /// No description provided for @onlyForDemo.
  ///
  /// In en, this message translates to:
  /// **'Only For Demo'**
  String get onlyForDemo;

  /// No description provided for @addYourMobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Add your mobile number with country code (without 0 or +) so you can see your contact in panel/chatbox etc.'**
  String get addYourMobileNumber;

  /// No description provided for @youCanAddComma.
  ///
  /// In en, this message translates to:
  /// **'You can add comma separated multiple numbers'**
  String get youCanAddComma;

  /// No description provided for @addYourMobileNumberTest.
  ///
  /// In en, this message translates to:
  /// **'Add your mobile number with country code to test'**
  String get addYourMobileNumberTest;

  /// No description provided for @pleaseEnterMobile.
  ///
  /// In en, this message translates to:
  /// **'Please enter mobile number'**
  String get pleaseEnterMobile;

  /// No description provided for @mobileNumberUpdated.
  ///
  /// In en, this message translates to:
  /// **'Mobile number updated successfully'**
  String get mobileNumberUpdated;

  /// No description provided for @uploadNewImage.
  ///
  /// In en, this message translates to:
  /// **'Upload New Image'**
  String get uploadNewImage;

  /// No description provided for @showSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Show Snackbar'**
  String get showSnackbar;

  /// No description provided for @selectItemsDot.
  ///
  /// In en, this message translates to:
  /// **'Select items...'**
  String get selectItemsDot;

  /// No description provided for @selectItems.
  ///
  /// In en, this message translates to:
  /// **'Select items'**
  String get selectItems;

  /// No description provided for @demoCompanyLogin.
  ///
  /// In en, this message translates to:
  /// **'Demo Company Login'**
  String get demoCompanyLogin;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'Or'**
  String get or;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @typeAMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message'**
  String get typeAMessage;

  /// No description provided for @addACaption.
  ///
  /// In en, this message translates to:
  /// **'Add a caption'**
  String get addACaption;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @whatsAppChat.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp Chat'**
  String get whatsAppChat;

  /// No description provided for @scanQrCode.
  ///
  /// In en, this message translates to:
  /// **'Scan QR Code to Start Chat'**
  String get scanQrCode;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not Now'**
  String get notNow;

  /// No description provided for @youCanUseFollowing.
  ///
  /// In en, this message translates to:
  /// **'You can use following QR Codes to invite people to get connect with you on this platform.'**
  String get youCanUseFollowing;

  /// No description provided for @whatsAppNow.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp Now'**
  String get whatsAppNow;

  /// No description provided for @couldNotLaunch.
  ///
  /// In en, this message translates to:
  /// **'Could not launch WhatsApp'**
  String get couldNotLaunch;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just Now'**
  String get justNow;

  /// No description provided for @pleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Please wait...'**
  String get pleaseWait;

  /// No description provided for @addLabel.
  ///
  /// In en, this message translates to:
  /// **'Add Label'**
  String get addLabel;

  /// No description provided for @editLabel.
  ///
  /// In en, this message translates to:
  /// **'Edit Label'**
  String get editLabel;

  /// No description provided for @manageLabel.
  ///
  /// In en, this message translates to:
  /// **'Manage Labels'**
  String get manageLabel;

  /// No description provided for @newLabel.
  ///
  /// In en, this message translates to:
  /// **'New Label'**
  String get newLabel;

  /// No description provided for @selectLable.
  ///
  /// In en, this message translates to:
  /// **'Select Label'**
  String get selectLable;

  /// No description provided for @enterNewLabel.
  ///
  /// In en, this message translates to:
  /// **'Enter label name'**
  String get enterNewLabel;

  /// No description provided for @pleaseEnterLabel.
  ///
  /// In en, this message translates to:
  /// **'Please enter label name'**
  String get pleaseEnterLabel;

  /// No description provided for @labelColors.
  ///
  /// In en, this message translates to:
  /// **'Label Colors'**
  String get labelColors;

  /// No description provided for @textColors.
  ///
  /// In en, this message translates to:
  /// **'Text Color'**
  String get textColors;

  /// No description provided for @selectTextColors.
  ///
  /// In en, this message translates to:
  /// **'Select Text Color'**
  String get selectTextColors;

  /// No description provided for @backgroundColor.
  ///
  /// In en, this message translates to:
  /// **'Background Color'**
  String get backgroundColor;

  /// No description provided for @selectBackgroundColor.
  ///
  /// In en, this message translates to:
  /// **'Select Background Color'**
  String get selectBackgroundColor;

  /// No description provided for @bgColor.
  ///
  /// In en, this message translates to:
  /// **'BG Color'**
  String get bgColor;

  /// No description provided for @areYoySureDeleteLabel.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this label?'**
  String get areYoySureDeleteLabel;

  /// No description provided for @pickColor.
  ///
  /// In en, this message translates to:
  /// **'Pick a color'**
  String get pickColor;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @dontHaveAcc.
  ///
  /// In en, this message translates to:
  /// **'If you don\'t have an Account yet? Create One! Its Free!!'**
  String get dontHaveAcc;

  /// No description provided for @createNewAcc.
  ///
  /// In en, this message translates to:
  /// **'Create New Account'**
  String get createNewAcc;

  /// No description provided for @termsCondAccept.
  ///
  /// In en, this message translates to:
  /// **'The terms and conditions must be accepted.'**
  String get termsCondAccept;

  /// No description provided for @registerVendorComp.
  ///
  /// In en, this message translates to:
  /// **'Register as Vendor/Company'**
  String get registerVendorComp;

  /// No description provided for @vendorCompName.
  ///
  /// In en, this message translates to:
  /// **'Vendor/Company Name'**
  String get vendorCompName;

  /// No description provided for @adminUserDeta.
  ///
  /// In en, this message translates to:
  /// **'Admin User Details'**
  String get adminUserDeta;

  /// No description provided for @mobileNumbCountry.
  ///
  /// In en, this message translates to:
  /// **'Mobile number should be with country code without 0 or +'**
  String get mobileNumbCountry;

  /// No description provided for @pleaseEntValEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address.'**
  String get pleaseEntValEmail;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'The field is required'**
  String get fieldRequired;

  /// No description provided for @mustBe8Character.
  ///
  /// In en, this message translates to:
  /// **'The field must be at least 8 character long'**
  String get mustBe8Character;

  /// No description provided for @mustBe9Character.
  ///
  /// In en, this message translates to:
  /// **'The field must be at least 9 character long'**
  String get mustBe9Character;

  /// No description provided for @mustBe2Character.
  ///
  /// In en, this message translates to:
  /// **'The field must be at least 2 character long'**
  String get mustBe2Character;

  /// No description provided for @passwordConfirMatch.
  ///
  /// In en, this message translates to:
  /// **'The password confirmation does not match'**
  String get passwordConfirMatch;

  /// No description provided for @agreeWith.
  ///
  /// In en, this message translates to:
  /// **'I agree with the '**
  String get agreeWith;

  /// No description provided for @userTermsCond.
  ///
  /// In en, this message translates to:
  /// **'User Terms And Conditions'**
  String get userTermsCond;

  /// No description provided for @termsAndCond.
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions'**
  String get termsAndCond;

  /// No description provided for @privacyCPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyCPolicy;

  /// No description provided for @createAcc.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAcc;

  /// No description provided for @clickLogin.
  ///
  /// In en, this message translates to:
  /// **'Click here to login'**
  String get clickLogin;

  /// No description provided for @showUnreadOnly.
  ///
  /// In en, this message translates to:
  /// **'Show unread only'**
  String get showUnreadOnly;

  /// No description provided for @showAll.
  ///
  /// In en, this message translates to:
  /// **'Show all'**
  String get showAll;

  /// No description provided for @enableAIbot.
  ///
  /// In en, this message translates to:
  /// **'Enable AI Bot'**
  String get enableAIbot;

  /// No description provided for @enableReplybot.
  ///
  /// In en, this message translates to:
  /// **'Enable Reply Bot'**
  String get enableReplybot;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
