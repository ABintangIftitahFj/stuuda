class PlanFeature {
  final String key;
  final String description;
  final int limit;

  const PlanFeature({
    required this.key,
    required this.description,
    required this.limit,
  });

  factory PlanFeature.fromMap(Map<String, dynamic> map) {
    final rawLimit = map['limit'];
    int parsedLimit = 0;
    if (rawLimit is num) {
      parsedLimit = rawLimit.toInt();
    } else if (rawLimit != null) {
      parsedLimit = int.tryParse(rawLimit.toString()) ?? 0;
    }
    return PlanFeature(
      key: map['key']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      limit: parsedLimit,
    );
  }

  String get limitLabel {
    if (limit == -1) return 'Unlimited';
    if (limit == 0) return 'Not included';
    if (limit == 1 && (key == 'ai_chat_bot' || key == 'api_access')) return 'Enabled';
    return limit.toString();
  }

  bool get isIncluded => limit != 0;
}

class SubscriptionInfo {
  final String planTitle;
  final String planType;
  final bool hasActivePlan;
  final String? endsAt;
  final List<PlanFeature> features;

  const SubscriptionInfo({
    required this.planTitle,
    required this.planType,
    required this.hasActivePlan,
    this.endsAt,
    required this.features,
  });

  static SubscriptionInfo get defaultFree {
    return const SubscriptionInfo(
      planTitle: 'Free Plan',
      planType: 'free',
      hasActivePlan: false,
      features: [
        PlanFeature(key: 'contacts', description: 'Contacts', limit: 5),
        PlanFeature(key: 'campaigns', description: 'Campaigns (Per Month)', limit: 10),
        PlanFeature(key: 'bot_replies', description: 'Bot Replies', limit: 10),
        PlanFeature(key: 'bot_flows', description: 'Bot Flows', limit: 5),
        PlanFeature(key: 'contact_custom_fields', description: 'Contact Custom Fields', limit: 2),
        PlanFeature(key: 'system_users', description: 'Team Members/Agents', limit: 0),
        PlanFeature(key: 'ai_chat_bot', description: 'AI Chat Bot', limit: 1),
        PlanFeature(key: 'api_access', description: 'API and Webhook Access', limit: 1),
      ],
    );
  }

  bool get isFree => planType == 'free';

  factory SubscriptionInfo.fromResponse(Map<String, dynamic>? response) {
    final data = response?['data'] is Map
        ? Map<String, dynamic>.from(response!['data'] as Map)
        : const <String, dynamic>{};
    final rawFeatures = data['features'] is List ? data['features'] as List : [];
    return SubscriptionInfo(
      planTitle: data['plan_title']?.toString() ?? 'Free',
      planType: data['plan_type']?.toString() ?? 'free',
      hasActivePlan: data['has_active_plan'] == true,
      endsAt: data['ends_at']?.toString(),
      features: rawFeatures
          .whereType<Map>()
          .map((f) => PlanFeature.fromMap(Map<String, dynamic>.from(f)))
          .toList(),
    );
  }
}
