import 'dart:convert';

import 'package:intl/intl.dart';
import '../../../services/utils.dart';
import '/services/auth.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/services/data_transport.dart' as data_transport;

// class ChatboxController extends GetxController {
class ChatboxController extends ChangeNotifier {  // Existing variables
  var holduser = <Map<String, dynamic>>[].obs;
  var emojiShowing = false.obs;
  var iscurrentUser = false.obs;
  var documentsOption = true.obs;
  TextEditingController messageController = TextEditingController();
  TextEditingController messageDraftController = TextEditingController();
  ScrollController scrollController = ScrollController();
  final AudioPlayer _player = AudioPlayer();
  String? userId;
  var _isDataCached = false.obs;

  var isLoading = false.obs;
  var isInitialLoading = false.obs;
  var hasMoreMessages = true.obs;


  var enableAiBot = false.obs;
  var replyAEnableBot = false.obs;
  // bool _isDataCached = false;

  // Cache variables
  var _cachedMessages = <Map<String, dynamic>>[].obs;
// Flag to check if data is cached

  void setUserId(String id) {
    userId = id;
  }

  void toggleEmojiShowing(BuildContext context) {
    emojiShowing.value = !emojiShowing.value;
  }

  bool checkUserLoggedIn() {
    return isLoggedIn();
  }

  void currentUser() {
    iscurrentUser.value = checkUserLoggedIn();
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.minScrollExtent,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void scrollToBottomAllChat() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.jumpTo(
          scrollController.position.maxScrollExtent,
        );
      }
    });
  }

  void addMessage(dynamic message,
      {bool isFile = false, dynamic filename, dynamic filetype}) {
    if (message.isNotEmpty) {
      var now = DateTime.now();
      var formattedDate = DateFormat("EEEE d MMMM yyyy h:mm:ss a").format(now);
      holduser.insert(0, {
        'content': message,
        'isFile': isFile,
        'filename': filename,
        'filetype': filetype,
        'isIncoming': false,
        'formattedMessagedAt': formattedDate,
      });
      _player.play(AssetSource('audio/sendsound.mp3'));
      scrollToBottom();
      messageController.clear();
    }
  }

  Future<void> clearChatHistory(BuildContext? context) async {
    // holduser.clear();
    try {
      await data_transport.post(
        'vendor/whatsapp/contact/chat/clear-history/$userId',
        inputData: {},
        context: context,
        onSuccess: (responseData) {
          getUserChatSend();
        },
        onFailed: (responseData) {
        },
      );
    } catch (e, stack) {
      pr("Error in ClearHistory: $e");
    }
    // _cachedMessages.clear(); // Clear cache when chat history is cleared
    // _isDataCached.value = false;
  }

  List<int> assignedLabelIds = [];

  Future<void> getUserChat() async {
    isInitialLoading.value = true;
    isLoading.value = true;
    try {
      if (userId == null || userId!.isEmpty) {
        _resetLoadingStates();
        return;
      }
      await data_transport.get(
        'vendor/whatsapp/contact/chat/$userId?assigned=',
        onSuccess: (response) {

          _handleSuccessResponse(response);
        },
        onError: (error) {
          _handleError(error);
        },
        onFailed: (failedResponse) {
          _handleFailedResponse(failedResponse);
        },
      );
    } catch (error) {
      _handleUnexpectedError(error);
    }
  }

  void _resetLoadingStates() {
    isLoading.value = false;
    isInitialLoading.value = false;
  }

  void _handleSuccessResponse(dynamic responseData) {
    try {
      holduser.value.clear();
      if (responseData == null) {
        return;
      }

      if (responseData is! Map<String, dynamic>) {
        return;
      }

      // Safely parse the response
      final clientModels = responseData['client_models'] as Map<String, dynamic>?;
      if (clientModels == null) {
        return;
      }
      final enableAiBotValue = clientModels['isAiChatBotEnabled'] ?? false;
      final replyAEnableBotValue = clientModels['isReplyBotEnable'] ?? false;

      enableAiBot.value = enableAiBotValue is bool ? enableAiBotValue : false;
      replyAEnableBot.value = replyAEnableBotValue is bool ? replyAEnableBotValue : false;


      // Parse message logs
      final messageLogs = clientModels['whatsappMessageLogs'];
      if (messageLogs != null && messageLogs is Map) {
        _parseAndAddMessages(messageLogs);
      }

      // Parse labels
      final labels = clientModels['assignedLabelIds'];

      if (labels is List) {
        assignedLabelIds = List<int>.from(labels.whereType<int>());
      }
    } catch (e) {
      pr("Error processing success response: ${e.toString()}");
    } finally {
      _resetLoadingStates();
    }
  }

  void _handleError(dynamic error) {
    pr("onError: ${error?.toString() ?? 'null error'}");
    _resetLoadingStates();
  }

  void _handleFailedResponse(dynamic failedResponse) {
    try {

      if (failedResponse == null) {
        pr("Failed response is null");
        return;
      }

      if (failedResponse is Map<String, dynamic>) {
        pr("Failure details: ${failedResponse['failed'] ?? 'No failure details'}");
      } else {
      }
    } catch (e) {
      pr("Error processing failed response: ${e.toString()}");
    } finally {
      _resetLoadingStates();
    }
  }

  void _handleUnexpectedError(dynamic error) {
    pr("Unexpected error in getUserChat: ${error?.toString() ?? 'unknown error'}");
    _resetLoadingStates();
  }

  Future<void> getUserChatSend() async {
    if (userId == null || userId!.isEmpty) {
      return;
    }
    try {
      await data_transport.get(
        'vendor/whatsapp/contact/chat/$userId?assigned=',
        onSuccess: (responseData) {
          holduser.clear();
          if (responseData is Map<String, dynamic>) {
            _parseAndAddMessages(responseData['client_models']?['whatsappMessageLogs']);
            // Update cache
            _cachedMessages.value = holduser.value;
            _isDataCached.value = true;
          }
        },
      ).catchError((error) {
        pr("catchError $error");
      });
    } catch (error) {
      pr("catch $error");
    } finally {
      if (scrollController.hasClients) {
        scrollController.jumpTo(scrollController.position.minScrollExtent);
      }
    }
  }


  int currentPage = 2;
  Future<void> loadMoreMessages2() async {
    if (!hasMoreMessages.value || isLoading.value) return;

    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 3));
    try {
      await data_transport.get(
        'vendor/whatsapp/contact/chat/$userId?way=prepend&assigned=&page=$currentPage',
        onSuccess: (responseData) {
          if (responseData is Map<String, dynamic>) {
            // _handleSuccessResponse(responseData);
            _parseAndAddMessages(responseData['client_models']?['whatsappMessageLogs']);
          } else {
            hasMoreMessages.value = false;
          }
        },
      ).catchError((error) {});
    } catch (error) {
    } finally {
      isLoading.value = false;
      currentPage++;
    }
  }

  Future<void> sendMediaN({
    String? caption,
    String? uploadingFileNameMedia,
    Map<String, dynamic>? data,
    required BuildContext context,
    String? label,
  }) async {
    final Map<String, dynamic> mediaData = {
      "message": data?["message"] ?? "File uploaded successfully.",
      "path": data?["path"],
      "original_filename": data?["original_filename"],
      "fileName": "67973476ee536---jpeg-20250127-125329-419887063546126133.jpg",
      "fileMimeType": data?["fileMimeType"],
      "fileExtension": data?["fileExtension"],
      "realPath": data?["realPath"],
      "incident": data?["incident"],
    };

    final Map<String, dynamic> payload = {
      "contact_uid": userId,
      "filepond": "undefined",
      "uploaded_media_file_name": uploadingFileNameMedia,
      "media_type": label,
      "raw_upload_data": jsonEncode(data),
      "caption": caption,
    };

    try {
      await data_transport.post(
        'vendor/whatsapp/contact/chat/send-media',
        inputData: payload,
        context: context,
        onSuccess: (responseData) async {
          Navigator.pop(context);
          _player.play(AssetSource('audio/sendsound.mp3'));
          if (userId != null && userId!.isNotEmpty) {
            getUserChatSend();
          }
        },
        onFailed: (responseData) {
        },
      );
    } catch (e, stack) {
      pr("Error in sendMedia: $e");
    }
  }


  void _parseAndAddMessages(Map<dynamic, dynamic>? whatsappMessageLogs) {
    if (whatsappMessageLogs == null) {
      pr("whatsappMessageLogs is null");
      return;
    }

    final newMessages = <Map<String, dynamic>>[];

    whatsappMessageLogs.forEach((key, value) {
      try {
        if (value is! Map<String, dynamic>) {
          pr("Skipping invalid message format for key $key");
          return;
        }

        final message = value['message']?.toString() ?? "";
        final isIncomingMessage = value['is_incoming_message'] == 1;

        final isSystemMessage = value['is_system_message'] == 1;


        // Safely extract all fields with null checks
        // final mediaValues = (value['__data'] as Map<String, dynamic>?)?['media_values']
        // as Map<String, dynamic>?;

        dynamic __data = value['__data'];
        Map<String, dynamic>? mediaValues;

        if (__data is Map<String, dynamic>) {
          mediaValues = __data['media_values'] as Map<String, dynamic>?;
        } else if (__data is List) {
          // Handle case where __data is a list (you might want to process it differently)
          mediaValues = null;
        }

        newMessages.add({
          'content': message,
          'isIncoming': isIncomingMessage,
          'isSystem': isSystemMessage,
          'status': value['status']?.toString() ?? 'unknown',
          'messagedAt': value['messaged_at']?.toString() ?? '',
          'formattedMessagedAt': value['formatted_message_time']?.toString() ?? '',
          'templateMessage': value['template_message']?.toString() ?? '',
          'whatsAppError': value['whatsapp_message_error']?.toString() ?? '',
          '__data': value['__data'] ?? {},
          'media': {
            'link': mediaValues?['link']?.toString() ?? '',
            'type': mediaValues?['type']?.toString() ?? '',
            'caption': mediaValues?['caption']?.toString() ?? '',
            'fileName': mediaValues?['file_name']?.toString() ?? '',
            'mimeType': mediaValues?['mime_type']?.toString() ?? '',
            'originalFileName': mediaValues?['original_filename']?.toString() ?? '',
          },
        });
      } catch (e) {
        pr("Error parsing message $key: ${e.toString()}");
      }
    });

    if (newMessages.isNotEmpty) {
      holduser.addAll(newMessages);
    } else {
      hasMoreMessages.value = false;
    }
  }


  Future<void> loadMessagesWithAppendLogic() async {
    try {
      isLoading.value = true;
      await data_transport.get(
        'vendor/whatsapp/contact/contacts-data/$userId?way=append&request_contact=$userId&=&assigned=',
        onSuccess: (responseData) {
          if (responseData is Map<String, dynamic>) {
            _parseAndAddMessages(responseData['client_models']?['whatsappMessageLogs']);
          }
        },
      ).catchError((error) {});
    } catch (e) {
    } finally {
      isLoading.value = false;
    }
  }

  // Clear cache manually (optional)
  void clearCache() {
    _cachedMessages.clear();
    _isDataCached.value = false;
  }

  // Refresh chat and clear cache
  Future<void> refreshChat() async {
    clearCache();
    await getUserChat();
  }
  @override
  void dispose() {
   currentPage = 2;
    super.dispose();
  }
}