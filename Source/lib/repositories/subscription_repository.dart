import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:stundaa/model/subscription_info.dart';
import 'package:stundaa/services/data_transport.dart' as data_transport;

class SubscriptionRepository {
  Future<SubscriptionInfo?> fetchSubscriptionInfo() async {
    final completer = Completer<SubscriptionInfo?>();
    await data_transport.get(
      'vendor/subscription-info',
      onSuccess: (responseData) {
        if (!completer.isCompleted) {
          try {
            completer.complete(SubscriptionInfo.fromResponse(responseData));
          } catch (e) {
            debugPrint('[SubscriptionRepository] fetchSubscriptionInfo error: $e');
            completer.complete(null);
          }
        }
      },
      onFailed: (_) {
        if (!completer.isCompleted) completer.complete(null);
      },
      onError: (_) {
        if (!completer.isCompleted) completer.complete(null);
      },
    ).catchError((_) => '');
    if (!completer.isCompleted) completer.complete(null);
    return completer.future;
  }

  Future<List<AvailablePlan>> fetchSubscriptionPlans() async {
    final completer = Completer<List<AvailablePlan>>();
    await data_transport.get(
      'vendor/subscription-plans',
      onSuccess: (responseData) {
        if (!completer.isCompleted) {
          try {
            final plansData = responseData?['data']?['plans'];
            if (plansData is Map) {
              final list = <AvailablePlan>[];
              for (final entry in plansData.entries) {
                if (entry.value is Map) {
                  list.add(AvailablePlan.fromMap(
                    entry.key.toString(),
                    Map<String, dynamic>.from(entry.value as Map),
                  ));
                }
              }
              completer.complete(list);
            } else {
              completer.complete([]);
            }
          } catch (e) {
            debugPrint('[SubscriptionRepository] fetchPlans error: $e');
            completer.complete([]);
          }
        }
      },
      onFailed: (_) {
        if (!completer.isCompleted) completer.complete([]);
      },
      onError: (_) {
        if (!completer.isCompleted) completer.complete([]);
      },
    ).catchError((_) => '');
    if (!completer.isCompleted) completer.complete([]);
    return completer.future;
  }
}
