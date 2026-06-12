import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stundaa/model/subscription_info.dart';
import 'package:stundaa/repositories/subscription_repository.dart';
import 'package:stundaa/support/app_theme.dart' as app_theme;
import 'package:url_launcher/url_launcher.dart';

const String _upgradeEmail = 'support@stundaa.com';

class MyPlanScreen extends StatefulWidget {
  const MyPlanScreen({super.key});

  @override
  State<MyPlanScreen> createState() => _MyPlanScreenState();
}

class _MyPlanScreenState extends State<MyPlanScreen> {
  final SubscriptionRepository _repo = SubscriptionRepository();
  SubscriptionInfo? _info;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final info = await _repo.fetchSubscriptionInfo();
    if (mounted) setState(() { _info = info; _loading = false; });
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
    return Scaffold(
      backgroundColor: app_theme.backgroundColor,
      appBar: AppBar(
        title: const Text('My Plan'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: app_theme.primary))
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    final info = _info;
    if (info == null) {
      return const Center(child: Text('Failed to load plan info', style: TextStyle(color: app_theme.secondary)));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPlanCard(info),
          const SizedBox(height: 24),
          _buildFeaturesSection(info),
          const SizedBox(height: 32),
          if (info.isFree) _buildUpgradeButton(),
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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
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
        const SizedBox(height: 12),
        Text(
          'Tap to contact us via email at $_upgradeEmail',
          textAlign: TextAlign.center,
          style: const TextStyle(color: app_theme.secondary, fontSize: 13),
        ),
      ],
    );
  }
}
