import 'dart:async';
import 'dart:convert';
import 'package:stundaa/model/chat_conversation.dart';
import 'package:stundaa/model/chat_message.dart';
import 'package:stundaa/repositories/chat_repository.dart';
import 'package:stundaa/services/utils.dart';
import 'package:stundaa/services/auth.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

// class ChatboxController extends GetxController {
class ChatboxController extends ChangeNotifier {
  // Existing variables
  var holduser = <Map<String, dynamic>>[].obs;
  var messageModels = <ChatMessage>[].obs;
  var emojiShowing = false.obs;
  var iscurrentUser = false.obs;
  var documentsOption = true.obs;
  TextEditingController messageController = TextEditingController();
  TextEditingController messageDraftController = TextEditingController();
  ScrollController scrollController = ScrollController();
  final AudioPlayer _player = AudioPlayer();
  final ChatRepository _chatRepository = ChatRepository();
  String? userId;
  final _isDataCached = false.obs;

  var isLoading = false.obs;
  var isInitialLoading = false.obs;
  var hasMoreMessages = true.obs;

  var enableAiBot = false.obs;
  var replyAEnableBot = false.obs;
  // bool _isDataCached = false;

  // Cache variables
  final _cachedMessages = <Map<String, dynamic>>[].obs;
  // Flag to check if data is cached

  // Reply chat states
  var selectedReplyMessage = Rxn<Map<String, dynamic>>();
  static final RegExp _htmlTagPattern = RegExp(r'<[^>]*>');

  /// Persistent reply cache: survives app restart because backend does not
  /// populate replied_to_whatsapp_message_logs__uid.
  /// Key = message wamid (outgoing), value = replied-to wamid/uid.
  /// Stored in SharedPreferences as JSON under key "reply_cache_{userId}".
  final _localReplyCache = <String, String>{};

  /// Load cache from SharedPreferences for current userId.
  /// Cache key = message content (trimmed), value = repliedToWamid/uid.
  Future<void> _loadReplyCache() async {
    if (userId == null || userId!.isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('reply_cache_$userId');
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is Map) {
          _localReplyCache.clear();
          decoded.forEach((k, v) {
            if (k is String && v is String) {
              _localReplyCache[k] = v;
            }
          });
        }
      }
    } catch (e) {
      pr('_loadReplyCache error: $e');
    }
  }

  /// Persist cache entry: message content → replied-to wamid/uid.
  Future<void> _persistReplyCacheEntry(String content, String repliedToId) async {
    if (userId == null || userId!.isEmpty) return;
    _localReplyCache[content] = repliedToId;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('reply_cache_$userId', jsonEncode(_localReplyCache));
    } catch (e) {
      pr('_persistReplyCacheEntry error: $e');
    }
  }

  void setReplyMessage(Map<String, dynamic> message) {
    selectedReplyMessage.value = message;
    notifyListeners();
  }

  void clearReplyMessage() {
    selectedReplyMessage.value = null;
    notifyListeners();
  }

  void addQuotedMessageWamid(Map<String, dynamic> payload) {
    final quotedMessageWamid =
        selectedReplyMessage.value?['wamid']?.toString() ?? '';
    if (quotedMessageWamid.isNotEmpty) {
      payload['quoted_message_wamid'] = quotedMessageWamid;
    }
  }

  bool canReplyToMessage(Map<String, dynamic> message) {
    if (message['isSystem'] == true) {
      return false;
    }

    final wamid = message['wamid']?.toString() ?? '';
    return wamid.isNotEmpty;
  }

  String buildReplyPreviewText(Map<String, dynamic>? message,
      {String fallback = 'Message'}) {
    if (message == null) {
      return fallback;
    }

    final content = message['content']?.toString() ?? '';
    final plainText = content.replaceAll(_htmlTagPattern, '').trim();
    if (plainText.isNotEmpty) {
      return plainText;
    }

    final media = message['media'] as Map<String, dynamic>? ?? const {};
    return mediaTypeLabel(media['type']?.toString() ?? '', fallback: fallback);
  }

  String mediaTypeLabel(String mediaType, {String fallback = 'Media'}) {
    switch (mediaType.toLowerCase()) {
      case 'image':
        return 'Photo';
      case 'video':
        return 'Video';
      case 'audio':
        return 'Audio';
      case 'document':
        return 'Document';
      default:
        return fallback;
    }
  }

  Map<String, dynamic>? findMessageByUid(String? messageUid) {
    if (messageUid == null || messageUid.isEmpty) {
      return null;
    }

    for (final message in holduser) {
      // Check both uid and wamid
      if (message['uid'] == messageUid || message['wamid'] == messageUid) {
        return message;
      }
    }

    return null;
  }

  Timer? _pollingTimer;

  void setUserId(String id) {
    if (userId != id) {
      userId = id;
      _loadReplyCache(); // load persisted reply cache for this contact
      _startPolling();
    }
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (userId != null && userId!.isNotEmpty) {
        getUserChatSend();
      }
    });
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  void toggleEmojiShowing() {
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
      final draftMessage = ChatMessage.localOutgoing(
        message.toString(),
        repliedToMessageUid: selectedReplyMessage.value?['wamid']?.toString().isNotEmpty == true
            ? selectedReplyMessage.value!['wamid'].toString()
            : selectedReplyMessage.value?['uid']?.toString() ?? '',
        isFile: isFile,
        filename: filename,
        filetype: filetype,
      );
      messageModels.insert(0, draftMessage);
      holduser.insert(0, draftMessage.toMap());
      _player.play(AssetSource('audio/sendsound.mp3'));
      scrollToBottom();
      messageController.clear();
    }
  }

  void injectReplyChatDummyConversation() {
    if (holduser.any((message) => message['uid'] == 'dummy-reply-1')) {
      return;
    }

    final dummyMessages = <ChatMessage>[
      ChatMessage.dummy(
        uid: 'dummy-original-1',
        wamid: 'wamid-dummy-original-1',
        repliedToMessageUid: '',
        content: 'Halo admin, saya mau tanya status jadwal saya hari ini.',
        isIncoming: true,
        status: 'received',
        messagedAt: '2026-06-08 08:12:00',
        formattedMessagedAt: '8:12 AM',
      ),
      ChatMessage.dummy(
        uid: 'dummy-reply-1',
        wamid: 'wamid-dummy-reply-1',
        repliedToMessageUid: 'dummy-original-1',
        content:
            'Baik, jadwal Anda sudah kami cek. Ini dummy 1 pesan terkirim untuk tes reply chat.',
        isIncoming: false,
        status: 'sent',
        messagedAt: '2026-06-08 08:15:00',
        formattedMessagedAt: '8:15 AM',
      ),
    ];
    _replaceMessages(dummyMessages);
  }

  void injectReplyChatDummyIfEmpty() {
    assert(() {
      if (holduser.isEmpty) {
        injectReplyChatDummyConversation();
      }
      return true;
    }());
  }

  Future<void> clearChatHistory(BuildContext? context) async {
    try {
      if (userId == null || userId!.isEmpty) {
        return;
      }
      await _chatRepository.clearHistory(
        context: context,
        contactUid: userId!,
      );
      await getUserChatSend();
    } catch (e) {
      pr("Error in ClearHistory: $e");
    }
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
      final conversation = await _chatRepository.fetchConversation(userId!);
      _handleConversationResponse(conversation, replaceExisting: true);
    } catch (error) {
      // Handle error gracefully - don't crash, just show empty chat
      pr("Error fetching conversation: $error");
      _resetLoadingStates();
      // Clear messages to show empty state
      holduser.clear();
      messageModels.clear();
    }
  }

  void _resetLoadingStates() {
    isLoading.value = false;
    isInitialLoading.value = false;
  }

  void _handleConversationResponse(
    ChatConversation conversation, {
    required bool replaceExisting,
  }) {
    try {
      enableAiBot.value = conversation.enableAiBot;
      replyAEnableBot.value = conversation.enableReplyBot;
      if (replaceExisting) {
        _replaceMessages(conversation.messages);
      } else {
        _appendMessages(conversation.messages);
      }
      injectReplyChatDummyIfEmpty();
      assignedLabelIds = conversation.assignedLabelIds;
    } catch (e) {
      pr("Error processing success response: ${e.toString()}");
    } finally {
      _resetLoadingStates();
    }
  }

  Future<void> getUserChatSend() async {
    if (userId == null || userId!.isEmpty) {
      return;
    }
    try {
      final conversation = await _chatRepository.fetchConversation(userId!);
      _handleConversationResponse(conversation, replaceExisting: true);
      _cachedMessages.assignAll(holduser);
      _isDataCached.value = true;
    } catch (error) {
      pr("Error in getUserChatSend: $error");
      // Don't crash, just keep current state
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
      final conversation = await _chatRepository.fetchConversation(
        userId!,
        way: 'prepend',
        page: currentPage,
      );
      if (conversation.messages.isEmpty) {
        hasMoreMessages.value = false;
      } else {
        _handleConversationResponse(conversation, replaceExisting: false);
      }
    } catch (error) {
      pr("loadMoreMessages2 catch $error");
    } finally {
      isLoading.value = false;
      currentPage++;
    }
  }

  Future<bool> sendMediaN({
    String? caption,
    String? uploadingFileNameMedia,
    Map<String, dynamic>? data,
    required BuildContext context,
    String? label,
  }) async {
    try {
      await _chatRepository.sendMedia(
        context: context,
        contactUid: userId ?? '',
        uploadedMediaFileName: uploadingFileNameMedia ?? '',
        mediaType: label ?? '',
        rawUploadData: data,
        caption: caption,
        quotedMessageWamid:
            selectedReplyMessage.value?['wamid']?.toString() ?? '',
      );
      clearReplyMessage();
      _player.play(AssetSource('audio/sendsound.mp3'));
      if (userId != null && userId!.isNotEmpty) {
        getUserChatSend();
      }
      return true;
    } catch (e) {
      pr("Error in sendMedia: $e");
      return false;
    }
  }

  void _replaceMessages(List<ChatMessage> messages) {
    // Keep local pending/sending messages so they don't disappear while refreshing
    final pendingMessages = holduser
        .where((m) => m['status'] == 'pending' || m['status'] == 'sending')
        .toList();

    // Build lookup: content → repliedToMessageUid from current local messages.
    // Used to restore reply context lost when API omits replied_to field.
    final localReplyByContent = <String, String>{};
    for (final m in holduser) {
      final uid = m['repliedToMessageUid']?.toString() ?? '';
      if (uid.isNotEmpty) {
        localReplyByContent[m['content']?.toString() ?? ''] = uid;
      }
    }
    // Also merge persisted cache.
    localReplyByContent.addAll(_localReplyCache);

    messageModels.assignAll(messages);
    final apiMessages = messages.map((message) {
      final map = message.toMap();
      // Restore repliedToMessageUid if API returned it empty but we have local data.
      final replied = map['repliedToMessageUid']?.toString() ?? '';
      if (replied.isEmpty) {
        final content = map['content']?.toString() ?? '';
        final restored = localReplyByContent[content];
        if (restored != null && restored.isNotEmpty) {
          map['repliedToMessageUid'] = restored;
        }
      }
      return map;
    }).toList();

    // Avoid duplicates if API already returned the message
    final apiUids = apiMessages.map((m) => m['uid']).toSet();
    final uniquePending =
        pendingMessages.where((m) => !apiUids.contains(m['uid'])).toList();

    holduser.assignAll([...uniquePending, ...apiMessages]);
  }

  void _appendMessages(List<ChatMessage> messages) {
    if (messages.isEmpty) {
      hasMoreMessages.value = false;
      return;
    }
    messageModels.addAll(messages);
    holduser.addAll(messages.map((message) => message.toMap()).toList());
  }

  Future<void> loadMessagesWithAppendLogic() async {
    try {
      isLoading.value = true;
      final conversation = await _chatRepository.fetchConversation(userId!);
      _handleConversationResponse(conversation, replaceExisting: true);
    } catch (e) {
      pr("loadMessagesWithAppendLogic catch $e");
    } finally {
      isLoading.value = false;
    }
  }

  DateTime? _lastSentTime;
  static const _cooldownDuration = Duration(seconds: 5);

  Future<void> sendTextMessage(BuildContext context, String messageBody) async {
    if (userId == null || userId!.isEmpty || messageBody.trim().isEmpty) {
      return;
    }

    final now = DateTime.now();
    if (_lastSentTime != null &&
        now.difference(_lastSentTime!) < _cooldownDuration) {
      final remaining =
          _cooldownDuration.inSeconds - now.difference(_lastSentTime!).inSeconds;
      showToastMessage(
          context, "Please wait $remaining seconds before sending again",
          type: "warning");
      return;
    }

    final trimmedMessage = messageBody.trim();
    // Only use wamid — local UIDs are not valid WhatsApp message IDs and
    // cannot be forwarded to WhatsApp Cloud API as context.message_id.
    final quotedMessageId =
        selectedReplyMessage.value?['wamid']?.toString() ?? '';
    // wamid must look like a real WA ID (not a local optimistic ID)
    final isValidWamid = quotedMessageId.isNotEmpty &&
        !quotedMessageId.startsWith('local-');
    final effectiveQuotedId = isValidWamid ? quotedMessageId : '';
    pr('[REPLY] quotedMessageId=$quotedMessageId isValid=$isValidWamid effectiveId=$effectiveQuotedId');

    _lastSentTime = now;

    // Cache reply association so bubble survives API refresh + app restart.
    // Use effectiveQuotedId (valid wamid only) for sending, but store
    // quotedMessageId (may be wamid or uid) for local bubble display.
    if (effectiveQuotedId.isNotEmpty) {
      _persistReplyCacheEntry(trimmedMessage, effectiveQuotedId);
    }

    // Optimistic update using factory — use raw quotedMessageId for local
    // display so bubble shows even when replying to outgoing messages.
    final pendingMessage = ChatMessage.localOutgoing(
      trimmedMessage,
      repliedToMessageUid: quotedMessageId,
    );

    final localId = pendingMessage.uid;
    holduser.insert(0, pendingMessage.toMap());
    messageController.clear();

    try {
      await _chatRepository.sendTextMessage(
        context: context,
        contactUid: userId!,
        messageBody: trimmedMessage,
        quotedMessageWamid: effectiveQuotedId, // only valid wamid sent to backend
      );

      // Status update to 'sent' (or just let the refresh handle it)
      _updateMessageStatus(localId, 'sent');
      clearReplyMessage();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (userId != null && userId!.isNotEmpty) {
          // Removed delay entirely for instant refresh
          getUserChatSend();
        }
      });
    } catch (e) {
      pr("Error sending message: $e");
      _updateMessageStatus(localId, 'failed');
      
      String errorMsg = "Failed to send message. Tap to retry.";
      if (e is Map && e['message'] != null) {
        errorMsg = e['message'].toString();
      } else if (e.toString().isNotEmpty) {
        errorMsg = e.toString();
      }

      if (context.mounted) {
        showToastMessage(context, errorMsg, type: "error");
      }
    }
  }

  void _updateMessageStatus(String localId, String newStatus) {
    final index = holduser.indexWhere((m) => m['uid'] == localId);
    if (index != -1) {
      final updated = Map<String, dynamic>.from(holduser[index]);
      updated['status'] = newStatus;
      holduser[index] = updated;
    }
  }

  Future<void> forwardMessages(
    BuildContext context,
    String targetContactUid,
    List<Map<String, dynamic>> messages,
  ) async {
    for (final msg in messages) {
      final content = msg['content']?.toString() ?? '';
      if (content.isEmpty) {
        continue;
      }
      await _chatRepository.sendTextMessage(
        context: context,
        contactUid: targetContactUid,
        messageBody: content,
      );
    }
  }

  Future<String?> prepareSendMedia(String label) {
    return _chatRepository.prepareSendMedia(label);
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
    _stopPolling();
    currentPage = 2;
    super.dispose();
  }
}
