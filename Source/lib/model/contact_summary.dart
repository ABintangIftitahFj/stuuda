import 'package:intl/intl.dart';

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
    
    // Safely parse name fields to avoid literal "null" strings
    final rawFullName = source['full_name'] ?? source['name'] ?? source['wa_id'];
    final fullName = (rawFullName == null || rawFullName.toString().trim().toLowerCase() == 'null')
        ? ''
        : rawFullName.toString().trim();

    final rawFirstName = source['first_name'];
    final firstName = (rawFirstName == null || rawFirstName.toString().trim().toLowerCase() == 'null')
        ? ''
        : rawFirstName.toString().trim();

    final rawLastName = source['last_name'];
    final lastName = (rawLastName == null || rawLastName.toString().trim().toLowerCase() == 'null')
        ? ''
        : rawLastName.toString().trim();

    final rawWaId = source['wa_id'];
    final waId = (rawWaId == null || rawWaId.toString().trim().toLowerCase() == 'null')
        ? ''
        : rawWaId.toString().trim();

    final initials = _buildInitials(
      explicitInitials: source['name_initials']?.toString(),
      fullName: fullName.isEmpty ? (waId.isEmpty ? uid : waId) : fullName,
      waId: waId.isEmpty ? uid : waId,
    );
    final unreadMessagesCount =
        _parseInt(source['unread_messages_count'] ?? source['unreadCount']);
    final lastMessageRaw = source['last_message'] ?? source['lastMessage'];
    final lastMessage = lastMessageRaw is Map
        ? Map<String, dynamic>.from(lastMessageRaw)
        : const <String, dynamic>{};
    final lastMessageTime = _formatLocalTime(
        (lastMessage['messaged_at'] ?? lastMessage['messagedAt'] ?? lastMessage['created_at'])?.toString(),
        (lastMessage['formatted_message_time'] ?? lastMessage['formattedMessageTime'] ?? '').toString().trim());

    var lastMessageText =
        (lastMessage['message'] ?? lastMessage['message_body'] ?? lastMessage['text'] ?? '').toString().trim();
    
    final isIncoming = lastMessage['is_incoming_message'] == 1 || 
                       lastMessage['is_incoming_message'] == true ||
                       lastMessage['is_incoming'] == true;
    if (lastMessageText.isNotEmpty && !isIncoming) {
      lastMessageText = "Me: $lastMessageText";
    }

    final resolvedFullName = fullName.isEmpty ? (waId.isEmpty ? uid : waId) : fullName;

    return ContactSummary(
      uid: uid.isEmpty ? fallbackUid : uid,
      rawKey: ((rawKey ?? (uid.isEmpty ? fallbackUid : uid))).toString(),
      fullName: resolvedFullName,
      firstName: firstName.isEmpty ? _firstWord(resolvedFullName) : firstName,
      lastName: lastName,
      waId: waId.isEmpty ? uid : waId,
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

  bool get isServiceWindowActive {
    final lastIncoming = raw['last_incoming_message'];
    
    // 1. Try parsing from last_incoming_message
    if (lastIncoming is Map) {
      final messagedAtRaw = lastIncoming['messaged_at']?.toString();
      if (messagedAtRaw != null && messagedAtRaw.isNotEmpty) {
        final parsed = _parseDateTime(messagedAtRaw);
        if (parsed != null) {
          final difference = DateTime.now().toUtc().difference(parsed);
          return difference.inHours < 24 && !difference.isNegative;
        }
      }
    }

    // 2. Try parsing from last_message if it's incoming
    final lastMessage = raw['last_message'];
    if (lastMessage is Map) {
      final isIncoming = lastMessage['is_incoming_message'] == 1 || 
                         lastMessage['is_incoming_message'] == true ||
                         lastMessage['is_incoming'] == true;
      if (isIncoming) {
        final messagedAtRaw = lastMessage['messaged_at']?.toString();
        if (messagedAtRaw != null && messagedAtRaw.isNotEmpty) {
          final parsed = _parseDateTime(messagedAtRaw);
          if (parsed != null) {
            final difference = DateTime.now().toUtc().difference(parsed);
            return difference.inHours < 24 && !difference.isNegative;
          }
        }
      }
    }

    // 3. Fallback to string matching (making it locale and 24h clock independent)
    if (lastMessageTime.isEmpty) return false;
    final time = lastMessageTime.toLowerCase().trim();

    // If it represents "just now" (English/Indonesian/Italian)
    if (time.contains('just now') || 
        time.contains('baru saja') || 
        time.contains('adesso') || 
        time.contains('proprio')) {
      return true;
    }

    // If it represents minutes or hours ago
    if (time.contains('min') || 
        time.contains('hour') || 
        time.contains('jam') || 
        time.contains('ora') || 
        time.contains('ore')) {
      return true;
    }

    // If it's a 12-hour or 24-hour time format (e.g. "14:30", "10:30 am", "10:30 pm")
    // and doesn't contain a date (which typically has "-", "/", or month names)
    final hasTimePattern = RegExp(r'\d{1,2}:\d{2}').hasMatch(time);
    final hasDatePattern = RegExp(r'[-/]|[a-z]{3,}').hasMatch(time); // Has dash, slash, or month name (like "jan", "feb", "kemarin", "yesterday")
    
    // We also exclude words like "yesterday", "kemarin", "ieri"
    final isPastDay = time.contains('yesterday') || 
                      time.contains('kemarin') || 
                      time.contains('ieri') || 
                      time.contains('day') || 
                      time.contains('hari') || 
                      time.contains('giorno');

    if (hasTimePattern && !hasDatePattern && !isPastDay) {
      return true;
    }

    return false;
  }

  DateTime? _parseDateTime(String raw) {
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

  static String _formatLocalTime(String? messagedAtRaw, String fallback) {
    if (messagedAtRaw == null || messagedAtRaw.isEmpty) return fallback;
    try {
      final normalized = messagedAtRaw.trim().replaceFirst(' ', 'T');
      final dt = DateTime.parse(normalized);
      final utcDt = dt.isUtc
          ? dt
          : DateTime.utc(
              dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second);
      final wib = utcDt.add(const Duration(hours: 7));
      return DateFormat("h:mm a").format(wib);
    } catch (_) {
      return fallback;
    }
  }
}
