import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stundaa/model/subscription_info.dart';
import 'package:stundaa/repositories/subscription_repository.dart';
import 'package:stundaa/screens/my_plan_viewmodel.dart';
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
  late final MyPlanViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = MyPlanViewModel(repository: widget.repository);
    WidgetsBinding.instance.addPostFrameCallback((_) => _viewModel.load());
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: app_theme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'My Plan',
          style: GoogleFonts.spaceGrotesk(
            color: app_theme.lavenderWhite,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) => LayoutBuilder(
          builder: (context, constraints) {
            final minH = constraints.maxHeight - 40;
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: minH),
                child: _body(),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _body() {
    final vm = _viewModel;
    if (vm.isLoading || vm.status == MyPlanStatus.initial) return _buildLoading();

    final info = vm.info;
    if (info == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Failed to load plan info',
                style: GoogleFonts.plusJakartaSans(color: app_theme.secondary)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: vm.load,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (vm.isOfflineFallback) _buildOfflineBanner(),
        if (vm.isOfflineFallback) const SizedBox(height: 20),
        _buildCurrentPlanCard(info).animate().fadeIn(duration: 500.ms, curve: Curves.easeOutCubic).slideY(begin: 0.06, duration: 500.ms, curve: Curves.easeOutCubic),
        const SizedBox(height: 20),
        _buildFeaturesSection(info).animate(delay: 120.ms).fadeIn(duration: 500.ms, curve: Curves.easeOutCubic).slideY(begin: 0.05, duration: 500.ms, curve: Curves.easeOutCubic),
        if (vm.plans.isNotEmpty) ...[
          const SizedBox(height: 28),
          _buildAvailablePlansTitle().animate(delay: 200.ms).fadeIn(duration: 400.ms, curve: Curves.easeOutCubic),
          const SizedBox(height: 16),
          _buildPlanCarousel(vm.plans),
        ],
        if (info.isFree) ...[
          const SizedBox(height: 32),
          _buildUpgradeButton().animate(delay: 350.ms).fadeIn(duration: 500.ms, curve: Curves.easeOutCubic),
        ],
      ],
    );
  }

  Widget _buildLoading() {
    return Shimmer.fromColors(
      baseColor: app_theme.surface,
      highlightColor: app_theme.surfaceElevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _skeletonBox(height: 220, radius: 32),
          const SizedBox(height: 24),
          _skeletonBox(height: 240, radius: 28),
          const SizedBox(height: 32),
          _skeletonBox(height: 20, width: 180),
          const SizedBox(height: 16),
          _skeletonBox(height: 130, radius: 24),
          const SizedBox(height: 12),
          _skeletonBox(height: 130, radius: 24),
          const SizedBox(height: 12),
          _skeletonBox(height: 130, radius: 24),
        ],
      ),
    );
  }

  Widget _skeletonBox({double height = 20, double radius = 8, double? width}) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  Widget _buildOfflineBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: app_theme.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: app_theme.warning.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: app_theme.warning, size: 18),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Unable to reach server. Showing default plan data.',
              style: TextStyle(color: app_theme.warning, fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
          TextButton(
            onPressed: _viewModel.load,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Retry',
                style: TextStyle(color: app_theme.primary, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentPlanCard(SubscriptionInfo info) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
      decoration: BoxDecoration(
        gradient: app_theme.primaryGradient,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: app_theme.primary.withValues(alpha: 0.3),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _glassBadge(
                text: info.isFree ? 'FREE' : 'ACTIVE',
                icon: info.isFree ? Icons.rocket_launch_rounded : Icons.check_circle_rounded,
              ),
              const Spacer(),
              if (!info.isFree) _glassBadge(text: 'Subscribed'),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            info.planTitle,
            style: GoogleFonts.spaceGrotesk(
              color: Colors.white,
              fontSize: 38,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.6,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            info.isFree ? 'Current plan' : 'Active subscription',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white.withValues(alpha: 0.78),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (info.endsAt != null) ...[
            const SizedBox(height: 14),
            _glassBadge(
              text: 'Expires ${info.endsAt}',
              icon: Icons.calendar_today_rounded,
            ),
          ],
        ],
      ),
    );
  }

  Widget _glassBadge({required String text, IconData? icon}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: icon != null ? 14 : 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: Colors.white, size: 14),
            const SizedBox(width: 6),
          ],
          Text(
            text,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 11,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection(SubscriptionInfo info) {
    return Container(
      decoration: app_theme.insetPanelDecoration(radius: 28),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: app_theme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.stars_rounded, color: app_theme.primary, size: 20),
              ),
              const SizedBox(width: 14),
              Text(
                'Plan Features',
                style: GoogleFonts.spaceGrotesk(
                  color: app_theme.lavenderWhite,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...info.features.map((f) => _buildFeatureRow(f)),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(PlanFeature feature) {
    final included = feature.isIncluded;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: included
                  ? app_theme.success.withValues(alpha: 0.12)
                  : app_theme.surfaceMuted,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              included ? Icons.check_rounded : Icons.close_rounded,
              color: included ? app_theme.success : app_theme.secondary,
              size: 16,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              feature.description,
              style: GoogleFonts.plusJakartaSans(
                color: included ? app_theme.lavenderWhite : app_theme.secondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: included
                  ? app_theme.primary.withValues(alpha: 0.1)
                  : app_theme.surfaceMuted,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              feature.limitLabel,
              style: GoogleFonts.plusJakartaSans(
                color: included ? app_theme.primary : app_theme.secondary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailablePlansTitle() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: app_theme.cyanGlow.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.diamond_rounded, color: app_theme.cyanGlow, size: 20),
        ),
        const SizedBox(width: 14),
        Text(
          'Available Plans',
          style: GoogleFonts.spaceGrotesk(
            color: app_theme.lavenderWhite,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildPlanCarousel(List<AvailablePlan> plans) {
    final enabled = plans.where((p) => p.enabled).toList();
    return Column(
      children: List.generate(enabled.length, (index) {
        return _buildPlanOfferCard(enabled[index], index)
            .animate(delay: Duration(milliseconds: 240 + index * 80))
            .fadeIn(duration: 450.ms, curve: Curves.easeOutCubic)
            .slideY(begin: 0.04, duration: 450.ms, curve: Curves.easeOutCubic);
      }),
    );
  }

  Widget _buildPlanOfferCard(AvailablePlan plan, int index) {
    final charge = plan.bestCharge;
    final isPopular = plan.popular;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isPopular
            ? app_theme.primary.withValues(alpha: 0.05)
            : app_theme.surfaceElevated,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isPopular
              ? app_theme.primary.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.04),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 0),
            child: Row(
              children: [
                Text(
                  plan.title,
                  style: GoogleFonts.spaceGrotesk(
                    color: app_theme.lavenderWhite,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.4,
                  ),
                ),
                if (isPopular) ...[
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: app_theme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Popular',
                      style: GoogleFonts.plusJakartaSans(
                        color: app_theme.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      charge.priceLabel,
                      style: GoogleFonts.spaceGrotesk(
                        color: app_theme.cyanGlow,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (charge.intervalLabel.isNotEmpty)
                      Text(
                        'per ${charge.intervalLabel}',
                        style: GoogleFonts.plusJakartaSans(
                          color: app_theme.secondary,
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          if (plan.features.isNotEmpty) ...[
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Divider(
                color: Colors.white.withValues(alpha: 0.06),
                height: 1,
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: plan.features.map((f) {
                  final included = f.isIncluded;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: included
                          ? app_theme.success.withValues(alpha: 0.08)
                          : app_theme.surfaceMuted,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          included ? Icons.check_rounded : Icons.close_rounded,
                          color: included ? app_theme.success : app_theme.secondary,
                          size: 13,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          f.limitLabel,
                          style: GoogleFonts.plusJakartaSans(
                            color: included ? app_theme.lavenderWhite : app_theme.secondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUpgradeButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: app_theme.primary.withValues(alpha: 0.25),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: _openUpgradeEmail,
            style: ElevatedButton.styleFrom(
              backgroundColor: app_theme.primary,
              foregroundColor: app_theme.black,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.diamond_rounded, size: 22),
                const SizedBox(width: 10),
                const Text('Upgrade Plan'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Contact us at $_upgradeEmail',
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(color: app_theme.secondary, fontSize: 13),
        ),
      ],
    );
  }

  Future<void> _openUpgradeEmail() async {
    final uri = Uri(
      scheme: 'mailto',
      path: _upgradeEmail,
      queryParameters: {
        'subject': 'Upgrade Plan Request',
        'body': 'Hi, I would like to upgrade my Stundaa plan.\n\nCurrent plan: Free',
      },
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
