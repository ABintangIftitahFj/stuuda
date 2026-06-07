import 'package:universal_io/io.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:progress_loading_button/progress_loading_button.dart';
import 'package:stundaa/screens/whatsapp/controller/user_info_controller.dart';

import 'package:stundaa/screens/whatsapp/controller/audio_controller.dart';
import 'package:stundaa/screens/whatsapp/screens/user_info.dart';
import 'package:stundaa/screens/whatsapp/componets/documents_picker.dart';
import 'package:stundaa/screens/whatsapp/componets/message_bubble.dart';
import 'package:stundaa/screens/whatsapp/componets/audioplayer.dart';
import 'package:stundaa/screens/whatsapp/componets/imagedetails.dart';
import 'package:stundaa/screens/whatsapp/controller/chatbox_controller.dart';
import 'package:stundaa/services/utils.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:stundaa/support/app_theme.dart' as app_theme;
import 'package:stundaa/services/data_transport.dart' as data_transport;
import 'package:stundaa/services/auth.dart' as auth;
import 'package:stundaa/services/whatsapp_call_service.dart';
import 'package:path/path.dart' as path;
import 'package:shimmer/shimmer.dart';
import 'package:smooth_list_view/smooth_list_view.dart';

class ChatboxScreen extends StatefulWidget {
  final dynamic contactdetails;

  const ChatboxScreen({super.key, required this.contactdetails});
  @override
  State<ChatboxScreen> createState() => _ChatboxScreenState();
}

class _ChatboxScreenState extends State<ChatboxScreen> {
  static const Color _chatBlue = Color(0xFF59AFFF);
  static const Color _chatBlueDeep = Color(0xFF142B68);
  static const Color _chatBlueDark = Color(0xFF07152F);
  String? userId = "";
  final ChatboxController controller = Get.put(ChatboxController());
  final Userinfocontroller controllerUser = Get.put(Userinfocontroller());
  final AudioController audioController = Get.put(AudioController());
  List<String> videoExtensions = ['mp4', 'mov', 'webm', 'mkv'];
  List<String> imageExtensions = ['jpg', 'png', 'jpeg', 'gif'];
  List<String> documentExtensions = ['pdf', 'doc', 'docx', 'txt'];
  String token = '';
  List<int> assignedLabelIds = [];
  String? uploadingFileName;
  Map<String, dynamic>? uploadedData;
  final Map<String, GlobalKey> _messageKeys = {};
  String? _highlightedMessageUid;

  @override
  void initState() {
    token = auth.getAuthToken();
    userId = widget.contactdetails['_uid'] ?? '';
    controller.scrollToBottomAllChat();
    controller.currentUser();
    controller.setUserId(userId!);
    controllerUser.setUserId(userId!);

    setState(() {
      controller.getUserChat();
      controllerUser.getUserInfo();
      _fetchAssignedLabels();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (userId != null && userId!.isNotEmpty) {
        controller.getUserChat();
      }
    });
    controller.scrollController.addListener(() {
      if (controller.scrollController.position.atEdge) {
        if (controller.scrollController.position.pixels ==
            controller.scrollController.position.maxScrollExtent) {
          if (!controller.isLoading.value) {
            controller.loadMoreMessages2();
          }
        }
      }
    });
    super.initState();
  }

  Future<void> _fetchAssignedLabels() async {
    await controller.getUserChat();
    setState(() {
      assignedLabelIds = controller.assignedLabelIds;
    });
  }

  Future<void> sendMessage() async {
    final messageBody = controller.messageController.text.trim();
    if (messageBody.isEmpty) {
      return;
    }

    final Map<String, dynamic> payload = {
      'contact_uid': userId,
      'message_body': messageBody,
    };

    controller.addQuotedMessageWamid(payload);

    try {
      await data_transport.post(
        'vendor/whatsapp/contact/chat/send',
        inputData: payload,
        context: context,
        onSuccess: (responseData) async {
          controller.addMessage(messageBody);
          controller.clearReplyMessage();

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (userId != null && userId!.isNotEmpty) {
              Future.delayed(const Duration(seconds: 3), () {
                controller.getUserChatSend();
              });
            }
          });
        },
        onFailed: (responseData) {},
      );
    } catch (e) {
      pr(e);
    } finally {}
  }

  Future<String?> getChatMedia(String label) async {
    String normalizedLabel = label.toLowerCase();
    if (normalizedLabel == 'documento') {
      normalizedLabel = 'document';
    } else if (normalizedLabel == 'immagine') {
      normalizedLabel = 'image';
    }
    String? uploadTitle;

    await data_transport.get(
      'vendor/whatsapp/contact/chat/prepare-send-media/$normalizedLabel',
      onSuccess: (responseData) {
        uploadTitle = responseData?['data']?['uploadTitle'];
      },
      onError: (error) {},
      onFailed: (failedResponse) {},
    );

    return uploadTitle;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newUserId = widget.contactdetails['_uid'] ?? '';
    if (newUserId != userId) {
      userId = newUserId;
      controller.setUserId(userId!);
    }
  }

  @override
  void dispose() {
    controller.isLoading = false.obs;
    controller.currentPage = 2;
    Get.delete<AudioController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedTime = DateFormat('h:mm a').format(now);
    return Scaffold(
      appBar: _buildAppBar(context, formattedTime),
      body: SafeArea(
        child: Stack(
          children: [
            SizedBox.expand(
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _chatBlueDark,
                      _chatBlueDeep,
                      Color(0xFF123D87),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Opacity(
                      opacity: 0.1,
                      child: Image.asset(
                        'assets/images/whatsapp_Back.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                    Align(
                      alignment: const Alignment(0.9, -0.95),
                      child: Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.42),
                              _chatBlue.withValues(alpha: 0.22),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: const Alignment(-0.95, 0.45),
                      child: Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              _chatBlue.withValues(alpha: 0.22),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Column(
              children: [
                Expanded(
                  child: _buildMessageList(formattedTime),
                ),
                Obx(() => controller.selectedReplyMessage.value != null
                    ? _buildReplyPreviewBar()
                    : const SizedBox.shrink()),
                _buildMessageInput(context),
                Obx(() => controller.emojiShowing.value
                    ? _buildEmojiPicker()
                    : const SizedBox.shrink()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, String formattedTime) {
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        margin: const EdgeInsets.fromLTRB(12, 8, 12, 6),
        decoration: app_theme.topBarDecoration(radius: 30),
      ),
      titleSpacing: 0,
      leadingWidth: 0,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            IconButton(
              onPressed: () {
                setState(() {
                  controller.isLoading = false.obs;
                });
                Navigator.pop(context);
              },
              icon: const Icon(
                CupertinoIcons.back,
                color: Colors.white,
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  audioController.stop();
                  navigatePage(
                    context,
                    UserInfo(
                      username: widget.contactdetails['full_name'],
                      userId: userId,
                      enableAiBot: controller.enableAiBot.value,
                      enableReplyBot: controller.replyAEnableBot.value,
                      assignedLabelIds: controller.assignedLabelIds,
                    ),
                  );
                },
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white.withValues(alpha: 0.10),
                      child: Text(
                        widget.contactdetails['name_initials'].toString(),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.contactdetails['full_name'].toString(),
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            widget.contactdetails['last_message']
                                ['formatted_message_time'],
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.72),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        if (userId != null) {
                          WhatsAppCallService.startCall(context, userId!);
                        }
                      },
                      icon: const Icon(
                        CupertinoIcons.phone,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        if (userId != null) {
                          WhatsAppCallService.startCall(context, userId!);
                        }
                      },
                      icon: const Icon(
                        CupertinoIcons.video_camera,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        PopupMenuButton<String>(
          color: app_theme.surface,
          offset: const Offset(-25, 55),
          icon: const Icon(CupertinoIcons.ellipsis, color: Colors.white),
          itemBuilder: (BuildContext context) {
            return [
              PopupMenuItem(
                onTap: () async {
                  audioController.stop();
                  await controllerUser.getUserInfo();
                  if (!context.mounted) {
                    return;
                  }

                  navigatePage(
                    context,
                    UserInfo(
                      username: widget.contactdetails['full_name'],
                      userId: userId,
                      enableAiBot:
                          controller.enableAiBot.value, // Pass the value
                      enableReplyBot: controller.replyAEnableBot.value,
                      assignedLabelIds: controller.assignedLabelIds,
                    ),
                  );
                },
                child: Row(
                  children: [
                    const Icon(CupertinoIcons.person, color: app_theme.iceBlue),
                    const SizedBox(width: 8),
                    Text(
                      context.lwTranslate.userInformation,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: app_theme.lavenderWhite),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      elevation: 24,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      backgroundColor: app_theme.surface,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Animated error icon
                            Icon(
                              CupertinoIcons.exclamationmark_triangle,
                              color: app_theme.warning,
                              size: 45,
                            ),

                            const SizedBox(height: 16),

                            // Title
                            Text(
                              context.lwTranslate
                                  .doYouWantToDeleteAllTheChatMessageOf,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                      color: app_theme.lavenderWhite,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: 16),

                            // Error message
                            Text(
                              context.lwTranslate.onlyChatHistory,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                      color: app_theme.secondary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: 24),

                            // Action button
                            SizedBox(
                              width: double.infinity,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: app_theme.error,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: () {
                                      controller.clearChatHistory(context);
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                        context.lwTranslate.yes.toUpperCase()),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          app_theme.surfaceElevated,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: () => Navigator.pop(context),
                                    child: Text(
                                        context.lwTranslate.no.toUpperCase()),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                  // showActionableDialog(
                  //     description: Text(
                  //       context
                  //           .lwTranslate.onlyChatHistory,
                  //     ),
                  //     onConfirm: controller.clearChatHistory,
                  //     onCancel: () {},
                  //     cancelActionText: context.lwTranslate.cancel,
                  //     confirmActionText: context.lwTranslate.agree,
                  //     title: context.lwTranslate.doYouWantToDeleteAllTheChatMessageOf,
                  //     context);
                },
                child: Row(
                  children: [
                    const Icon(Icons.delete, color: app_theme.error),
                    const SizedBox(width: 8),
                    Text(context.lwTranslate.deleteAllChatHistory,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: app_theme.lavenderWhite)),
                  ],
                ),
              ),
            ];
          },
        ),
      ],
    );
  }

  Widget _buildMessageList(String formattedTime) {
    return Obx(() {
      final reversedList = controller.holduser;
      return controller.isInitialLoading.value
          ? buildShimmerLoader()
          : Column(
              children: [
                Expanded(
                  child: SmoothListView.builder(
                    // child: ListView.builder(
                    duration: const Duration(milliseconds: 200),
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 8),
                    addAutomaticKeepAlives: true,
                    addRepaintBoundaries: true,
                    controller: controller.scrollController,
                    itemCount: reversedList.length + 1,
                    reverse: true,
                    itemBuilder: (context, index) {
                      if (index == reversedList.length) {
                        return _buildLoadingIndicator();
                        // return controller.isLoading.value
                        //     ? LoadingAnimationWidget.hexagonDots(
                        //         color: Colors.grey,
                        //         size: 40,
                        //       )
                        //     : const SizedBox.shrink();
                      }
                      final messageData = reversedList[index];
                      final isFile = messageData['isFile'] ?? false;
                      final messageContent = messageData['content'] ?? "";
                      final filename = messageData['filename'];
                      final filetype = messageData['filetype'];
                      final isIncoming = messageData['isIncoming'] ?? false;
                      final isSystem = messageData['isSystem'] ?? false;

                      final status = messageData['status'] ?? 'unknown';
                      final messagedAt =
                          messageData['messagedAt'] as String? ?? 'unknown';
                      final formattedMessagedAt =
                          messageData['formattedMessagedAt'] as String? ?? '';
                      final templateMessage =
                          messageData['templateMessage'] as String? ?? '';
                      final media =
                          (messageData['media'] as Map<String, dynamic>?) ?? {};
                      final link = (media['link'] as String?) ?? '';
                      final type = (media['type'] as String?) ?? '';
                      final caption = (media['caption'] as String?) ?? '';
                      final fileName = (media['fileName'] as String?) ?? '';
                      final mimeType = (media['mimeType'] as String?) ?? '';
                      final originalFileName =
                          (media['originalFileName'] as String?) ?? '';
                      final whatsAppError =
                          (messageData['whatsAppError'] as String?) ?? "";
                      final data = messageData['__data'] ?? {};
                      final repliedToMessageUid =
                          messageData['repliedToMessageUid'] as String? ?? '';
                      final quotedMessage =
                          controller.findMessageByUid(repliedToMessageUid);
                      final quotedSenderName = quotedMessage == null
                          ? null
                          : quotedMessage['isIncoming'] == true
                              ? (widget.contactdetails['first_name'] ??
                                  'Contact')
                              : 'You';
                      final messageUid = messageData['uid']?.toString() ?? '';
                      final messageKey = messageUid.isEmpty
                          ? null
                          : _messageKeys.putIfAbsent(messageUid, GlobalKey.new);

                      return AnimatedContainer(
                        key: messageKey,
                        duration: const Duration(milliseconds: 250),
                        color: _highlightedMessageUid == messageUid
                            ? app_theme.primary.withValues(alpha: 0.16)
                            : Colors.transparent,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          child: Row(
                            mainAxisAlignment: !isIncoming
                                ? isSystem
                                    ? MainAxisAlignment.center
                                    : MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (!isIncoming) ...[
                                const Expanded(flex: 0, child: SizedBox())
                              ],
                              if (isSystem) ...[
                                const Expanded(flex: 0, child: SizedBox())
                              ],
                              Expanded(
                                flex: isSystem ? 0 : 6,
                                child: GestureDetector(
                                  onLongPress: () {
                                    if (controller
                                        .canReplyToMessage(messageData)) {
                                      controller.setReplyMessage(messageData);
                                    }
                                  },
                                  child: isFile
                                      ? _buildFileMessageBubble(
                                          messageContent,
                                          formattedTime,
                                          filename,
                                          filetype,
                                          controller.iscurrentUser.value)
                                      : MessageBubble(
                                          message: messageContent,
                                          formattedTime: formattedTime,
                                          isCurrentUser:
                                              controller.iscurrentUser.value,
                                          isIncoming: isIncoming,
                                          isSystem: isSystem,
                                          status: status,
                                          messagedAt: messagedAt,
                                          formattedMessagedAt:
                                              formattedMessagedAt,
                                          templateMessage: templateMessage,
                                          whatsAppError: whatsAppError,
                                          errorDetails: "",
                                          statusCode: "",
                                          mediaLink: link,
                                          mediaType: type,
                                          mediaCaption: caption,
                                          mediaFileName: fileName,
                                          mediaMimeType: mimeType,
                                          mediaoOriginalFileName:
                                              originalFileName,
                                          media: media,
                                          data: data.isEmpty ? {} : data,
                                          quotedMessage: quotedMessage,
                                          quotedSenderName: quotedSenderName,
                                          hasQuotedMessage:
                                              repliedToMessageUid.isNotEmpty,
                                          onQuotedMessageTap:
                                              repliedToMessageUid.isEmpty
                                                  ? null
                                                  : () => _scrollToMessage(
                                                      repliedToMessageUid),
                                        ),
                                ),
                              ),
                              if (!controller.iscurrentUser.value) ...[
                                const Expanded(flex: 3, child: SizedBox())
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
    });
  }

  Future<void> _scrollToMessage(String messageUid) async {
    final messageContext = _messageKeys[messageUid]?.currentContext;
    if (messageContext == null) {
      return;
    }

    await Scrollable.ensureVisible(
      messageContext,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      alignment: 0.5,
    );
    if (!mounted) {
      return;
    }

    setState(() => _highlightedMessageUid = messageUid);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted && _highlightedMessageUid == messageUid) {
      setState(() => _highlightedMessageUid = null);
    }
  }

  Widget _buildReplyPreviewBar() {
    final message = controller.selectedReplyMessage.value!;
    final senderName = message['isIncoming'] == true
        ? (widget.contactdetails['first_name'] ?? 'Contact')
        : 'You';
    final contentPreview =
        controller.buildReplyPreviewText(message, fallback: 'Message');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
      decoration: BoxDecoration(
        color: app_theme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: app_theme.cyanGlow.withValues(alpha: 0.22),
        ),
        boxShadow: [
          BoxShadow(
            color: app_theme.cyanGlow.withValues(alpha: 0.10),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 42,
            decoration: BoxDecoration(
              color: _chatBlue,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Replying to $senderName',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: app_theme.iceBlue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  contentPreview,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: app_theme.secondary,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20, color: app_theme.secondary),
            onPressed: () => controller.clearReplyMessage(),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: Colors.transparent),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 9,
                  child: _buildTextField(context),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: app_theme.cyanGlow,
                    child: IconButton(
                      onPressed: () {
                        sendMessage();
                      },
                      icon: const Icon(Icons.send_rounded,
                          color: app_theme.black),
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

  Widget _buildTextField(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: app_theme.surface.withValues(alpha: 0.96),
        border: Border.all(
          color: app_theme.cyanGlow.withValues(alpha: 0.18),
        ),
        borderRadius: BorderRadius.circular(18.0),
        boxShadow: [
          BoxShadow(
            color: app_theme.cyanGlow.withValues(alpha: 0.15),
            spreadRadius: 1,
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TextField(
        controller: controller.messageController,
        onTap: () {
          FocusScope.of(context).unfocus();
          controller.emojiShowing.value = false;
        },
        decoration: InputDecoration(
          prefixIcon: IconButton(
            onPressed: () {
              controller.emojiShowing.value = !controller.emojiShowing.value;
              if (controller.emojiShowing.value) {
                FocusScope.of(context).unfocus();
              } else {
                FocusScope.of(context).requestFocus(FocusNode());
              }
            },
            icon: const Icon(Icons.face_6, color: app_theme.iceBlue),
          ),
          suffixIcon: Obx(() {
            return controller.documentsOption.value
                ? IconButton(
                    onPressed: () => _showAttachmentOptions(context),
                    icon: const Icon(
                      Icons.attachment_sharp,
                      color: app_theme.iceBlue,
                    ),
                  )
                : const SizedBox.shrink();
          }),
          hintText: context.lwTranslate.typeAMessage,
          hintStyle: const TextStyle(
            fontSize: 14,
            color: app_theme.secondary,
          ),
          border: const OutlineInputBorder(borderSide: BorderSide.none),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
        style: const TextStyle(
          color: app_theme.lavenderWhite,
        ),
      ),
    );
  }

  void _showAttachmentOptions(context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Card(
          margin: const EdgeInsets.all(10),
          color: app_theme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(
              color: Color.fromRGBO(167, 223, 255, 0.16),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildAttachmentOption(
                  // label: context.lwTranslate.document,
                  label: "document",
                  icon: Icons.edit_document,
                  color: Colors.purple,
                  fileType: FileType.custom,
                  allowedExtensions: documentExtensions,
                ),
                _buildAttachmentOption(
                  // label: context.lwTranslate.image,
                  label: "image",
                  icon: Icons.photo,
                  color: Colors.red,
                  fileType: FileType.image,
                ),
                _buildAttachmentOption(
                  label: context.lwTranslate.video,
                  icon: Icons.video_call,
                  color: Colors.orange,
                  fileType: FileType.video,
                ),
                _buildAttachmentOption(
                  label: context.lwTranslate.audio,
                  icon: Icons.headphones,
                  color: Colors.greenAccent,
                  fileType: FileType.audio,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAttachmentOption({
    required String label,
    required IconData icon,
    required Color color,
    required FileType fileType,
    List<String>? allowedExtensions,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: color,
          child: IconButton(
            icon: Icon(icon, size: 28),
            onPressed: () async {
              Navigator.pop(context);
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => Center(
                  child: LoadingAnimationWidget.discreteCircle(
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              );
              try {
                final uploadTitle = await getChatMedia(label);

                if (!mounted) {
                  return;
                }
                Navigator.of(context).pop();
                showCustomDialog(context,
                    uploadTitle: uploadTitle, label: label);
              } catch (e) {
                if (!mounted) {
                  return;
                }
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildEmojiPicker() {
    return AnimatedContainer(
      width: MediaQuery.sizeOf(context).width,
      height: 250,
      duration: const Duration(seconds: 5),
      curve: Curves.easeIn,
      child: EmojiPicker(
        textEditingController: controller.messageDraftController,
        onEmojiSelected: (category, emoji) {
          controller.messageController.text += emoji.emoji;
        },
        config: Config(
          skinToneConfig: SkinToneConfig(
            indicatorColor: Colors.green,
            dialogBackgroundColor: Colors.white,
          ),
          emojiViewConfig: EmojiViewConfig(
            columns: 7,
            recentsLimit: 28,
            noRecents: Text(
              context.lwTranslate.noRecent,
              style: TextStyle(fontSize: 20, color: Colors.black26),
              textAlign: TextAlign.center,
            ),
          ),
          checkPlatformCompatibility: true,
        ),
      ),
    );
  }

  Widget _buildFileMessageBubble(String filePath, String formattedTime,
      filename, String filetype, bool isCurrentUser) {
    final isImage = imageExtensions.any((ext) => filePath.endsWith('.$ext'));
    final isDocument =
        documentExtensions.any((ext) => filePath.endsWith('.$ext'));
    final isVideo = videoExtensions.any((ext) => filePath.endsWith('.$ext'));

    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
          topLeft: Radius.circular(10),
        ),
        color: isCurrentUser
            ? const Color.fromRGBO(215, 250, 209, 100)
            : Colors.white,
      ),
      padding: const EdgeInsets.all(8.0),
      child: isImage
          ? GestureDetector(
              onTap: () {
                navigatePage(
                  context,
                  Imagedetails(
                    filepath: filePath,
                  ),
                );
              },
              child: Column(
                children: [
                  Hero(
                    tag: 'image',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(File(filePath)),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        formattedTime,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.black,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      const SizedBox(width: 10),
                      if (isCurrentUser)
                        const Align(
                          alignment: Alignment.bottomRight,
                          child: Icon(
                            Icons.done_all,
                            color: Colors.blue,
                            size: 15,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            )
          : Column(
              children: [
                isDocument
                    ? PdfPickerPage(
                        pickedFilePath: filePath,
                        filename: filename,
                      )
                    : isVideo
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Text(
                              context.lwTranslate.tempVideo,
                            ) /* VideoPlayerScreen(
                            ) */
                            ,
                          )
                        : CustomAudioPlayer(
                            file: filePath,
                            filename: filename,
                          ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      formattedTime,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.black,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (isCurrentUser)
                      const Align(
                        alignment: Alignment.bottomRight,
                        child: Icon(
                          Icons.done_all,
                          color: Colors.blue,
                          size: 15,
                        ),
                      ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget buildShimmerLoader() {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            mainAxisAlignment: index % 2 == 0
                ? MainAxisAlignment.start
                : MainAxisAlignment.end,
            children: [
              if (index % 2 != 0) const Expanded(flex: 1, child: SizedBox()),
              Expanded(
                flex: 7,
                child: Shimmer.fromColors(
                  // baseColor: Colors.grey[300]!,
                  baseColor: const Color(0xA5CBF8BD),
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              if (index % 2 == 0) const Expanded(flex: 1, child: SizedBox()),
            ],
          ),
        );
      },
    );
  }

  void showCustomDialog(BuildContext context,
      {String? uploadTitle, String? label}) {
    TextEditingController textController = TextEditingController();
    uploadTitle ??= 'Select File';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        bool? selectImageTap;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: app_theme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24.0),
                side: const BorderSide(
                  color: Color.fromRGBO(167, 223, 255, 0.16),
                ),
              ),
              actionsPadding:
                  const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
              insetPadding:
                  const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      context.lwTranslate.sendMedia,
                      style: const TextStyle(
                          color: app_theme.lavenderWhite,
                          fontSize: 15,
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.08,
                      decoration: BoxDecoration(
                        color: app_theme.surfaceElevated,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: const Color.fromRGBO(167, 223, 255, 0.16),
                        ),
                      ),
                      child: selectImageTap == null
                          ? GestureDetector(
                              onTap: () {
                                String uploadPath;
                                String allowedExtensions = "";
                                switch (label) {
                                  case 'image':
                                    uploadPath =
                                        'media/upload-temp-media/whatsapp_image';
                                    allowedExtensions =
                                        'jpg,jpeg,png,gif'; // Comma-separated string
                                    break;
                                  case 'video':
                                    uploadPath =
                                        'media/upload-temp-media/whatsapp_video';
                                    allowedExtensions =
                                        'mp4,mov,avi,mp3,pdf,doc'; // Multiple file types
                                    break;
                                  case 'document':
                                    uploadPath =
                                        'media/upload-temp-media/whatsapp_document';
                                    allowedExtensions =
                                        'pdf,doc,docx,txt'; // Example extensions
                                    break;
                                  case 'audio':
                                    uploadPath =
                                        'media/upload-temp-media/whatsapp_audio';
                                    allowedExtensions =
                                        'mp3,wav,aac'; // Example extensions
                                    break;
                                  default:
                                    uploadPath =
                                        'media/upload-temp-media/whatsapp_other';
                                    allowedExtensions =
                                        '*'; // Wildcard for all types
                                    break;
                                }
                                pickAndUploadFile(
                                  context,
                                  uploadPath,
                                  allowMultiple: (label == 'video'),
                                  selectImageTap: false,
                                  allowedExtensions:
                                      allowedExtensions, // Pass as a string
                                  onStart: (fileSelected) {
                                    setState(() {
                                      selectImageTap = false;
                                      uploadingFileName =
                                          path.basename(fileSelected);
                                    });
                                  },
                                  onSuccess: (value, data) {
                                    setState(() {
                                      selectImageTap = true;
                                    });
                                  },
                                  onError: (error) {
                                    setState(() {
                                      selectImageTap = null;
                                    });
                                    pr(error);
                                  },
                                );
                              },
                              child: Container(
                                  padding: EdgeInsets.all(5),
                                  alignment: Alignment.center,
                                  height:
                                      MediaQuery.of(context).size.height * 0.05,
                                  child: Text(
                                    uploadTitle == null
                                        ? 'Loading...'
                                        : uploadTitle.toString(),
                                    style: TextStyle(
                                        color: uploadTitle == null
                                            ? app_theme.secondary.withValues(
                                                alpha: 0.72,
                                              )
                                            : app_theme.secondary,
                                        fontWeight: FontWeight.w500),
                                  )),
                            )
                          : selectImageTap == false
                              ? Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 7),
                                  child: Container(
                                    padding: EdgeInsets.all(4),
                                    alignment: Alignment.center,
                                    height: MediaQuery.of(context).size.height *
                                        0.06,
                                    decoration: BoxDecoration(
                                      color: app_theme.surface,
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                        color: const Color.fromRGBO(
                                            167, 223, 255, 0.16),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Flexible(
                                          flex: 4,
                                          child: Text(
                                            uploadingFileName ??
                                                context.lwTranslate.uploading,
                                            style: TextStyle(
                                                color: app_theme.lavenderWhite,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 9),
                                            textAlign: TextAlign.left,
                                          ),
                                        ),
                                        Flexible(flex: 1, child: Container()),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Flexible(
                                          flex: 2,
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  context.lwTranslate.uploading,
                                                  style: TextStyle(
                                                      color:
                                                          app_theme.secondary,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 7),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 3,
                                              ),
                                              SizedBox(
                                                height: 15,
                                                width: 15,
                                                child: LoadingAnimationWidget
                                                    .inkDrop(
                                                  color: app_theme.cyanGlow,
                                                  size: 20,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 7),
                                  child: Container(
                                    padding: EdgeInsets.all(4),
                                    alignment: Alignment.center,
                                    height: MediaQuery.of(context).size.height *
                                        0.06,
                                    decoration: BoxDecoration(
                                      color: app_theme.cyanGlow,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Flexible(
                                          flex: 4,
                                          child: Text(
                                            uploadingFileName ??
                                                context.lwTranslate.uploading,
                                            style: TextStyle(
                                                color: app_theme.black,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 9),
                                            textAlign: TextAlign.left,
                                          ),
                                        ),
                                        Flexible(flex: 1, child: Container()),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Flexible(
                                          flex: 2,
                                          child: Row(
                                            children: [
                                              Text(
                                                context
                                                    .lwTranslate.uploadComplete,
                                                style: TextStyle(
                                                    color: app_theme.black,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 7),
                                              ),
                                              SizedBox(
                                                width: 3,
                                              ),
                                              Icon(
                                                Icons.check_circle,
                                                color: app_theme.black,
                                                size: 20,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      context.lwTranslate.captionText,
                      style: const TextStyle(
                          color: app_theme.lavenderWhite,
                          fontSize: 15,
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color.fromRGBO(167, 223, 255, 0.18),
                        ),
                        borderRadius: BorderRadius.circular(4),
                        color: app_theme.surfaceElevated,
                      ),
                      child: TextField(
                        controller: textController,
                        autofocus: false,
                        style: const TextStyle(
                          fontSize: 13,
                          color: app_theme.lavenderWhite,
                        ),
                        maxLines: null,
                        minLines: 8,
                        decoration: InputDecoration(
                          hintText: context.lwTranslate.addACaption,
                          hintStyle: const TextStyle(
                              fontSize: 12, color: app_theme.secondary),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 8.0),
                          border: const OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius:
                                BorderRadius.all(Radius.circular(15.0)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                LoadingButton(
                  defaultWidget: Text(
                    context.lwTranslate.send,
                    style: const TextStyle(
                      color: app_theme.black,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  color: selectImageTap == true
                      ? app_theme.cyanGlow
                      : app_theme.surfaceElevated,
                  width: 70,
                  height: 35,
                  onPressed: selectImageTap == true
                      ? () async {
                          if (uploadedData == null) {
                            showToastMessage(
                              context,
                              context.lwTranslate.pleaseUploadFile,
                              type: context.lwTranslate.error,
                            );
                            return;
                          }
                          controller.sendMediaN(
                            uploadingFileNameMedia:
                                uploadingFileName.toString(),
                            caption: textController.text,
                            data: uploadedData!,
                            label: label,
                            context: context,
                          );
                        }
                      : null, // Disable button when selectImageTap is not true
                ),
                LoadingButton(
                  defaultWidget: Text(context.lwTranslate.cancel,
                      style:
                          const TextStyle(color: Colors.white, fontSize: 13)),
                  color: app_theme.surfaceElevated,
                  width: MediaQuery.of(context).size.width * 0.23,
                  height: MediaQuery.of(context).size.height * 0.045,
                  onPressed: () async {
                    setState(() {
                      selectImageTap = null;
                    });
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void pickAndUploadFile(
    BuildContext context,
    String url, {
    Function? onSuccess,
    Function? onError,
    Function? onStart,
    bool allowMultiple = true,
    String? allowedExtensions = '',
    required bool selectImageTap,
  }) async {
    try {
      var paths = (await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowMultiple: allowMultiple,
        allowedExtensions: (allowedExtensions?.isNotEmpty ?? false)
            ? allowedExtensions?.replaceAll(' ', '').split(',')
            : null,
      ))
          ?.files;

      String uploadedImageName = paths?[0].path ?? '';

      if (uploadedImageName == '') {
        return;
      }

      if (onStart != null) {
        onStart(uploadedImageName);
      }
      await Future.delayed(Duration(seconds: 2));
      if (!context.mounted) {
        return;
      }
      data_transport.uploadFile(
        uploadedImageName,
        url,
        context: context,
        inputData: {},
        onError: (error) {
          if (onError != null) {
            onError(error);
          }
        },
        thenCallback: (data) {},
        onSuccess: (responseData) {
          if (responseData is Map<String, dynamic>) {
            final uploadedResponseData = responseData['data'];
            if (uploadedResponseData is! Map<String, dynamic>) {
              return;
            }
            uploadingFileName = uploadedResponseData['fileName']?.toString();
            uploadedData = uploadedResponseData;
            if (onSuccess != null) {
              onSuccess(responseData, null);
            }
          }
        },
      );
    } catch (e) {
      pr("Error during upload: $e");
      if (onError != null) {
        onError(e);
      }
      if (!context.mounted) {
        return;
      }
      showToastMessage(context, context.lwTranslate.uploadFailed,
          type: context.lwTranslate.error);
    }
  }

  Widget _buildLoadingIndicator() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Obx(() {
          return controller.isLoading.value
              ? Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      LoadingAnimationWidget.discreteCircle(
                        color: Colors.grey,
                        size: 25,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        context.lwTranslate.pleaseWait,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink();
        }),
      ),
    );
  }
}
