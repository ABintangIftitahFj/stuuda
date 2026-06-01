import 'dart:io';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:progress_loading_button/progress_loading_button.dart';
import '../controller/user_info_controller.dart';

import '/common/widgets/common.dart';
import '/screens/whatsapp/controller/audio_controller.dart';
import '/screens/whatsapp/screens/user_info.dart';
import '/screens/whatsapp/componets/documents_picker.dart';
import '/screens/whatsapp/componets/message_bubble.dart';
import '/screens/whatsapp/componets/audioplayer.dart';
import '/screens/whatsapp/componets/imagedetails.dart';
import '/screens/whatsapp/controller/chatbox_controller.dart';
import '/services/utils.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '/support/app_theme.dart' as app_theme;
import '/services/data_transport.dart' as data_transport;
import '/services/auth.dart' as auth;
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
    final Map<String, dynamic> payload = {
      'contact_uid': userId,
      'message_body': controller.messageController.text.trim(),
    };
    try {
      await data_transport.post(
        'vendor/whatsapp/contact/chat/send',
        inputData: payload,
        context: context,
        onSuccess: (responseData) async {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (userId != null && userId!.isNotEmpty) {
              // controller.getUserChatSend();
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
      onError: (error) {
      },
      onFailed: (failedResponse) {
      },
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
              child: Image.asset(
                // 'assets/images/ic_background.png',
                'assets/images/whatsapp_Back.png',
                fit: BoxFit.cover,
              ),
            ),
            Column(
              children: [
                Expanded(
                  child: _buildMessageList(formattedTime),
                ),
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
      backgroundColor: app_theme.primary,
      actions: [
        IconButton(
          onPressed: () {
            setState(() {
              controller.isLoading = false.obs;
            });
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
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
                  enableAiBot: controller.enableAiBot.value,  // Pass the value
                  enableReplyBot: controller.replyAEnableBot.value,
                  assignedLabelIds: controller.assignedLabelIds,
                ),
              );
            },
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: app_theme.green,
                  child: Text(
                    widget.contactdetails['name_initials'].toString(),
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.contactdetails['full_name'].toString(),
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      widget.contactdetails['last_message']
                          ['formatted_message_time'],
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ],
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
        PopupMenuButton<String>(
          color: app_theme.primary,
          offset: const Offset(-25, 55),
          icon: const Icon(Icons.more_vert, color: Colors.white),
          itemBuilder: (BuildContext context) {
            return [
              PopupMenuItem(
                onTap: () async {
                  audioController.stop();
                  await controllerUser.getUserInfo();

                  navigatePage(
                    context,
                    UserInfo(
                      username: widget.contactdetails['full_name'],
                      userId: userId,
                          enableAiBot: controller.enableAiBot.value,  // Pass the value
                          enableReplyBot: controller.replyAEnableBot.value,
                      assignedLabelIds: controller.assignedLabelIds,
                    ),
                  );
                },
                child: Row(
                  children: [
                    Icon(Icons.person, color: Colors.white),
                    Text(
                      context.lwTranslate.userInformation,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white),
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
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Animated error icon
                            Icon(
                              Icons.error_outline,
                              color: Colors.orange.shade900,
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
                                      color: Colors.black,
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
                                      color: Colors.orange.shade900,
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
                                      backgroundColor: Colors.red[700],
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
                                      backgroundColor: Colors.grey[400],
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
                    Icon(Icons.delete, color: Colors.white),
                    Text(context.lwTranslate.deleteAllChatHistory,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white)),
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
                      final errorDetails =
                          messageData['errorDetails'] as String? ?? '';
                      final statusCode = messageData['statusCode'] as String? ?? '';

                      return Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        child: Row(
                          mainAxisAlignment: !isIncoming
                              ? isSystem ? MainAxisAlignment.center
                         :
                          MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!isIncoming) ...[
                              const Expanded(flex: 0, child: SizedBox())
                            ],

                            if (isSystem ) ...[
                              const Expanded(flex: 0,child: SizedBox())
                            ],
                            Expanded(
                              flex: isSystem ?  0:
                              6,
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
                                      isCurrentUser: controller.iscurrentUser.value,
                                      isIncoming: isIncoming,
                                      isSystem: isSystem,
                                      status: status,
                                      messagedAt: messagedAt,
                                      formattedMessagedAt: formattedMessagedAt,
                                      templateMessage: templateMessage,
                                      whatsAppError: whatsAppError,
                                      errorDetails: "",
                                      statusCode: "",
                                      mediaLink: link,
                                      mediaType: type,
                                      mediaCaption: caption,
                                      mediaFileName: fileName,
                                      mediaMimeType: mimeType,
                                      mediaoOriginalFileName: originalFileName,
                                      media: media,
                                      data: data.isEmpty ? {} : data,
                                    ),
                            ),
                            if (!controller.iscurrentUser.value) ...[
                              const Expanded(flex: 3, child: SizedBox())
                            ],
                          ],
                        ),
                      );
                    },
                  ),
              ),
            ],
          );
    });
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
                    child: IconButton(
                      onPressed: () {
                        sendMessage();
                        controller
                            .addMessage(controller.messageController.text);
                      },
                      icon: const Icon(Icons.send),
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
        color: Colors.white,
        border: Border.all(color: Colors.transparent),
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 4,
            offset: const Offset(0, 2),
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
            icon: const Icon(Icons.face_6, color: app_theme.primary),
          ),
          suffixIcon: Obx(() {
            return controller.documentsOption.value
                ? IconButton(
                    onPressed: () => _showAttachmentOptions(context),
                    icon: const Icon(Icons.attachment_sharp,
                        color: app_theme.primary),
                  )
                : const SizedBox.shrink();
          }),
          hintText: context.lwTranslate.typeAMessage,
          hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
          border: const OutlineInputBorder(borderSide: BorderSide.none),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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

                Navigator.of(context).pop();

                showCustomDialog(context,
                    uploadTitle: uploadTitle, label: label);
              } catch (e) {
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              actionsPadding:   EdgeInsets.symmetric(vertical: 20, horizontal: 15) ,
              contentPadding:
                  EdgeInsets.symmetric(vertical: 20, horizontal: 15),
              insetPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      context.lwTranslate.sendMedia,
                      style: TextStyle(
                          color: Colors.grey.shade800,
                          fontSize: 15,
                          fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 5),
                    Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.08,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(5),
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
                            allowMultiple: (label ==
                                'video'),
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
                            height: MediaQuery.of(context).size.height *
                                0.05,
                            child: Text(
                              uploadTitle == null
                                  ? 'Loading...'
                                  : uploadTitle.toString(),
                              style: TextStyle(
                                  color: uploadTitle == null
                                      ? Colors.grey
                                      .shade400 // Lighter color for loading text
                                      : Colors.grey.shade600,
                                  fontWeight: FontWeight.w500),
                            )),
                      )
                          : selectImageTap == false
                          ? Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7),
                        child: Container(
                          padding: EdgeInsets.all(4),
                          alignment: Alignment.center,
                          height:
                          MediaQuery.of(context).size.height *
                              0.06,
                          decoration: BoxDecoration(
                            color: Colors.grey,
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
                                      color: Colors.black,
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
                                        context
                                            .lwTranslate.uploading,
                                        style: TextStyle(
                                            color: Colors.white,
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
                                        color: Colors.white,
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7),
                        child: Container(
                          padding: EdgeInsets.all(4),
                          alignment: Alignment.center,
                          height:
                          MediaQuery.of(context).size.height *
                              0.06,
                          decoration: BoxDecoration(
                            color: app_theme.primary,
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
                                      color: Colors.black,
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
                                      context.lwTranslate
                                          .uploadComplete,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight:
                                          FontWeight.w500,
                                          fontSize: 7),
                                    ),
                                    SizedBox(
                                      width: 3,
                                    ),
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.white,
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
                    SizedBox(height: 16.0),
                    Text(
                      context.lwTranslate.captionText,
                      style: TextStyle(
                          color: Colors.grey.shade800,
                          fontSize: 15,
                          fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 5),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.white,
                      ),
                      child: TextField(
                        controller: textController,
                        autofocus: false,
                        style: TextStyle(fontSize: 13, color: Colors.black),
                        maxLines: null,
                        minLines: 8,
                        decoration: InputDecoration(
                          hintText: context.lwTranslate.addACaption,
                          hintStyle: TextStyle(
                              fontSize: 12, color: Colors.grey.shade500),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 8, vertical: 8.0),
                          border: OutlineInputBorder(
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
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                  color: selectImageTap == true
                      ? app_theme.primary
                      : Colors.green.shade200, // Change color when disabled
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
                      // 'Cancel',
                      style: TextStyle(color: Colors.white, fontSize: 13)),
                  color: Colors.grey.shade600,
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
          if (responseData != null && responseData is Map) {
            var data = responseData['data'];
            String fileName = data['fileName'] ?? 'No fileName';
            uploadingFileName = responseData['data']['fileName'];
            uploadedData = responseData['data'];
            if (onSuccess != null) {
              onSuccess(responseData, null);
            }
          } else {}
        },
      );
    } catch (e) {
      pr("Error during upload: $e");
      if (onError != null) {
        onError(e);
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
