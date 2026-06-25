import 'package:stundaa/model/chat_message.dart';

class ChatConversation {
  const ChatConversation({
    required this.messages,
    required this.enableAiBot,
    required this.enableReplyBot,
    required this.assignedLabelIds,
    this.isDirectMessageDeliveryWindowOpened = false,
    this.directMessageDeliveryWindowOpenedTillMessage = '',
    this.windowExpiresAt,
  });

  final List<ChatMessage> messages;
  final bool enableAiBot;
  final bool enableReplyBot;
  final List<int> assignedLabelIds;
  final bool isDirectMessageDeliveryWindowOpened;
  final String directMessageDeliveryWindowOpenedTillMessage;
  final DateTime? windowExpiresAt;

  factory ChatConversation.empty() {
    return const ChatConversation(
      messages: <ChatMessage>[],
      enableAiBot: false,
      enableReplyBot: false,
      assignedLabelIds: <int>[],
      isDirectMessageDeliveryWindowOpened: false,
      directMessageDeliveryWindowOpenedTillMessage: '',
      windowExpiresAt: null,
    );
  }

  factory ChatConversation.fromChatResponse(Map<String, dynamic>? response) {
    final data = response?['data'] is Map ? response!['data'] as Map : response;
    final clientModels = response?['client_models'] is Map
        ? response!['client_models'] as Map
        : (data?['client_models'] is Map
            ? data!['client_models'] as Map
            : const <String, dynamic>{});
    final rawLogs = clientModels['whatsappMessageLogs'] is Map
        ? clientModels['whatsappMessageLogs'] as Map
        : const <dynamic, dynamic>{};
    final rawAssignedLabels = clientModels['assignedLabelIds'];

    return ChatConversation(
      messages: rawLogs.entries.map(ChatMessage.fromApiEntry).toList(),
      enableAiBot: _parseBool(clientModels['isAiChatBotEnabled']),
      enableReplyBot: _parseBool(clientModels['isReplyBotEnable']),
      isDirectMessageDeliveryWindowOpened:
          _parseBool(data?['isDirectMessageDeliveryWindowOpened']),
      directMessageDeliveryWindowOpenedTillMessage:
          data?['directMessageDeliveryWindowOpenedTillMessage']?.toString() ??
              '',
      windowExpiresAt: _parseUtcDate(
          data?['directMessageDeliveryWindowExpiresAt']?.toString()),
      assignedLabelIds: rawAssignedLabels is List
          ? rawAssignedLabels
              .map((label) => int.tryParse(label.toString()))
              .whereType<int>()
              .toList()
          : const <int>[],
    );
  }

  // Server emits naive "YYYY-MM-DD HH:mm:ss" already in UTC. DateTime.parse
  // treats no-offset as LOCAL, which made the countdown 7h off in WIB. Treat
  // unspecified-zone timestamps as UTC, then convert to device local.
  static DateTime? _parseUtcDate(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final normalized = raw.trim().replaceFirst(' ', 'T');
      final dt = DateTime.parse(normalized);
      final utc = dt.isUtc
          ? dt
          : DateTime.utc(
              dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second);
      return utc.toLocal();
    } catch (_) {
      return null;
    }
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final text = value?.toString().trim().toLowerCase();
    return text == 'true' || text == '1' || text == 'yes';
  }
}
