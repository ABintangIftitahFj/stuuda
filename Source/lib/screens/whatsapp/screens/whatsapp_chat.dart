import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:stundaa/model/contact_summary.dart';
import 'package:stundaa/provider/contacts_provider.dart';
import 'package:stundaa/services/utils.dart';
import 'package:stundaa/screens/whatsapp/screens/chatbox.dart';
import 'package:flutter/material.dart';
import 'package:stundaa/model/user.dart';
import 'package:stundaa/support/app_theme.dart' as app_theme;
import 'package:stundaa/screens/whatsapp/controller/user_info_controller.dart';

class WhatsAppChat extends StatefulWidget {
  const WhatsAppChat({super.key});

  @override
  State<WhatsAppChat> createState() => _WhatsAppChatState();
}

class _WhatsAppChatState extends State<WhatsAppChat>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  final Userinfocontroller controller = Get.put(Userinfocontroller());
  TextEditingController textController = TextEditingController();
  List<UserDetails> filteredItems = [];
  bool isLoading = true;
  bool isLoadingMore = false;
  bool isSelected = false;
  bool isReadonly = false;
  bool isReadChat = false;
  List<String> tabs = ['Unread'];
  String selectedValue = 'Option 1';
  List names = [];
  List nameinitials = [];
  List phonenumber = [];
  List msgunreadcount = [];
  late TabController _tabController;
  bool _isTabLoading = false;
  final ScrollController _scrollController = ScrollController();
  bool _showAllText = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_scrollListener);
    final provider = Provider.of<ContactProvider>(context, listen: false);
    provider.getUser(isRefresh: true, assigned: '');

    // Count the current vendorMessagingUsers to set correct initial length
    final filteredUsers = controller.vendorMessagingUsers
        .where((user) => user.vendorId == 'null')
        .toList();
    _tabController = TabController(
      length: 4 + filteredUsers.length + provider.pockets.length + 1,
      vsync: this,
      initialIndex: 1, // Default to "All" instead of "Pinned"
    );
    _setupTabListener(provider);

    controller.getChatLabels().then((_) {
      if (mounted) {
        final currentFilteredUsers = controller.vendorMessagingUsers
            .where((user) => user.vendorId == 'null')
            .toList();
        int tabCount =
            4 + currentFilteredUsers.length + provider.pockets.length + 1;

        if (_tabController.length != tabCount) {
          final oldController = _tabController;
          _tabController = TabController(
            length: tabCount,
            vsync: this,
            initialIndex: oldController.index.clamp(0, tabCount - 1),
          );
          oldController.dispose();
          _setupTabListener(provider);
          setState(() {});
        }
      }
    });
  }

  void _setupTabListener(ContactProvider provider) {
    _tabController.addListener(() async {
      if (_tabController.indexIsChanging && !_isTabLoading) {
        setState(() {
          _isTabLoading = true;
          _showAllText = false;
        });
        try {
          final currentFilteredUsers = controller.vendorMessagingUsers
              .where((user) => user.vendorId == 'null')
              .toList();

          int index = _tabController.index;
          if (index == 0) {
            // Pinned
          } else if (index == 1) {
            await provider.getUser(isRefresh: true, assigned: '');
          } else if (index == 2) {
            await provider.getUser(isRefresh: true, assigned: 'to-me');
          } else if (index == 3) {
            await provider.getUser(isRefresh: true, assigned: 'unassigned');
          } else if (index < 4 + currentFilteredUsers.length) {
            int userIndex = index - 4;
            String assignedId = currentFilteredUsers[userIndex].id;
            await provider.getUser(isRefresh: true, assigned: assignedId);
          } else {
            // Pocket tabs - local filtering only
          }
        } finally {
          if (mounted) {
            setState(() => _isTabLoading = false);
          }
        }
      }
    });
  }

  void search(String query) {
    setState(() => _searchQuery = query);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    //
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final provider = Provider.of<ContactProvider>(context);
    return Column(
      children: [
        // Toggle Section - Improved Visual Hierarchy & Spacing
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0B1627),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Row(
              children: [
                CupertinoSwitch(
                  activeTrackColor: app_theme.primary,
                  value: _showAllText,
                  onChanged: (value) => setState(() => _showAllText = value),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Show All Chats",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Include archived and old conversations",
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Custom Tab Bar - Modern Styling & Better Tap Area
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            dividerColor: Colors.transparent,
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(width: 3, color: app_theme.primary),
              insets: const EdgeInsets.symmetric(horizontal: 16),
            ),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white38,
            labelStyle:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            unselectedLabelStyle:
                const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            tabs: [
              Tab(
                  child: Row(children: [
                const Icon(CupertinoIcons.pin_fill, size: 18),
                const SizedBox(width: 8),
                const Text("Pinned")
              ])),
              Tab(
                  child: Row(children: [
                const Icon(CupertinoIcons.chat_bubble_2, size: 18),
                const SizedBox(width: 8),
                Text(context.lwTranslate.all)
              ])),
              Tab(
                  child: Row(children: [
                const Icon(CupertinoIcons.person, size: 18),
                const SizedBox(width: 8),
                Text(context.lwTranslate.mineFilter)
              ])),
              Tab(
                  child: Row(children: [
                const Icon(CupertinoIcons.person_2, size: 18),
                const SizedBox(width: 8),
                Text(context.lwTranslate.unassignedFilter)
              ])),
              ...controller.vendorMessagingUsers
                  .where((user) => user.vendorId == 'null')
                  .map((user) => Tab(
                        child: Row(
                          children: [
                            const Icon(CupertinoIcons.tag, size: 18),
                            const SizedBox(width: 8),
                            Text(user.name),
                          ],
                        ),
                      )),
              ...provider.pockets.keys.map((pocketName) => Tab(
                    child: Row(
                      children: [
                        const Icon(CupertinoIcons.folder, size: 18),
                        const SizedBox(width: 8),
                        Text(pocketName),
                      ],
                    ),
                  )),
              Tab(
                child: IconButton(
                  onPressed: _showCreatePocketDialog,
                  icon: const Icon(CupertinoIcons.plus_circle,
                      size: 20, color: app_theme.primary),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
            ],
          ),
        ),

        // Search Bar - Touch-friendly with 48dp height minimum
        Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            height: 52, // Comfortable touch target
            decoration: BoxDecoration(
              color: const Color(0xFF0B1627),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: TextField(
              onChanged: search,
              textAlignVertical: TextAlignVertical.center,
              style: const TextStyle(color: Colors.white, fontSize: 15),
              decoration: InputDecoration(
                hintText: "Search conversations...",
                hintStyle: const TextStyle(color: Colors.white24),
                prefixIcon: const Icon(CupertinoIcons.search,
                    color: Colors.white38, size: 20),
                suffixIcon: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(CupertinoIcons.slider_horizontal_3,
                      color: Colors.white70, size: 16),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
        ),

        Expanded(
          child: TabBarView(
            physics: const BouncingScrollPhysics(),
            controller: _tabController,
            children: [
              buildPinnedTabContent(),
              buildAllTabContent(),
              buildAllTabContent(assigned: 'to-me'),
              buildAllTabContent(assigned: 'unassigned'),
              ...controller.vendorMessagingUsers
                  .where((user) => user.vendorId == 'null')
                  .map((user) => buildAllTabContent(assigned: user.id)),
              ...provider.pockets.keys
                  .map((pocketName) => buildPocketTabContent(pocketName)),
              const Center(
                  child: Text("Create new pocket",
                      style: TextStyle(color: Colors.white54))),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildPocketTabContent(String pocketName) {
    final provider = Provider.of<ContactProvider>(context);
    List<ContactSummary> pocketContacts =
        provider.getPocketContacts(pocketName);

    if (pocketContacts.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Pocket is Empty",
                style: TextStyle(color: Colors.white54, fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => provider.deletePocket(pocketName),
                style:
                    ElevatedButton.styleFrom(backgroundColor: app_theme.error),
                child: const Text("Delete Pocket"),
              ),
            ],
          ),
        ),
      );
    }

    return buildContactList(pocketContacts, currentPocketName: pocketName);
  }

  void _showCreatePocketDialog() {
    final TextEditingController pocketNameController = TextEditingController();
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text("New Pocket"),
        content: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: CupertinoTextField(
            controller: pocketNameController,
            placeholder: "Pocket name (e.g. Work, College)",
            style: const TextStyle(color: Colors.white),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text("Create"),
            onPressed: () {
              final name = pocketNameController.text.trim();
              if (name.isNotEmpty) {
                Provider.of<ContactProvider>(context, listen: false)
                    .createPocket(name);
                Navigator.pop(context);
                _updateTabController();
              }
            },
          ),
        ],
      ),
    );
  }

  void _updateTabController() {
    final provider = Provider.of<ContactProvider>(context, listen: false);
    final filteredUsers = controller.vendorMessagingUsers
        .where((user) => user.vendorId == 'null')
        .toList();
    int tabCount = 4 + filteredUsers.length + provider.pockets.length + 1;

    final oldController = _tabController;
    _tabController = TabController(
      length: tabCount,
      vsync: this,
      initialIndex: oldController.index.clamp(0, tabCount - 1),
    );
    oldController.dispose();
    _setupTabListener(provider);
    setState(() {});
  }

  Widget buildPinnedTabContent() {
    final provider = Provider.of<ContactProvider>(context);
    List<ContactSummary> pinnedContacts = provider.pinnedContacts;

    if (pinnedContacts.isEmpty) {
      return const Center(
        child: Text(
          "No Pinned Chats",
          style: TextStyle(color: Colors.white54, fontSize: 16),
        ),
      );
    }

    return buildContactList(pinnedContacts);
  }

  List<ContactSummary> _filterContactsByQuery(List<ContactSummary> contacts) {
    final query = _searchQuery.trim();
    if (query.isEmpty) return contacts;

    return contacts.where((contact) => contact.matchesQuery(query)).toList();
  }

  Widget buildAllTabContent({String assigned = ''}) {
    final provider = Provider.of<ContactProvider>(context);
    final contacts = provider.contactSummariesForAssigned(assigned);
    List<ContactSummary> filteredContacts = _showAllText
        ? contacts.where((contact) => contact.unreadMessagesCount > 0).toList()
        : contacts;
    filteredContacts = _filterContactsByQuery(filteredContacts);

    if (filteredContacts.isEmpty && provider.isLoadingAssigned(assigned)) {
      return const Center(
        child: CupertinoActivityIndicator(radius: 14),
      );
    }

    if (filteredContacts.isEmpty && !provider.isLoading) {
      return Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: app_theme.primary.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(CupertinoIcons.chat_bubble_2_fill,
                    size: 64, color: app_theme.primary.withValues(alpha: 0.15)),
              ),
              const SizedBox(height: 32),
              const Text(
                "No Conversations Found",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                "Try searching for a name or phone number,\nor check your filters.",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 15,
                    height: 1.5),
              ),
            ],
          ),
        ),
      );
    }

    return buildContactList(filteredContacts);
  }

  Widget buildContactList(List<ContactSummary> filteredContacts,
      {String? currentPocketName}) {
    final provider = Provider.of<ContactProvider>(context, listen: false);
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: filteredContacts.length,
      separatorBuilder: (context, index) => Divider(
          height: 1, indent: 80, color: Colors.white.withValues(alpha: 0.05)),
      itemBuilder: (context, index) {
        final contact = filteredContacts[index];
        final int unreadCount = contact.unreadMessagesCount;
        final bool isPinned = provider.isPinned(contact.uid);

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatboxScreen(contact: contact),
                ),
              );
            },
            onLongPress: () {
              _showPinOptions(context, contact, isPinned,
                  currentPocketName: currentPocketName);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Avatar with status indicator
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: const Color(0xFF1A263D),
                        child: Text(contact.nameInitials,
                            style: const TextStyle(
                                color: app_theme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 18)),
                      ),
                      if (unreadCount > 0)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: app_theme.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: const Color(0xFF02040A), width: 2),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      "${contact.displayName} - ${contact.waId}",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15),
                                    ),
                                  ),
                                  if (isPinned) ...[
                                    const SizedBox(width: 6),
                                    const Flexible(
                                      child: Icon(CupertinoIcons.pin_fill,
                                          size: 14, color: app_theme.primary),
                                    ),
                                  ],
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 1.5),
                                    decoration: BoxDecoration(
                                      color: contact.isServiceWindowActive
                                          ? Colors.green.withValues(alpha: 0.15)
                                          : Colors.orange.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                        color: contact.isServiceWindowActive
                                            ? Colors.green.withValues(alpha: 0.3)
                                            : Colors.orange.withValues(alpha: 0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          CupertinoIcons.time,
                                          size: 9,
                                          color: contact.isServiceWindowActive
                                              ? Colors.green
                                              : Colors.orange,
                                        ),
                                        const SizedBox(width: 2.5),
                                        Text(
                                          contact.isServiceWindowActive
                                              ? "24h"
                                              : "Expired",
                                          style: TextStyle(
                                            color: contact.isServiceWindowActive
                                                ? Colors.green
                                                : Colors.orange,
                                            fontSize: 8.5,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                contact.lastMessageText,
                                style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.5),
                                    fontSize: 13,
                                    fontWeight: unreadCount > 0
                                        ? FontWeight.w600
                                        : FontWeight.normal),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (unreadCount > 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: app_theme.primary,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      unreadCount.toString(),
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                const SizedBox(width: 6),
                                Text(
                                  contact.lastMessageTime,
                                  style: TextStyle(
                                      color: unreadCount > 0
                                          ? app_theme.primary
                                          : Colors.white38,
                                      fontSize: 11),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showPinOptions(
      BuildContext context, ContactSummary contact, bool isPinned,
      {String? currentPocketName}) {
    final provider = Provider.of<ContactProvider>(context, listen: false);
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text(contact.displayName),
        message: Text(isPinned ? "Unpin this chat?" : "Pin this chat?"),
        actions: [
          CupertinoActionSheetAction(
            child: Text(isPinned ? "Unpin" : "Pin"),
            onPressed: () {
              provider.togglePin(contact.uid);
              Navigator.pop(context);
            },
          ),
          if (currentPocketName != null) ...[
            CupertinoActionSheetAction(
              child: const Text("Remove from Pocket"),
              onPressed: () {
                Navigator.pop(context);
                provider.removeFromPocket(currentPocketName, contact.uid);
              },
            ),
            if (provider.pockets.length > 1)
              CupertinoActionSheetAction(
                child: const Text("Move to another Pocket"),
                onPressed: () {
                  Navigator.pop(context);
                  _showMovePocketChooser(
                      context, contact, currentPocketName, provider);
                },
              ),
          ] else ...[
            if (provider.pockets.isNotEmpty)
              CupertinoActionSheetAction(
                child: const Text("Add to Pocket"),
                onPressed: () {
                  Navigator.pop(context);
                  _showPocketChooser(context, contact, provider);
                },
              ),
          ],
        ],
        cancelButton: CupertinoActionSheetAction(
          child: const Text("Cancel"),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _showPocketChooser(
      BuildContext context, ContactSummary contact, ContactProvider provider) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text("Choose Pocket"),
        message: const Text("Select a pocket to add this chat to"),
        actions: [
          ...provider.pockets.keys.map((pocketName) {
            final isIn = provider.isInPocket(pocketName, contact.uid);
            return CupertinoActionSheetAction(
              child: Text(isIn ? "✓ $pocketName" : pocketName),
              onPressed: () {
                provider.toggleInPocket(pocketName, contact.uid);
                Navigator.pop(context);
              },
            );
          }),
          if (provider.pockets.keys
              .any((name) => provider.isInPocket(name, contact.uid)))
            CupertinoActionSheetAction(
              isDestructiveAction: true,
              child: const Text("Remove from All Pockets"),
              onPressed: () {
                provider.clearFromAllPockets(contact.uid);
                Navigator.pop(context);
              },
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: const Text("Cancel"),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  void _showMovePocketChooser(BuildContext context, ContactSummary contact,
      String currentPocketName, ContactProvider provider) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text("Move to Pocket"),
        message: Text("Select a new pocket for ${contact.displayName}"),
        actions: [
          ...provider.pockets.keys
              .where((pocketName) => pocketName != currentPocketName)
              .map((pocketName) {
            return CupertinoActionSheetAction(
              child: Text(pocketName),
              onPressed: () {
                Navigator.pop(context);
                provider.moveContactPocket(
                    currentPocketName, pocketName, contact.uid);
              },
            );
          }),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: const Text("Cancel"),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
