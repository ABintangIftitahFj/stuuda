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
      onSuccess: (responseData) {
        final raw = responseData?['data'];
        if (raw is Map<String, dynamic>) {
          if (!completer.isCompleted) {
            completer.complete(CampaignStats.fromMap(raw));
          }
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
          final nested = raw['groups'] ?? raw['contactGroupList'];
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
          final nested = raw['whatsAppMessageTemplateList'] ?? raw['templates'];
          if (nested is List) {
            templates = nested.whereType<Map<String, dynamic>>().toList();
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

  Future<bool> scheduleCampaign(Map<String, dynamic> data) async {
    final completer = Completer<bool>();
    data_transport.post(
      'campaign/schedule',
      inputData: data,
      onSuccess: (_) {
        if (!completer.isCompleted) completer.complete(true);
      },
      onFailed: (_) {
        if (!completer.isCompleted) completer.complete(false);
      },
      onError: (_) {
        if (!completer.isCompleted) completer.complete(false);
      },
    );
    return completer.future;
  }
}
