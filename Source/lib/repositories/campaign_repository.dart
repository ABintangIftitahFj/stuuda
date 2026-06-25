import 'dart:async';
import 'package:stundaa/model/campaign.dart';
import 'package:stundaa/services/data_transport.dart' as data_transport;

class CampaignRepository {
  Future<List<Campaign>> fetchCampaignList() async {
    final completer = Completer<List<Campaign>>();
    data_transport.get(
      'campaign',
      onSuccess: (responseData) {
        final raw = responseData?['data']?['campaignList'];
        List<Campaign> list = [];
        if (raw is Map) {
          final data = raw['data'];
          if (data is List) {
            list = data
                .whereType<Map<String, dynamic>>()
                .map(Campaign.fromMap)
                .toList();
          }
        } else if (raw is List) {
          list = raw
              .whereType<Map<String, dynamic>>()
              .map(Campaign.fromMap)
              .toList();
        }
        if (!completer.isCompleted) completer.complete(list);
      },
      onFailed: (_) {
        if (!completer.isCompleted) completer.complete([]);
      },
      onError: (_) {
        if (!completer.isCompleted) completer.complete([]);
      },
    );
    return completer.future;
  }

  Future<CampaignStats?> fetchCampaignStatus(String campaignUid) async {
    final completer = Completer<CampaignStats?>();
    data_transport.get(
      'campaign-status/$campaignUid',
      isExternalApi: true,
      onSuccess: (responseData) {
        final raw = responseData?['data'];
        if (raw is Map<String, dynamic>) {
          final uid = raw['_uid']?.toString() ?? raw['uid']?.toString() ?? '';
          final title = raw['title']?.toString()
              ?? raw['campaign']?['title']?.toString()
              ?? '';
          final stats = CampaignStats.fromMap(raw, uid: uid, title: title);
          if (!completer.isCompleted) completer.complete(stats);
        } else {
          if (!completer.isCompleted) completer.complete(null);
        }
      },
      onFailed: (_) {
        if (!completer.isCompleted) completer.complete(null);
      },
      onError: (_) {
        if (!completer.isCompleted) completer.complete(null);
      },
    );
    return completer.future;
  }

  Future<List<Map<String, dynamic>>> fetchContactGroups() async {
    final completer = Completer<List<Map<String, dynamic>>>();
    data_transport.get(
      'contact/groups',
      onSuccess: (responseData) {
        final raw = responseData?['data'];
        List<Map<String, dynamic>> groups = [];
        if (raw is List) {
          groups = raw.whereType<Map<String, dynamic>>().toList();
        } else if (raw is Map) {
          final nested = raw['contactList']?['data']
              ?? raw['groups']
              ?? raw['contactGroupList'];
          if (nested is List) {
            groups = nested.whereType<Map<String, dynamic>>().toList();
          }
        }
        if (!completer.isCompleted) completer.complete(groups);
      },
      onFailed: (_) {
        if (!completer.isCompleted) completer.complete([]);
      },
      onError: (_) {
        if (!completer.isCompleted) completer.complete([]);
      },
    );
    return completer.future;
  }

  Future<List<Map<String, dynamic>>> fetchTemplates() async {
    final completer = Completer<List<Map<String, dynamic>>>();
    data_transport.get(
      'contact/template-list',
      onSuccess: (responseData) {
        final raw = responseData?['data'];
        List<Map<String, dynamic>> templates = [];
        if (raw is List) {
          templates = raw.whereType<Map<String, dynamic>>().toList();
        } else if (raw is Map) {
          final nested = raw['whatsAppMessageTemplateList'] ?? raw['templates'] ?? raw['templateList'];
          if (nested is List) {
            templates = nested.whereType<Map<String, dynamic>>().toList();
          } else if (nested is Map) {
            final dataList = nested['data'];
            if (dataList is List) {
              templates = dataList.whereType<Map<String, dynamic>>().toList();
            }
          }
        }
        if (!completer.isCompleted) completer.complete(templates);
      },
      onFailed: (_) {
        if (!completer.isCompleted) completer.complete([]);
      },
      onError: (_) {
        if (!completer.isCompleted) completer.complete([]);
      },
    );
    return completer.future;
  }

  String _mapError(String? backendMsg, int? reactionCode) {
    final raw = (backendMsg ?? '').toLowerCase();

    if (reactionCode == 22) return 'Subscription or plan limit reached.';
    if (raw.contains('template does not exist')) return 'Selected template no longer exists. Please sync templates.';
    if (raw.contains('template not found')) return 'Template not found. Sync templates and try again.';
    if (raw.contains('invalid group')) return 'Selected contact group is unavailable.';
    if (raw.contains('group contact does not found')) return 'Selected group has no contacts.';
    if (raw.contains('tidak ada kontak aktif') || raw.contains('no active contacts')) return 'No active contacts found in the selected group.';
    if (raw.contains('demo limit')) return 'Demo accounts can send to 3 contacts maximum.';
    if (raw.contains('test contact missing')) return 'Set a test contact under WhatsApp Settings first.';
    if (raw.contains('test contact does not found')) return 'Test contact not found in your contacts.';
    if (raw.contains('failed to send test message')) return 'Test message failed. Check WhatsApp Cloud API setup.';
    if (raw.contains('failed to create campaign')) return 'Failed to create broadcast. Please try again.';
    if (raw.contains('failed to queue messages')) return 'Failed to prepare broadcast messages. Please try again.';
    if (raw.contains('network or server error')) return 'Connection failed. Check your internet and try again.';
    if (raw.contains('request timed out')) return 'Connection timed out. Please check your internet connection.';
    if (raw.contains('no internet connection')) return 'No internet connection. Check your network.';

    return backendMsg ?? 'Failed to schedule broadcast. Please try again.';
  }

  Future<Map<String, dynamic>> scheduleCampaign(Map<String, dynamic> data) async {
    final completer = Completer<Map<String, dynamic>>();
    data_transport.post(
      'campaign/schedule',
      inputData: data,
      onSuccess: (res) {
        if (!completer.isCompleted) {
          completer.complete({
            'success': true,
            'message': res?['data']?['message'] ?? 'Broadcast scheduled',
          });
        }
      },
      onFailed: (res) {
        if (!completer.isCompleted) {
          final backendMsg = res?['data']?['message'] as String?
              ?? res?['message'] as String?;
          final reactionCode = res?['reaction'] is int
              ? res!['reaction'] as int?
              : int.tryParse(res?['reaction']?.toString() ?? '');
          completer.complete({
            'success': false,
            'message': _mapError(backendMsg, reactionCode),
            'reaction_code': reactionCode,
          });
        }
      },
      onError: (res) {
        if (!completer.isCompleted) {
          final backendMsg = res?['data']?['message'] as String?
              ?? res?['message'] as String?;
          final reactionCode = res?['reaction'] is int
              ? res!['reaction'] as int?
              : int.tryParse(res?['reaction']?.toString() ?? '');
          completer.complete({
            'success': false,
            'message': _mapError(backendMsg, reactionCode),
            'reaction_code': reactionCode,
          });
        }
      },
    );
    return completer.future;
  }
}
