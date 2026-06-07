import 'package:flutter/cupertino.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import 'package:stundaa/common/widgets/common.dart';
import 'package:stundaa/components/dropdown.dart';
import 'package:stundaa/provider/contacts_provider.dart';
import 'package:stundaa/services/utils.dart';
import 'package:stundaa/screens/whatsapp/controller/chatbox_controller.dart';
import 'package:stundaa/support/app_theme.dart' as app_theme;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stundaa/screens/whatsapp/controller/user_info_controller.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:stundaa/services/data_transport.dart' as data_transport;
import 'package:stundaa/services/whatsapp_call_service.dart';

class UserInfo extends StatefulWidget {
  final String username;
  final String? userId;
  final bool? enableAiBot;
  final bool? enableReplyBot;
  final List<int>? assignedLabelIds;
  const UserInfo(
      {super.key,
      required this.username,
      this.userId,
      this.assignedLabelIds,
      this.enableAiBot,
      this.enableReplyBot});

  @override
  State<UserInfo> createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfo> with TickerProviderStateMixin {
  late String holduser;
  final _formKey = GlobalKey<FormState>();
  final Userinfocontroller controller = Get.put(Userinfocontroller());
  final ChatboxController chatController = Get.put(ChatboxController());
  TextEditingController textController = TextEditingController();
  Color color1 = Colors.white;
  Color color2 = Colors.black;
  String? userId = "";
  String? selectedUserUid = "";
  List<String> selectedLabelIds = [];
  bool isEdit = false;
  String? assignUserId;
  bool isAssignUserLoader = false;
  bool isAssignLableLoader = false;
  bool isCheckedAI = false;
  bool isCheckedReply = false;
  @override
  void initState() {
    super.initState();
    isCheckedAI = widget.enableAiBot ?? false;
    isCheckedReply = widget.enableReplyBot ?? false;
    holduser = widget.username;
    setState(() {
      userId = widget.userId;
      controller.setUserId(userId!);
      controller.getUserInfo();
      controller.getChatLabels();
    });
  }

  Future<void> updateNotesApi() async {
    final Map<String, dynamic> payload = {
      'contactIdOrUid': userId,
      'contact_notes': controller.notesController.text.trim(),
    };
    try {
      await data_transport.post(
        'vendor/whatsapp/contact/chat/update-notes',
        inputData: payload,
        context: context,
        onSuccess: (responseData) async {},
        onFailed: (responseData) {},
      );
    } catch (e) {
      pr("Update notes failed: $e");
    } finally {
      setState(() {
        isEdit = false;
      });
    }
  }

  Future<void> addLableApi({
    required String label,
    required Color textColor,
    required Color bgColor,
  }) async {
    String toHex(Color color) {
      return '#${color.toARGB32().toRadixString(16).substring(2, 8)}';
    }

    final Map<String, dynamic> payload = {
      'title': label,
      'text_color': toHex(textColor),
      'bg_color': toHex(bgColor),
    };
    try {
      await data_transport.post(
        'vendor/whatsapp/contact/create-label',
        inputData: payload,
        context: context,
        onSuccess: (responseData) async {
          controller.getChatLabels();
        },
        onFailed: (responseData) {},
      );
    } catch (e) {
      pr("Add label failed: $e");
    }
  }

  Future<void> editLableApi({
    required String label,
    required String uid,
    required Color textColor,
    required Color bgColor,
  }) async {
    String toHex(Color color) {
      return '#${color.toARGB32().toRadixString(16).substring(2, 8)}';
    }

    final Map<String, dynamic> payload = {
      'labelUid': uid,
      'title': label,
      'text_color': toHex(textColor),
      'bg_color': toHex(bgColor),
    };

    try {
      await data_transport.post(
        'vendor/whatsapp/contact/chat/edit-label',
        inputData: payload,
        context: context,
        onSuccess: (responseData) async {
          controller.getChatLabels();
        },
        onFailed: (responseData) {},
      );
    } catch (e) {
      pr("Edit label failed: $e");
    }
  }

  Future<void> deleteLableApi({
    required String uid,
  }) async {
    try {
      await data_transport.post(
        'vendor/whatsapp/contact/chat/delete-label/$uid',
        inputData: {},
        context: context,
        onSuccess: (responseData) async {
          controller.getChatLabels();
          Navigator.pop(context);
        },
        onFailed: (responseData) {},
      );
    } catch (e) {
      pr("Delete label failed: $e");
    }
  }

  Future<void> assignUserApi(String? selectedUserUid) async {
    if (selectedUserUid == null || selectedUserUid.isEmpty) return;
    final Map<String, dynamic> payload = {
      'contactIdOrUid': userId,
      'assigned_users_uid': selectedUserUid,
      'enable_ai_bot': isCheckedAI,
      'enable_reply_bot': isCheckedReply,
    };
    try {
      setState(() {
        isAssignUserLoader = true;
      });
      await data_transport.post(
        'vendor/whatsapp/contact/chat/assign-user',
        inputData: payload,
        context: context,
        onSuccess: (responseData) async {
          setState(() {
            isAssignUserLoader = false;
            chatController.getUserChat();
          });
        },
        onFailed: (responseData) {
          setState(() {
            isAssignUserLoader = false;
          });
        },
      );
    } catch (e) {
      setState(() {
        isAssignUserLoader = false;
      });
    }
  }

  Future<void> assignLableApi(List<String> selectedLabelIds) async {
    final Map<String, dynamic> payload = {
      'contactUid': userId,
      'contact_labels': selectedLabelIds,
    };
    try {
      setState(() {
        isAssignLableLoader = true;
      });
      await data_transport.post(
        'vendor/whatsapp/contact/chat/assign-labels',
        inputData: payload,
        context: context,
        onSuccess: (responseData) async {
          setState(() {
            isAssignLableLoader = false;
          });
        },
        onFailed: (responseData) {
          setState(() {
            isAssignLableLoader = false;
          });
        },
      );
    } catch (e) {
      setState(() {
        isAssignLableLoader = false;
      });
    } finally {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: app_theme.backgroundColor,
      appBar: innerAppBar(
        title: context.lwTranslate.userInformation,
        context: context,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Profile Card
            _buildProfileCard(context),
            SizedBox(height: 24),

            // User Details Section
            _buildUserDetailsSection(context),
            SizedBox(height: 24),

            // Assign Team and Labels Section
            _buildAssignSection(context),
            SizedBox(height: 24),

            // Notes Section
            _buildNotesSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    return Container(
      decoration: app_theme.insetPanelDecoration(radius: 24).copyWith(
        gradient: app_theme.cardGradient,
      ),
      child: Column(
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              gradient: app_theme.primaryGradient,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Center(
              child: Obx(() => Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: app_theme.surfaceMuted,
                        child: Icon(
                          CupertinoIcons.person,
                          size: 50,
                          color: app_theme.iceBlue,
                        ),
                      ),
                      if (controller.isLoading.value)
                        Positioned.fill(
                          child: Center(
                            child: CircularProgressIndicator(
                              valueColor:
                                  const AlwaysStoppedAnimation(app_theme.black),
                            ),
                          ),
                        ),
                    ],
                  )),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Obx(() => Column(
                  children: [
                    Text(
                      controller.firstName.value.isNotEmpty
                          ? controller.firstName.value
                          : context.lwTranslate.loading,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: app_theme.lavenderWhite,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      controller.waId.value.isNotEmpty
                          ? controller.waId.value
                          : '',
                      style: const TextStyle(
                        fontSize: 16,
                        color: app_theme.secondary,
                      ),
                    ),
                  ],
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildUserDetailsSection(BuildContext context) {
    return Container(
      decoration: app_theme.insetPanelDecoration(radius: 24),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.lwTranslate.userInformation,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: app_theme.primary,
              ),
            ),
            SizedBox(height: 16),
            Obx(() {
              if (controller.isLoading.value) {
                return Center(
                  child: LoadingAnimationWidget.hexagonDots(
                    color: app_theme.primary,
                    size: 40,
                  ),
                );
              }
              return Column(
                children: [
                  _buildDetailItem(
                    icon: CupertinoIcons.person,
                    label: context.lwTranslate.name,
                    value: controller.firstName.value.isNotEmpty
                        ? controller.firstName.value
                        : context.lwTranslate.loading,
                  ),
                  const Divider(
                      height: 24, color: Color.fromRGBO(167, 223, 255, 0.12)),
                  _buildDetailItem(
                    icon: CupertinoIcons.phone,
                    label: context.lwTranslate.phone,
                    value: controller.waId.value.isNotEmpty
                        ? controller.waId.value
                        : context.lwTranslate.loading,
                    onTap: () {
                      if (userId != null) {
                        WhatsAppCallService.startCall(context, userId!);
                      }
                    },
                  ),
                  const Divider(
                      height: 24, color: Color.fromRGBO(167, 223, 255, 0.12)),
                  _buildDetailItem(
                    icon: CupertinoIcons.mail,
                    label: context.lwTranslate.email,
                    value: controller.emailV.value.isNotEmpty
                        ? controller.emailV.value
                        : "...",
                  ),
                  const Divider(
                      height: 24, color: Color.fromRGBO(167, 223, 255, 0.12)),
                  _buildDetailItem(
                    icon: CupertinoIcons.globe,
                    label: context.lwTranslate.language,
                    value: controller.languageCode.value.isNotEmpty
                        ? controller.languageCode.value
                        : "...",
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(
      {required IconData icon,
      required String label,
      required String value,
      VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: app_theme.surfaceMuted,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 20, color: app_theme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: app_theme.secondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: app_theme.lavenderWhite,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignSection(BuildContext context) {
    final provider = Provider.of<ContactProvider>(context, listen: false);
    return Card(
      color: app_theme.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(
          color: Color.fromRGBO(167, 223, 255, 0.16),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.lwTranslate.assignTeamAndLables,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: app_theme.primary,
              ),
            ),
            SizedBox(height: 16),

            // Assign Team Member
            _buildSectionTitle(context.lwTranslate.assignTeamMember),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Checkbox(
                        value: isCheckedAI,
                        activeColor: app_theme.cyanGlow,
                        onChanged: (bool? value) {
                          setState(() {
                            isCheckedAI = value ?? false;
                          });
                        },
                      ),
                      Flexible(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              isCheckedAI = !isCheckedAI;
                            });
                          },
                          child: Text(
                            context.lwTranslate.enableAIbot,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: app_theme.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Checkbox(
                        value: isCheckedReply,
                        activeColor: app_theme.cyanGlow,
                        onChanged: (bool? value) {
                          setState(() {
                            isCheckedReply = value ?? false;
                          });
                        },
                      ),
                      Flexible(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              isCheckedReply = !isCheckedReply;
                            });
                          },
                          child: Text(
                            context.lwTranslate.enableReplybot,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: app_theme.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),

            Obx(() {
              if (controller.isLoading.value) {
                return Center(child: CircularProgressIndicator());
              }
              return CustomDropdown(
                labelText: context.lwTranslate.teamMember,
                onChanged: (value) {
                  setState(() {
                    if (value == 'no_one') {
                      controller.assignedUserId.value = 'no_one';
                      controller.selectedUserName.value =
                          context.lwTranslate.unassignedFilter;
                      selectedUserUid = null;
                    } else {
                      controller.assignedUserId.value = value!;
                      final selectedUser = controller.vendorMessagingUsers
                          .firstWhereOrNull((user) => user['id'] == value);
                      controller.selectedUserName.value =
                          selectedUser?['value'] ?? '';
                      selectedUserUid = selectedUser?['_uid'];
                    }
                  });
                },
                listItems: [
                  {
                    'id': 'no_one',
                    'value': context.lwTranslate.unassignedFilter
                  },
                  ...controller.vendorMessagingUsers,
                ],
                optionKeyName: 'id',
                optionLabelName: 'value',
                value: controller.assignedUserId.value.isEmpty
                    ? 'no_one'
                    : controller.assignedUserId.value,
                padding: EdgeInsets.zero,
              );
            }),
            SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: app_theme.cyanGlow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    if (controller.assignedUserId.value.isEmpty ||
                        controller.assignedUserId.value == 'no_one') {
                      assignUserApi('no_one');
                      return;
                    }

                    if (selectedUserUid == null || selectedUserUid!.isEmpty) {
                      final selectedUser = controller.vendorMessagingUsers
                          .firstWhereOrNull((user) =>
                              user['id'] == controller.assignedUserId.value);
                      if (selectedUser != null) {
                        setState(() {
                          selectedUserUid = selectedUser['_uid']?.toString();
                        });
                      }
                    }
                    if (selectedUserUid != null &&
                        selectedUserUid!.isNotEmpty) {
                      assignUserApi(selectedUserUid!);
                    } else {
                      assignUserApi('no_one');
                    }
                  },
                  child: isAssignUserLoader
                      ? SizedBox(
                          height: 15,
                          width: 15,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ))
                      : Text(
                          context.lwTranslate.save,
                          style: TextStyle(color: Colors.white),
                        )),
            ),
            SizedBox(height: 24),

            // Assign Labels
            Row(
              children: [
                _buildSectionTitle(context.lwTranslate.lablesTags),
                SizedBox(
                  width: 8,
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.settings,
                      color: Colors.blue.shade800, size: 17),
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem<String>(
                      value: 'add',
                      child: Text(context.lwTranslate.addLabel),
                    ),
                    PopupMenuItem<String>(
                      value: 'edit',
                      child: Text(context.lwTranslate.editLabel),
                    ),
                  ],
                  onSelected: (String value) {
                    if (value == 'add') {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return StatefulBuilder(
                            builder: (context, setState) {
                              return AlertDialog(
                                insetPadding: EdgeInsets.all(5),
                                title: Text(context.lwTranslate.addLabel,
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold)),
                                content: Form(
                                  key:
                                      _formKey, // Add this to your widget's state: final _formKey = GlobalKey<FormState>();
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.8,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey.shade300,
                                          width: 1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: EdgeInsets.all(8),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(context.lwTranslate.newLabel,
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.grey[700])),
                                        SizedBox(height: 12),

                                        // Label name text field with validation
                                        TextFormField(
                                          controller: textController,
                                          decoration: InputDecoration(
                                            hintText:
                                                context.lwTranslate.newLabel,
                                            hintStyle: TextStyle(
                                                color: Colors.grey.shade400,
                                                fontSize: 14),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 12),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.grey.shade300),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            errorStyle: TextStyle(fontSize: 12),
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return context
                                                  .lwTranslate.pleaseEnterLabel;
                                            }
                                            return null;
                                          },
                                        ),

                                        SizedBox(height: 16),

                                        // Color selection section (no validation)
                                        Text(context.lwTranslate.labelColors,
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.grey[700])),
                                        SizedBox(height: 8),

                                        Row(
                                          children: [
                                            // Text Color
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                      context.lwTranslate
                                                          .textColors,
                                                      style: TextStyle(
                                                          fontSize: 14)),
                                                  SizedBox(height: 4),
                                                  _buildColorSquareWithLabel(
                                                      color1, "Text", () async {
                                                    final selectedColor =
                                                        await showColorPicker(
                                                            context,
                                                            color1,
                                                            context.lwTranslate
                                                                .selectTextColors,
                                                            setState);
                                                    if (selectedColor != null) {
                                                      setState(() => color1 =
                                                          selectedColor);
                                                    }
                                                  }),
                                                ],
                                              ),
                                            ),

                                            SizedBox(width: 12),

                                            // Background Color
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                      context.lwTranslate
                                                          .backgroundColor,
                                                      style: TextStyle(
                                                          fontSize: 14)),
                                                  SizedBox(height: 4),
                                                  _buildColorSquareWithLabel(
                                                      color2, "BG", () async {
                                                    final selectedColor =
                                                        await showColorPicker(
                                                            context,
                                                            color2,
                                                            context.lwTranslate
                                                                .selectBackgroundColor,
                                                            setState);
                                                    if (selectedColor != null) {
                                                      setState(() => color2 =
                                                          selectedColor);
                                                    }
                                                  }),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                actions: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        child: Text(context.lwTranslate.cancel,
                                            style: TextStyle(
                                                color: Colors.grey[700])),
                                        onPressed: () {
                                          textController.clear();
                                          Navigator.of(context).pop();
                                          setState(() {
                                            color1 = Colors.white;
                                            color2 = Colors.black;
                                          });
                                        },
                                      ),
                                      SizedBox(width: 12),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: app_theme.primary,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 24, vertical: 10),
                                        ),
                                        child: Text(context.lwTranslate.create,
                                            style:
                                                TextStyle(color: Colors.white)),
                                        onPressed: () {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            addLableApi(
                                              label: textController.text,
                                              textColor: color1,
                                              bgColor: color2,
                                            );
                                            textController.clear();
                                            Navigator.of(context).pop();
                                            setState(() {
                                              color1 = Colors.white;
                                              color2 = Colors.black;
                                            });
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ).then((_) {
                        textController.clear();
                        setState(() {
                          color1 = Colors.white;
                          color2 = Colors.black;
                        });
                      });
                    } else if (value == 'edit') {
                      _showAllLabelsEditDialog(context);
                    }
                  },
                )
              ],
            ),
            SizedBox(height: 8),
            CustomMultiDropdown(
              items: controller.labelsDropdownItems,
              selectedValues:
                  widget.assignedLabelIds!.map((id) => id.toString()).toList(),
              onSelectionChanged: (selected) {
                setState(() {
                  selectedLabelIds = selected.map((e) => e.toString()).toList();
                });
              },
            ),
            SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: app_theme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () async {
                  final labelsToSave = selectedLabelIds.isNotEmpty
                      ? selectedLabelIds
                      : widget.assignedLabelIds!
                          .map((id) => id.toString())
                          .toList();

                  assignLableApi(labelsToSave);

                  // assignLableApi(selectedLabelIds);

                  chatController.getUserChat();
                  await provider.getUser(isRefresh: true, assigned: '');
                },
                child: isAssignLableLoader
                    ? SizedBox(
                        height: 15,
                        width: 15,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ))
                    : Text(
                        context.lwTranslate.save,
                        style: const TextStyle(color: app_theme.black),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection(BuildContext context) {
    return Container(
      decoration: app_theme.insetPanelDecoration(radius: 24),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.lwTranslate.notes,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: app_theme.primary,
                  ),
                ),
                if (!isEdit)
                  IconButton(
                    icon: const Icon(
                      CupertinoIcons.pencil,
                      color: app_theme.primary,
                    ),
                    onPressed: () => setState(() => isEdit = true),
                  ),
              ],
            ),
            SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color.fromRGBO(167, 223, 255, 0.18),
                ),
                borderRadius: BorderRadius.circular(18),
                color: app_theme.surfaceElevated,
              ),
              child: TextField(
                controller: controller.notesController,
                readOnly: !isEdit,
                maxLines: 5,
                minLines: 5,
                style: const TextStyle(color: app_theme.lavenderWhite),
                decoration: InputDecoration(
                  hintText: context.lwTranslate.notesDot,
                  hintStyle: const TextStyle(color: app_theme.secondary),
                  contentPadding: const EdgeInsets.all(12),
                  border: InputBorder.none,
                ),
              ),
            ),
            if (isEdit) SizedBox(height: 16),
            if (isEdit)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: app_theme.secondary),
                      ),
                      onPressed: () => setState(() => isEdit = false),
                      child: Text(
                        context.lwTranslate.cancel,
                        style: const TextStyle(color: app_theme.secondary),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: app_theme.cyanGlow,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: updateNotesApi,
                      child: Text(
                        context.lwTranslate.save,
                        style: const TextStyle(color: app_theme.black),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: app_theme.iceBlue,
      ),
    );
  }

  String formatDate(String dateString) {
    return dateString;
  }

  Widget _buildColorSquareWithLabel(
      Color color, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.grey.shade400, width: 1),
        ),
      ),
    );
  }

  Future<Color?> showColorPicker(BuildContext context, Color initialColor,
      String title, Function setState) async {
    Color selectedColor = initialColor;
    return await showDialog<Color>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: app_theme.surface,
        title: Text(title, style: TextStyle(fontSize: 17)),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: initialColor,
            onColorChanged: (color) {
              selectedColor = color;
            },
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: [
          TextButton(
            child: Text(context.lwTranslate.cancel),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
              child: Text(context.lwTranslate.ok),
              onPressed: () {
                setState(() {});
                Navigator.of(context).pop(selectedColor);
              } // Return the selected color
              ),
        ],
      ),
    );
  }

  void _showAllLabelsEditDialog(BuildContext context) {
    final controllers = controller.labelsDropdownItems.map((label) {
      return {
        'title': TextEditingController(text: label['value']),
        'textColor': TextEditingController(text: label['textColor']),
        'bgColor': TextEditingController(text: label['bgColor']),
        'id': label['id'],
        '_uid': label['_uid'],
      };
    }).toList();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: app_theme.surface,
              insetPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              title: Text(context.lwTranslate.editLabel),
              content: SizedBox(
                width: double.maxFinite,
                height: MediaQuery.of(context).size.height * 0.55,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var i = 0; i < controllers.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Column(
                            children: [
                              // Label Title
                              TextFormField(
                                controller: controllers[i]['title'],
                                decoration: InputDecoration(
                                  labelText: '',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Color Pickers
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Text Color Square
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => _showColorPicker(
                                          context,
                                          controllers[i]['textColor']!,
                                          setState),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(context.lwTranslate.textColors,
                                              style: const TextStyle(
                                                  fontSize: 10,
                                                  color: app_theme.secondary)),
                                          SizedBox(height: 4),
                                          Container(
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: _parseColor(controllers[i]
                                                      ['textColor']!
                                                  .text),
                                              border: Border.all(
                                                  color: Colors.grey),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),

                                  // Background Color Square
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => _showColorPicker(context,
                                          controllers[i]['bgColor']!, setState),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(context.lwTranslate.bgColor,
                                              style: const TextStyle(
                                                  fontSize: 10,
                                                  color: app_theme.secondary)),
                                          SizedBox(height: 4),
                                          Container(
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: _parseColor(controllers[i]
                                                      ['bgColor']!
                                                  .text),
                                              border: Border.all(
                                                  color: Colors.grey),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Column(
                                    children: [
                                      Text("", style: TextStyle(fontSize: 10)),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: app_theme.cyanGlow,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 24, vertical: 10),
                                        ),
                                        child: Text(context.lwTranslate.save,
                                            style: const TextStyle(
                                                color: app_theme.black)),
                                        onPressed: () {
                                          editLableApi(
                                            uid: controllers[i]['_uid'],
                                            label:
                                                controllers[i]['title']!.text,
                                            textColor: _parseColor(
                                                controllers[i]['textColor']!
                                                    .text),
                                            bgColor: _parseColor(controllers[i]
                                                    ['bgColor']!
                                                .text),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 8),
                                  Column(
                                    children: [
                                      Text("", style: TextStyle(fontSize: 13)),
                                      Container(
                                        alignment: Alignment.center,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.red),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: IconButton(
                                          icon: Icon(
                                            Icons.delete,
                                            size: 15,
                                            color: Colors.red,
                                          ),
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) => Dialog(
                                                elevation: 24,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                                backgroundColor:
                                                    app_theme.surface,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(24),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      // Animated error icon
                                                      Icon(
                                                        Icons.error_outline,
                                                        color:
                                                            app_theme.warning,
                                                        size: 45,
                                                      ),

                                                      const SizedBox(
                                                          height: 16),

                                                      // Title
                                                      Text(
                                                        context.lwTranslate
                                                            .areYoySureDeleteLabel,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .headlineSmall
                                                            ?.copyWith(
                                                                color: app_theme
                                                                    .lavenderWhite,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 14),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),

                                                      const SizedBox(
                                                          height: 24),

                                                      // Action button
                                                      SizedBox(
                                                        width: double.infinity,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceEvenly,
                                                          children: [
                                                            ElevatedButton(
                                                              style:
                                                                  ElevatedButton
                                                                      .styleFrom(
                                                                backgroundColor:
                                                                    Colors.red[
                                                                        700],
                                                                foregroundColor:
                                                                    Colors
                                                                        .white,
                                                                shape:
                                                                    RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              12),
                                                                ),
                                                              ),
                                                              onPressed: () {
                                                                deleteLableApi(
                                                                  uid: controllers[
                                                                          i]
                                                                      ['_uid'],
                                                                );
                                                                setState(() {});
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                              child: Text(context
                                                                  .lwTranslate
                                                                  .yes
                                                                  .toUpperCase()),
                                                            ),
                                                            ElevatedButton(
                                                              style:
                                                                  ElevatedButton
                                                                      .styleFrom(
                                                                backgroundColor:
                                                                    app_theme
                                                                        .surfaceElevated,
                                                                foregroundColor:
                                                                    Colors
                                                                        .white,
                                                                shape:
                                                                    RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              12),
                                                                ),
                                                              ),
                                                              onPressed: () =>
                                                                  Navigator.pop(
                                                                      context),
                                                              child: Text(context
                                                                  .lwTranslate
                                                                  .no
                                                                  .toUpperCase()),
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
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: app_theme.surfaceElevated,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  ),
                  child: Text(context.lwTranslate.close,
                      style: const TextStyle(color: Colors.white)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Color _parseColor(String colorString) {
    try {
      if (colorString.startsWith('#')) {
        final hexCode = colorString.substring(1);
        return Color(int.parse('FF$hexCode', radix: 16));
      }
      return Colors.black;
    } catch (e) {
      return Colors.black;
    }
  }

  Future<void> _showColorPicker(
    BuildContext context,
    TextEditingController controller,
    Function setState,
  ) async {
    final initialColor = _parseColor(controller.text);
    Color selectedColor = initialColor; // Local variable to track selection

    await showDialog<Color>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: app_theme.surface,
        title: Text(context.lwTranslate.pickColor),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: initialColor,
            onColorChanged: (color) {
              selectedColor = color; // Only update local variable
            },
          ),
        ),
        actions: [
          TextButton(
            child: Text(context.lwTranslate.cancel),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text(context.lwTranslate.ok),
            onPressed: () {
              controller.text =
                  '#${selectedColor.toARGB32().toRadixString(16).substring(2)}';
              setState(() {});
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

// Future<void> _showColorPicker(
//     BuildContext context,
//     TextEditingController controller,
//     Function setState,
//     ) async {
//   final initialColor = _parseColor(controller.text);
//   Color currentColor = initialColor;
//   await showDialog<Color>(
//     context: context,
//     builder: (context) => AlertDialog(
//       title: const Text('Pick a color'),
//       content: SingleChildScrollView(
//         child: ColorPicker(
//           pickerColor: initialColor,
//           onColorChanged: (color) {
//             currentColor = color;
//             controller.text = '#${color.value.toRadixString(16).substring(2)}';
//           },
//         ),
//       ),
//       actions: [
//         TextButton(
//           child: Text(context.lwTranslate.cancel),
//           onPressed: () {
//             // currentColor = color;
//             Navigator.of(context).pop();
//           }
//         ),
//         TextButton(
//           child: const Text('OK'),
//           onPressed: () {
//             setState(() {}); // Trigger rebuild
//             Navigator.pop(context);
//           },
//         ),
//       ],
//     ),
//   );
// }
}
