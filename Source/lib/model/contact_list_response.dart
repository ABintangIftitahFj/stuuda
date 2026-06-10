class ContactListResponse {
  const ContactListResponse({
    required this.contacts,
    required this.unreadMessagesCount,
  });

  final List<MapEntry<String, dynamic>> contacts;
  final int unreadMessagesCount;

  factory ContactListResponse.fromResponse(Map<String, dynamic>? response) {
    final clientModels = response?['client_models'] is Map
        ? response!['client_models'] as Map
        : const <String, dynamic>{};
    final rawContacts = clientModels['contacts'] is Map
        ? clientModels['contacts'] as Map
        : const <dynamic, dynamic>{};

    return ContactListResponse(
      contacts: rawContacts.entries
          .map(
            (entry) => MapEntry<String, dynamic>(
              entry.key.toString(),
              entry.value is Map
                  ? Map<String, dynamic>.from(entry.value as Map)
                  : <String, dynamic>{},
            ),
          )
          .toList(),
      unreadMessagesCount: _parseInt(clientModels['unreadMessagesCount']),
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
