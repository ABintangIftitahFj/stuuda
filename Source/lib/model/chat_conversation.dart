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
    final clientModels = data?['client_models'] is Map
        ? data!['client_models'] as Map
        : const <String, dynamic>{};
    final rawLogs = clientModels['whatsappMessageLogs'] is Map
        ? clientModels['whatsappMessageLogs'] as Map
        : const <dynamic, dynamic>{};
    final rawAssignedLabels = clientModels['assignedLabelIds'];

    return ChatConversation(
      messages: rawLogs.entries.map(ChatMessage.fromApiEntry).toList(),
      enableAiBot: clientModels['isAiChatBotEnabled'] == true,
      enableReplyBot: clientModels['isReplyBotEnable'] == true,
      isDirectMessageDeliveryWindowOpened: data?['isDirectMessageDeliveryWindowOpened'] == true,
      directMessageDeliveryWindowOpenedTillMessage: data?['directMessageDeliveryWindowOpenedTillMessage']?.toString() ?? '',
      windowExpiresAt: data?['directMessageDeliveryWindowExpiresAt'] != null
          ? DateTime.tryParse(data!['directMessageDeliveryWindowExpiresAt'].toString())
          : null,
      assignedLabelIds: rawAssignedLabels is List
          ? rawAssignedLabels
              .map((label) => int.tryParse(label.toString()))
              .whereType<int>()
              .toList()
          : const <int>[],
    );
  }
}
