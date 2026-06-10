import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stundaa/model/agent_user.dart';
import 'package:stundaa/model/contact_chatbox_metadata.dart';
import 'package:stundaa/model/contact_label.dart';
import 'package:stundaa/model/contact_profile.dart';
import 'package:stundaa/repositories/contact_info_repository.dart';
import 'package:stundaa/services/utils.dart';

class Userinfocontroller extends GetxController {
  RxBool isEditable = true.obs;
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController languageCodeController = TextEditingController();
  TextEditingController notesController = TextEditingController();
  String? userId;
  RxString firstName = ''.obs;
  RxString waId = ''.obs;
  RxString emailV = ''.obs;
  RxString languageCode = ''.obs;
  RxString notes = ''.obs;
  final ContactInfoRepository _contactInfoRepository = ContactInfoRepository();
  void setUserId(String id) {
    userId = id;
  }

  RxList<AgentUser> vendorMessagingUsers = <AgentUser>[].obs;
  RxList<ContactLabel> labels = <ContactLabel>[].obs;
  Rxn<ContactProfile> profile = Rxn<ContactProfile>();

  RxString assignedUserId = ''.obs;
  RxString selectedUserName = ''.obs;
  RxBool isLoading = true.obs;
  RxBool isLoadingUpdateData = true.obs;

  List<Map<String, dynamic>> get vendorMessagingUsersDropdownItems =>
      vendorMessagingUsers.map((user) => user.toDropdownItem()).toList();

  List<Map<String, dynamic>> get labelsDropdownItems =>
      labels.map((label) => label.toDropdownItem()).toList();

  Future<void> updateProfileApi({
    BuildContext? context,
    required String firstNameValue,
    required String emailValue,
    required String languageCodeValue,
  }) async {
    isLoadingUpdateData.value = true;
    try {
      // If the email field is empty and we have an existing email, use that.
      // If both are empty, send an empty string (or whatever the backend expects for optional).
      // If the backend strictly requires a valid email even if not changed, we ensure we don't send "empty".
      String emailToSend = emailValue.trim();
      if (emailToSend.isEmpty && emailV.value.isNotEmpty && emailV.value != "...") {
        emailToSend = emailV.value;
      }
      
      await _contactInfoRepository.updateContactProfile(
        context: context,
        contactUid: userId ?? '',
        firstName: firstNameValue,
        email: emailToSend,
        languageCode: languageCodeValue,
      );
      firstName.value = firstNameValue;
      emailV.value = emailValue;
      languageCode.value = languageCodeValue;
    } catch (e) {
      pr("Update profile failed: $e");
    } finally {
      isLoadingUpdateData.value = false;
    }
  }

  Future<void> getUserInfo() async {
    isLoadingUpdateData.value = true;
    isLoading.value = true;
    try {
      if (userId == null || userId!.isEmpty) {
        return;
      }
      final response =
          await _contactInfoRepository.fetchContactProfile(userId!);
      profile.value = response;
      assignedUserId.value = response.assignedUserId;
      firstName.value = response.firstName;
      nameController.text = response.firstName;
      waId.value = response.waId;
      emailV.value = response.email;
      emailController.text = response.email;
      languageCode.value = response.languageCode;
      languageCodeController.text = response.languageCode;
      notesController.text = response.notes;
      notes.value = response.notes;
      _syncSelectedUserName();
    } finally {
      isLoadingUpdateData.value = false;
      isLoading.value = false;
    }
  }

  Future<List<AgentUser>> getChatLabels() async {
    isLoading.value = true;
    try {
      if (userId == null || userId!.isEmpty) {
        return vendorMessagingUsers;
      }
      final metadata =
          await _contactInfoRepository.fetchChatboxMetadata(userId!);
      _applyChatboxMetadata(metadata);
    } finally {
      isLoading.value = false;
    }
    return vendorMessagingUsers;
  }

  void _applyChatboxMetadata(ContactChatboxMetadata metadata) {
    vendorMessagingUsers.assignAll(metadata.agentUsers);
    labels.assignAll(metadata.labels);
    _syncSelectedUserName();
  }

  void _syncSelectedUserName() {
    if (assignedUserId.isEmpty) {
      selectedUserName.value = '';
      return;
    }
    final matchingUser = vendorMessagingUsers.firstWhereOrNull(
      (user) => user.id == assignedUserId.value,
    );
    selectedUserName.value = matchingUser?.name ?? '';
  }
}
