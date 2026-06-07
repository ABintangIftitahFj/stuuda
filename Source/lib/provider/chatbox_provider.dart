import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:stundaa/services/auth.dart';
import 'package:stundaa/services/data_transport.dart' as data_transport;

class ChatboxProvider with ChangeNotifier {
  List<Map<String, dynamic>> holduser = [];
  bool emojiShowing = false;
  bool isCurrentUser = false;
  bool documentsOption = true;
  TextEditingController messageController = TextEditingController();
  TextEditingController messageDraftController = TextEditingController();
  ScrollController scrollController = ScrollController();
  final AudioPlayer _player = AudioPlayer();
  String? userId;
  int currentPage = 2;
  // bool isLoading = false;
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  bool isInitialLoading = false;
  bool hasMoreMessages = true;

  void setUserId(String id) {
    userId = id;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }


  void toggleEmojiShowing() {
    emojiShowing = !emojiShowing;
    notifyListeners();
  }

  bool checkUserLoggedIn() {
    return isLoggedIn();
  }

  void currentUser() {
    isCurrentUser = checkUserLoggedIn();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
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
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      }
    });
  }

  void addMessage(dynamic message, {bool isFile = false, dynamic filename, dynamic filetype}) {
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
      notifyListeners();
    }
  }

  void clearChatHistory() {
    holduser.clear();
  }

  List<int> assignedLabelIds = [];

  Future<List<int>> getUserChat() async {
    if (userId == null || userId!.isEmpty) {
      return [];
    }

    isInitialLoading = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      await data_transport.get(
        'vendor/whatsapp/contact/chat/$userId?assigned=',
        onSuccess: (responseData) {
          holduser.clear();

          if (responseData is Map<String, dynamic>) {
            _parseAndAddMessages(
                responseData['client_models']?['whatsappMessageLogs']);

            var labels = responseData['client_models']?['assignedLabelIds'];
            if (labels is List) {
              assignedLabelIds = List<int>.from(labels);
            }
          }
        },
      );
      return [];
    } catch (error) {
      debugPrint("Error: $error");
      return [];
    } finally {
      isInitialLoading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      // notifyListeners();
      if (scrollController.hasClients) {
        scrollController.jumpTo(scrollController.position.minScrollExtent);
      }
    }
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
            _parseAndAddMessages(
                responseData['client_models']?['whatsappMessageLogs']);
          }
        },
      ).catchError((error) {
        return "";
      });
    } catch (error) {
      // ignore
    } finally {
      if (scrollController.hasClients) {
        scrollController.jumpTo(scrollController.position.minScrollExtent);
      }
    }
  }

  Future<void> loadMoreMessages2() async {
    if (!hasMoreMessages || isLoading) return;
    isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 3));

      await data_transport.get(
        'vendor/whatsapp/contact/chat/$userId?way=prepend&assigned=&page=$currentPage',
        onSuccess: (responseData) {
          if (responseData is Map<String, dynamic>) {
            _parseAndAddMessages(
                responseData['client_models']?['whatsappMessageLogs']);
          } else {
            hasMoreMessages = false; // No more messages
          }
        },
      ).catchError((error) {
        debugPrint("Error loading more messages: $error");
        return "";
      });
    } finally {
      isLoading = false;
      notifyListeners();
      currentPage++;
    }
  }


  void _parseAndAddMessages(Map<String, dynamic>? whatsappMessageLogs) {
    if (whatsappMessageLogs == null) return;

    var newMessages = <Map<String, dynamic>>[];
    whatsappMessageLogs.forEach((key, value) {
      final message = value['message'];
      final isIncomingMessage = value['is_incoming_message'];
      final status = value['status'];
      final formattedMessagedAt = value['formatted_message_time'];
      final mediaValues = value['__data']?['media_values'];
      final link = mediaValues?['link'];
      final type = mediaValues?['type'];
      final fileName = mediaValues?['file_name'];
      final mimeType = mediaValues?['mime_type'];

      if (message != null && isIncomingMessage != null) {
        newMessages.add({
          'content': message ?? '',
          'isIncoming': isIncomingMessage == 1,
          'status': status ?? '',
          'formattedMessagedAt': formattedMessagedAt ?? '',
          'media': {
            'link': link ?? '',
            'type': type ?? '',
            'fileName': fileName ?? '',
            'mimeType': mimeType ?? '',
          },
        });
      }
    });

    if (newMessages.isEmpty) {
      hasMoreMessages = false;
    } else {
      holduser.addAll(newMessages);
    }

    notifyListeners();
  }
}
