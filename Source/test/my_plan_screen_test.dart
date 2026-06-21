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
          {"key": "api_access", "description": "API and Webhook Access", "limit": 1}
        ]
      }
    });
  }

  @override
  Future<Map<String, dynamic>?> fetchSubscriptionPlans() async {
    return {
      "plan_1": {
        "id": "plan_1",
        "enabled": "on",
        "popular": true,
        "title": "Standard",
        "trial_days": 0,
        "features": {
          "contacts": {"description": "Contacts", "limit": "5"},
          "campaigns": {"limit_duration": "monthly", "limit_duration_title": "Per Month", "description": "Campaigns", "limit": "10"},
          "bot_replies": {"description": "Bot Replies", "limit": "10"},
          "bot_flows": {"description": "Bot Flows", "limit": "5"},
          "contact_custom_fields": {"description": "Contact Custom Fields", "limit": "5"},
          "system_users": {"description": "Team Members/Agents", "limit": "5"},
          "ai_chat_bot": {"type": "switch", "description": "AI Chat Bot", "limit": "1"},
          "api_access": {"type": "switch", "description": "API and Webhook Access", "limit": "1"},
          "WhatsJetCallingAddon": {"type": "switch", "description": "Whatsapp Calling API", "limit": "1"}
        },
        "charges": {
          "monthly": {"title": "monthly", "enabled": 0, "price_id": "", "charge": 10},
          "yearly": {"title": "yearly", "enabled": "on", "price_id": "", "charge": 100}
        }
      },
      "plan_2": {
        "id": "plan_2",
        "enabled": "on",
        "popular": false,
        "title": "Premium",
        "trial_days": 0,
        "features": {
          "contacts": {"description": "Contacts", "limit": "15"},
          "campaigns": {"limit_duration": "monthly", "limit_duration_title": "Per Month", "description": "Campaigns", "limit": "10"},
          "bot_replies": {"description": "Bot Replies", "limit": "10"},
          "bot_flows": {"description": "Bot Flows", "limit": "5"},
          "contact_custom_fields": {"description": "Contact Custom Fields", "limit": "10"},
          "system_users": {"description": "Team Members/Agents", "limit": "10"},
          "ai_chat_bot": {"type": "switch", "description": "AI Chat Bot", "limit": "1"},
          "api_access": {"type": "switch", "description": "API and Webhook Access", "limit": "1"},
          "WhatsJetCallingAddon": {"type": "switch", "description": "Whatsapp Calling API", "limit": "1"}
        },
        "charges": {
          "monthly": {"title": "monthly", "enabled": 0, "price_id": "", "charge": 20},
          "yearly": {"title": "yearly", "enabled": "on", "price_id": "", "charge": 199}
        }
      },
      "plan_3": {
        "id": "plan_3",
        "enabled": "on",
        "popular": false,
        "title": "Ultimate",
        "trial_days": 0,
        "features": {
          "contacts": {"description": "Contacts", "limit": "-1"},
          "campaigns": {"limit_duration": "monthly", "limit_duration_title": "Per Month", "description": "Campaigns", "limit": "-1"},
          "bot_replies": {"description": "Bot Replies", "limit": "-1"},
          "bot_flows": {"description": "Bot Flows", "limit": "-1"},
          "contact_custom_fields": {"description": "Contact Custom Fields", "limit": "-1"},
          "system_users": {"description": "Team Members/Agents", "limit": "-1"},
          "ai_chat_bot": {"type": "switch", "description": "AI Chat Bot", "limit": "1"},
          "api_access": {"type": "switch", "description": "API and Webhook Access", "limit": "1"},
          "WhatsJetCallingAddon": {"type": "switch", "description": "Whatsapp Calling API", "limit": "1"}
        },
        "charges": {
          "monthly": {"title": "monthly", "enabled": "on", "price_id": "", "charge": 30},
          "yearly": {"title": "yearly", "enabled": "on", "price_id": "", "charge": 299}
        }
      }
    };
  }
}

void main() {
  testWidgets('MyPlanScreen renders subscription details without error', (WidgetTester tester) async {
    // We want to verify if MyPlanScreen renders using the parsed response structure
    await tester.pumpWidget(
      MaterialApp(
        home: MyPlanScreen(repository: MockSubscriptionRepository()),
      ),
    );

    // Let it run through the states
    await tester.pump();
    await tester.pumpAndSettle();

    // Check if we see the subscription details
    expect(find.text('My Plan'), findsOneWidget);
  });
}
