import 'package:flutter/material.dart';
import 'package:stundaa/model/campaign.dart';
import 'package:stundaa/repositories/campaign_repository.dart';
import 'package:stundaa/support/app_theme.dart' as app_theme;

class BroadcastDetailScreen extends StatefulWidget {
  final String campaignUid;
  final String campaignTitle;

  const BroadcastDetailScreen({
    super.key,
    required this.campaignUid,
    required this.campaignTitle,
  });

  @override
  State<BroadcastDetailScreen> createState() => _BroadcastDetailScreenState();
}

class _BroadcastDetailScreenState extends State<BroadcastDetailScreen> {
  final CampaignRepository _repo = CampaignRepository();
  CampaignStats? _stats;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final stats = await _repo.fetchCampaignStatus(widget.campaignUid);
    if (mounted) {
      setState(() {
        _stats = stats;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: app_theme.backgroundColor,
      appBar: AppBar(
        title: Text(widget.campaignTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: app_theme.primary))
          : _stats == null
              ? const Center(
                  child: Text('Failed to load stats',
                      style: TextStyle(color: app_theme.secondary)))
              : _buildBody(_stats!),
    );
  }

  Widget _buildBody(CampaignStats stats) {
    return RefreshIndicator(
      onRefresh: _load,
      color: app_theme.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(stats),
            const SizedBox(height: 20),
            _buildStatsGrid(stats),
            if (stats.timeTook != null) ...[
              const SizedBox(height: 20),
              _buildTimeTook(stats.timeTook!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(CampaignStats stats) {
    final isRunning = stats.campaignStatus == 'running';
    final color = isRunning ? app_theme.warning : app_theme.success;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: app_theme.surfaceElevated,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  stats.statusText.toUpperCase(),
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            stats.title,
            style: const TextStyle(
              color: app_theme.lavenderWhite,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(CampaignStats stats) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        _buildStatCard('Sent', stats.totalSent, stats.totalSentInPercent, app_theme.primary),
        _buildStatCard('Delivered', stats.totalDelivered, stats.totalDeliveredInPercent, app_theme.success),
        _buildStatCard('Read', stats.totalRead, stats.totalReadInPercent, app_theme.cyanGlow),
        _buildStatCard('Failed', stats.totalFailed, stats.totalFailedInPercent, app_theme.error),
      ],
    );
  }

  Widget _buildStatCard(String label, int count, String? percent, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: app_theme.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              color: color,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: app_theme.secondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (percent != null)
            Text(
              percent,
              style: TextStyle(
                color: color.withValues(alpha: 0.7),
                fontSize: 11,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTimeTook(String timeTook) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: app_theme.surfaceMuted,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.timer_outlined, color: app_theme.secondary, size: 18),
          const SizedBox(width: 10),
          Text(
            timeTook,
            style: const TextStyle(color: app_theme.secondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
