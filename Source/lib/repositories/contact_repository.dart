import 'dart:async';

import 'package:stundaa/model/contact_list_response.dart';
import 'package:stundaa/services/data_transport.dart' as data_transport;

class ContactRepository {
  Future<ContactListResponse> fetchContacts({
    required int page,
    String assigned = '',
  }) async {
    final completer = Completer<ContactListResponse>();

    await data_transport.get(
      'vendor/contact/contacts-data?page=$page&assigned=$assigned',
      onSuccess: (responseData) {
        if (!completer.isCompleted) {
          completer.complete(ContactListResponse.fromResponse(responseData));
        }
      },
      onFailed: (responseData) {
        if (!completer.isCompleted) {
          completer.complete(ContactListResponse.fromResponse(responseData));
        }
      },
      onError: (error) {
        if (!completer.isCompleted) {
          completer.completeError(error ?? 'Failed to fetch contacts');
        }
      },
    );

    return completer.future;
  }

  /// Finds or creates a contact by phone number.
  /// Returns the real [contact_uid] from the server.
  Future<String?> initiateContactByPhone(String phoneNumber) async {
    final completer = Completer<String?>();

    await data_transport.post(
      'vendor/whatsapp/contact/initiate-by-phone',
      inputData: {'phone_number': phoneNumber},
      context: null,
      onSuccess: (responseData) {
        final uid = responseData?['data']?['contact_uid']?.toString();
        if (!completer.isCompleted) completer.complete(uid);
      },
      onFailed: (responseData) {
        if (!completer.isCompleted) completer.complete(null);
      },
      onError: (error) {
        if (!completer.isCompleted) completer.complete(null);
      },
    );

    return completer.future;
  }

  Future<ContactListResponse> fetchSingleContact({
    required String vendorUid,
    required String contactUid,
    String assigned = '',
  }) async {
    final completer = Completer<ContactListResponse>();

    await data_transport.get(
      'vendor/contact/contacts-data/$vendorUid?way=append&request_contact=$contactUid&assigned=$assigned',
      onSuccess: (responseData) {
        if (!completer.isCompleted) {
          completer.complete(ContactListResponse.fromResponse(responseData));
        }
      },
      onFailed: (responseData) {
        if (!completer.isCompleted) {
          completer.complete(ContactListResponse.fromResponse(responseData));
        }
      },
      onError: (error) {
        if (!completer.isCompleted) {
          completer.completeError(error ?? 'Failed to fetch contact');
        }
      },
    );

    return completer.future;
  }
}
