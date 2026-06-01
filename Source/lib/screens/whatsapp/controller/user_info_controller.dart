import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/utils.dart';
import '/services/data_transport.dart' as data_transport;

class Userinfocontroller extends GetxController {
  // RxString name ='Name'.obs;
  // RxString email ='email'.obs;
  // RxString phone ='phone'.obs;
  // RxString address ='address'.obs;
  // RxString notes ='notes'.obs;
  RxBool isEditable = true.obs;
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController notesController = TextEditingController();
  String? userId;
  RxString firstName = ''.obs;
  RxString waId = ''.obs;
  RxString emailV = ''.obs;
  RxString languageCode = ''.obs;
  RxString notes = ''.obs;
  void setUserId(String id) {
    userId = id;
  }

  RxList<Map<String, dynamic>> vendorMessagingUsers =
      <Map<String, dynamic>>[].obs;
  var labelsDropdownItems = <Map<String, dynamic>>[].obs;

  RxString assignedUserId = ''.obs;
  RxString selectedUserName = ''.obs;
  RxBool isLoading = true.obs;
  RxBool isLoadingUpdateData = true.obs;

  Future<void> getUserInfo() async {
    isLoadingUpdateData.value = true;
    isLoading.value = true;
    await data_transport.get(
      'vendor/contacts/$userId/get-update-data',
      onSuccess: (responseData) {
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('data')) {
          final data = responseData['data'];
          assignedUserId.value = (data['assigned_users__id'] ?? '').toString();
          if (assignedUserId.isNotEmpty) {
            final matchingUser = vendorMessagingUsers.firstWhereOrNull(
              (user) => user['id'] == assignedUserId.value,
            );
            selectedUserName.value =
                matchingUser != null ? matchingUser['value'] : '';
          }
          firstName.value = data['first_name'] ?? 'Unknown';
          waId.value = data['wa_id'] ?? '-';
          emailV.value = data['email'] ?? '-';
          languageCode.value = data['language_code'] ?? '-';

          if (data['__data'] is Map<String, dynamic>) {
            final innerData = data['__data'];
            notesController.text = innerData['contact_notes'] ?? '';
            notes.value = innerData['contact_notes'] ?? '';
          } else if (data['__data'] is List) {
            notesController.text = '';
            notes.value = '';
          } else {}
        }
      },
      onError: (error) {},
    );
    isLoadingUpdateData.value = false;
    isLoading.value = false;
  }

  Future<List<Map<String, dynamic>>> getChatLabels() async {
    isLoading.value = true;
    try {
      await data_transport.get(
        'vendor/whatsapp/contact/chat-box-data/$userId',
        onSuccess: (responseData) {
          if (responseData != null && responseData['data'] != null) {
            List<Map<String, dynamic>> users = List<Map<String, dynamic>>.from(
              responseData['data']['vendorMessagingUsers'] ?? [],
            );

            List<Map<String, dynamic>> lablesList =
                List<Map<String, dynamic>>.from(
              responseData['data']['listOfAllLabels'] ?? [],
            );
            final List<Map<String, dynamic>> formattedUsers = users
                .map((user) => {
                      'id': user['_id'].toString(),
                      '_uid': user['_uid'].toString(),
                      'value': user['full_name'] ?? 'Unknown',
                      'vendors__id': user['vendors__id']?.toString() ?? 'null',
                    })
                .toList();
            vendorMessagingUsers.assignAll(formattedUsers);

            List<Map<String, dynamic>> formattedLabels =
                lablesList.map((label) {
              return {
                'id': label['_id'].toString(),
                '_uid': label['_uid'].toString(),
                'value': label['title'] ?? 'Untitled',
                'textColor': label['text_color'] ?? '#000000',
                'bgColor': label['bg_color'] ?? '#ffffff',
              };
            }).toList();
            labelsDropdownItems.assignAll(formattedLabels);

            if (assignedUserId.isNotEmpty) {
              final matchingUser = vendorMessagingUsers.firstWhereOrNull(
                (user) => user['id'] == assignedUserId.value,
              );
              if (matchingUser != null) {
                selectedUserName.value = matchingUser['value'];
              } else {
                selectedUserName.value = '';
              }
            }
          }
        },
        onError: (error) {},
      );
    } catch (error) {
    } finally {
      isLoading.value = false;
    }
    return vendorMessagingUsers;
  }
}
