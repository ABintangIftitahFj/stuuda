import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stundaa/model/subscription_info.dart';
import 'package:stundaa/screens/my_plan.dart';
import 'package:stundaa/repositories/subscription_repository.dart';

class MockSubscriptionRepository implements SubscriptionRepository {
  @override
  Future<SubscriptionInfo?> fetchSubscriptionInfo() async {
    return SubscriptionInfo.fromResponse({
      "reaction": 1,
      "reaction_code": 1,
      "data": {
        "plan_title": "Ultimate",
        "plan_type": "paid",
        "has_active_plan": true,
        "ends_at": "2233-06-12T00:00:00.000000Z",
        "features": [
          {"key": "contacts", "description": "Contacts", "limit": -1},
          {"key": "campaigns", "description": "Campaigns", "limit": -1},
          {"key": "bot_replies", "description": "Bot Replies", "limit": -1},
          {"key": "bot_flows", "description": "Bot Flows", "limit": -1},
          {"key": "contact_custom_fields", "description": "Contact Custom Fields", "limit": -1},
          {"key": "system_users", "description": "Team Members/Agents", "limit": -1},
          {"key": "ai_chat_bot", "description": "AI Chat Bot", "limit": 1},
          {"key": "api_access", "description": "API and Webhook Access", "limit": 1},
        ],
      },
    });
  }

  @override
  Future<List<AvailablePlan>> fetchSubscriptionPlans() async {
    return [
      AvailablePlan.fromMap('plan_1', {
        "id": "plan_1",
        "enabled": "on",
        "popular": true,
        "title": "Standard",
        "trial_days": 0,
        "features": {
          "contacts": {"description": "Contacts", "limit": "5"},
          "campaigns": {"limit_duration": "monthly", "limit_duration_title": "Per Month", "description": "Campaigns", "limit": "10"},
        },
        "charges": {
          "monthly": {"title": "monthly", "enabled": 0, "price_id": "", "charge": 10},
          "yearly": {"title": "yearly", "enabled": "on", "price_id": "", "charge": 100},
        },
      }),
      AvailablePlan.fromMap('plan_2', {
        "id": "plan_2",
        "enabled": "on",
        "popular": false,
        "title": "Premium",
        "trial_days": 0,
        "features": {
          "contacts": {"description": "Contacts", "limit": "15"},
        },
        "charges": {
          "monthly": {"title": "monthly", "enabled": 0, "price_id": "", "charge": 20},
          "yearly": {"title": "yearly", "enabled": "on", "price_id": "", "charge": 199},
        },
      }),
    ];
  }
}

class MockEmptySubscriptionRepository implements SubscriptionRepository {
  @override
  Future<SubscriptionInfo?> fetchSubscriptionInfo() async => null;

  @override
  Future<List<AvailablePlan>> fetchSubscriptionPlans() async => [];
}

void main() {
  testWidgets('renders active subscription with plan cards', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(home: MyPlanScreen(repository: MockSubscriptionRepository())),
    );

    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('My Plan'), findsOneWidget);
    expect(find.text('Ultimate'), findsOneWidget);
    expect(find.text('ACTIVE'), findsOneWidget);
    expect(find.text('Standard'), findsOneWidget);
    expect(find.text('Popular'), findsOneWidget);
    expect(find.text('Premium'), findsOneWidget);
    expect(find.text('Plan Features'), findsOneWidget);
    expect(find.text('Available Plans'), findsOneWidget);
  });

  testWidgets('shows free fallback with offline banner', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(home: MyPlanScreen(repository: MockEmptySubscriptionRepository())),
    );

    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('My Plan'), findsOneWidget);
    expect(find.text('Free Plan'), findsOneWidget);
    expect(find.text('FREE'), findsOneWidget);
    expect(find.textContaining('Unable to reach server'), findsOneWidget);
    expect(find.text('Upgrade Plan'), findsOneWidget);
  });
}
