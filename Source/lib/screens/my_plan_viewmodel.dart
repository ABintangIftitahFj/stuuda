import 'package:flutter/foundation.dart';
import 'package:stundaa/model/subscription_info.dart';
import 'package:stundaa/repositories/subscription_repository.dart';

enum MyPlanStatus { initial, loading, loaded, offlineFallback }

class MyPlanViewModel extends ChangeNotifier {
  MyPlanViewModel({SubscriptionRepository? repository})
      : _repo = repository ?? SubscriptionRepository();

  final SubscriptionRepository _repo;

  MyPlanStatus _status = MyPlanStatus.initial;
  SubscriptionInfo? _info;
  List<AvailablePlan> _plans = [];

  MyPlanStatus get status => _status;
  SubscriptionInfo? get info => _info;
  List<AvailablePlan> get plans => _plans;

  bool get isLoading => _status == MyPlanStatus.loading;
  bool get isOfflineFallback => _status == MyPlanStatus.offlineFallback;

  static List<AvailablePlan> get defaultPlans => [
        const AvailablePlan(
          id: 'plan_1', title: 'Standard', popular: true, enabled: true,
          features: [],
          charges: [PlanCharge(title: 'monthly', enabled: true, charge: 10), PlanCharge(title: 'yearly', enabled: true, charge: 100)],
        ),
        const AvailablePlan(
          id: 'plan_2', title: 'Premium', popular: false, enabled: true,
          features: [],
          charges: [PlanCharge(title: 'monthly', enabled: true, charge: 20), PlanCharge(title: 'yearly', enabled: true, charge: 199)],
        ),
        const AvailablePlan(
          id: 'plan_3', title: 'Ultimate', popular: false, enabled: true,
          features: [],
          charges: [PlanCharge(title: 'monthly', enabled: true, charge: 30), PlanCharge(title: 'yearly', enabled: true, charge: 299)],
        ),
      ];

  Future<void> load() async {
    _status = MyPlanStatus.loading;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repo.fetchSubscriptionInfo(),
        _repo.fetchSubscriptionPlans(),
      ]);
      final info = results[0] as SubscriptionInfo?;
      final plans = results[1] as List<AvailablePlan>? ?? [];

      if (info != null) {
        _info = info;
        _plans = plans;
        _status = MyPlanStatus.loaded;
      } else {
        _info = SubscriptionInfo.defaultFree;
        _plans = defaultPlans;
        _status = MyPlanStatus.offlineFallback;
      }
    } catch (_) {
      _info = SubscriptionInfo.defaultFree;
      _plans = defaultPlans;
      _status = MyPlanStatus.offlineFallback;
    }

    notifyListeners();
  }
}
