import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:stundaa/model/chat_conversation.dart';
import 'package:stundaa/services/data_transport.dart' as data_transport;

class ChatRepository {
  Future<ChatConversation> fetchConversation(
    String contactUid, {
    String way = '',
    int? page,
  }) async {
    final completer = Completer<ChatConversation>();
    final buffer =
        StringBuffer('vendor/whatsapp/contact/chat/$contactUid?assigned=');
    if (way.isNotEmpty) {
      buffer.write('&way=$way');
    }
    if (page != null) {
      buffer.write('&page=$page');
    }

    await data_transport.get(
      buffer.toString(),
      onSuccess: (responseData) {
        if (!completer.isCompleted) {
          completer.complete(ChatConversation.fromChatResponse(responseData));
        }
      },
      onFailed: (responseData) {
        if (!completer.isCompleted) {
          completer.complete(ChatConversation.fromChatResponse(responseData));
        }
      },
      onError: (error) {
        if (!completer.isCompleted) {
          completer.completeError(error ?? 'Failed to fetch conversation');
        }
      },
    );

    return completer.future;
  }

  Future<void> sendTextMessage({
    required BuildContext context,
    required String contactUid,
    required String messageBody,
    String quotedMessageWamid = '',
  }) async {
    final payload = <String, dynamic>{
      'contact_uid': contactUid,
      'message_body': messageBody,
    };
    if (quotedMessageWamid.isNotEmpty) {
      payload['quoted_message_wamid'] = quotedMessageWamid;
    }

    final completer = Completer<void>();
    await data_transport.post(
      'vendor/whatsapp/contact/chat/send',
      inputData: payload,
      context: context,
      onSuccess: (_) {
        if (!completer.isCompleted) {
          completer.complete();
        }
      },
      onFailed: (responseData) {
        if (!completer.isCompleted) {
          completer.completeError(responseData ?? 'Failed to send message');
        }
      },
      onError: (error) {
        if (!completer.isCompleted) {
          completer.completeError(error ?? 'Failed to send message');
        }
      },
    );

    return completer.future;
  }

  Future<void> clearHistory({
    BuildContext? context,
    required String contactUid,
  }) async {
    final completer = Completer<void>();
    await data_transport.post(
      'vendor/whatsapp/contact/chat/clear-history/$contactUid',
      inputData: const <String, dynamic>{},
      context: context,
      onSuccess: (_) {
        if (!completer.isCompleted) {
          completer.complete();
        }
      },
      onFailed: (responseData) {
        if (!completer.isCompleted) {
          completer.completeError(responseData ?? 'Failed to clear history');
        }
      },
      onError: (error) {
        if (!completer.isCompleted) {
          completer.completeError(error ?? 'Failed to clear history');
        }
      },
    );

    return completer.future;
  }

  Future<void> sendMedia({
    required BuildContext context,
    required String contactUid,
    required String uploadedMediaFileName,
    required String mediaType,
    Map<String, dynamic>? rawUploadData,
    String? caption,
    String quotedMessageWamid = '',
  }) async {
    final payload = <String, dynamic>{
      'contact_uid': contactUid,
      'filepond': 'undefined',
      'uploaded_media_file_name': uploadedMediaFileName,
      'media_type': mediaType,
      'raw_upload_data': jsonEncode(rawUploadData),
      'caption': caption,
    };
    if (quotedMessageWamid.isNotEmpty) {
      payload['quoted_message_wamid'] = quotedMessageWamid;
    }

    final completer = Completer<void>();
    await data_transport.post(
      'vendor/whatsapp/contact/chat/send-media',
      inputData: payload,
      context: context,
      onSuccess: (_) {
        if (!completer.isCompleted) {
          completer.complete();
        }
      },
      onFailed: (responseData) {
        if (!completer.isCompleted) {
          completer.completeError(responseData ?? 'Failed to send media');
        }
      },
      onError: (error) {
        if (!completer.isCompleted) {
          completer.completeError(error ?? 'Failed to send media');
        }
      },
    );

    return completer.future;
  }

  Future<String?> prepareSendMedia(String label) async {
    final completer = Completer<String?>();
    await data_transport.get(
      'vendor/whatsapp/contact/chat/prepare-send-media/$label',
      onSuccess: (responseData) {
        if (!completer.isCompleted) {
          completer.complete(responseData?['data']?['uploadTitle']?.toString());
        }
      },
      onFailed: (_) {
        if (!completer.isCompleted) {
          completer.complete(null);
        }
      },
      onError: (_) {
        if (!completer.isCompleted) {
          completer.complete(null);
        }
      },
    );

    return completer.future;
  }
}
