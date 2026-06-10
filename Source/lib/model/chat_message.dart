import 'package:intl/intl.dart';

class ChatMessage {
  /// Parse [messagedAtRaw] as UTC and format in device local time.
  /// Falls back to [fallback] on parse failure.
  static String _formatLocalTime(String? messagedAtRaw, String fallback) {
    if (messagedAtRaw == null || messagedAtRaw.isEmpty) return fallback;
    try {
      // Normalize "YYYY-MM-DD HH:mm:ss" → ISO-8601
      final normalized = messagedAtRaw.trim().replaceFirst(' ', 'T');
      final dt = DateTime.parse(normalized);
      // Server sends UTC; if no timezone info in string, treat as UTC
      final utcDt = dt.isUtc
          ? dt
          : DateTime.utc(dt.year, dt.month, dt.day, dt.hour, dt.minute,
              dt.second);
      return DateFormat("h:mm a").format(utcDt.toLocal());
    } catch (_) {
      return fallback;
    }
  }
  const ChatMessage({
    required this.uid,
    required this.wamid,
    required this.repliedToMessageUid,
    required this.content,
    required this.isIncoming,
    required this.isSystem,
    required this.status,
    required this.messagedAt,
    required this.formattedMessagedAt,
    required this.templateMessage,
    required this.whatsAppError,
    required this.data,
    required this.media,
    this.isFile = false,
    this.filename,
    this.filetype,
  });

  final String uid;
  final String wamid;
  final String repliedToMessageUid;
  final String content;
  final bool isIncoming;
  final bool isSystem;
  final String status;
  final String messagedAt;
  final String formattedMessagedAt;
  final String templateMessage;
  final String whatsAppError;
  final Map<String, dynamic> data;
  final ChatMedia media;
  final bool isFile;
  final dynamic filename;
  final dynamic filetype;

  factory ChatMessage.fromApiEntry(MapEntry<dynamic, dynamic> entry) {
    final value = entry.value is Map
        ? Map<String, dynamic>.from(entry.value)
        : <String, dynamic>{};
    final rawData = value['__data'];
    final data = rawData is Map
        ? Map<String, dynamic>.from(rawData)
        : <String, dynamic>{};
    final rawMedia = data['media_values'];
    final mediaMap = rawMedia is Map
        ? Map<String, dynamic>.from(rawMedia)
        : <String, dynamic>{};

    return ChatMessage(
      uid: (value['_uid'] ?? entry.key).toString(),
      wamid: value['wamid']?.toString() ?? '',
      repliedToMessageUid: (value['replied_to_whatsapp_message_logs__uid'] ??
              value['replied_to_uid'] ??
              value['replied_to_message_uid'] ??
              '')
          .toString(),
      content: value['message']?.toString() ?? '',
      isIncoming: value['is_incoming_message'] == 1,
      isSystem: value['is_system_message'] == 1,
      status: value['status']?.toString() ?? 'unknown',
      messagedAt: value['messaged_at']?.toString() ?? '',
      formattedMessagedAt: _formatLocalTime(
        value['messaged_at']?.toString(),
        value['formatted_message_time']?.toString() ?? '',
      ),
      templateMessage: value['template_message']?.toString() ?? '',
      whatsAppError: value['whatsapp_message_error']?.toString() ?? '',
      data: data,
      media: ChatMedia.fromMap(mediaMap),
    );
  }

  factory ChatMessage.localOutgoing(
    String message, {
    String repliedToMessageUid = '',
    bool isFile = false,
    dynamic filename,
    dynamic filetype,
  }) {
    final now = DateTime.now();
    return ChatMessage(
      uid: 'local-${now.microsecondsSinceEpoch}',
      wamid: '',
      repliedToMessageUid: repliedToMessageUid,
      content: message,
      isIncoming: false,
      isSystem: false,
      status: 'pending',
      messagedAt: now.toIso8601String(),
      formattedMessagedAt: DateFormat("h:mm a").format(now),
      templateMessage: '',
      whatsAppError: '',
      data: const <String, dynamic>{},
      media: const ChatMedia(),
      isFile: isFile,
      filename: filename,
      filetype: filetype,
    );
  }

  factory ChatMessage.dummy({
    required String uid,
    required String wamid,
    required String repliedToMessageUid,
    required String content,
    required bool isIncoming,
    required String status,
    required String messagedAt,
    required String formattedMessagedAt,
  }) {
    return ChatMessage(
      uid: uid,
      wamid: wamid,
      repliedToMessageUid: repliedToMessageUid,
      content: content,
      isIncoming: isIncoming,
      isSystem: false,
      status: status,
      messagedAt: messagedAt,
      formattedMessagedAt: formattedMessagedAt,
      templateMessage: '',
      whatsAppError: '',
      data: const <String, dynamic>{},
      media: const ChatMedia(),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'wamid': wamid,
      'repliedToMessageUid': repliedToMessageUid,
      'content': content,
      'isIncoming': isIncoming,
      'isSystem': isSystem,
      'status': status,
      'messagedAt': messagedAt,
      'formattedMessagedAt': formattedMessagedAt,
      'templateMessage': templateMessage,
      'whatsAppError': whatsAppError,
      '__data': data,
      'media': media.toMap(),
      'isFile': isFile,
      'filename': filename,
      'filetype': filetype,
    };
  }
}

class ChatMedia {
  const ChatMedia({
    this.link = '',
    this.type = '',
    this.caption = '',
    this.fileName = '',
    this.mimeType = '',
    this.originalFileName = '',
  });

  final String link;
  final String type;
  final String caption;
  final String fileName;
  final String mimeType;
  final String originalFileName;

  factory ChatMedia.fromMap(Map<String, dynamic> map) {
    return ChatMedia(
      link: map['link']?.toString() ?? '',
      type: map['type']?.toString() ?? '',
      caption: map['caption']?.toString() ?? '',
      fileName:
          map['file_name']?.toString() ?? map['fileName']?.toString() ?? '',
      mimeType:
          map['mime_type']?.toString() ?? map['mimeType']?.toString() ?? '',
      originalFileName: map['original_filename']?.toString() ??
          map['originalFileName']?.toString() ??
          '',
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'link': link,
      'type': type,
      'caption': caption,
      'fileName': fileName,
      'mimeType': mimeType,
      'originalFileName': originalFileName,
    };
  }
}
