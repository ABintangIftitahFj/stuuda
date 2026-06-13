import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stundaa/model/contact_summary.dart';
import 'package:stundaa/repositories/contact_repository.dart';
import 'package:stundaa/services/auth.dart';

class ContactProvider with ChangeNotifier {
  List<MapEntry<String, dynamic>> contactsList = [];
  List<MapEntry<String, dynamic>> originalContactsList = [];
  final AudioPlayer _player = AudioPlayer();
  final ContactRepository _contactRepository = ContactRepository();
  int unreadMsgCount = 0;
  bool isLoading = false;
  bool isLoadingMore = false;
  bool isLoadingList = false;
  int currentPage = 1;
  int totalPages = 5;
  List<String> pinnedContactUids = [];
  Map<String, List<String>> pockets = {}; // Pocket Name -> List of Contact UIDs

  ContactProvider() {
    _loadPinnedContacts();
    _loadPockets();
  }

  Future<void> _loadPinnedContacts() async {
    final prefs = await SharedPreferences.getInstance();
    pinnedContactUids = prefs.getStringList('pinned_contacts') ?? [];
    notifyListeners();
  }

  Future<void> _loadPockets() async {
    final prefs = await SharedPreferences.getInstance();
    final String? pocketsJson = prefs.getString('chat_pockets');
    if (pocketsJson != null) {
      try {
        final Map<String, dynamic> decoded = json.decode(pocketsJson);
        pockets = decoded.map(
            (key, value) => MapEntry(key, List<String>.from(value as List)));
      } catch (e) {
        debugPrint('Error decoding pockets: $e');
        pockets = {};
      }
    }
    notifyListeners();
  }

  Future<void> savePockets() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('chat_pockets', json.encode(pockets));
    notifyListeners();
  }

  Future<void> createPocket(String name) async {
    if (name.trim().isEmpty) return;
    if (!pockets.containsKey(name)) {
      pockets[name] = [];
      await savePockets();
    }
  }

  Future<void> deletePocket(String name) async {
    if (pockets.containsKey(name)) {
      pockets.remove(name);
      await savePockets();
    }
  }

  Future<void> toggleInPocket(String pocketName, String contactUid) async {
    if (!pockets.containsKey(pocketName)) return;

    if (pockets[pocketName]!.contains(contactUid)) {
      pockets[pocketName]!.remove(contactUid);
    } else {
      pockets[pocketName]!.add(contactUid);
    }
    await savePockets();
  }

  Future<void> removeFromPocket(String pocketName, String contactUid) async {
    if (pockets.containsKey(pocketName)) {
      pockets[pocketName]?.remove(contactUid);
      await savePockets();
    }
  }

  Future<void> moveContactPocket(String fromPocket, String toPocket, String contactUid) async {
    if (pockets.containsKey(fromPocket)) {
      pockets[fromPocket]?.remove(contactUid);
    }
    if (pockets.containsKey(toPocket)) {
      if (!pockets[toPocket]!.contains(contactUid)) {
        pockets[toPocket]!.add(contactUid);
      }
    }
    await savePockets();
  }

  Future<void> clearFromAllPockets(String contactUid) async {
    for (var pocketName in pockets.keys) {
      pockets[pocketName]?.remove(contactUid);
    }
    await savePockets();
  }

  bool isInPocket(String pocketName, String contactUid) {
    return pockets[pocketName]?.contains(contactUid) ?? false;
  }

  List<ContactSummary> getPocketContacts(String pocketName) {
    final uids = pockets[pocketName] ?? [];
    return originalContactSummaries.where((c) => uids.contains(c.uid)).toList();
  }

  Future<void> togglePin(String contactUid) async {
    if (pinnedContactUids.contains(contactUid)) {
      pinnedContactUids.remove(contactUid);
    } else {
      pinnedContactUids.add(contactUid);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('pinned_contacts', pinnedContactUids);
    notifyListeners();
  }

  bool isPinned(String contactUid) => pinnedContactUids.contains(contactUid);

  List<ContactSummary> get pinnedContacts =>
      originalContactSummaries.where((c) => isPinned(c.uid)).toList();

  bool _isTabLoading = false;

  bool get isTabLoading => _isTabLoading;

  void setTabLoading(bool loading) {
    _isTabLoading = loading;
    notifyListeners();
  }

  bool hasReachedMax = false;
  bool hasError = false;
  String errorMessage = '';

  List<ContactSummary> get contactSummaries =>
      List<ContactSummary>.unmodifiable(
        contactsList.map(ContactSummary.fromEntry),
      );

  List<ContactSummary> get originalContactSummaries =>
      List<ContactSummary>.unmodifiable(
        originalContactsList.map(ContactSummary.fromEntry),
      );

  MapEntry<String, dynamic> normalizeContactEntry(
      MapEntry<String, dynamic> entry) {
    return ContactSummary.fromEntry(entry).toEntry();
  }

  List<MapEntry<String, dynamic>> filterOriginalContacts(String query) {
    final normalizedQuery = query.trim();
    if (normalizedQuery.isEmpty) {
      return List<MapEntry<String, dynamic>>.from(
        originalContactSummaries.map((contact) => contact.toEntry()),
      );
    }

    return originalContactSummaries
        .where((contact) => contact.matchesQuery(normalizedQuery))
        .map((contact) => contact.toEntry())
        .toList();
  }

  void resetVisibleContacts() {
    contactsList = List<MapEntry<String, dynamic>>.from(
      originalContactSummaries.map((contact) => contact.toEntry()),
    );
    notifyListeners();
  }

  void setVisibleContactsFromQuery(String query) {
    contactsList = filterOriginalContacts(query);
    notifyListeners();
  }

  MapEntry<String, dynamic> _buildDummyReplyChatContact() {
    return const MapEntry('dummy-contact-1', {
      '_uid': 'dummy-contact-1',
      'contact_uid': 'dummy-contact-1',
      'full_name': 'Dummy Reply Chat',
      'first_name': 'Dummy',
      'last_name': 'Reply Chat',
      'wa_id': '+6281234567890',
      'name_initials': 'DR',
      'unread_messages_count': 0,
      'last_message': {
        '_uid': 'dummy-reply-1',
        'formatted_message_time': '8:15 AM',
      },
    });
  }

  void injectDummyContactIfEmpty() {
    assert(() {
      if (contactsList.isEmpty && originalContactsList.isEmpty) {
        final dummyContact =
            normalizeContactEntry(_buildDummyReplyChatContact());
        contactsList.add(dummyContact);
        originalContactsList.add(dummyContact);
      }
      return true;
    }());
  }

  Future<void> getUser({bool isRefresh = true, String assigned = ''}) async {
    // Prevent duplicate calls
    if ((isLoading && isRefresh) || (isLoadingMore && !isRefresh)) return;
    if (!isRefresh && hasReachedMax) return;

    // Update state
    isLoading = isRefresh;
    isLoadingMore = !isRefresh;

    // Use postFrameCallback to safely notify after build completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      // For load-more operations, increment page BEFORE making the API call
      if (!isRefresh) {
        currentPage++;
      } else {
        currentPage = 1;
        // Do not clear lists immediately to avoid blank screen
        // contactsList.clear();
        // originalContactsList.clear();
        hasReachedMax = false;
      }

      final response = await _contactRepository.fetchContacts(
        page: currentPage,
        assigned: assigned,
      );
      final clientContacts = response.contacts;
      unreadMsgCount = response.unreadMessagesCount;

      if (isRefresh) {
        contactsList.clear();
        originalContactsList.clear();
      }

      if (clientContacts.isEmpty) {
        hasReachedMax = true;
        if (!isRefresh) currentPage--;
      } else {
        for (var entry in clientContacts) {
          final normalizedEntry = normalizeContactEntry(entry);
          if (!contactsList.any((e) => e.key == normalizedEntry.key)) {
            contactsList.add(normalizedEntry);
            originalContactsList.add(normalizedEntry);
          }
        }
      }
      injectDummyContactIfEmpty();
    } catch (e) {
      if (!isRefresh) currentPage--;
      errorMessage = 'Failed to load contacts';
      hasError = true;
      debugPrint('Error loading contacts: $e');
      injectDummyContactIfEmpty();
    } finally {
      isLoading = false;
      isLoadingMore = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  Future<void> getUserLable({bool isRefresh = false, int? labelId}) async {
    if (isLoading || (isLoadingMore && !isRefresh)) return;
    if (isRefresh) {
      currentPage = 1;
      contactsList.clear();
      originalContactsList.clear();
    }
    isLoading = isRefresh;
    isLoadingMore = !isRefresh;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      final response =
          await _contactRepository.fetchContacts(page: currentPage);
      unreadMsgCount = response.unreadMessagesCount;
      var newContacts = response.contacts;

      for (var entry in newContacts) {
        final normalizedEntry = normalizeContactEntry(entry);
        if (!contactsList.any((e) => e.key == normalizedEntry.key)) {
          if (labelId == null ||
              (normalizedEntry.value['labels'] as List)
                  .any((label) => label['_id'] == labelId)) {
            contactsList.add(normalizedEntry);
            originalContactsList.add(normalizedEntry);
          }
        }
      }

      if (!isRefresh) {
        currentPage++;
      }
    } catch (e) {
      // Handle error
    } finally {
      isLoading = false;
      isLoadingMore = false;
      notifyListeners();
    }
  }

  bool contactExists(String contactUid) {
    return contactsList.any((entry) => entry.value['_uid'] == contactUid);
  }

  Future<void> fetchSingleContact(String contactUid) async {
    try {
      final vendorUid = getAuthInfo('vendor_uid');
      final response = await _contactRepository.fetchSingleContact(
        vendorUid: vendorUid,
        contactUid: contactUid,
      );
      unreadMsgCount = response.unreadMessagesCount;

      for (var entry in response.contacts) {
        final normalizedEntry = normalizeContactEntry(entry);
        if (!contactsList.any((e) => e.key == normalizedEntry.key)) {
          contactsList.insert(0, normalizedEntry);
          originalContactsList.insert(0, normalizedEntry);
          _player.play(AssetSource('audio/receivesound.mp3'));
        }
      }

      injectDummyContactIfEmpty();

      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching single contact: $e');
    }
  }

  void updateMessageCountToZero(String contactId) {
    int index =
        contactsList.indexWhere((entry) => entry.value['_uid'] == contactId);
    if (index != -1) {
      final contactEntry = contactsList[index];
      int unreadMessages = contactEntry.value['unread_messages_count'] ?? 0;

      if (unreadMessages > 0) {
        unreadMsgCount -= unreadMessages;
        unreadMsgCount = unreadMsgCount < 0 ? 0 : unreadMsgCount;
        final updatedContact = {
          ...contactEntry.value,
          'unread_messages_count': 0,
        };
        contactsList[index] = MapEntry(contactEntry.key, updatedContact);
        int originalIndex = originalContactsList
            .indexWhere((entry) => entry.value['_uid'] == contactId);
        if (originalIndex != -1) {
          originalContactsList[originalIndex] =
              MapEntry(contactEntry.key, updatedContact);
        }
        notifyListeners();
      }
    }
  }

  void updateContactWithNewMessage(
    String contactUid,
    String lastMessageUid,
    String formattedTime,
    String justNowLabel, {
    String? lastMessageText,
    bool? lastMessageIsIncoming,
  }) {
    final contactIndex =
        contactsList.indexWhere((entry) => entry.key == contactUid);
    if (contactIndex != -1) {
      final contactEntry = contactsList[contactIndex];
      final updatedContact = {
        ...contactEntry.value,
        'last_message': {
          'formatted_message_time': justNowLabel,
          '_uid': lastMessageUid,
          'message': lastMessageText ?? contactEntry.value['last_message']?['message'],
          'is_incoming_message': lastMessageIsIncoming ?? contactEntry.value['last_message']?['is_incoming_message'],
        },
        'unread_messages_count':
            (contactEntry.value['unread_messages_count'] ?? 0) + 1,
      };
      _player.play(AssetSource('audio/receivesound.mp3'));
      contactsList.removeAt(contactIndex);
      contactsList.insert(0, MapEntry(contactUid, updatedContact));
    } else {
      final newContact = MapEntry(contactUid, {
        'last_message': {
          'formatted_message_time': justNowLabel,
          '_uid': lastMessageUid,
          'message': lastMessageText,
          'is_incoming_message': lastMessageIsIncoming,
        },
        'unread_messages_count': 1,
      });
      contactsList.insert(0, newContact);
    }
    unreadMsgCount++;

    final originalContactIndex =
        originalContactsList.indexWhere((entry) => entry.key == contactUid);
    if (originalContactIndex != -1) {
      final originalEntry = originalContactsList[originalContactIndex];
      final updatedOriginalContact = {
        ...originalEntry.value,
        'last_message': {
          'formatted_message_time': justNowLabel,
          '_uid': lastMessageUid,
          'message': lastMessageText ?? originalEntry.value['last_message']?['message'],
          'is_incoming_message': lastMessageIsIncoming ?? originalEntry.value['last_message']?['is_incoming_message'],
        },
        'unread_messages_count':
            (originalEntry.value['unread_messages_count'] ?? 0) + 1,
      };
      originalContactsList.removeAt(originalContactIndex);
      originalContactsList.insert(0, MapEntry(contactUid, updatedOriginalContact));
    } else {
      final newOriginalContact = MapEntry(contactUid, {
        'last_message': {
          'formatted_message_time': justNowLabel,
          '_uid': lastMessageUid,
          'message': lastMessageText,
          'is_incoming_message': lastMessageIsIncoming,
        },
        'unread_messages_count': 1,
      });
      originalContactsList.insert(0, newOriginalContact);
    }
    notifyListeners();
  }
}
