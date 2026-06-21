import 'dart:async';
import 'package:stundaa/model/subscription_info.dart';
import 'package:stundaa/services/data_transport.dart' as data_transport;

class SubscriptionRepository {
  Future<SubscriptionInfo?> fetchSubscriptionInfo() async {
    final completer = Completer<SubscriptionInfo?>();
    data_transport.get(
      'vendor/subscription-info',
      onSuccess: (responseData) {
        if (!completer.isCompleted) {
          try {
            completer.complete(SubscriptionInfo.fromResponse(responseData));
          } catch (e) {
            completer.complete(null);
          }
        }
      },
      onFailed: (responseData) {
        if (!completer.isCompleted) {
          completer.complete(null);
        }
      },
      onError: (error) {
        if (!completer.isCompleted) {
          completer.complete(null);
        }
      },
    );
    return completer.future;
  }

  Future<Map<String, dynamic>?> fetchSubscriptionPlans() async {
    final completer = Completer<Map<String, dynamic>?>();
    data_transport.get(
      'vendor/subscription-plans',
      onSuccess: (responseData) {
        if (!completer.isCompleted) {
          try {
            final plansData = responseData?['data']?['plans'];
            if (plansData is Map) {
              completer.complete(Map<String, dynamic>.from(plansData));
            } else {
              completer.complete({});
            }
          } catch (e) {
            completer.complete(null);
          }
        }
      },
      onFailed: (responseData) {
        if (!completer.isCompleted) {
          completer.complete(null);
        }
      },
      onError: (error) {
        if (!completer.isCompleted) {
          completer.complete(null);
        }
      },
    );
    return completer.future;
  }
}
