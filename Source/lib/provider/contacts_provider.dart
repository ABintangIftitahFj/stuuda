import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:stundaa/services/auth.dart';
import 'package:stundaa/services/data_transport.dart' as data_transport;
import 'package:stundaa/services/utils.dart';

class ContactProvider with ChangeNotifier {
  List<MapEntry<String, dynamic>> contactsList = [];
  List<MapEntry<String, dynamic>> originalContactsList = [];
  final AudioPlayer _player = AudioPlayer();
  int unreadMsgCount = 0;
  bool isLoading = false;
  bool isLoadingMore = false;
  bool isLoadingList = false;
  int currentPage = 1;
  int totalPages = 5;

  bool _isTabLoading = false;

  bool get isTabLoading => _isTabLoading;

  void setTabLoading(bool loading) {
    _isTabLoading = loading;
    notifyListeners();
  }

  bool hasReachedMax = false;
  bool hasError = false;
  String errorMessage = '';

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
        contactsList.clear();
        originalContactsList.clear();
        hasReachedMax = false;
      }

      final response = await data_transport.get(
          'vendor/contact/contacts-data?page=$currentPage&assigned=$assigned'
      );

      final clientContacts = getItemValue(response, 'client_models.contacts');
      unreadMsgCount = getItemValue(response, 'client_models.unreadMessagesCount') ?? 0;

      if (clientContacts.isEmpty) {
        hasReachedMax = true;
        if (!isRefresh) currentPage--;
      } else {
        final newContacts = clientContacts.entries.toList();

        for (var entry in newContacts) {
          if (!contactsList.any((e) => e.key == entry.key)) {
            contactsList.add(entry);
            originalContactsList.add(entry);
          }
        }
      }
    } catch (e) {
      if (!isRefresh) currentPage--;
      errorMessage = 'Failed to load contacts';
      hasError = true;
      debugPrint('Error loading contacts: $e');
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
      final responseData = await data_transport
          .get('vendor/contact/contacts-data?page=$currentPage');
      var clientContacts =
          getItemValue(responseData, 'client_models.contacts');
      unreadMsgCount =
          getItemValue(responseData, 'client_models.unreadMessagesCount') ??
              0;
      var newContacts = clientContacts.entries;

      for (var entry in newContacts) {
        if (!contactsList.any((e) => e.key == entry.key)) {
          if (labelId == null ||
              (entry.value['labels'] as List)
                  .any((label) => label['_id'] == labelId)) {
            contactsList.add(entry);
            originalContactsList.add(entry);
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
      final response = await data_transport.get(
        'vendor/contact/contacts-data/$vendorUid?way=append&request_contact=$contactUid&assigned=',
      );

      final clientContacts = getItemValue(response, 'client_models.contacts');
      final newUnreadCount = getItemValue(response, 'client_models.unreadMessagesCount') ?? 0;

      unreadMsgCount = newUnreadCount;

      for (var entry in clientContacts.entries) {
        if (!contactsList.any((e) => e.key == entry.key)) {
          contactsList.add(entry);
          originalContactsList.add(entry);
        }
      }

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
        unreadMsgCount = unreadMsgCount < 0
            ? 0
            : unreadMsgCount;
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
      BuildContext context,
      String contactUid, String lastMessageUid, String formattedTime,
      ) {
    final contactIndex =
        contactsList.indexWhere((entry) => entry.key == contactUid);
    if (contactIndex != -1) {
      final contactEntry = contactsList[contactIndex];
      final updatedContact = {
        ...contactEntry.value,
        'last_message': {
          'formatted_message_time': context.lwTranslate.justNow,
          '_uid': lastMessageUid,
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
          'formatted_message_time': context.lwTranslate.justNow,
          '_uid': lastMessageUid,
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
          'formatted_message_time': context.lwTranslate.justNow,
          '_uid': lastMessageUid,
        },
        'unread_messages_count':
            (originalEntry.value['unread_messages_count'] ?? 0) + 1,
      };
      originalContactsList.removeAt(originalContactIndex);
      originalContactsList.insert(
          0, MapEntry(contactUid, updatedOriginalContact));
    } else {
      final newOriginalContact = MapEntry(contactUid, {
        'last_message': {
          'formatted_message_time': context.lwTranslate.justNow,
          '_uid': lastMessageUid,
        },
        'unread_messages_count': 1,
      });
      originalContactsList.insert(0, newOriginalContact);
    }
    notifyListeners();
  }
}
