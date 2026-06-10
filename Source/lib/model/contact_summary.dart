class ContactSummary {
  const ContactSummary({
    required this.uid,
    required this.rawKey,
    required this.fullName,
    required this.firstName,
    required this.lastName,
    required this.waId,
    required this.nameInitials,
    required this.unreadMessagesCount,
    required this.lastMessageTime,
    required this.lastMessageText,
    required this.raw,
  });

  final String uid;
  final String rawKey;
  final String fullName;
  final String firstName;
  final String lastName;
  final String waId;
  final String nameInitials;
  final int unreadMessagesCount;
  final String lastMessageTime;
  final String lastMessageText;
  final Map<String, dynamic> raw;

  factory ContactSummary.fromEntry(MapEntry<String, dynamic> entry) {
    final map = entry.value is Map<String, dynamic>
        ? Map<String, dynamic>.from(entry.value as Map<String, dynamic>)
        : <String, dynamic>{};
    return ContactSummary.fromMap(
      map,
      fallbackUid: entry.key.toString(),
      rawKey: entry.key.toString(),
    );
  }

  factory ContactSummary.fromMap(
    Map<String, dynamic> source, {
    String fallbackUid = '',
    String? rawKey,
  }) {
    final uid = (source['_uid'] ?? source['contact_uid'] ?? fallbackUid)
        .toString()
        .trim();
    final fullName = (source['full_name'] ?? source['name'] ?? source['wa_id'])
        .toString()
        .trim();
    final firstName = (source['first_name'] ?? '').toString().trim();
    final lastName = (source['last_name'] ?? '').toString().trim();
    final waId = (source['wa_id'] ?? '').toString().trim();
    final initials = _buildInitials(
      explicitInitials: source['name_initials']?.toString(),
      fullName: fullName,
      waId: waId,
    );
    final unreadMessagesCount =
        _parseInt(source['unread_messages_count'] ?? source['unreadCount']);
    final lastMessage = source['last_message'] is Map<String, dynamic>
        ? source['last_message'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final lastMessageTime =
        (lastMessage['formatted_message_time'] ?? '').toString().trim();

    final lastMessageText =
        (lastMessage['message'] ?? lastMessage['message_body'] ?? lastMessage['text'] ?? '').toString().trim();

    return ContactSummary(
      uid: uid.isEmpty ? fallbackUid : uid,
      rawKey: ((rawKey ?? (uid.isEmpty ? fallbackUid : uid))).toString(),
      fullName: fullName.isEmpty ? waId : fullName,
      firstName: firstName.isEmpty ? _firstWord(fullName) : firstName,
      lastName: lastName,
      waId: waId,
      nameInitials: initials,
      unreadMessagesCount: unreadMessagesCount,
      lastMessageTime: lastMessageTime,
      lastMessageText: lastMessageText,
      raw: Map<String, dynamic>.from(source),
    );
  }

  factory ContactSummary.forPhoneNumber(String phoneNumber) {
    final normalizedPhone = phoneNumber.trim();
    return ContactSummary(
      uid: normalizedPhone,
      rawKey: normalizedPhone,
      fullName: normalizedPhone,
      firstName: normalizedPhone,
      lastName: '',
      waId: normalizedPhone,
      nameInitials:
          _buildInitials(fullName: normalizedPhone, waId: normalizedPhone),
      unreadMessagesCount: 0,
      lastMessageTime: '',
      lastMessageText: '',
      raw: <String, dynamic>{
        '_uid': normalizedPhone,
        'contact_uid': normalizedPhone,
        'full_name': normalizedPhone,
        'first_name': normalizedPhone,
        'last_name': '',
        'wa_id': normalizedPhone,
        'name_initials':
            _buildInitials(fullName: normalizedPhone, waId: normalizedPhone),
        'last_message': <String, dynamic>{
          'formatted_message_time': '',
        },
      },
    );
  }

  ContactSummary copyWithUid(String newUid) {
    return ContactSummary(
      uid: newUid,
      rawKey: newUid,
      fullName: fullName,
      firstName: firstName,
      lastName: lastName,
      waId: waId,
      nameInitials: nameInitials,
      unreadMessagesCount: unreadMessagesCount,
      lastMessageTime: lastMessageTime,
      lastMessageText: lastMessageText,
      raw: <String, dynamic>{
        ...raw,
        '_uid': newUid,
        'contact_uid': newUid,
      },
    );
  }

  bool matchesQuery(String query) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      return true;
    }

    return fullName.toLowerCase().contains(normalizedQuery) ||
        waId.toLowerCase().contains(normalizedQuery);
  }

  String get displayName => fullName.isEmpty ? waId : fullName;

  Map<String, dynamic> toChatboxPayload() {
    return <String, dynamic>{
      ...raw,
      '_uid': uid,
      'contact_uid': uid,
      'full_name': displayName,
      'first_name': firstName.isEmpty ? _firstWord(displayName) : firstName,
      'last_name': lastName,
      'wa_id': waId,
      'name_initials': nameInitials,
      'unread_messages_count': unreadMessagesCount,
      'last_message': <String, dynamic>{
        ...(raw['last_message'] is Map
            ? Map<String, dynamic>.from(raw['last_message'] as Map)
            : const <String, dynamic>{}),
        'formatted_message_time': lastMessageTime,
      },
    };
  }

  MapEntry<String, dynamic> toEntry() {
    final key = rawKey.isEmpty ? uid : rawKey;
    return MapEntry<String, dynamic>(key, toChatboxPayload());
  }

  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String _firstWord(String text) {
    final words =
        text.trim().split(RegExp(r'\s+')).where((word) => word.isNotEmpty);
    return words.isEmpty ? '' : words.first;
  }

  static String _buildInitials({
    String? explicitInitials,
    required String fullName,
    required String waId,
  }) {
    final preset = explicitInitials?.trim() ?? '';
    if (preset.isNotEmpty) {
      return preset.length > 2
          ? preset.substring(0, 2).toUpperCase()
          : preset.toUpperCase();
    }

    final words = fullName
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .take(2)
        .toList();
    if (words.isNotEmpty) {
      return words.map((word) => word[0]).join().toUpperCase();
    }

    final fallback = waId.replaceAll(RegExp(r'[^0-9A-Za-z]'), '');
    if (fallback.isEmpty) {
      return 'U';
    }
    return fallback.substring(0, fallback.length >= 2 ? 2 : 1).toUpperCase();
  }
}
