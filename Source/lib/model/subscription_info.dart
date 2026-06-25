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

class PlanCharge {
  final String title;
  final bool enabled;
  final double charge;

  const PlanCharge({
    required this.title,
    required this.enabled,
    required this.charge,
  });

  factory PlanCharge.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const PlanCharge(title: '', enabled: false, charge: 0);
    final chargeRaw = map['charge'];
    double parsed = 0;
    if (chargeRaw is num) {
      parsed = chargeRaw.toDouble();
    } else if (chargeRaw != null) {
      parsed = double.tryParse(chargeRaw.toString()) ?? 0;
    }
    final rawEnabled = map['enabled'];
    final enabled = rawEnabled == true || rawEnabled == 1 || rawEnabled == 'on' || rawEnabled == '1';
    return PlanCharge(
      title: map['title']?.toString() ?? '',
      enabled: enabled,
      charge: parsed,
    );
  }

  String get priceLabel {
    if (charge == 0) return 'Free';
    return '\$${charge.toStringAsFixed(0)}';
  }

  String get intervalLabel => title.isNotEmpty ? title : '';
}

class AvailablePlan {
  final String id;
  final String title;
  final bool popular;
  final bool enabled;
  final List<PlanFeature> features;
  final List<PlanCharge> charges;

  const AvailablePlan({
    required this.id,
    required this.title,
    required this.popular,
    required this.enabled,
    required this.features,
    required this.charges,
  });

  factory AvailablePlan.fromMap(String planId, Map<String, dynamic> map) {
    final rawFeatures = map['features'] is Map ? map['features'] as Map : const {};
    final rawCharges = map['charges'] is Map ? map['charges'] as Map : const {};

    final rawEnabled = map['enabled'];
    final enabled = rawEnabled == true || rawEnabled == 1 || rawEnabled == 'on' || rawEnabled == '1';

    return AvailablePlan(
      id: planId,
      title: map['title']?.toString() ?? planId,
      popular: map['popular'] == true || map['popular'] == 1,
      enabled: enabled,
      features: rawFeatures.entries
          .where((entry) => entry.value is Map)
          .map((entry) {
            final featureMap = Map<String, dynamic>.from(entry.value as Map);
            featureMap['key'] = entry.key.toString();
            return PlanFeature.fromMap(featureMap);
          })
          .toList(),
      charges: rawCharges.values
          .whereType<Map>()
          .map((c) => PlanCharge.fromMap(Map<String, dynamic>.from(c)))
          .toList(),
    );
  }

  PlanCharge? get monthlyCharge => charges.where((c) => c.title.toLowerCase() == 'monthly').firstOrNull;
  PlanCharge? get yearlyCharge => charges.where((c) => c.title.toLowerCase() == 'yearly').firstOrNull;
  PlanCharge get bestCharge => yearlyCharge ?? monthlyCharge ?? (charges.isNotEmpty ? charges.first : const PlanCharge(title: '', enabled: false, charge: 0));
}

extension FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
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
