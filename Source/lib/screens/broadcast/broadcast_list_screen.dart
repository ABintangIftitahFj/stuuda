import 'package:flutter/material.dart';
import 'package:stundaa/model/campaign.dart';
import 'package:stundaa/repositories/campaign_repository.dart';
import 'package:stundaa/screens/broadcast/broadcast_create_screen.dart';
import 'package:stundaa/screens/broadcast/broadcast_detail_screen.dart';
import 'package:stundaa/support/app_theme.dart' as app_theme;

class BroadcastListScreen extends StatefulWidget {
  const BroadcastListScreen({super.key});

  @override
  State<BroadcastListScreen> createState() => _BroadcastListScreenState();
}

class _BroadcastListScreenState extends State<BroadcastListScreen> {
  final CampaignRepository _repo = CampaignRepository();
  List<Campaign> _campaigns = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final list = await _repo.fetchCampaignList();
    if (mounted) {
      setState(() {
        _campaigns = list;
        _loading = false;
      });
    }
  }

  Future<void> _openCreate() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const BroadcastCreateScreen()),
    );
    if (result == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: app_theme.backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Broadcasts'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: app_theme.primary),
            onPressed: _openCreate,
            tooltip: 'New Broadcast',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: app_theme.primary))
          : _campaigns.isEmpty
              ? _buildEmpty()
              : RefreshIndicator(
                  onRefresh: _load,
                  color: app_theme.primary,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _campaigns.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _buildCampaignCard(_campaigns[i]),
                  ),
                ),
      floatingActionButton: _campaigns.isNotEmpty
          ? FloatingActionButton(
              onPressed: _openCreate,
              backgroundColor: app_theme.primary,
              foregroundColor: app_theme.black,
              child: const Icon(Icons.add_rounded),
            )
          : null,
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.campaign_outlined,
              color: app_theme.secondary.withValues(alpha: 0.4), size: 64),
          const SizedBox(height: 16),
          const Text(
            'No broadcasts yet',
            style: TextStyle(
              color: app_theme.secondary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Schedule a broadcast to send to your contacts',
            style: TextStyle(color: app_theme.secondary, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _openCreate,
            icon: const Icon(Icons.add_rounded),
            label: const Text('New Broadcast'),
            style: ElevatedButton.styleFrom(
              backgroundColor: app_theme.primary,
              foregroundColor: app_theme.black,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCampaignCard(Campaign campaign) {
    final statusColor = _statusColor(campaign.status);
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => BroadcastDetailScreen(
            campaignUid: campaign.uid,
            campaignTitle: campaign.title,
          ),
        ),
      ),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: app_theme.surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: app_theme.outlineSoft),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    campaign.title,
                    style: const TextStyle(
                      color: app_theme.lavenderWhite,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    campaign.status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            if (campaign.scheduledAt != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.schedule_outlined,
                      color: app_theme.secondary, size: 13),
                  const SizedBox(width: 4),
                  Text(
                    campaign.scheduledAt!,
                    style: const TextStyle(
                        color: app_theme.secondary, fontSize: 12),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.people_outline,
                    color: app_theme.secondary, size: 14),
                const SizedBox(width: 6),
                Text(
                  '${campaign.totalContacts} contacts',
                  style: const TextStyle(
                      color: app_theme.secondary, fontSize: 12),
                ),
                const Spacer(),
                const Icon(Icons.chevron_right_rounded,
                    color: app_theme.secondary, size: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'running':
        return app_theme.warning;
      case 'completed':
        return app_theme.success;
      case 'failed':
        return app_theme.error;
      case 'pending':
        return app_theme.info;
      default:
        return app_theme.secondary;
    }
  }
}
