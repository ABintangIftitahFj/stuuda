class Campaign {
  final String uid;
  final String title;
  final String status;
  final String? scheduledAt;
  final String? expireAt;
  final int totalContacts;
  final int totalSent;
  final int totalDelivered;
  final int totalRead;
  final int totalFailed;

  const Campaign({
    required this.uid,
    required this.title,
    required this.status,
    this.scheduledAt,
    this.expireAt,
    required this.totalContacts,
    required this.totalSent,
    required this.totalDelivered,
    required this.totalRead,
    required this.totalFailed,
  });

  factory Campaign.fromMap(Map<String, dynamic> map) {
    return Campaign(
      uid: map['_uid']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      status: map['status']?.toString() ?? '',
      scheduledAt: map['scheduled_at']?.toString(),
      expireAt: map['expire_at']?.toString() ?? map['expireAt']?.toString(),
      totalContacts: (map['total_contacts'] as num?)?.toInt()
          ?? (map['totalContacts'] as num?)?.toInt()
          ?? 0,
      totalSent: (map['totalSent'] as num?)?.toInt() ?? 0,
      totalDelivered: (map['totalDelivered'] as num?)?.toInt() ?? 0,
      totalRead: (map['totalRead'] as num?)?.toInt() ?? 0,
      totalFailed: (map['totalFailed'] as num?)?.toInt() ?? 0,
    );
  }

  bool get isPending => status == 'pending';
  bool get isRunning => status == 'running';
  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';
}

class CampaignStats {
  final String uid;
  final String title;
  final String statusText;
  final String campaignStatus;
  final int totalSent;
  final int totalDelivered;
  final int totalRead;
  final int totalFailed;
  final int inQueueCount;
  final String? totalSentInPercent;
  final String? totalDeliveredInPercent;
  final String? totalReadInPercent;
  final String? totalFailedInPercent;
  final String? timeTook;

  const CampaignStats({
    required this.uid,
    required this.title,
    required this.statusText,
    required this.campaignStatus,
    required this.totalSent,
    required this.totalDelivered,
    required this.totalRead,
    required this.totalFailed,
    required this.inQueueCount,
    this.totalSentInPercent,
    this.totalDeliveredInPercent,
    this.totalReadInPercent,
    this.totalFailedInPercent,
    this.timeTook,
  });

  factory CampaignStats.fromMap(Map<String, dynamic> map, {String? uid, String? title}) {
    final campaignMap = map['campaign'] as Map<String, dynamic>?;
    return CampaignStats(
      uid: uid
          ?? map['_uid']?.toString()
          ?? campaignMap?['_uid']?.toString()
          ?? '',
      title: title
          ?? map['title']?.toString()
          ?? campaignMap?['title']?.toString()
          ?? '',
      statusText: map['statusText']?.toString() ?? '',
      campaignStatus: map['campaignStatus']?.toString() ?? '',
      totalSent: (map['totalSent'] as num?)?.toInt() ?? 0,
      totalDelivered: (map['totalDelivered'] as num?)?.toInt() ?? 0,
      totalRead: (map['totalRead'] as num?)?.toInt() ?? 0,
      totalFailed: (map['totalFailed'] as num?)?.toInt() ?? 0,
      inQueueCount: (map['inQueueCount'] as num?)?.toInt()
          ?? (map['inQueuedCount'] as num?)?.toInt()
          ?? 0,
      totalSentInPercent: map['totalSentInPercent']?.toString(),
      totalDeliveredInPercent: map['totalDeliveredInPercent']?.toString(),
      totalReadInPercent: map['totalReadInPercent']?.toString(),
      totalFailedInPercent: map['totalFailedInPercent']?.toString(),
      timeTook: map['timeTookFromScheduledAtFormatted']?.toString(),
    );
  }
}
