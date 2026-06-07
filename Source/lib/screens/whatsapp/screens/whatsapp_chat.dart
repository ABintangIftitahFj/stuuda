import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
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
  Map<String, dynamic> clientcontacts = {};
  String selectedValue = 'Option 1';
  List names = [];
  List nameinitials = [];
  List phonenumber = [];
  List msgunreadcount = [];
  Map<String, dynamic> contactValues = {};
  List<MapEntry<String, dynamic>> contactsList = [];
  late TabController _tabController;
  int? selectedLabelId;
  bool _isTabLoading = false;
  final ScrollController _scrollController = ScrollController();
  bool _showAllText = false;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_scrollListener);
    final provider = Provider.of<ContactProvider>(context, listen: false);
    provider.getUser(isRefresh: true);
    
    // Count the current vendorMessagingUsers to set correct initial length
    final filteredUsers = controller.vendorMessagingUsers
        .where((user) =>
            user['vendors__id'] == null || user['vendors__id'] == 'null')
        .toList();
    _tabController = TabController(
      length: 3 + filteredUsers.length,
      vsync: this,
    );
    _setupTabListener(provider);

    controller.getChatLabels().then((_) {
      if (mounted) {
        final currentFilteredUsers = controller.vendorMessagingUsers
            .where((user) =>
                user['vendors__id'] == null || user['vendors__id'] == 'null')
            .toList();
        int tabCount = 3 + currentFilteredUsers.length;

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
              .where((user) =>
                  user['vendors__id'] == null || user['vendors__id'] == 'null')
              .toList();
          if (_tabController.index == 0) {
            await provider.getUser(isRefresh: true, assigned: '');
          } else if (_tabController.index == 1) {
            await provider.getUser(isRefresh: true, assigned: 'to-me');
          } else if (_tabController.index == 2) {
            await provider.getUser(isRefresh: true, assigned: 'unassigned');
          } else {
            int userIndex = _tabController.index - 3;
            if (currentFilteredUsers.isNotEmpty &&
                userIndex >= 0 &&
                userIndex < currentFilteredUsers.length) {
              String assignedId = currentFilteredUsers[userIndex]['id'];
              await provider.getUser(isRefresh: true, assigned: assignedId);
            }
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
    final provider = Provider.of<ContactProvider>(context, listen: false);
    if (query.isEmpty) {
      setState(() {
        provider.contactsList = provider.originalContactsList;
      });
    } else {
      final filteredContacts =
          provider.originalContactsList.where((contactEntry) {
        final contact = contactEntry.value;
        final fullName = contact['full_name'].toLowerCase();
        final waId = contact['wa_id'].toLowerCase();
        final searchQuery = query.toLowerCase();
        return fullName.contains(searchQuery) || waId.contains(searchQuery);
      }).toList();
      setState(() {
        provider.contactsList = filteredContacts;
      });
    }
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
    return Scaffold(
      backgroundColor: app_theme.backgroundColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: Container(
          decoration: const BoxDecoration(
            color: app_theme.deepNavy,
            border: Border(
              bottom: BorderSide(
                color: Color.fromRGBO(167, 223, 255, 0.12),
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Row(
                  children: [
                    SizedBox(
                      height: 30,
                      child: CupertinoSwitch(
                        activeTrackColor: app_theme.cyanGlow,
                        inactiveTrackColor: app_theme.surfaceElevated,
                        value: _showAllText,
                        onChanged: (bool value) {
                          setState(() {
                            _showAllText = value;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: Text(
                        _showAllText ? "Show unread only" : "Show all",
                        style: const TextStyle(
                            color: app_theme.lavenderWhite,
                            fontSize: 14,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
                // Text(
                //   context.lwTranslate.all,
                // ),
              ),
              Flexible(
                child: IgnorePointer(
                  ignoring: _isTabLoading,
                  child: AppBar(
                    elevation: 0,
                    toolbarHeight: 0,
                    backgroundColor: app_theme.deepNavy,
                    bottom: TabBar(
                      tabAlignment: TabAlignment.start,
                      isScrollable: true,
                      indicatorPadding: const EdgeInsets.only(left: 0),
                      indicatorSize: TabBarIndicatorSize.tab,
                      controller: _tabController,
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: app_theme.surfaceElevated,
                        border: Border.all(
                          color: const Color.fromRGBO(73, 200, 255, 0.32),
                        ),
                      ),
                      labelColor: app_theme.lavenderWhite,
                      labelStyle: const TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 15),
                      unselectedLabelColor: _isTabLoading
                          ? app_theme.secondary
                          : app_theme.iceBlue,
                      unselectedLabelStyle: const TextStyle(
                          fontWeight: FontWeight.w400, fontSize: 14),
                      tabs: [
                        // All tab
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                context.lwTranslate.all,
                              ),
                              provider.unreadMsgCount > 0
                                  ? const SizedBox(width: 3)
                                  : Container(),
                              provider.unreadMsgCount > 0
                                  ? Container(
                                      height: 20,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: Text(
                                          provider.unreadMsgCount.toString(),
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: app_theme.black,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    )
                                  : Container(),
                            ],
                          ),
                        ),
                        // Mine tab
                        Tab(
                          text: context.lwTranslate.mineFilter,
                        ),
                        // Unassigned tab
                        Tab(
                          text: context.lwTranslate.unassignedFilter,
                        ),
                        ...controller.vendorMessagingUsers
                            .where((user) =>
                                user['vendors__id'] == null ||
                                user['vendors__id'] == 'null')
                            .map((user) {
                          // Safely find the matching contact
                          final contact = provider.contactsList
                              .cast<MapEntry<String, dynamic>?>()
                              .firstWhere(
                                (contact) =>
                                    contact?.value['assigned_users__id']
                                        ?.toString() ==
                                    user['id'],
                                orElse: () => null,
                              );

                          final unreadCount =
                              contact?.value['unread_messages_count'] ?? 0;

                          return Tab(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(user['value']),
                                if (unreadCount > 0) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    height: 20,
                                    width: 20,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      // borderRadius: BorderRadius.circular(5),
                                      color: Colors.white,
                                    ),
                                    child: Text(
                                      unreadCount.toString(),
                                      style: const TextStyle(
                                          fontSize: 10,
                                          color: app_theme.black,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                          }),
                          ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: IgnorePointer(
        ignoring: _isTabLoading,
        child: Column(
          children: [
            Expanded(
              child: TabBarView(
                physics: NeverScrollableScrollPhysics(),
                controller: _tabController,
                children: [
                  buildAllTabContent(),
                  buildAllTabContent(),
                  buildAllTabContent(),
                  ...controller.vendorMessagingUsers
                      .where((user) =>
                          user['vendors__id'] == null ||
                          user['vendors__id'] == 'null')
                      .map((user) => buildAllTabContent()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildAllTabContent() {
    final provider = Provider.of<ContactProvider>(context);

    // List<MapEntry<String, dynamic>> filteredContacts = _showAllText
    //     ? provider.originalContactsList.where((contact) =>
    // (contact.value['unread_messages_count'] ?? 0) > 0).toList()
    //     : provider.originalContactsList;

    List<MapEntry<String, dynamic>> filteredContacts = _showAllText
        ? provider.contactsList
            .where(
                (contact) => (contact.value['unread_messages_count'] ?? 0) > 0)
            .toList()
        : provider.contactsList;
    return Column(
      children: [
        const SizedBox(height: 8),
        SizedBox(
          height: 30,
          width: MediaQuery.of(context).size.width,
          child: Row(
            children: [
              GestureDetector(
                onTap: () async {
                  await provider.getUser(isRefresh: false);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Container(
                    height: 24,
                    width: 26,
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: const Color.fromRGBO(167, 223, 255, 0.18)),
                      color: app_theme.surfaceElevated,
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: const Icon(Icons.clear_outlined,
                        color: app_theme.iceBlue, size: 20),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.labelsDropdownItems.length,
                  itemBuilder: (context, index) {
                    final label = controller.labelsDropdownItems[index];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedLabelId =
                              int.tryParse(label['id'].toString()) ?? 0;
                        });
                        provider.getUserLable(
                            isRefresh: true, labelId: selectedLabelId);
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 2.0, vertical: 3),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Color(int.parse(
                                  '0xff${label['textColor'].substring(1)}')),
                              width: 0.5),
                          color: Color(int.parse(
                              '0xff${label['bgColor'].substring(1)}')),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        padding: EdgeInsets.symmetric(
                            vertical: 0.0, horizontal: 8.0),
                        child: Center(
                          child: Text(
                            label['value'] ?? '',
                            style: TextStyle(
                                color: Color(int.parse(
                                    '0xff${label['textColor'].substring(1)}')),
                                fontSize: 11.0,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            bottom: 0,
            left: 8,
            right: 8,
            top: 8,
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: app_theme.surface,
              border: Border.all(
                color: const Color.fromRGBO(167, 223, 255, 0.18),
              ),
            ),
            child: TextField(
              onChanged: search,
              readOnly: isReadonly,
              onTap: () {
                setState(() {
                  isReadonly = !isReadonly;
                });
              },
              autofocus: false,
              style: const TextStyle(
                fontSize: 12,
                color: app_theme.lavenderWhite,
              ),
              cursorColor: app_theme.cyanGlow,
              cursorHeight: 15,
              decoration: InputDecoration(
                hintText: context.lwTranslate.search,
                hintStyle:
                    const TextStyle(fontSize: 12, color: app_theme.secondary),
                suffixIcon: IconButton(
                  padding: const EdgeInsets.all(0),
                  iconSize: 18,
                  icon: const Icon(Icons.search, color: app_theme.iceBlue),
                  onPressed: () {},
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8.0,
                ),
                border: const OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: NotificationListener<ScrollNotification>(
            onNotification: (scrollNotification) {
              if (scrollNotification is ScrollEndNotification &&
                  scrollNotification.metrics.pixels ==
                      scrollNotification.metrics.maxScrollExtent &&
                  !provider.isLoadingMore &&
                  !provider.hasReachedMax) {
                provider.getUser(isRefresh: false);
                return true;
              }
              return false;
            },
            child: provider.isLoading && provider.contactsList.isEmpty
                ? Center(
                    child: Column(
                      children: [
                        LoadingAnimationWidget.hexagonDots(
                          color: app_theme.cyanGlow,
                          size: 40,
                        ),
                        const SizedBox(height: 8),
                        Text(context.lwTranslate.loading)
                      ],
                    ),
                  )
                : Consumer<ContactProvider>(
                    builder: (context, provider, child) {
                      // if (provider.contactsList.isEmpty && !provider.isLoading) {
                      //   return Align(
                      //       alignment: Alignment.center,
                      //       child: Column(
                      //         mainAxisAlignment: MainAxisAlignment.center,
                      //         children: [
                      //           Icon(Icons.error, color: Colors.green.shade300, size: 45),
                      //           Text(
                      //             context.lwTranslate.noResultFound,
                      //             style: TextStyle(
                      //               fontSize: 15,
                      //               fontWeight: FontWeight.w500,
                      //               color: Colors.grey.shade400,
                      //             ),
                      //           ),
                      //         ],
                      //       )
                      //   );
                      // }

                      if (filteredContacts.isEmpty && !provider.isLoading) {
                        return Align(
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error,
                                    color: Colors.green.shade300, size: 45),
                                // ignore: deprecated_member_use
                                Text(
                                  _showAllText
                                      ? "No Unread Message"
                                      : context.lwTranslate.noResultFound,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: app_theme.secondary,
                                  ),
                                ),
                              ],
                            ));
                      }
                      return RefreshIndicator(
                        onRefresh: _handleRefresh,
                        // onRefresh: () async {
                        //   // await provider.getUser(isRefresh: true);
                        //   // await provider.loadMockData(isRefresh: true);
                        //
                        // },
                        child: ListView.builder(
                          controller: _scrollController,
                          physics: const ClampingScrollPhysics(),
                          itemCount: filteredContacts.length +
                              // provider.contactsList.length +
                              (provider.isLoadingMore ? 1 : 0) +
                              (provider.hasReachedMax ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index >= filteredContacts.length) {
                              // if (index >= provider.contactsList.length) {
                              // return Container();
                              if (provider.isLoadingMore) {
                                return const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Center(
                                      child: CircularProgressIndicator()),
                                );
                              } else
                              // if (provider.hasReachedMax &&  _isScrollingUp) {
                              if (provider.hasReachedMax) {
                                return const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Center(
                                    child: Text(
                                      '',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                );
                              }
                            }

                            // if (index >= provider.contactsList.length && provider.isLoadingMore) {
                            //   return Padding(
                            //     padding: EdgeInsets.symmetric(vertical: 16),
                            //     child: Center(
                            //       child: LoadingAnimationWidget.hexagonDots(
                            //         color: Colors.grey,
                            //         size: 40,
                            //       ),
                            //     ),
                            //   );
                            // }
                            // final contactEntry = provider.contactsList[index];

                            final contactEntry = filteredContacts[index];
                            final contact = contactEntry.value;
                            int messageCount =
                                contact['unread_messages_count'] ?? 0;

                            return GestureDetector(
                              onTap: () {
                                provider.updateMessageCountToZero(
                                    contact['_uid'].toString());
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ChatboxScreen(contactdetails: contact),
                                  ),
                                ).then((_) {
                                  provider.updateMessageCountToZero(
                                      contact['_uid']);
                                });
                              },
                              child: Column(
                                children: [
                                  ListTile(
                                    minVerticalPadding: 10,
                                    leading: CircleAvatar(
                                      backgroundColor:
                                          app_theme.surfaceElevated,
                                      child: Text(
                                        contact['name_initials'] ?? "U",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: app_theme.iceBlue,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    title: Row(
                                      children: [
                                        Expanded(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  contact['full_name'] ??
                                                      "Unknown",
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    color:
                                                        app_theme.lavenderWhite,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Wrap(
                                                  spacing: -15,
                                                  runSpacing: 2,
                                                  children: (contact['labels']
                                                              as List<dynamic>?)
                                                          ?.map((label) {
                                                        return Stack(
                                                          alignment:
                                                              Alignment.center,
                                                          children: [
                                                            Transform.rotate(
                                                              angle: -135 *
                                                                  (3.1415926535 /
                                                                      180), // Convert degrees to radians
                                                              child: Icon(
                                                                Icons.label,
                                                                color: Color(int.parse(label[
                                                                        'bg_color']
                                                                    .replaceFirst(
                                                                        '#',
                                                                        '0xff'))),
                                                                size: 30,
                                                                shadows: [
                                                                  BoxShadow(
                                                                    color: Colors
                                                                        .grey
                                                                        .withValues(
                                                                            alpha:
                                                                                0.3),
                                                                    blurRadius:
                                                                        1,
                                                                    spreadRadius:
                                                                        3,
                                                                    offset:
                                                                        Offset(
                                                                            3,
                                                                            3),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            Positioned(
                                                              left: 10,
                                                              top: 10,
                                                              child: Transform
                                                                  .rotate(
                                                                angle: -135 *
                                                                    (3.1415926535 /
                                                                        180),
                                                                child: Icon(
                                                                  Icons.circle,
                                                                  color: Color(int.parse(label[
                                                                          'text_color']
                                                                      .replaceFirst(
                                                                          '#',
                                                                          '0xff'))),
                                                                  size: 6,
                                                                  shadows: [
                                                                    BoxShadow(
                                                                      color: Colors
                                                                          .grey
                                                                          .withValues(
                                                                              alpha: 0.3),
                                                                      blurRadius:
                                                                          2,
                                                                      spreadRadius:
                                                                          1,
                                                                      offset:
                                                                          Offset(
                                                                              1,
                                                                              1),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        );
                                                      }).toList() ??
                                                      [],
                                                ),
                                              ),
                                              // Your label widgets here
                                            ],
                                          ),
                                        ),
                                        if (messageCount > 0)
                                          CircleAvatar(
                                            radius: 10,
                                            backgroundColor:
                                                app_theme.surfaceElevated,
                                            child: Text(
                                              messageCount.toString(),
                                              style: const TextStyle(
                                                  fontSize: 8,
                                                  color: app_theme.cyanGlow,
                                                  fontWeight: FontWeight.w900),
                                            ),
                                          ),
                                      ],
                                    ),
                                    subtitle: Text(
                                        contact['wa_id'] ?? "Unknown",
                                        style: const TextStyle(
                                            fontSize: 11,
                                            color: app_theme.secondary)),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: Align(
                                        alignment: Alignment.topRight,
                                        child: Text(
                                          (contact['last_message']?[
                                                      'formatted_message_time'] ??
                                                  "")
                                              .toString(),
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: app_theme.secondary,
                                          ),
                                        )),
                                  ),
                                  const Divider(
                                      height: 1,
                                      color:
                                          Color.fromRGBO(167, 223, 255, 0.10)),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        )
      ],
    );
  }

  Future<void> _handleRefresh() async {
    final provider = Provider.of<ContactProvider>(context, listen: false);
    if (_tabController.index == 0) {
      await provider.getUser(isRefresh: true, assigned: '');
    } else if (_tabController.index == 1) {
      await provider.getUser(isRefresh: true, assigned: 'to-me');
    } else if (_tabController.index == 2) {
      await provider.getUser(isRefresh: true, assigned: 'unassigned');
    } else {
      int userIndex = _tabController.index - 3;
      final filteredUsers = controller.vendorMessagingUsers
          .where((user) =>
              user['vendors__id'] == null || user['vendors__id'] == 'null')
          .toList();
      if (filteredUsers.isNotEmpty &&
          userIndex >= 0 &&
          userIndex < filteredUsers.length) {
        String assignedId = filteredUsers[userIndex]['id'];
        await provider.getUser(isRefresh: true, assigned: assignedId);
      }
    }
  }

  @override
  bool get wantKeepAlive => true;
}
