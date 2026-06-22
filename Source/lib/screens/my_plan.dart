import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stundaa/model/subscription_info.dart';
import 'package:stundaa/repositories/subscription_repository.dart';
import 'package:stundaa/support/app_theme.dart' as app_theme;
import 'package:url_launcher/url_launcher.dart';

const String _upgradeEmail = 'support@stundaa.com';

class MyPlanScreen extends StatefulWidget {
  final SubscriptionRepository? repository;
  const MyPlanScreen({super.key, this.repository});

  @override
  State<MyPlanScreen> createState() => _MyPlanScreenState();
}

class _MyPlanScreenState extends State<MyPlanScreen> {
  late final SubscriptionRepository _repo;
  SubscriptionInfo? _info;
  Map<String, dynamic> _availablePlans = {};
  bool _loading = true;
  String? _errorMessage;
  bool _isUsingFallback = false;
  String _loadingStatus = 'Initializing...';
  final List<String> _logs = [];

  static const Map<String, dynamic> defaultAvailablePlans = {
    'plan_1': {
      'id': 'plan_1',
      'title': 'Standard',
      'charges': {
        'monthly': {
          'title': '\$10 / Month',
          'charge': 10,
        },
        'yearly': {
          'title': '\$100 / Year',
          'charge': 100,
        },
      },
    },
    'plan_2': {
      'id': 'plan_2',
      'title': 'Premium',
      'charges': {
        'monthly': {
          'title': '\$20 / Month',
          'charge': 20,
        },
        'yearly': {
          'title': '\$199 / Year',
          'charge': 199,
        },
      },
    },
    'plan_3': {
      'id': 'plan_3',
      'title': 'Ultimate',
      'charges': {
        'monthly': {
          'title': '\$30 / Month',
          'charge': 30,
        },
        'yearly': {
          'title': '\$299 / Year',
          'charge': 299,
        },
      },
    },
  };

  void _addLog(String msg) {
    debugPrint(msg);
    _logs.add(msg);
  }

  @override
  void initState() {
    super.initState();
    _repo = widget.repository ?? SubscriptionRepository();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    _addLog('[MyPlan] _load start, mounted=$mounted');
    if (mounted) {
      setState(() {
        _loading = true;
        _errorMessage = null;
        _isUsingFallback = false;
        _loadingStatus = 'Connecting to server...';
      });
    }
    SubscriptionInfo? info;
    Map<String, dynamic>? plans;
    try {
      _addLog('[MyPlan] fetching subscription info...');
      if (mounted) {
        setState(() {
          _loadingStatus = 'Fetching subscription info...';
        });
      }
      info = await _repo.fetchSubscriptionInfo();
      _addLog('[MyPlan] info fetched: $info');

      if (mounted) {
        setState(() {
          _loadingStatus = 'Fetching available plans...';
        });
      }
      _addLog('[MyPlan] fetching subscription plans...');
      plans = await _repo.fetchSubscriptionPlans();
      _addLog('[MyPlan] plans fetched: $plans');
    } catch (e, stack) {
      _addLog('[MyPlan] error while fetching: $e');
      _addLog('[MyPlan] stack: $stack');
    }

    if (mounted) {
      setState(() {
        if (info != null && plans != null) {
          _info = info;
          _availablePlans = plans;
          _isUsingFallback = false;
          _errorMessage = null;
        } else {
          _info = info ?? SubscriptionInfo.defaultFree;
          _availablePlans = plans ?? defaultAvailablePlans;
          _isUsingFallback = true;
          _errorMessage = null;
        }
        _loading = false;
      });
    }
    _addLog('[MyPlan] _load done, _loading=$_loading, _isUsingFallback=$_isUsingFallback');
  }

  Future<void> _openUpgradeEmail() async {
    final uri = Uri(
      scheme: 'mailto',
      path: _upgradeEmail,
      queryParameters: {
        'subject': 'Upgrade Plan Request',
        'body': 'Hi, I would like to upgrade my Stundaa plan. Please provide details.\n\nCurrent plan: ${_info?.planTitle ?? "Free"}',
      },
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    try {
      return Scaffold(
        backgroundColor: app_theme.backgroundColor,
        appBar: AppBar(
          title: const Text('My Plan'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: _loading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: app_theme.primary),
                    const SizedBox(height: 16),
                    Text(
                      _loadingStatus,
                      style: const TextStyle(color: app_theme.secondary, fontSize: 14),
                    ),
                  ],
                ),
              )
            : _errorMessage != null
                ? _buildErrorState()
                : _buildBody(),
      );
    } catch (e, stack) {
      return Scaffold(
        backgroundColor: app_theme.backgroundColor,
        appBar: AppBar(
          title: const Text('My Plan Error'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Render Error',
                  style: TextStyle(color: Colors.red, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  e.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 16),
                Text(
                  stack.toString(),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget _buildOfflineBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: app_theme.warning.withValues(alpha: 0.15),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: app_theme.warning,
            size: 20,
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Gagal terhubung ke server. Menampilkan data rencana default.',
              style: TextStyle(
                color: app_theme.warning,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: _load,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Coba Lagi',
              style: TextStyle(
                color: app_theme.primary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    final info = _info;
    if (info == null) {
      return const Center(
          child: Text('Failed to load plan info',
              style: TextStyle(color: app_theme.secondary)));
    }
    if (_isUsingFallback) {
      return Column(
        children: [
          _buildOfflineBanner(),
          Expanded(child: _buildBodyContent(info)),
        ],
      );
    }
    return _buildBodyContent(info);
  }

  Widget _buildBodyContent(SubscriptionInfo info) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPlanCard(info),
          const SizedBox(height: 24),
          _buildFeaturesSection(info),
          const SizedBox(height: 32),
          if (_availablePlans.isNotEmpty) ...[
            const Text(
              'Available Plans',
              style: TextStyle(
                color: app_theme.lavenderWhite,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            ..._availablePlans.entries.map((entry) => _buildAvailablePlanCard(entry.key, entry.value)),
            const SizedBox(height: 24),
          ],
          if (info.isFree) _buildUpgradeButton(),
        ],
      ),
    );
  }

  Widget _buildAvailablePlanCard(String id, dynamic plan) {
    if (plan is! Map) return const SizedBox.shrink();
    final title = plan['title']?.toString() ?? id;
    final charges = plan['charges'] is Map ? plan['charges'] as Map : const {};
    String priceText = 'Contact Us';
    if (charges.isNotEmpty) {
      final firstCharge = charges.values.first;
      if (firstCharge is Map) {
        priceText = '${firstCharge['title'] ?? ''}';
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: app_theme.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: app_theme.lavenderWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  priceText,
                  style: const TextStyle(
                    color: app_theme.cyanGlow,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _openUpgradeEmail,
            style: ElevatedButton.styleFrom(
              backgroundColor: app_theme.primary.withValues(alpha: 0.1),
              foregroundColor: app_theme.primary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(SubscriptionInfo info) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: app_theme.primaryGradient,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  info.isFree ? 'FREE' : 'PAID',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            info.planTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            info.isFree ? 'Current active plan' : 'Active subscription',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14,
            ),
          ),
          if (info.endsAt != null) ...[
            const SizedBox(height: 8),
            Text(
              'Expires: ${info.endsAt}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFeaturesSection(SubscriptionInfo info) {
    return Container(
      decoration: app_theme.insetPanelDecoration(radius: 20),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Plan Features',
            style: TextStyle(
              color: app_theme.primary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          ...info.features.map((f) => _buildFeatureRow(f)),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(PlanFeature feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            feature.isIncluded ? CupertinoIcons.checkmark_circle_fill : CupertinoIcons.xmark_circle_fill,
            color: feature.isIncluded ? app_theme.cyanGlow : app_theme.secondary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              feature.description,
              style: TextStyle(
                color: feature.isIncluded ? app_theme.lavenderWhite : app_theme.secondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: feature.isIncluded
                  ? app_theme.primary.withValues(alpha: 0.15)
                  : app_theme.surfaceMuted,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              feature.limitLabel,
              style: TextStyle(
                color: feature.isIncluded ? app_theme.primary : app_theme.secondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradeButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _openUpgradeEmail,
                icon: const Icon(Icons.upgrade_rounded),
                label: const Text('Upgrade Plan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: app_theme.primary,
                  foregroundColor: app_theme.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Tap to contact us via email at $_upgradeEmail',
          textAlign: TextAlign.center,
          style: const TextStyle(color: app_theme.secondary, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: app_theme.insetPanelDecoration(radius: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: app_theme.error,
                        size: 60,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Connection Error',
                        style: TextStyle(
                          color: app_theme.lavenderWhite,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _errorMessage ?? 'An error occurred while loading your plan.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: app_theme.secondary,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _load,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Try Again'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: app_theme.primary,
                          foregroundColor: app_theme.black,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 4,
                        ),
                      ),
                      if (_logs.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        ExpansionTile(
                          title: const Text(
                            'Debug Details / Logs',
                            style: TextStyle(color: app_theme.lavenderWhite, fontSize: 13),
                          ),
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _logs.join('\n'),
                                style: const TextStyle(color: Colors.grey, fontSize: 11, fontFamily: 'monospace'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
