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
