import 'dart:async';
import 'package:stundaa/model/subscription_info.dart';
import 'package:stundaa/services/data_transport.dart' as data_transport;

class SubscriptionRepository {
  Future<SubscriptionInfo> fetchSubscriptionInfo() async {
    final completer = Completer<SubscriptionInfo>();
    data_transport.get(
      'vendor/subscription-info',
      onSuccess: (responseData) {
        if (!completer.isCompleted) {
          completer.complete(SubscriptionInfo.fromResponse(responseData));
        }
      },
      onFailed: (responseData) {
        if (!completer.isCompleted) {
          completer.complete(SubscriptionInfo.fromResponse(null));
        }
      },
      onError: (error) {
        if (!completer.isCompleted) {
          completer.complete(SubscriptionInfo.fromResponse(null));
        }
      },
    );
    return completer.future;
  }

  Future<Map<String, dynamic>> fetchSubscriptionPlans() async {
    final completer = Completer<Map<String, dynamic>>();
    data_transport.get(
      'vendor/subscription-plans',
      onSuccess: (responseData) {
        if (!completer.isCompleted) {
          completer.complete(responseData?['data']?['plans'] ?? {});
        }
      },
      onFailed: (responseData) {
        if (!completer.isCompleted) {
          completer.complete({});
        }
      },
      onError: (error) {
        if (!completer.isCompleted) {
          completer.complete({});
        }
      },
    );
    return completer.future;
  }
}
