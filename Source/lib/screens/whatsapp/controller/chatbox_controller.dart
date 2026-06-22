import 'dart:async';
import 'dart:convert';
import 'package:stundaa/model/chat_conversation.dart';
import 'package:stundaa/model/chat_message.dart';
import 'package:stundaa/model/contact_summary.dart';
import 'package:stundaa/repositories/chat_repository.dart';
import 'package:stundaa/repositories/campaign_repository.dart';
import 'package:stundaa/services/utils.dart';
import 'package:stundaa/services/auth.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

// class ChatboxController extends GetxController {
class ChatboxController extends ChangeNotifier {
  static const templateWaitingNoticeText =
      'Template terkirim. Menunggu balasan customer untuk membuka chat kembali.';

  var templatesList = <Map<String, dynamic>>[].obs;
  var isLoadingTemplates = false.obs;
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
  var isWindowOpened = false.obs;
  var windowExpiresText = ''.obs;
  var windowCountdownText = ''.obs;
  DateTime? _windowExpiresAt;
  Timer? _windowCountdownTimer;
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
  Future<void> _persistReplyCacheEntry(
      String content, String repliedToId) async {
    if (userId == null || userId!.isEmpty) return;
    _localReplyCache[content] = repliedToId;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'reply_cache_$userId', jsonEncode(_localReplyCache));
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
    return message['isSystem'] != true;
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
  String? _activeContactUid;

  void setUserId(String id) {
    if (userId != id) {
      userId = id;
      _activeContactUid = id;
      holduser.clear();
      messageModels.clear();
      currentPage = 2;
      hasMoreMessages.value = true;
      selectedReplyMessage.value = null;
      _loadReplyCache(); // load persisted reply cache for this contact
      _startPolling();
    } else {
      _activeContactUid = id;
    }
  }

  bool isActiveContact(dynamic contactUid) {
    final activeContactUid = _activeContactUid;
    if (activeContactUid == null || activeContactUid.isEmpty) {
      return false;
    }
    return contactUid?.toString() == activeContactUid;
  }

  void clearActiveContact(String contactUid) {
    if (_activeContactUid != contactUid) {
      return;
    }
    _activeContactUid = null;
    _stopPolling();
  }

  void seedLatestMessageFromContact(ContactSummary contact) {
    if (contact.uid != userId) {
      return;
    }

    // Seed window state from contact list payload so badge inside chat
    // matches outside immediately (before chat detail API resolves).
    _seedWindowFromContact(contact);

    final lastMessage = contact.raw['last_message'];
    if (lastMessage is! Map) {
      return;
    }

    final message = ChatMessage.fromApiEntry(
      MapEntry(
        lastMessage['_uid'] ?? lastMessage['uid'] ?? 'latest-${contact.uid}',
        Map<String, dynamic>.from(lastMessage),
      ),
    );

    if (message.content.trim().isEmpty &&
        message.templateMessage.trim().isEmpty &&
        message.media.link.trim().isEmpty) {
      return;
    }

    final messageMap = message.toMap();
    final messageUid = messageMap['uid']?.toString() ?? '';
    if (messageUid.isNotEmpty &&
        holduser.any((entry) => entry['uid']?.toString() == messageUid)) {
      return;
    }

    holduser.insert(0, messageMap);
    messageModels.insert(0, message);
  }

  /// Parse server timestamp ("YYYY-MM-DD HH:mm:ss" or ISO-8601) as UTC.
  DateTime? _parseUtcTimestamp(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final normalized = raw.trim().replaceFirst(' ', 'T');
      final dt = DateTime.parse(normalized);
      return dt.isUtc
          ? dt
          : DateTime.utc(
              dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second);
    } catch (_) {
      return null;
    }
  }

  /// Seed window state from contact.raw.last_incoming_message so the badge
  /// inside chat matches the contact list badge immediately on open.
  void _seedWindowFromContact(ContactSummary contact) {
    final lastIncoming = contact.raw['last_incoming_message'];
    if (lastIncoming is! Map) return;
    final messagedAt = _parseUtcTimestamp(lastIncoming['messaged_at']?.toString());
    if (messagedAt == null) return;
    final expiresAt = messagedAt.add(const Duration(hours: 24));
    if (DateTime.now().toUtc().isBefore(expiresAt)) {
      isWindowOpened.value = true;
      _startWindowCountdown(expiresAt.toLocal());
    }
  }

  /// Compute window state from messages we already have. Used to override
  /// a stale API `isDirectMessageDeliveryWindowOpened=false` when the local
  /// data shows a recent incoming message — keeps the inside badge in sync
  /// with the outside contact-list badge (both derive from "last incoming
  /// message <24h ago").
  DateTime? _windowExpiryFromLocal() {
    DateTime? newestIncomingUtc;
    for (final m in holduser) {
      final isIncoming = m['isIncoming'] == true;
      final isSystem = m['isSystem'] == true;
      if (!isIncoming || isSystem) continue;
      final ts = _parseUtcTimestamp(m['messagedAt']?.toString());
      if (ts == null) continue;
      if (newestIncomingUtc == null || ts.isAfter(newestIncomingUtc)) {
        newestIncomingUtc = ts;
      }
    }
    if (newestIncomingUtc == null) return null;
    final expiresAt = newestIncomingUtc.add(const Duration(hours: 24));
    if (DateTime.now().toUtc().isBefore(expiresAt)) {
      return expiresAt.toLocal();
    }
    return null;
  }

  Future<void> refreshActiveChatForContact(dynamic contactUid) async {
    if (!isActiveContact(contactUid)) {
      return;
    }

    final activeContactUid = _activeContactUid;
    await getUserChatSend();

    // Webhook broadcasts can arrive before the latest log is available to the
    // chat endpoint. Retry once shortly after the event while the chat is open.
    Future.delayed(const Duration(seconds: 2), () {
      if (activeContactUid != null && isActiveContact(activeContactUid)) {
        getUserChatSend();
      }
    });
  }

  bool _pusherConnected = false;

  void setPusherConnected(bool connected) {
    _pusherConnected = connected;
    if (connected) {
      _stopPolling();
    } else {
      _startPolling();
    }
  }

  void _startPolling() {
    if (_pusherConnected) return;
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

  void _startWindowCountdown(DateTime expiresAt) {
    _windowExpiresAt = expiresAt;
    _windowCountdownTimer?.cancel();
    _updateWindowCountdown();
    _windowCountdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateWindowCountdown();
    });
  }

  void _updateWindowCountdown() {
    final expires = _windowExpiresAt;
    if (expires == null) return;
    final remaining = expires.difference(DateTime.now());
    if (remaining.isNegative) {
      windowCountdownText.value = '';
      isWindowOpened.value = false;
      _windowCountdownTimer?.cancel();
      return;
    }
    final h = remaining.inHours;
    final m = remaining.inMinutes % 60;
    final s = remaining.inSeconds % 60;
    windowCountdownText.value =
        '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _stopWindowCountdown() {
    _windowCountdownTimer?.cancel();
    _windowCountdownTimer = null;
    _windowExpiresAt = null;
    windowCountdownText.value = '';
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
        repliedToMessageUid:
            selectedReplyMessage.value?['wamid']?.toString().isNotEmpty == true
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
      holduser.clear();
      messageModels.clear();
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
      windowExpiresText.value =
          conversation.directMessageDeliveryWindowOpenedTillMessage;

      // Apply messages FIRST so window reconciliation can read holduser.
      if (replaceExisting) {
        _replaceMessages(conversation.messages);
      } else {
        _appendMessages(conversation.messages);
      }

      // Reconcile window state: prefer API when open; otherwise fall back
      // to local computation (newest incoming <24h). The contact-list
      // endpoint and chat endpoint use the same backend formula but can
      // briefly diverge — local data is what the user already sees, so
      // align the inside badge to it instead of trusting a stale flag.
      final apiOpen = conversation.isDirectMessageDeliveryWindowOpened;
      final apiExpires = conversation.windowExpiresAt;
      final localExpiresLocal = _windowExpiryFromLocal();
      final seededExpires = _windowExpiresAt;
      final seededStillValid =
          seededExpires != null && seededExpires.isAfter(DateTime.now());
      if (apiOpen && apiExpires != null) {
        isWindowOpened.value = true;
        _startWindowCountdown(apiExpires);
      } else if (localExpiresLocal != null) {
        isWindowOpened.value = true;
        _startWindowCountdown(localExpiresLocal);
      } else if (seededStillValid) {
        isWindowOpened.value = true;
      } else {
        isWindowOpened.value = false;
        _stopWindowCountdown();
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
    // Snapshot scroll position BEFORE refresh. With reverse:true,
    // minScrollExtent == newest end. If user is browsing older messages
    // (scrolled away from the newest end), preserve their position so
    // 10s polling doesn't yank them to the bottom and hide old messages.
    final wasNearNewest = scrollController.hasClients
        ? (scrollController.position.pixels -
                scrollController.position.minScrollExtent) <
            120
        : true;
    try {
      final conversation = await _chatRepository.fetchConversation(userId!);
      _handleConversationResponse(conversation, replaceExisting: true);
      _cachedMessages.assignAll(holduser);
      _isDataCached.value = true;
    } catch (error) {
      pr("Error in getUserChatSend: $error");
      // Don't crash, just keep current state
    } finally {
      if (wasNearNewest && scrollController.hasClients) {
        scrollController.jumpTo(scrollController.position.minScrollExtent);
      }
    }
  }

  int currentPage = 2;
  Future<void> loadMoreMessages2() async {
    if (!hasMoreMessages.value || isLoading.value) return;

    isLoading.value = true;
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
    bool isRecordedAudio = false,
  }) async {
    try {
      final mediaWamid = selectedReplyMessage.value?['wamid']?.toString() ?? '';
      final mediaUid = selectedReplyMessage.value?['uid']?.toString() ?? '';
      final isMediaValidWamid = mediaWamid.isNotEmpty &&
          !mediaWamid.startsWith('local-') &&
          mediaWamid != mediaUid;
      final effectiveMediaQuotedId = isMediaValidWamid ? mediaWamid : '';

      await _chatRepository.sendMedia(
        context: context,
        contactUid: userId ?? '',
        uploadedMediaFileName: uploadingFileNameMedia ?? '',
        mediaType: label ?? '',
        rawUploadData: data,
        caption: caption,
        quotedMessageWamid: effectiveMediaQuotedId,
        isRecordedAudio: isRecordedAudio,
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
    if (messages.isEmpty && holduser.isNotEmpty) {
      return;
    }

    // Build lookup: content → repliedToMessageUid from current local messages.
    // Used to restore reply context lost when API omits replied_to field.
    final localReplyByContent = <String, String>{};
    // Build lookup: content → local uid for outgoing optimistic messages so
    // we can remap reply pointers when the API returns the real uid.
    final localUidByOutgoingContent = <String, String>{};
    for (final m in holduser) {
      final uid = m['repliedToMessageUid']?.toString() ?? '';
      if (uid.isNotEmpty) {
        localReplyByContent[m['content']?.toString() ?? ''] = uid;
      }
      final mUid = m['uid']?.toString() ?? '';
      final isIncoming = m['isIncoming'] == true;
      if (mUid.startsWith('local-') && !isIncoming) {
        localUidByOutgoingContent[m['content']?.toString() ?? ''] = mUid;
      }
    }
    localReplyByContent.addAll(_localReplyCache);

    // localUid → realUid mapping: an API message with content matching an
    // outstanding local-* outgoing message means the optimistic uid is being
    // replaced. Anything still pointing at the local uid (as a reply target)
    // must be remapped or its quoted bubble breaks.
    final localToRealUid = <String, String>{};
    for (final message in messages) {
      if (message.isIncoming) continue;
      final localUid = localUidByOutgoingContent[message.content];
      if (localUid != null && localUid.isNotEmpty && localUid != message.uid) {
        localToRealUid[localUid] = message.uid;
      }
    }

    messageModels.assignAll(messages);
    final apiMessages = messages.map((message) {
      final map = message.toMap();
      final replied = map['repliedToMessageUid']?.toString() ?? '';
      if (replied.isEmpty) {
        final content = map['content']?.toString() ?? '';
        final restored = localReplyByContent[content];
        if (restored != null && restored.isNotEmpty) {
          // Restored value may itself be a stale local uid — remap if known.
          map['repliedToMessageUid'] = localToRealUid[restored] ?? restored;
        }
      } else if (localToRealUid.containsKey(replied)) {
        map['repliedToMessageUid'] = localToRealUid[replied]!;
      }
      return map;
    }).toList();

    final apiUids = apiMessages.map((m) => m['uid']).toSet();

    // Preserve any local message whose uid is not in the API response.
    // - Pending/sending/failed optimistic sends still in flight.
    // - Newly accepted server messages not yet indexed in API (any status).
    // - Older paginated messages loaded via loadMoreMessages2 (page > 1).
    // Without this, polling refresh (page=1) wipes pagination history and
    // newly-sent messages with non-whitelisted status (e.g. "initialize").
    final preservedPending = <Map<String, dynamic>>[];
    final preservedOlder = <Map<String, dynamic>>[];
    for (final m in holduser) {
      if (apiUids.contains(m['uid'])) continue;
      final status = m['status']?.toString() ?? '';
      final uid = m['uid']?.toString() ?? '';
      final isInFlightLocal = uid.startsWith('local-') ||
          status == 'pending' ||
          status == 'sending' ||
          status == 'failed';
      // Remap stale local-uid reply pointers on preserved entries so the
      // quoted bubble can resolve once the target's real uid has arrived.
      final repliedTo = m['repliedToMessageUid']?.toString() ?? '';
      Map<String, dynamic> entry = m;
      if (repliedTo.isNotEmpty && localToRealUid.containsKey(repliedTo)) {
        entry = Map<String, dynamic>.from(m);
        entry['repliedToMessageUid'] = localToRealUid[repliedTo]!;
      }
      if (isInFlightLocal) {
        preservedPending.add(entry);
      } else {
        preservedOlder.add(entry);
      }
    }

    // Order: in-flight optimistic first (newest), API page, then older paginated.
    holduser.assignAll([...preservedPending, ...apiMessages, ...preservedOlder]);
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
      final remaining = _cooldownDuration.inSeconds -
          now.difference(_lastSentTime!).inSeconds;
      showToastMessage(
          context, "Please wait $remaining seconds before sending again",
          type: "warning");
      return;
    }

    final trimmedMessage = messageBody.trim();

    final wamid = selectedReplyMessage.value?['wamid']?.toString() ?? '';
    final uid = selectedReplyMessage.value?['uid']?.toString() ?? '';
    final isValidWamid =
        wamid.isNotEmpty && !wamid.startsWith('local-') && wamid != uid;
    final effectiveQuotedId = isValidWamid ? wamid : '';
    final quotedMessageId = wamid.isNotEmpty ? wamid : uid;
    pr('[REPLY] wamid=$wamid uid=$uid isValid=$isValidWamid effectiveId=$effectiveQuotedId');

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
      final sentMessage = await _chatRepository.sendTextMessage(
        context: context,
        contactUid: userId!,
        messageBody: trimmedMessage,
        quotedMessageWamid:
            effectiveQuotedId, // only valid wamid sent to backend
      );

      // Replace the local optimistic message with the real server message
      _replaceLocalOptimisticMessage(localId, sentMessage);
      clearReplyMessage();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (userId != null && userId!.isNotEmpty) {
          // Refresh conversation list to get latest messages and updates
          getUserChatSend();
        }
      });
    } catch (e) {
      pr("Error sending message: $e");

      final errorMsg = _parseErrorMessage(e, fallback: "Failed to send message. Tap to retry.");

      _updateMessageStatus(localId, 'failed', errorMessage: errorMsg);

      if (context.mounted) {
        showToastMessage(context, errorMsg, type: "error");
      }
    }
  }

  Future<void> loadTemplates() async {
    isLoadingTemplates.value = true;
    try {
      final CampaignRepository campaignRepo = CampaignRepository();
      final list = await campaignRepo.fetchTemplates();
      templatesList.assignAll(list);
    } catch (e) {
      pr("Error loading templates: $e");
    } finally {
      isLoadingTemplates.value = false;
    }
  }

  Future<bool> sendTemplateMessage(
      BuildContext context, String templateUid) async {
    if (userId == null || userId!.isEmpty) {
      return false;
    }
    isLoading.value = true;
    try {
      await _chatRepository.sendTemplateMessage(
        context: context,
        contactUid: userId!,
        templateUid: templateUid,
      );
      _insertTemplateWaitingNotice();
      // Wait for a second and refresh
      await Future.delayed(const Duration(seconds: 1));
      await getUserChatSend();
      return true;
    } catch (e) {
      pr("Error sending template message: $e");
      final errorMsg = _parseErrorMessage(e, fallback: "Failed to send template message.");
      if (context.mounted) {
        showToastMessage(context, errorMsg, type: "error");
      }
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void _insertTemplateWaitingNotice() {
    final now = DateTime.now();
    final notice = ChatMessage(
      uid: 'local-template-waiting-${now.microsecondsSinceEpoch}',
      wamid: '',
      repliedToMessageUid: '',
      content: templateWaitingNoticeText,
      isIncoming: false,
      isSystem: true,
      status: 'sent',
      messagedAt: now.toIso8601String(),
      formattedMessagedAt: DateFormat('h:mm a').format(now),
      templateMessage: '',
      whatsAppError: '',
      data: const <String, dynamic>{},
      media: const ChatMedia(),
    );

    holduser.insert(0, notice.toMap());
    messageModels.insert(0, notice);
  }

  void _updateMessageStatus(String localId, String newStatus,
      {String? errorMessage}) {
    final index = holduser.indexWhere((m) => m['uid'] == localId);
    if (index != -1) {
      final updated = Map<String, dynamic>.from(holduser[index]);
      updated['status'] = newStatus;
      if (errorMessage != null) {
        updated['whatsAppError'] = errorMessage;
      }
      holduser[index] = updated;
    }
  }

  void _replaceLocalOptimisticMessage(String localId, ChatMessage sentMessage) {
    final index = holduser.indexWhere((m) => m['uid'] == localId);
    if (index != -1) {
      final oldMap = holduser[index];
      final newMap = sentMessage.toMap();

      // Server may queue the message and return log_message with empty
      // 'message' field before WhatsApp acknowledges delivery. Keep the
      // user-typed content so the bubble isn't blank in the meantime.
      final oldContent = oldMap['content']?.toString() ?? '';
      final newContent = newMap['content']?.toString() ?? '';
      if (newContent.isEmpty && oldContent.isNotEmpty) {
        newMap['content'] = oldContent;
      }

      // Same for reply metadata.
      final oldRepliedId = oldMap['repliedToMessageUid']?.toString() ?? '';
      final newRepliedId = newMap['repliedToMessageUid']?.toString() ?? '';
      if (newRepliedId.isEmpty && oldRepliedId.isNotEmpty) {
        newMap['repliedToMessageUid'] = oldRepliedId;
        if (newMap['repliedToMessage'] == null &&
            oldMap['repliedToMessage'] != null) {
          newMap['repliedToMessage'] = oldMap['repliedToMessage'];
        }
      }

      holduser[index] = newMap;

      // Remap any other messages that reference the old local uid as their
      // replied-to target. Without this, replies to own optimistic messages
      // orphan once the local uid is replaced by the real server uid — the
      // quoted bubble would then fail to resolve and disappear.
      final newUid = newMap['uid']?.toString() ?? '';
      final newWamid = newMap['wamid']?.toString() ?? '';
      final replacementId = newWamid.isNotEmpty ? newWamid : newUid;
      if (localId.isNotEmpty && replacementId.isNotEmpty && replacementId != localId) {
        for (var i = 0; i < holduser.length; i++) {
          if (i == index) continue;
          final m = holduser[i];
          if (m['repliedToMessageUid']?.toString() == localId) {
            final remapped = Map<String, dynamic>.from(m);
            remapped['repliedToMessageUid'] = replacementId;
            holduser[i] = remapped;
          }
        }
      }

      notifyListeners();
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

  String _parseErrorMessage(dynamic e, {String fallback = "An error occurred"}) {
    if (e == null) return fallback;
    if (e is Map) {
      if (e['message'] != null && e['message'].toString().trim().isNotEmpty) {
        return e['message'].toString();
      }
      final data = e['data'];
      if (data is Map && data['message'] != null && data['message'].toString().trim().isNotEmpty) {
        return data['message'].toString();
      }
      final errors = e['errors'];
      if (errors is Map && errors.isNotEmpty) {
        final firstError = errors.values.first;
        if (firstError is List && firstError.isNotEmpty) {
          return firstError.first.toString();
        }
        return firstError.toString();
      }
    }
    final errorStr = e.toString();
    if (errorStr.trim().isNotEmpty && errorStr != "null") {
      return errorStr;
    }
    return fallback;
  }

  @override
  void dispose() {
    _stopPolling();
    _stopWindowCountdown();
    currentPage = 2;
    super.dispose();
  }
}
