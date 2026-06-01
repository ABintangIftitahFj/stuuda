// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name =
        (locale.countryCode?.isEmpty ?? false)
            ? locale.languageCode
            : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Change Password`
  String get menuChangePassword {
    return Intl.message(
      'Change Password',
      name: 'menuChangePassword',
      desc: '',
      args: [],
    );
  }

  /// `Change Email`
  String get menuChangeEmail {
    return Intl.message(
      'Change Email',
      name: 'menuChangeEmail',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get menuSettings {
    return Intl.message('Settings', name: 'menuSettings', desc: '', args: []);
  }

  /// `Logout`
  String get menuLogout {
    return Intl.message('Logout', name: 'menuLogout', desc: '', args: []);
  }

  /// `Are you sure?`
  String get areYouSure {
    return Intl.message(
      'Are you sure?',
      name: 'areYouSure',
      desc: '',
      args: [],
    );
  }

  /// `Version`
  String get version {
    return Intl.message('Version', name: 'version', desc: '', args: []);
  }

  /// `Find`
  String get find {
    return Intl.message('Find', name: 'find', desc: '', args: []);
  }

  /// `My Profile`
  String get myProfile {
    return Intl.message('My Profile', name: 'myProfile', desc: '', args: []);
  }

  /// `Register`
  String get register {
    return Intl.message('Register', name: 'register', desc: '', args: []);
  }

  /// `Failed`
  String get failed {
    return Intl.message('Failed', name: 'failed', desc: '', args: []);
  }

  /// `Notifications`
  String get notifications {
    return Intl.message(
      'Notifications',
      name: 'notifications',
      desc: '',
      args: [],
    );
  }

  /// `no result found`
  String get noResultFound {
    return Intl.message(
      'no result found',
      name: 'noResultFound',
      desc: '',
      args: [],
    );
  }

  /// `OK`
  String get ok {
    return Intl.message('OK', name: 'ok', desc: '', args: []);
  }

  /// `Send`
  String get send {
    return Intl.message('Send', name: 'send', desc: '', args: []);
  }

  /// `Cancel`
  String get cancel {
    return Intl.message('Cancel', name: 'cancel', desc: '', args: []);
  }

  /// `Gender`
  String get gender {
    return Intl.message('Gender', name: 'gender', desc: '', args: []);
  }

  /// `Mobile Number`
  String get mobileNumber {
    return Intl.message(
      'Mobile Number',
      name: 'mobileNumber',
      desc: '',
      args: [],
    );
  }

  /// `Location`
  String get location {
    return Intl.message('Location', name: 'location', desc: '', args: []);
  }

  /// `Select Country Code`
  String get selectCountryCode {
    return Intl.message(
      'Select Country Code',
      name: 'selectCountryCode',
      desc: '',
      args: [],
    );
  }

  /// `First Name`
  String get firstName {
    return Intl.message('First Name', name: 'firstName', desc: '', args: []);
  }

  /// `Last Name`
  String get lastName {
    return Intl.message('Last Name', name: 'lastName', desc: '', args: []);
  }

  /// `Language`
  String get language {
    return Intl.message('Language', name: 'language', desc: '', args: []);
  }

  /// `Birthday`
  String get birthday {
    return Intl.message('Birthday', name: 'birthday', desc: '', args: []);
  }

  /// `Country Phone Code`
  String get countryPhoneCode {
    return Intl.message(
      'Country Phone Code',
      name: 'countryPhoneCode',
      desc: '',
      args: [],
    );
  }

  /// `All`
  String get all {
    return Intl.message('All', name: 'all', desc: '', args: []);
  }

  /// `Name`
  String get name {
    return Intl.message('Name', name: 'name', desc: '', args: []);
  }

  /// `Username`
  String get username {
    return Intl.message('Username', name: 'username', desc: '', args: []);
  }

  /// `Go back`
  String get goBack {
    return Intl.message('Go back', name: 'goBack', desc: '', args: []);
  }

  /// `Change Email`
  String get changeEmail {
    return Intl.message(
      'Change Email',
      name: 'changeEmail',
      desc: '',
      args: [],
    );
  }

  /// `Activate your new email address`
  String get activateYourNewEmailAddress {
    return Intl.message(
      'Activate your new email address',
      name: 'activateYourNewEmailAddress',
      desc: '',
      args: [],
    );
  }

  /// `Almost finished... You need to confirm your email address. To complete the activation process, please click the link in the email we just sent you.`
  String get almostFinishedYouNeedToConfirmYourEmailAddressTo {
    return Intl.message(
      'Almost finished... You need to confirm your email address. To complete the activation process, please click the link in the email we just sent you.',
      name: 'almostFinishedYouNeedToConfirmYourEmailAddressTo',
      desc: '',
      args: [],
    );
  }

  /// `Current Email`
  String get currentEmail {
    return Intl.message(
      'Current Email',
      name: 'currentEmail',
      desc: '',
      args: [],
    );
  }

  /// `New Email`
  String get newEmail {
    return Intl.message('New Email', name: 'newEmail', desc: '', args: []);
  }

  /// `Password`
  String get password {
    return Intl.message('Password', name: 'password', desc: '', args: []);
  }

  /// `Change Password`
  String get changePassword {
    return Intl.message(
      'Change Password',
      name: 'changePassword',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Password`
  String get confirmPassword {
    return Intl.message(
      'Confirm Password',
      name: 'confirmPassword',
      desc: '',
      args: [],
    );
  }

  /// `error ...`
  String get error {
    return Intl.message('error ...', name: 'error', desc: '', args: []);
  }

  /// `Are you sure you want to clear chat history for this contact?`
  String get doYouWantToDeleteAllTheChatMessageOf {
    return Intl.message(
      'Are you sure you want to clear chat history for this contact?',
      name: 'doYouWantToDeleteAllTheChatMessageOf',
      desc: '',
      args: [],
    );
  }

  /// `Only chat history will be deleted permanently, it won't delete campaign messages.`
  String get onlyChatHistory {
    return Intl.message(
      'Only chat history will be deleted permanently, it won\'t delete campaign messages.',
      name: 'onlyChatHistory',
      desc: '',
      args: [],
    );
  }

  /// `Yes`
  String get yes {
    return Intl.message('Yes', name: 'yes', desc: '', args: []);
  }

  /// `No`
  String get no {
    return Intl.message('No', name: 'no', desc: '', args: []);
  }

  /// `Delete All Chat History`
  String get deleteAllChatHistory {
    return Intl.message(
      'Delete All Chat History',
      name: 'deleteAllChatHistory',
      desc: '',
      args: [],
    );
  }

  /// `loading ...`
  String get loading {
    return Intl.message('loading ...', name: 'loading', desc: '', args: []);
  }

  /// `Settings`
  String get settings {
    return Intl.message('Settings', name: 'settings', desc: '', args: []);
  }

  /// `Select Language`
  String get selectLanguage {
    return Intl.message(
      'Select Language',
      name: 'selectLanguage',
      desc: '',
      args: [],
    );
  }

  /// `English`
  String get english {
    return Intl.message('English', name: 'english', desc: '', args: []);
  }

  /// `Sign in`
  String get signIn {
    return Intl.message('Sign in', name: 'signIn', desc: '', args: []);
  }

  /// `Email or Username`
  String get emailOrUsername {
    return Intl.message(
      'Email or Username',
      name: 'emailOrUsername',
      desc: '',
      args: [],
    );
  }

  /// `Login`
  String get login {
    return Intl.message('Login', name: 'login', desc: '', args: []);
  }

  /// `Forgot Password?`
  String get forgotPassword {
    return Intl.message(
      'Forgot Password?',
      name: 'forgotPassword',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get email {
    return Intl.message('Email', name: 'email', desc: '', args: []);
  }

  /// `I accept all the `
  String get iAcceptAllThe {
    return Intl.message(
      'I accept all the ',
      name: 'iAcceptAllThe',
      desc: '',
      args: [],
    );
  }

  /// ` and `
  String get and {
    return Intl.message(' and ', name: 'and', desc: '', args: []);
  }

  /// `terms & conditions`
  String get termsConditions {
    return Intl.message(
      'terms & conditions',
      name: 'termsConditions',
      desc: '',
      args: [],
    );
  }

  /// `privacy policy`
  String get privacyPolicy {
    return Intl.message(
      'privacy policy',
      name: 'privacyPolicy',
      desc: '',
      args: [],
    );
  }

  /// `Account Created Successfully`
  String get accountCreatedSuccessfully {
    return Intl.message(
      'Account Created Successfully',
      name: 'accountCreatedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Go to login now`
  String get goToLoginNow {
    return Intl.message(
      'Go to login now',
      name: 'goToLoginNow',
      desc: '',
      args: [],
    );
  }

  /// `Sign in with Facebook`
  String get signInWithFacebook {
    return Intl.message(
      'Sign in with Facebook',
      name: 'signInWithFacebook',
      desc: '',
      args: [],
    );
  }

  /// `Sign in with Google`
  String get signInWithGoogle {
    return Intl.message(
      'Sign in with Google',
      name: 'signInWithGoogle',
      desc: '',
      args: [],
    );
  }

  /// `Your email address`
  String get yourEmailAddress {
    return Intl.message(
      'Your email address',
      name: 'yourEmailAddress',
      desc: '',
      args: [],
    );
  }

  /// `Send Email OTP`
  String get sendEmailOtp {
    return Intl.message(
      'Send Email OTP',
      name: 'sendEmailOtp',
      desc: '',
      args: [],
    );
  }

  /// `Email OTP`
  String get emailOtp {
    return Intl.message('Email OTP', name: 'emailOtp', desc: '', args: []);
  }

  /// `New Password`
  String get newPassword {
    return Intl.message(
      'New Password',
      name: 'newPassword',
      desc: '',
      args: [],
    );
  }

  /// `Confirm New Password`
  String get confirmNewPassword {
    return Intl.message(
      'Confirm New Password',
      name: 'confirmNewPassword',
      desc: '',
      args: [],
    );
  }

  /// `Submit`
  String get submit {
    return Intl.message('Submit', name: 'submit', desc: '', args: []);
  }

  /// `Don't have an account?`
  String get dontHaveAnAcc {
    return Intl.message(
      'Don\'t have an account?',
      name: 'dontHaveAnAcc',
      desc: '',
      args: [],
    );
  }

  /// `Mine`
  String get mineFilter {
    return Intl.message(
      'Mine',
      name: 'mineFilter',
      desc: 'Filter option to show only user\'s items',
      args: [],
    );
  }

  /// `Unassigned`
  String get unassignedFilter {
    return Intl.message(
      'Unassigned',
      name: 'unassignedFilter',
      desc: 'Filter option to show unassigned items',
      args: [],
    );
  }

  /// `Send Media`
  String get sendMedia {
    return Intl.message(
      'Send Media',
      name: 'sendMedia',
      desc: 'Option to send media files in chat',
      args: [],
    );
  }

  /// `Caption/Text`
  String get captionText {
    return Intl.message(
      'Caption/Text',
      name: 'captionText',
      desc: '',
      args: [],
    );
  }

  /// `User Information`
  String get userInformation {
    return Intl.message(
      'User Information',
      name: 'userInformation',
      desc: '',
      args: [],
    );
  }

  /// `Agree`
  String get agree {
    return Intl.message('Agree', name: 'agree', desc: '', args: []);
  }

  /// `No Recent`
  String get noRecent {
    return Intl.message('No Recent', name: 'noRecent', desc: '', args: []);
  }

  /// `Temp Video`
  String get tempVideo {
    return Intl.message('Temp Video', name: 'tempVideo', desc: '', args: []);
  }

  /// `Uploading...`
  String get uploading {
    return Intl.message('Uploading...', name: 'uploading', desc: '', args: []);
  }

  /// `Upload\nComplete`
  String get uploadComplete {
    return Intl.message(
      'Upload\nComplete',
      name: 'uploadComplete',
      desc: '',
      args: [],
    );
  }

  /// `Clear Chat History`
  String get clearChatHistory {
    return Intl.message(
      'Clear Chat History',
      name: 'clearChatHistory',
      desc: '',
      args: [],
    );
  }

  /// `Please upload a file`
  String get pleaseUploadFile {
    return Intl.message(
      'Please upload a file',
      name: 'pleaseUploadFile',
      desc: '',
      args: [],
    );
  }

  /// `Upload Failed`
  String get uploadFailed {
    return Intl.message(
      'Upload Failed',
      name: 'uploadFailed',
      desc: '',
      args: [],
    );
  }

  /// `document`
  String get document {
    return Intl.message('document', name: 'document', desc: '', args: []);
  }

  /// `Open Document`
  String get openDocument {
    return Intl.message(
      'Open Document',
      name: 'openDocument',
      desc: '',
      args: [],
    );
  }

  /// `Error Details`
  String get errorDetaila {
    return Intl.message(
      'Error Details',
      name: 'errorDetaila',
      desc: '',
      args: [],
    );
  }

  /// `Close`
  String get close {
    return Intl.message('Close', name: 'close', desc: '', args: []);
  }

  /// `Save`
  String get save {
    return Intl.message('Save', name: 'save', desc: '', args: []);
  }

  /// `Notes`
  String get notes {
    return Intl.message('Notes', name: 'notes', desc: '', args: []);
  }

  /// `notes...`
  String get notesDot {
    return Intl.message('notes...', name: 'notesDot', desc: '', args: []);
  }

  /// `Update`
  String get update {
    return Intl.message('Update', name: 'update', desc: '', args: []);
  }

  /// `Labels / Tags`
  String get lablesTags {
    return Intl.message(
      'Labels / Tags',
      name: 'lablesTags',
      desc: '',
      args: [],
    );
  }

  /// `Assign Team Member and Labels/Tags`
  String get assignTeamAndLables {
    return Intl.message(
      'Assign Team Member and Labels/Tags',
      name: 'assignTeamAndLables',
      desc: '',
      args: [],
    );
  }

  /// `Assign Team Member`
  String get assignTeamMember {
    return Intl.message(
      'Assign Team Member',
      name: 'assignTeamMember',
      desc: '',
      args: [],
    );
  }

  /// `Team Member`
  String get teamMember {
    return Intl.message('Team Member', name: 'teamMember', desc: '', args: []);
  }

  /// `Current Password`
  String get currentPassword {
    return Intl.message(
      'Current Password',
      name: 'currentPassword',
      desc: '',
      args: [],
    );
  }

  /// `Please accept terms & conditions to proceed`
  String get plsAcceptTermsAndConditions {
    return Intl.message(
      'Please accept terms & conditions to proceed',
      name: 'plsAcceptTermsAndConditions',
      desc: '',
      args: [],
    );
  }

  /// `Error loading data`
  String get errorLoadingData {
    return Intl.message(
      'Error loading data',
      name: 'errorLoadingData',
      desc: '',
      args: [],
    );
  }

  /// `Already have an account?`
  String get alreadyHaveAnAccount {
    return Intl.message(
      'Already have an account?',
      name: 'alreadyHaveAnAccount',
      desc: '',
      args: [],
    );
  }

  /// `Login now`
  String get loginNow {
    return Intl.message('Login now', name: 'loginNow', desc: '', args: []);
  }

  /// `Are you sure you want to logout?`
  String get areYouSureToLogout {
    return Intl.message(
      'Are you sure you want to logout?',
      name: 'areYouSureToLogout',
      desc: '',
      args: [],
    );
  }

  /// `Contact Us`
  String get contactUs {
    return Intl.message('Contact Us', name: 'contactUs', desc: '', args: []);
  }

  /// `Full Name`
  String get fullName {
    return Intl.message('Full Name', name: 'fullName', desc: '', args: []);
  }

  /// `Please enter a valid email address`
  String get enterValidAddress {
    return Intl.message(
      'Please enter a valid email address',
      name: 'enterValidAddress',
      desc: '',
      args: [],
    );
  }

  /// `Subject`
  String get subject {
    return Intl.message('Subject', name: 'subject', desc: '', args: []);
  }

  /// `Message`
  String get message {
    return Intl.message('Message', name: 'message', desc: '', args: []);
  }

  /// `Message...`
  String get messagee {
    return Intl.message('Message...', name: 'messagee', desc: '', args: []);
  }

  /// `image`
  String get image {
    return Intl.message('image', name: 'image', desc: '', args: []);
  }

  /// `video`
  String get video {
    return Intl.message('video', name: 'video', desc: '', args: []);
  }

  /// `audio`
  String get audio {
    return Intl.message('audio', name: 'audio', desc: '', args: []);
  }

  /// `Open`
  String get open {
    return Intl.message('Open', name: 'open', desc: '', args: []);
  }

  /// `Profile`
  String get profile {
    return Intl.message('Profile', name: 'profile', desc: '', args: []);
  }

  /// `Add Numbers for Test`
  String get addNumberForTest {
    return Intl.message(
      'Add Numbers for Test',
      name: 'addNumberForTest',
      desc: '',
      args: [],
    );
  }

  /// `Only For Demo`
  String get onlyForDemo {
    return Intl.message(
      'Only For Demo',
      name: 'onlyForDemo',
      desc: '',
      args: [],
    );
  }

  /// `Add your mobile number with country code (without 0 or +) so you can see your contact in panel/chatbox etc.`
  String get addYourMobileNumber {
    return Intl.message(
      'Add your mobile number with country code (without 0 or +) so you can see your contact in panel/chatbox etc.',
      name: 'addYourMobileNumber',
      desc: '',
      args: [],
    );
  }

  /// `You can add comma separated multiple numbers`
  String get youCanAddComma {
    return Intl.message(
      'You can add comma separated multiple numbers',
      name: 'youCanAddComma',
      desc: '',
      args: [],
    );
  }

  /// `Add your mobile number with country code to test`
  String get addYourMobileNumberTest {
    return Intl.message(
      'Add your mobile number with country code to test',
      name: 'addYourMobileNumberTest',
      desc: '',
      args: [],
    );
  }

  /// `Please enter mobile number`
  String get pleaseEnterMobile {
    return Intl.message(
      'Please enter mobile number',
      name: 'pleaseEnterMobile',
      desc: '',
      args: [],
    );
  }

  /// `Mobile number updated successfully`
  String get mobileNumberUpdated {
    return Intl.message(
      'Mobile number updated successfully',
      name: 'mobileNumberUpdated',
      desc: '',
      args: [],
    );
  }

  /// `Upload New Image`
  String get uploadNewImage {
    return Intl.message(
      'Upload New Image',
      name: 'uploadNewImage',
      desc: '',
      args: [],
    );
  }

  /// `Show Snackbar`
  String get showSnackbar {
    return Intl.message(
      'Show Snackbar',
      name: 'showSnackbar',
      desc: '',
      args: [],
    );
  }

  /// `Select items...`
  String get selectItemsDot {
    return Intl.message(
      'Select items...',
      name: 'selectItemsDot',
      desc: '',
      args: [],
    );
  }

  /// `Select items`
  String get selectItems {
    return Intl.message(
      'Select items',
      name: 'selectItems',
      desc: '',
      args: [],
    );
  }

  /// `Demo Company Login`
  String get demoCompanyLogin {
    return Intl.message(
      'Demo Company Login',
      name: 'demoCompanyLogin',
      desc: '',
      args: [],
    );
  }

  /// `Or`
  String get or {
    return Intl.message('Or', name: 'or', desc: '', args: []);
  }

  /// `Phone`
  String get phone {
    return Intl.message('Phone', name: 'phone', desc: '', args: []);
  }

  /// `Type a message`
  String get typeAMessage {
    return Intl.message(
      'Type a message',
      name: 'typeAMessage',
      desc: '',
      args: [],
    );
  }

  /// `Add a caption`
  String get addACaption {
    return Intl.message(
      'Add a caption',
      name: 'addACaption',
      desc: '',
      args: [],
    );
  }

  /// `Search`
  String get search {
    return Intl.message('Search', name: 'search', desc: '', args: []);
  }

  /// `WhatsApp Chat`
  String get whatsAppChat {
    return Intl.message(
      'WhatsApp Chat',
      name: 'whatsAppChat',
      desc: '',
      args: [],
    );
  }

  /// `Scan QR Code to Start Chat`
  String get scanQrCode {
    return Intl.message(
      'Scan QR Code to Start Chat',
      name: 'scanQrCode',
      desc: '',
      args: [],
    );
  }

  /// `Not Now`
  String get notNow {
    return Intl.message('Not Now', name: 'notNow', desc: '', args: []);
  }

  /// `You can use following QR Codes to invite people to get connect with you on this platform.`
  String get youCanUseFollowing {
    return Intl.message(
      'You can use following QR Codes to invite people to get connect with you on this platform.',
      name: 'youCanUseFollowing',
      desc: '',
      args: [],
    );
  }

  /// `WhatsApp Now`
  String get whatsAppNow {
    return Intl.message(
      'WhatsApp Now',
      name: 'whatsAppNow',
      desc: '',
      args: [],
    );
  }

  /// `Could not launch WhatsApp`
  String get couldNotLaunch {
    return Intl.message(
      'Could not launch WhatsApp',
      name: 'couldNotLaunch',
      desc: '',
      args: [],
    );
  }

  /// `Just Now`
  String get justNow {
    return Intl.message('Just Now', name: 'justNow', desc: '', args: []);
  }

  /// `Please wait...`
  String get pleaseWait {
    return Intl.message(
      'Please wait...',
      name: 'pleaseWait',
      desc: '',
      args: [],
    );
  }

  /// `Add Label`
  String get addLabel {
    return Intl.message('Add Label', name: 'addLabel', desc: '', args: []);
  }

  /// `Edit Label`
  String get editLabel {
    return Intl.message('Edit Label', name: 'editLabel', desc: '', args: []);
  }

  /// `Manage Labels`
  String get manageLabel {
    return Intl.message(
      'Manage Labels',
      name: 'manageLabel',
      desc: '',
      args: [],
    );
  }

  /// `New Label`
  String get newLabel {
    return Intl.message('New Label', name: 'newLabel', desc: '', args: []);
  }

  /// `Select Label`
  String get selectLable {
    return Intl.message(
      'Select Label',
      name: 'selectLable',
      desc: '',
      args: [],
    );
  }

  /// `Enter label name`
  String get enterNewLabel {
    return Intl.message(
      'Enter label name',
      name: 'enterNewLabel',
      desc: '',
      args: [],
    );
  }

  /// `Please enter label name`
  String get pleaseEnterLabel {
    return Intl.message(
      'Please enter label name',
      name: 'pleaseEnterLabel',
      desc: '',
      args: [],
    );
  }

  /// `Label Colors`
  String get labelColors {
    return Intl.message(
      'Label Colors',
      name: 'labelColors',
      desc: '',
      args: [],
    );
  }

  /// `Text Color`
  String get textColors {
    return Intl.message('Text Color', name: 'textColors', desc: '', args: []);
  }

  /// `Select Text Color`
  String get selectTextColors {
    return Intl.message(
      'Select Text Color',
      name: 'selectTextColors',
      desc: '',
      args: [],
    );
  }

  /// `Background Color`
  String get backgroundColor {
    return Intl.message(
      'Background Color',
      name: 'backgroundColor',
      desc: '',
      args: [],
    );
  }

  /// `Select Background Color`
  String get selectBackgroundColor {
    return Intl.message(
      'Select Background Color',
      name: 'selectBackgroundColor',
      desc: '',
      args: [],
    );
  }

  /// `BG Color`
  String get bgColor {
    return Intl.message('BG Color', name: 'bgColor', desc: '', args: []);
  }

  /// `Are you sure you want to delete this label?`
  String get areYoySureDeleteLabel {
    return Intl.message(
      'Are you sure you want to delete this label?',
      name: 'areYoySureDeleteLabel',
      desc: '',
      args: [],
    );
  }

  /// `Pick a color`
  String get pickColor {
    return Intl.message('Pick a color', name: 'pickColor', desc: '', args: []);
  }

  /// `Create`
  String get create {
    return Intl.message('Create', name: 'create', desc: '', args: []);
  }

  /// `If you don't have an Account yet? Create One! Its Free!!`
  String get dontHaveAcc {
    return Intl.message(
      'If you don\'t have an Account yet? Create One! Its Free!!',
      name: 'dontHaveAcc',
      desc: '',
      args: [],
    );
  }

  /// `Create New Account`
  String get createNewAcc {
    return Intl.message(
      'Create New Account',
      name: 'createNewAcc',
      desc: '',
      args: [],
    );
  }

  /// `The terms and conditions must be accepted.`
  String get termsCondAccept {
    return Intl.message(
      'The terms and conditions must be accepted.',
      name: 'termsCondAccept',
      desc: '',
      args: [],
    );
  }

  /// `Register as Vendor/Company`
  String get registerVendorComp {
    return Intl.message(
      'Register as Vendor/Company',
      name: 'registerVendorComp',
      desc: '',
      args: [],
    );
  }

  /// `Vendor/Company Name`
  String get vendorCompName {
    return Intl.message(
      'Vendor/Company Name',
      name: 'vendorCompName',
      desc: '',
      args: [],
    );
  }

  /// `Admin User Details`
  String get adminUserDeta {
    return Intl.message(
      'Admin User Details',
      name: 'adminUserDeta',
      desc: '',
      args: [],
    );
  }

  /// `Mobile number should be with country code without 0 or +`
  String get mobileNumbCountry {
    return Intl.message(
      'Mobile number should be with country code without 0 or +',
      name: 'mobileNumbCountry',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid email address.`
  String get pleaseEntValEmail {
    return Intl.message(
      'Please enter a valid email address.',
      name: 'pleaseEntValEmail',
      desc: '',
      args: [],
    );
  }

  /// `The field is required`
  String get fieldRequired {
    return Intl.message(
      'The field is required',
      name: 'fieldRequired',
      desc: '',
      args: [],
    );
  }

  /// `The field must be at least 8 character long`
  String get mustBe8Character {
    return Intl.message(
      'The field must be at least 8 character long',
      name: 'mustBe8Character',
      desc: '',
      args: [],
    );
  }

  /// `The field must be at least 9 character long`
  String get mustBe9Character {
    return Intl.message(
      'The field must be at least 9 character long',
      name: 'mustBe9Character',
      desc: '',
      args: [],
    );
  }

  /// `The field must be at least 2 character long`
  String get mustBe2Character {
    return Intl.message(
      'The field must be at least 2 character long',
      name: 'mustBe2Character',
      desc: '',
      args: [],
    );
  }

  /// `The password confirmation does not match`
  String get passwordConfirMatch {
    return Intl.message(
      'The password confirmation does not match',
      name: 'passwordConfirMatch',
      desc: '',
      args: [],
    );
  }

  /// `I agree with the `
  String get agreeWith {
    return Intl.message(
      'I agree with the ',
      name: 'agreeWith',
      desc: '',
      args: [],
    );
  }

  /// `User Terms And Conditions`
  String get userTermsCond {
    return Intl.message(
      'User Terms And Conditions',
      name: 'userTermsCond',
      desc: '',
      args: [],
    );
  }

  /// `Terms and Conditions`
  String get termsAndCond {
    return Intl.message(
      'Terms and Conditions',
      name: 'termsAndCond',
      desc: '',
      args: [],
    );
  }

  /// `Privacy policy`
  String get privacyCPolicy {
    return Intl.message(
      'Privacy policy',
      name: 'privacyCPolicy',
      desc: '',
      args: [],
    );
  }

  /// `Create Account`
  String get createAcc {
    return Intl.message(
      'Create Account',
      name: 'createAcc',
      desc: '',
      args: [],
    );
  }

  /// `Click here to login`
  String get clickLogin {
    return Intl.message(
      'Click here to login',
      name: 'clickLogin',
      desc: '',
      args: [],
    );
  }

  /// `Show unread only`
  String get showUnreadOnly {
    return Intl.message(
      'Show unread only',
      name: 'showUnreadOnly',
      desc: '',
      args: [],
    );
  }

  /// `Show all`
  String get showAll {
    return Intl.message('Show all', name: 'showAll', desc: '', args: []);
  }

  /// `Enable AI Bot`
  String get enableAIbot {
    return Intl.message(
      'Enable AI Bot',
      name: 'enableAIbot',
      desc: '',
      args: [],
    );
  }

  /// `Enable Reply Bot`
  String get enableReplybot {
    return Intl.message(
      'Enable Reply Bot',
      name: 'enableReplybot',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'it'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
