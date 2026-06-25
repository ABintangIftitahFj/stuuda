import 'package:intl/intl.dart';

class ChatMessage {
  /// Format chat timestamp as Indonesia time (WIB, UTC+7).
  ///
  /// Prefers the server-provided [fallback] (already formatted in the
  /// vendor's timezone) when present, so we don't double-shift a naive
  /// Jakarta timestamp and end up 7 hours off. Falls back to parsing
  /// [messagedAtRaw] as UTC and shifting to WIB only when the server did
  /// not supply a formatted value.
  static const Duration _wibOffset = Duration(hours: 7);
  static String _formatLocalTime(String? messagedAtRaw, String fallback) {
    if (fallback.trim().isNotEmpty) return fallback;
    if (messagedAtRaw == null || messagedAtRaw.isEmpty) return fallback;
    try {
      final normalized = messagedAtRaw.trim().replaceFirst(' ', 'T');
      final dt = DateTime.parse(normalized);
      final utcDt = dt.isUtc
          ? dt
          : DateTime.utc(
              dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second);
      final wib = utcDt.add(_wibOffset);
      return DateFormat("h:mm a").format(wib);
    } catch (_) {
      return fallback;
    }
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final text = value?.toString().trim().toLowerCase();
    return text == 'true' || text == '1' || text == 'yes';
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
    this.repliedToMessage,
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
  final ChatMessage? repliedToMessage;

  factory ChatMessage.fromApiEntry(MapEntry<dynamic, dynamic> entry) {
    final value = entry.value is Map
        ? Map<String, dynamic>.from(entry.value)
        : <String, dynamic>{};
    final rawData = value['__data'] ?? value['data'];
    final data = rawData is Map
        ? Map<String, dynamic>.from(rawData)
        : <String, dynamic>{};
    final rawMedia = data['media_values'] ?? data['mediaValues'] ?? data['media'];
    final mediaMap = rawMedia is Map
        ? Map<String, dynamic>.from(rawMedia)
        : <String, dynamic>{};

    final rawReplied = value['replied_to_message'] ?? value['repliedToMessage'];
    ChatMessage? repliedToMessage;
    if (rawReplied is Map) {
      repliedToMessage = ChatMessage.fromApiEntry(
        MapEntry(
          rawReplied['_uid'] ?? rawReplied['uid'] ?? '',
          Map<String, dynamic>.from(rawReplied),
        ),
      );
    }

    return ChatMessage(
      uid: (value['_uid'] ?? value['uid'] ?? entry.key).toString(),
      wamid: (value['wamid'] ?? value['wa_mid'] ?? '').toString(),
      repliedToMessageUid: (value['replied_to_whatsapp_message_logs__uid'] ??
              value['replied_to_whatsapp_message_logs_uid'] ??
              value['repliedToWhatsappMessageLogsUid'] ??
              value['replied_to_uid'] ??
              value['repliedToUid'] ??
              value['replied_to_message_uid'] ??
              value['repliedToMessageUid'] ??
              '')
          .toString(),
      content: (value['message'] ?? value['content'] ?? '').toString(),
      isIncoming: _parseBool(value['is_incoming_message'] ??
          value['isIncomingMessage'] ??
          value['is_incoming'] ??
          value['isIncoming']),
      isSystem: _parseBool(value['is_system_message'] ??
          value['isSystemMessage'] ??
          value['is_system'] ??
          value['isSystem']),
      status: (value['status'] ?? 'unknown').toString(),
      messagedAt: (value['messaged_at'] ?? value['messagedAt'] ?? '').toString(),
      formattedMessagedAt: _formatLocalTime(
        (value['messaged_at'] ?? value['messagedAt'])?.toString(),
        (value['formatted_message_time'] ??
                value['formattedMessageTime'] ??
                value['formatted_message_ago_time'] ??
                value['formattedMessageAgoTime'] ??
                '')
            .toString(),
      ),
      templateMessage: (value['template_message'] ?? value['templateMessage'] ?? '').toString(),
      whatsAppError: (value['whatsapp_message_error'] ?? value['whatsAppMessageError'] ?? '').toString(),
      data: data,
      media: ChatMedia.fromMap(mediaMap),
      repliedToMessage: repliedToMessage,
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
    final nowUtc = now.toUtc();
    final wib = nowUtc.add(_wibOffset);
    return ChatMessage(
      uid: 'local-${now.microsecondsSinceEpoch}',
      wamid: '',
      repliedToMessageUid: repliedToMessageUid,
      content: message,
      isIncoming: false,
      isSystem: false,
      status: 'pending',
      messagedAt: nowUtc.toIso8601String(),
      formattedMessagedAt: DateFormat("h:mm a").format(wib),
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
      'repliedToMessage': repliedToMessage?.toMap(),
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
