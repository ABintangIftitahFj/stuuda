import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stundaa/model/contact_chatbox_metadata.dart';
import 'package:stundaa/model/contact_profile.dart';
import 'package:stundaa/services/data_transport.dart' as data_transport;

class ContactInfoRepository {
  Future<ContactProfile> fetchContactProfile(String contactUid) async {
    final completer = Completer<ContactProfile>();
    await data_transport.get(
      'vendor/contacts/$contactUid/get-update-data',
      onSuccess: (responseData) {
        if (!completer.isCompleted) {
          completer.complete(ContactProfile.fromResponse(responseData));
        }
      },
      onFailed: (responseData) {
        if (!completer.isCompleted) {
          completer.complete(ContactProfile.fromResponse(responseData));
        }
      },
      onError: (error) {
        if (!completer.isCompleted) {
          completer.completeError(error ?? 'Failed to fetch contact profile');
        }
      },
    );

    return completer.future;
  }

  Future<ContactChatboxMetadata> fetchChatboxMetadata(String contactUid) async {
    final completer = Completer<ContactChatboxMetadata>();
    await data_transport.get(
      'vendor/whatsapp/contact/chat-box-data/$contactUid',
      onSuccess: (responseData) {
        if (!completer.isCompleted) {
          completer.complete(ContactChatboxMetadata.fromResponse(responseData));
        }
      },
      onFailed: (responseData) {
        if (!completer.isCompleted) {
          completer.complete(ContactChatboxMetadata.fromResponse(responseData));
        }
      },
      onError: (error) {
        if (!completer.isCompleted) {
          completer.completeError(error ?? 'Failed to fetch chatbox metadata');
        }
      },
    );

    return completer.future;
  }

  Future<void> updateContactProfile({
    BuildContext? context,
    required String contactUid,
    required String firstName,
    required String email,
    required String languageCode,
  }) async {
    final completer = Completer<void>();
    
    await data_transport.post(
      'vendor/contacts/update-process',
      inputData: <String, dynamic>{
        'contactIdOrUid': contactUid,
        'first_name': firstName,
        'email': email.trim() == "..." ? "" : email.trim(),
        'language_code': languageCode,
      },
      context: context,
      onSuccess: (_) {
        if (!completer.isCompleted) {
          completer.complete();
        }
      },
      onFailed: (responseData) {
        if (!completer.isCompleted) {
          completer.completeError(responseData ?? 'Failed to update contact profile');
        }
      },
      onError: (error) {
        if (!completer.isCompleted) {
          completer.completeError(error ?? 'Failed to update contact profile');
        }
      },
    );
    return completer.future;
  }

  Future<void> updateNotes({
    required BuildContext context,
    required String contactUid,
    required String notes,
  }) async {
    final completer = Completer<void>();
    await data_transport.post(
      'vendor/whatsapp/contact/chat/update-notes',
      inputData: <String, dynamic>{
        'contactIdOrUid': contactUid,
        'contact_notes': notes,
      },
      context: context,
      onSuccess: (_) {
        if (!completer.isCompleted) {
          completer.complete();
        }
      },
      onFailed: (responseData) {
        if (!completer.isCompleted) {
          completer.completeError(responseData ?? 'Failed to update notes');
        }
      },
      onError: (error) {
        if (!completer.isCompleted) {
          completer.completeError(error ?? 'Failed to update notes');
        }
      },
    );
    return completer.future;
  }

  Future<void> createLabel({
    required BuildContext context,
    required String title,
    required String textColor,
    required String backgroundColor,
  }) async {
    final completer = Completer<void>();
    await data_transport.post(
      'vendor/whatsapp/contact/create-label',
      inputData: <String, dynamic>{
        'title': title,
        'text_color': textColor,
        'bg_color': backgroundColor,
      },
      context: context,
      onSuccess: (_) {
        if (!completer.isCompleted) {
          completer.complete();
        }
      },
      onFailed: (responseData) {
        if (!completer.isCompleted) {
          completer.completeError(responseData ?? 'Failed to create label');
        }
      },
      onError: (error) {
        if (!completer.isCompleted) {
          completer.completeError(error ?? 'Failed to create label');
        }
      },
    );
    return completer.future;
  }

  Future<void> editLabel({
    required BuildContext context,
    required String labelUid,
    required String title,
    required String textColor,
    required String backgroundColor,
  }) async {
    final completer = Completer<void>();
    await data_transport.post(
      'vendor/whatsapp/contact/chat/edit-label',
      inputData: <String, dynamic>{
        'labelUid': labelUid,
        'title': title,
        'text_color': textColor,
        'bg_color': backgroundColor,
      },
      context: context,
      onSuccess: (_) {
        if (!completer.isCompleted) {
          completer.complete();
        }
      },
      onFailed: (responseData) {
        if (!completer.isCompleted) {
          completer.completeError(responseData ?? 'Failed to edit label');
        }
      },
      onError: (error) {
        if (!completer.isCompleted) {
          completer.completeError(error ?? 'Failed to edit label');
        }
      },
    );
    return completer.future;
  }

  Future<void> deleteLabel({
    required BuildContext context,
    required String labelUid,
  }) async {
    final completer = Completer<void>();
    await data_transport.post(
      'vendor/whatsapp/contact/chat/delete-label/$labelUid',
      inputData: const <String, dynamic>{},
      context: context,
      onSuccess: (_) {
        if (!completer.isCompleted) {
          completer.complete();
        }
      },
      onFailed: (responseData) {
        if (!completer.isCompleted) {
          completer.completeError(responseData ?? 'Failed to delete label');
        }
      },
      onError: (error) {
        if (!completer.isCompleted) {
          completer.completeError(error ?? 'Failed to delete label');
        }
      },
    );
    return completer.future;
  }

  Future<void> assignUser({
    required BuildContext context,
    required String contactUid,
    required String assignedUserUid,
    required bool enableAiBot,
    required bool enableReplyBot,
  }) async {
    final completer = Completer<void>();
    await data_transport.post(
      'vendor/whatsapp/contact/chat/assign-user',
      inputData: <String, dynamic>{
        'contactIdOrUid': contactUid,
        'assigned_users_uid': assignedUserUid,
        'enable_ai_bot': enableAiBot,
        'enable_reply_bot': enableReplyBot,
      },
      context: context,
      onSuccess: (_) {
        if (!completer.isCompleted) {
          completer.complete();
        }
      },
      onFailed: (responseData) {
        if (!completer.isCompleted) {
          completer.completeError(responseData ?? 'Failed to assign user');
        }
      },
      onError: (error) {
        if (!completer.isCompleted) {
          completer.completeError(error ?? 'Failed to assign user');
        }
      },
    );
    return completer.future;
  }

  Future<void> assignLabels({
    required BuildContext context,
    required String contactUid,
    required List<String> labelIds,
  }) async {
    final completer = Completer<void>();
    await data_transport.post(
      'vendor/whatsapp/contact/chat/assign-labels',
      inputData: <String, dynamic>{
        'contactUid': contactUid,
        'contact_labels': labelIds,
      },
      context: context,
      onSuccess: (_) {
        if (!completer.isCompleted) {
          completer.complete();
        }
      },
      onFailed: (responseData) {
        if (!completer.isCompleted) {
          completer.completeError(responseData ?? 'Failed to assign labels');
        }
      },
      onError: (error) {
        if (!completer.isCompleted) {
          completer.completeError(error ?? 'Failed to assign labels');
        }
      },
    );
    return completer.future;
  }
}
