import 'dart:async';
import 'package:stundaa/model/subscription_info.dart';
import 'package:stundaa/services/data_transport.dart' as data_transport;

class SubscriptionRepository {
  Future<SubscriptionInfo> fetchSubscriptionInfo() {
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
}
