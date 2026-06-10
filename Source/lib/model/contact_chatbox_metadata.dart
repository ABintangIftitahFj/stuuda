import 'package:stundaa/model/agent_user.dart';
import 'package:stundaa/model/contact_label.dart';

class ContactChatboxMetadata {
  const ContactChatboxMetadata({
    required this.agentUsers,
    required this.labels,
  });

  final List<AgentUser> agentUsers;
  final List<ContactLabel> labels;

  factory ContactChatboxMetadata.fromResponse(Map<String, dynamic>? response) {
    final data = response?['data'] is Map
        ? Map<String, dynamic>.from(response!['data'] as Map)
        : const <String, dynamic>{};
    final rawUsers = data['vendorMessagingUsers'] is List
        ? List<Map<String, dynamic>>.from(
            (data['vendorMessagingUsers'] as List).whereType<Map>(),
          )
        : const <Map<String, dynamic>>[];
    final rawLabels = data['listOfAllLabels'] is List
        ? List<Map<String, dynamic>>.from(
            (data['listOfAllLabels'] as List).whereType<Map>(),
          )
        : const <Map<String, dynamic>>[];

    return ContactChatboxMetadata(
      agentUsers: rawUsers.map(AgentUser.fromMap).toList(),
      labels: rawLabels.map(ContactLabel.fromMap).toList(),
    );
  }
}
