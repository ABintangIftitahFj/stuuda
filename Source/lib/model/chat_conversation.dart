import 'package:stundaa/model/chat_message.dart';

class ChatConversation {
  const ChatConversation({
    required this.messages,
    required this.enableAiBot,
    required this.enableReplyBot,
    required this.assignedLabelIds,
  });

  final List<ChatMessage> messages;
  final bool enableAiBot;
  final bool enableReplyBot;
  final List<int> assignedLabelIds;

  factory ChatConversation.empty() {
    return const ChatConversation(
      messages: <ChatMessage>[],
      enableAiBot: false,
      enableReplyBot: false,
      assignedLabelIds: <int>[],
    );
  }

  factory ChatConversation.fromChatResponse(Map<String, dynamic>? response) {
    final clientModels = response?['client_models'] is Map
        ? response!['client_models'] as Map
        : const <String, dynamic>{};
    final rawLogs = clientModels['whatsappMessageLogs'] is Map
        ? clientModels['whatsappMessageLogs'] as Map
        : const <dynamic, dynamic>{};
    final rawAssignedLabels = clientModels['assignedLabelIds'];

    return ChatConversation(
      messages: rawLogs.entries.map(ChatMessage.fromApiEntry).toList(),
      enableAiBot: clientModels['isAiChatBotEnabled'] == true,
      enableReplyBot: clientModels['isReplyBotEnable'] == true,
      assignedLabelIds: rawAssignedLabels is List
          ? rawAssignedLabels
              .map((label) => int.tryParse(label.toString()))
              .whereType<int>()
              .toList()
          : const <int>[],
    );
  }
}
