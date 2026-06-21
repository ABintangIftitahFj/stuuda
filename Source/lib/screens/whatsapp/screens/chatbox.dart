import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:universal_io/io.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:progress_loading_button/progress_loading_button.dart';
import 'package:stundaa/screens/whatsapp/controller/user_info_controller.dart';

import 'package:stundaa/screens/whatsapp/controller/audio_controller.dart';
import 'package:stundaa/screens/whatsapp/componets/swipe_to_reply.dart';
import 'package:stundaa/screens/whatsapp/screens/user_info.dart';
import 'package:stundaa/screens/whatsapp/componets/documents_picker.dart';
import 'package:stundaa/screens/whatsapp/componets/message_bubble.dart';
import 'package:stundaa/screens/whatsapp/componets/audioplayer.dart';
import 'package:stundaa/screens/whatsapp/componets/imagedetails.dart';
import 'package:stundaa/screens/whatsapp/screens/media_gallery.dart';
import 'package:stundaa/screens/whatsapp/controller/chatbox_controller.dart';
import 'package:stundaa/services/utils.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:stundaa/model/contact_summary.dart';
import 'package:stundaa/provider/contacts_provider.dart';
import 'package:stundaa/support/app_theme.dart' as app_theme;
import 'package:stundaa/services/data_transport.dart' as data_transport;
import 'package:stundaa/services/auth.dart' as auth;
import 'package:stundaa/services/whatsapp_call_service.dart';
import 'package:path/path.dart' as path;
import 'package:shimmer/shimmer.dart';
import 'package:smooth_list_view/smooth_list_view.dart';

class ChatboxScreen extends StatefulWidget {
  final ContactSummary contact;

  const ChatboxScreen({super.key, required this.contact});
  @override
  State<ChatboxScreen> createState() => _ChatboxScreenState();
}

class _ChatboxScreenState extends State<ChatboxScreen> {
  static const Color _chatBlue = Color(0xFF59AFFF);
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
  bool _isSelectionMode = false;
  final List<Map<String, dynamic>> _selectedMessages = [];
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecorderInitialized = false;
  bool _isRecording = false;
  String? _recordedFilePath;

  @override
  void initState() {
    token = auth.getAuthToken();
    userId = widget.contact.uid;
    controller.scrollToBottomAllChat();
    controller.currentUser();
    controller.setUserId(userId!);
    controllerUser.setUserId(userId!);
    _initRecorder();

    controller.addListener(() {
      if (mounted) setState(() {});
    });

    controller.messageController.addListener(() {
      if (mounted) setState(() {});
    });

    setState(() {
      controller.getUserChat();
      controllerUser.getUserInfo();
      _fetchAssignedLabels();

      // Update unread message count to zero when chat is opened
      final provider = Provider.of<ContactProvider>(context, listen: false);
      provider.updateMessageCountToZero(userId!);
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

  Future<void> _initRecorder() async {
    if (!kIsWeb) {
      final status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        if (mounted) {
          showToastMessage(
              context, "Izin mikrofon diperlukan untuk merekam pesan suara.",
              type: 'error');
        }
        return;
      }
    }
    await _recorder.openRecorder();
    _isRecorderInitialized = true;
  }

  Future<void> _startRecording() async {
    if (!_isRecorderInitialized) {
      await _initRecorder();
      if (!_isRecorderInitialized) {
        if (mounted) {
          showToastMessage(
              context, "Gagal merekam. Silakan aktifkan izin mikrofon.",
              type: 'error');
        }
        return;
      }
    }
    try {
      if (kIsWeb) {
        _recordedFilePath = 'recorded_audio.webm';
      } else {
        Directory tempDir = await getTemporaryDirectory();
        _recordedFilePath = '${tempDir.path}/recorded_audio.aac';
      }
      await _recorder.startRecorder(
        toFile: _recordedFilePath,
        codec: kIsWeb ? Codec.opusWebM : Codec.aacADTS,
      );
      setState(() {
        _isRecording = true;
      });
    } catch (e) {
      if (mounted) {
        showToastMessage(context, "Gagal merekam suara: ${e.toString()}",
            type: 'error');
      }
    }
  }

  Future<void> _stopRecording() async {
    if (!_isRecorderInitialized || !_isRecording) return;
    try {
      String? path = await _recorder.stopRecorder();
      setState(() {
        _isRecording = false;
      });
      String? finalPath = kIsWeb ? path : _recordedFilePath;
      if (finalPath != null) {
        _sendVoiceNote(finalPath);
      }
    } catch (e) {
      setState(() {
        _isRecording = false;
      });
      if (mounted) {
        showToastMessage(context, "Gagal menghentikan rekaman: ${e.toString()}",
            type: 'error');
      }
    }
  }

  Future<void> _sendVoiceNote(String filePath) async {
    final ctx = context;
    showDialog(
      context: ctx,
      barrierDismissible: false,
      builder: (context) => Center(
        child: LoadingAnimationWidget.discreteCircle(
          color: Colors.white,
          size: 40,
        ),
      ),
    );

    try {
      final uploadTitle = await controller.prepareSendMedia('audio');
      if (uploadTitle == null) throw 'Failed to prepare media upload';
      if (!ctx.mounted) return;

      data_transport.uploadFile(
        filePath,
        'media/upload-temp-media/whatsapp_audio',
        context: ctx,
        inputData: {},
        onSuccess: (responseData) async {
          if (responseData is Map<String, dynamic>) {
            final d = responseData['data'];
            if (d is Map<String, dynamic>) {
              await controller.sendMediaN(
                uploadingFileNameMedia: d['fileName']?.toString() ?? '',
                caption: '',
                data: d,
                label: 'audio',
                context: ctx,
                isRecordedAudio: true,
              );
              if (ctx.mounted) Navigator.of(ctx).pop();
            }
          }
        },
        onError: (e) {
          if (ctx.mounted) {
            Navigator.of(ctx).pop();
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(content: Text('Upload failed: $e')),
            );
          }
        },
      );
    } catch (e) {
      if (ctx.mounted) {
        Navigator.of(ctx).pop();
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _forwardMessages(
      String targetContactUid, List<Map<String, dynamic>> messages) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: app_theme.primary),
      ),
    );

    try {
      await controller.forwardMessages(context, targetContactUid, messages);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pesan berhasil diteruskan')),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal meneruskan pesan: $e')),
        );
      }
    }
  }

  void _showForwardContactPicker(List<Map<String, dynamic>> messagesToForward) {
    final provider = Provider.of<ContactProvider>(context, listen: false);
    final searchController = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) {
        List<MapEntry<String, dynamic>> filteredContacts =
            provider.filterOriginalContacts('');

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            void updateSearchResults(String query) {
              final normalizedQuery = query.trim().toLowerCase();
              setModalState(() {
                if (normalizedQuery.isEmpty) {
                  filteredContacts = List<MapEntry<String, dynamic>>.from(
                    provider.filterOriginalContacts(''),
                  );
                  return;
                }

                filteredContacts = provider.filterOriginalContacts(
                  normalizedQuery,
                );
              });
            }

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  MediaQuery.of(sheetContext).viewInsets.bottom + 16,
                ),
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(sheetContext).size.height * 0.7,
                  ),
                  decoration: BoxDecoration(
                    color: app_theme.surface,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: const Color.fromRGBO(167, 223, 255, 0.16),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 12),
                      Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Teruskan pesan ke...',
                              style: TextStyle(
                                color: app_theme.lavenderWhite,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: searchController,
                              onChanged: updateSearchResults,
                              style: const TextStyle(
                                color: app_theme.lavenderWhite,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Cari kontak...',
                                hintStyle:
                                    const TextStyle(color: Colors.white38),
                                prefixIcon: const Icon(
                                  Icons.search,
                                  color: Colors.white54,
                                ),
                                filled: true,
                                fillColor: app_theme.surfaceElevated,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Flexible(
                        child: filteredContacts.isEmpty
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(24),
                                  child: Text(
                                    'Kontak tidak ditemukan',
                                    style: TextStyle(
                                      color: Colors.white60,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              )
                            : ListView.separated(
                                shrinkWrap: true,
                                padding:
                                    const EdgeInsets.fromLTRB(12, 0, 12, 12),
                                itemCount: filteredContacts.length,
                                separatorBuilder: (_, __) => const Divider(
                                  height: 1,
                                  color: Color.fromRGBO(167, 223, 255, 0.08),
                                ),
                                itemBuilder: (context, index) {
                                  final contact = ContactSummary.fromEntry(
                                    filteredContacts[index],
                                  );

                                  return ListTile(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    leading: CircleAvatar(
                                      backgroundColor: app_theme.surfaceMuted,
                                      child: Text(
                                        contact.nameInitials,
                                        style: const TextStyle(
                                          color: app_theme.lavenderWhite,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      contact.displayName,
                                      style: const TextStyle(
                                        color: app_theme.lavenderWhite,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    subtitle: Text(
                                      contact.waId,
                                      style: const TextStyle(
                                        color: Colors.white54,
                                      ),
                                    ),
                                    onTap: () {
                                      Navigator.of(sheetContext).pop();
                                      _forwardMessages(
                                        contact.uid,
                                        messagesToForward,
                                      );
                                    },
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(searchController.dispose);
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

    try {
      await controller.sendTextMessage(context, messageBody);
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

    uploadTitle = await controller.prepareSendMedia(normalizedLabel);

    return uploadTitle;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newUserId = widget.contact.uid;
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
    _recorder.closeRecorder();
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
                      app_theme.black,
                      app_theme.deepNavy,
                      app_theme.surface,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Opacity(
                      opacity: 0.4,
                      child: Image.asset(
                        'assets/images/stundaa_bg.jpeg',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Container(),
                      ),
                    ).animate().fadeIn(duration: 600.ms),
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
                    )
                        .animate()
                        .scale(duration: 800.ms, curve: Curves.easeOutBack),
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
                    )
                        .animate()
                        .scale(duration: 1000.ms, curve: Curves.easeOutBack),
                  ],
                ),
              ),
            ),
            Column(
              children: [
                Obx(() => controller.isWindowOpened.value
                    ? Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        color: Colors.green.withValues(alpha: 0.1),
                        child: Row(
                          children: [
                            const Icon(Icons.timer_outlined,
                                color: Colors.green, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Obx(() {
                                final countdown =
                                    controller.windowCountdownText.value;
                                return Text(
                                  countdown.isNotEmpty
                                      ? 'Chat window closes in $countdown'
                                      : controller.windowExpiresText.value,
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      )
                    : Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        color: Colors.orange.withValues(alpha: 0.1),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded,
                                color: Colors.orange, size: 16),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'The 24-hour window is closed. You can only send template messages.',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                Expanded(
                  child: _buildMessageList(formattedTime),
                ),
                Obx(() => controller.selectedReplyMessage.value != null
                    ? _buildReplyPreviewBar()
                        .animate()
                        .slideY(
                            begin: 1,
                            end: 0,
                            duration: 300.ms,
                            curve: Curves.easeOutCubic)
                        .fadeIn()
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
    if (_isSelectionMode) {
      return AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          margin: const EdgeInsets.fromLTRB(12, 8, 12, 6),
          decoration: BoxDecoration(
            color: const Color(0xFF1A263D),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
        ),
        titleSpacing: 0,
        leadingWidth: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 24),
                onPressed: () {
                  setState(() {
                    _isSelectionMode = false;
                    _selectedMessages.clear();
                  });
                },
              ),
              const SizedBox(width: 8),
              Text(
                '${_selectedMessages.length} terpilih',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy, color: Colors.white, size: 20),
            onPressed: () {
              final textToCopy = _selectedMessages
                  .map((m) => m['content']?.toString() ?? '')
                  .where((text) => text.isNotEmpty)
                  .join('\n');
              if (textToCopy.isNotEmpty) {
                Clipboard.setData(ClipboardData(text: textToCopy));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pesan disalin ke clipboard')),
                );
              }
              setState(() {
                _isSelectionMode = false;
                _selectedMessages.clear();
              });
            },
          ),
          if (_selectedMessages.length == 1)
            IconButton(
              icon: const Icon(Icons.reply_all, color: Colors.white, size: 20),
              onPressed: () {
                final msg = _selectedMessages.first;
                setState(() {
                  _isSelectionMode = false;
                  _selectedMessages.clear();
                });
                if (!controller.isWindowOpened.value) {
                  _showTemplateSelectorDialog(context);
                  return;
                }
                if (controller.canReplyToMessage(msg)) {
                  controller.setReplyMessage(msg);
                }
              },
            ),
          IconButton(
            icon: const Icon(Icons.reply,
                color: Colors.white, size: 22), // reply/forward icon
            onPressed: () {
              if (_selectedMessages.isNotEmpty) {
                final list = List<Map<String, dynamic>>.from(_selectedMessages);
                setState(() {
                  _isSelectionMode = false;
                  _selectedMessages.clear();
                });
                _showForwardContactPicker(list);
              }
            },
          ),
          const SizedBox(width: 16),
        ],
      );
    }

    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      toolbarHeight: 68,
      backgroundColor: app_theme.backgroundColor,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          color: app_theme.backgroundColor,
          border: Border(
            bottom: BorderSide(
              color: Colors.white.withValues(alpha: 0.06),
              width: 1,
            ),
          ),
        ),
      ),
      titleSpacing: 0,
      leadingWidth: 0,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            // Back button — minimal circle tap area
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  child: const Icon(
                    CupertinoIcons.chevron_back,
                    color: app_theme.iceBlue,
                    size: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            // Avatar + name — tap to open user info
            Expanded(
              child: GestureDetector(
                onTap: () {
                  audioController.stop();
                  navigatePage(
                    context,
                    UserInfo(
                      username: widget.contact.displayName,
                      userId: userId,
                      enableAiBot: controller.enableAiBot.value,
                      enableReplyBot: controller.replyAEnableBot.value,
                      assignedLabelIds: controller.assignedLabelIds,
                    ),
                  );
                },
                child: Row(
                  children: [
                    // Double-bezel avatar
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: app_theme.primary.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 17,
                        backgroundColor: app_theme.surfaceElevated,
                        child: Text(
                          widget.contact.nameInitials,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: app_theme.primary,
                            letterSpacing: 0.5,
                          ),
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
                            widget.contact.displayName,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: const TextStyle(
                              color: app_theme.lavenderWhite,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                widget.contact.waId,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.35),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              if (controller.isWindowOpened.value &&
                                  controller
                                      .windowExpiresText.value.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                        color: Colors.green
                                            .withValues(alpha: 0.3)),
                                  ),
                                  child: Text(
                                    controller.windowExpiresText.value,
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ] else if (widget
                                  .contact.isServiceWindowActive) ...[
                                const SizedBox(width: 4),
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
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
        // Phone action — pill icon button
        _AppBarIconButton(
          icon: CupertinoIcons.phone,
          onTap: () {
            if (userId != null) WhatsAppCallService.startCall(context, userId!);
          },
        ),
        _AppBarIconButton(
          icon: CupertinoIcons.videocam,
          onTap: () {
            if (userId != null) WhatsAppCallService.startCall(context, userId!);
          },
        ),
        PopupMenuButton<String>(
          color: app_theme.surface,
          offset: const Offset(-15, 55),
          icon: const Icon(CupertinoIcons.ellipsis_vertical,
              color: Colors.white, size: 18),
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
                      username: widget.contact.displayName,
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
                  final allMedia = controller.holduser
                      .where((m) =>
                          (m['media'] as Map<String, dynamic>?)?['type'] ==
                              'image' &&
                          ((m['media'] as Map<String, dynamic>?)?['link'] ?? '')
                              .toString()
                              .isNotEmpty)
                      .map((m) => {
                            'link': (m['media'] as Map<String, dynamic>)['link']
                                as String,
                            'type': 'image',
                            'caption':
                                (m['media'] as Map<String, dynamic>)['caption']
                                        as String? ??
                                    '',
                          })
                      .toList();
                  navigatePage(
                    context,
                    MediaGalleryScreen(
                      mediaItems: allMedia,
                      contactName: widget.contact.displayName,
                    ),
                  );
                },
                child: Row(
                  children: [
                    const Icon(CupertinoIcons.photo_on_rectangle,
                        color: app_theme.cyanGlow),
                    const SizedBox(width: 8),
                    const Text(
                      'Media Gallery',
                      style: TextStyle(
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
                },
                child: Row(
                  children: [
                    const Icon(CupertinoIcons.trash, color: app_theme.error),
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
                      final quotedMessage = messageData['repliedToMessage']
                              as Map<String, dynamic>? ??
                          controller.findMessageByUid(repliedToMessageUid);
                      final quotedSenderName = quotedMessage == null
                          ? null
                          : quotedMessage['isIncoming'] == true
                              ? (widget.contact.firstName.isNotEmpty
                                  ? widget.contact.firstName
                                  : 'Contact')
                              : 'You';
                      final messageUid = messageData['uid']?.toString() ?? '';
                      final messageKey = messageUid.isEmpty
                          ? null
                          : _messageKeys.putIfAbsent(messageUid, GlobalKey.new);

                      final isSelected =
                          _selectedMessages.any((m) => m['uid'] == messageUid);

                      return AnimatedContainer(
                        key: messageKey,
                        duration: const Duration(milliseconds: 250),
                        color: isSelected
                            ? app_theme.primary.withValues(alpha: 0.3)
                            : _highlightedMessageUid == messageUid
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
                              Flexible(
                                flex: isSystem ? 1 : 6,
                                fit: isSystem ? FlexFit.loose : FlexFit.tight,
                                child: GestureDetector(
                                  onTap: _isSelectionMode
                                      ? () {
                                          setState(() {
                                            if (_selectedMessages.any((m) =>
                                                m['uid'] == messageUid)) {
                                              _selectedMessages.removeWhere(
                                                  (m) =>
                                                      m['uid'] == messageUid);
                                              if (_selectedMessages.isEmpty) {
                                                _isSelectionMode = false;
                                              }
                                            } else {
                                              _selectedMessages
                                                  .add(messageData);
                                            }
                                          });
                                        }
                                      : null,
                                  onLongPress: () {
                                    if (_isSelectionMode) return;
                                    setState(() {
                                      _isSelectionMode = true;
                                      _selectedMessages.add(messageData);
                                    });
                                  },
                                  child: isSystem
                                      ? (isFile
                                          ? _buildFileMessageBubble(
                                              messageContent,
                                              formattedTime,
                                              filename,
                                              filetype,
                                              controller.iscurrentUser.value)
                                          : MessageBubble(
                                              message: messageContent,
                                              formattedTime: formattedTime,
                                              isCurrentUser: controller
                                                  .iscurrentUser.value,
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
                                              quotedSenderName:
                                                  quotedSenderName,
                                              hasQuotedMessage:
                                                  repliedToMessageUid
                                                      .isNotEmpty,
                                              onQuotedMessageTap:
                                                  repliedToMessageUid.isEmpty
                                                      ? null
                                                      : () => _scrollToMessage(
                                                          repliedToMessageUid),
                                            ))
                                      : SwipeToReply(
                                          onReply: () {
                                            if (!controller
                                                .isWindowOpened.value) {
                                              _showTemplateSelectorDialog(
                                                  context);
                                              return;
                                            }
                                            if (controller.canReplyToMessage(
                                                messageData)) {
                                              controller
                                                  .setReplyMessage(messageData);
                                            }
                                          },
                                          child: isFile
                                              ? _buildFileMessageBubble(
                                                  messageContent,
                                                  formattedTime,
                                                  filename,
                                                  filetype,
                                                  controller
                                                      .iscurrentUser.value)
                                              : MessageBubble(
                                                  message: messageContent,
                                                  formattedTime: formattedTime,
                                                  isCurrentUser: controller
                                                      .iscurrentUser.value,
                                                  isIncoming: isIncoming,
                                                  isSystem: isSystem,
                                                  status: status,
                                                  messagedAt: messagedAt,
                                                  formattedMessagedAt:
                                                      formattedMessagedAt,
                                                  templateMessage:
                                                      templateMessage,
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
                                                  data:
                                                      data.isEmpty ? {} : data,
                                                  quotedMessage: quotedMessage,
                                                  quotedSenderName:
                                                      quotedSenderName,
                                                  hasQuotedMessage:
                                                      repliedToMessageUid
                                                          .isNotEmpty,
                                                  onQuotedMessageTap:
                                                      repliedToMessageUid
                                                              .isEmpty
                                                          ? null
                                                          : () => _scrollToMessage(
                                                              repliedToMessageUid),
                                                ),
                                        ),
                                ),
                              ),
                              if (!controller.iscurrentUser.value) ...[
                                const Expanded(flex: 3, child: SizedBox())
                              ],
                            ],
                          ),
                        ),
                      ).animate().fadeIn(duration: 400.ms).slideX(
                          begin: isIncoming ? -0.1 : 0.1,
                          end: 0,
                          curve: Curves.easeOutCubic);
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
        ? (widget.contact.firstName.isNotEmpty
            ? widget.contact.firstName
            : 'Contact')
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
            if (_isRecording)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LoadingAnimationWidget.staggeredDotsWave(
                      color: Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Recording...',
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _buildTextField(context),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 56,
                  height: 56,
                  child: Material(
                    color: _isRecording ? Colors.red : app_theme.cyanGlow,
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: IconButton(
                      onPressed: () {
                        if (!controller.isWindowOpened.value) {
                          _showTemplateSelectorDialog(context);
                          return;
                        }
                        if (controller.messageController.text
                            .trim()
                            .isNotEmpty) {
                          sendMessage();
                        } else {
                          if (_isRecording) {
                            _stopRecording();
                          } else {
                            _startRecording();
                          }
                        }
                      },
                      icon: Icon(
                        controller.messageController.text.trim().isNotEmpty
                            ? Icons.send_rounded
                            : (_isRecording ? Icons.stop : Icons.mic),
                        color: _isRecording ? Colors.white : app_theme.black,
                      ),
                      tooltip:
                          controller.messageController.text.trim().isNotEmpty
                              ? context.lwTranslate.send
                              : (_isRecording
                                  ? 'Stop Recording'
                                  : 'Record Voice Note'),
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
      child: Obx(() => TextField(
            controller: controller.messageController,
            readOnly: !controller.isWindowOpened.value,
            onTap: () {
              if (!controller.isWindowOpened.value) {
                _showTemplateSelectorDialog(context);
              } else {
                FocusScope.of(context).unfocus();
                controller.emojiShowing.value = false;
              }
            },
            decoration: InputDecoration(
              prefixIcon: IconButton(
                onPressed: () {
                  if (!controller.isWindowOpened.value) {
                    _showTemplateSelectorDialog(context);
                  } else {
                    controller.emojiShowing.value =
                        !controller.emojiShowing.value;
                    if (controller.emojiShowing.value) {
                      FocusScope.of(context).unfocus();
                    } else {
                      FocusScope.of(context).requestFocus(FocusNode());
                    }
                  }
                },
                icon: const Icon(Icons.face_6, color: app_theme.iceBlue),
              ),
              suffixIcon: controller.documentsOption.value
                  ? IconButton(
                      onPressed: () {
                        if (!controller.isWindowOpened.value) {
                          _showTemplateSelectorDialog(context);
                        } else {
                          _showAttachmentOptions(context);
                        }
                      },
                      icon: const Icon(
                        Icons.attachment_sharp,
                        color: app_theme.iceBlue,
                      ),
                    )
                  : const SizedBox.shrink(),
              hintText: controller.isWindowOpened.value
                  ? context.lwTranslate.typeAMessage
                  : 'Obrolan terkunci. Ketuk untuk mengaktifkan.',
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
          )),
    );
  }

  void _showAttachmentOptions(BuildContext context) {
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
    // Alternating bubble sizes for realism
    final bubbleSizes = [
      56.0,
      72.0,
      44.0,
      88.0,
      52.0,
      68.0,
      48.0,
      76.0,
      60.0,
      40.0
    ];
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: bubbleSizes.length,
      itemBuilder: (context, index) {
        final isRight = index % 2 != 0;
        final height = bubbleSizes[index];
        final width = (150 + (index % 3) * 40).toDouble();

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment:
                isRight ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isRight)
                Shimmer.fromColors(
                  baseColor: app_theme.surfaceElevated,
                  highlightColor: app_theme.surface.withValues(alpha: 0.8),
                  child: Container(
                    width: 28,
                    height: 28,
                    margin: const EdgeInsets.only(right: 8, bottom: 2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: app_theme.surfaceElevated,
                    ),
                  ),
                ),
              Column(
                crossAxisAlignment:
                    isRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Shimmer.fromColors(
                    baseColor: isRight
                        ? const Color(0xFF0F2E4A)
                        : app_theme.surfaceElevated,
                    highlightColor:
                        isRight ? const Color(0xFF163C5E) : app_theme.surface,
                    child: Container(
                      width: width,
                      height: height,
                      decoration: BoxDecoration(
                        color: app_theme.surfaceElevated,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(18),
                          topRight: const Radius.circular(18),
                          bottomLeft: Radius.circular(isRight ? 18 : 4),
                          bottomRight: Radius.circular(isRight ? 4 : 18),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Timestamp shimmer
                  Shimmer.fromColors(
                    baseColor: app_theme.surfaceElevated,
                    highlightColor: app_theme.surface,
                    child: Container(
                      width: 36,
                      height: 8,
                      decoration: BoxDecoration(
                        color: app_theme.surfaceElevated,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
            .animate(delay: Duration(milliseconds: index * 60))
            .fadeIn(duration: 350.ms, curve: Curves.easeOut)
            .slideY(
                begin: 0.08, end: 0, duration: 350.ms, curve: Curves.easeOut);
      },
    );
  }

  void showCustomDialog(BuildContext context,
      {String? uploadTitle, String? label}) {
    final textController = TextEditingController();
    uploadTitle ??= 'Select File';
    final isImage = label == 'image';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // null = idle, false = uploading, true = done (single file flow)
        bool? selectImageTap;

        // Multi-photo state (image only)
        // Each entry: { 'path': String, 'status': 'idle'|'uploading'|'done'|'error', 'data': Map? }
        final List<Map<String, dynamic>> photoQueue = [];

        return StatefulBuilder(
          builder: (context, setState) {
            // ── helpers ──────────────────────────────────────────────
            String uploadPath() {
              switch (label) {
                case 'image':
                  return 'media/upload-temp-media/whatsapp_image';
                case 'video':
                  return 'media/upload-temp-media/whatsapp_video';
                case 'document':
                  return 'media/upload-temp-media/whatsapp_document';
                case 'audio':
                  return 'media/upload-temp-media/whatsapp_audio';
                default:
                  return 'media/upload-temp-media/whatsapp_other';
              }
            }

            String allowedExts() {
              switch (label) {
                case 'image':
                  return 'jpg,jpeg,png,gif';
                case 'video':
                  return 'mp4,mov,avi';
                case 'document':
                  return 'pdf,doc,docx,txt';
                case 'audio':
                  return 'mp3,wav,aac';
                default:
                  return 'jpg,jpeg,png,gif';
              }
            }

            // Upload a single photo entry at [index].
            void uploadPhoto(int index) {
              final entry = photoQueue[index];
              setState(() => entry['status'] = 'uploading');
              data_transport.uploadFile(
                entry['path'] as String,
                uploadPath(),
                context: context,
                inputData: {},
                thenCallback: (_) {},
                onSuccess: (responseData) {
                  if (responseData is Map<String, dynamic>) {
                    final d = responseData['data'];
                    if (d is Map<String, dynamic>) {
                      setState(() {
                        entry['status'] = 'done';
                        entry['data'] = d;
                      });
                    }
                  }
                },
                onError: (e) {
                  pr('Upload error: $e');
                  setState(() => entry['status'] = 'error');
                },
              );
            }

            // Pick multiple photos then start uploading each.
            Future<void> pickPhotos() async {
              try {
                final result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowMultiple: true,
                  allowedExtensions: allowedExts().split(','),
                );
                if (result == null || result.files.isEmpty) return;
                setState(() {
                  for (final f in result.files) {
                    if (f.path != null) {
                      photoQueue.add({
                        'path': f.path!,
                        'status': 'idle',
                        'data': null,
                      });
                    }
                  }
                });
                // Start upload for newly added idle items.
                for (int i = 0; i < photoQueue.length; i++) {
                  if (photoQueue[i]['status'] == 'idle') {
                    uploadPhoto(i);
                  }
                }
              } catch (e) {
                pr('Pick error: $e');
              }
            }

            final bool allDone = photoQueue.isNotEmpty &&
                photoQueue.every((e) => e['status'] == 'done');

            // ── single-file pick (non-image) ──────────────────────────
            void pickSingleFile() {
              pickAndUploadFile(
                context,
                uploadPath(),
                allowMultiple: label == 'video',
                selectImageTap: false,
                allowedExtensions: allowedExts(),
                onStart: (fileSelected) {
                  setState(() {
                    selectImageTap = false;
                    uploadingFileName = path.basename(fileSelected as String);
                  });
                },
                onSuccess: (value, data) {
                  setState(() => selectImageTap = true);
                },
                onError: (error) {
                  setState(() => selectImageTap = null);
                  pr(error);
                },
              );
            }

            // ── multi-photo grid ──────────────────────────────────────
            Widget buildPhotoGrid() {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (photoQueue.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 6,
                        mainAxisSpacing: 6,
                      ),
                      itemCount: photoQueue.length,
                      itemBuilder: (_, i) {
                        final entry = photoQueue[i];
                        final status = entry['status'] as String;
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                File(entry['path'] as String),
                                fit: BoxFit.cover,
                              ),
                            ),
                            // overlay
                            if (status == 'uploading')
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  color: Colors.black54,
                                  child: Center(
                                    child: LoadingAnimationWidget.inkDrop(
                                      color: app_theme.cyanGlow,
                                      size: 22,
                                    ),
                                  ),
                                ),
                              ),
                            if (status == 'done')
                              Positioned(
                                top: 4,
                                right: 4,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: app_theme.cyanGlow,
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(2),
                                  child: const Icon(Icons.check,
                                      size: 12, color: Colors.black),
                                ),
                              ),
                            if (status == 'error')
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () => uploadPhoto(i),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(2),
                                    child: const Icon(Icons.refresh,
                                        size: 12, color: Colors.white),
                                  ),
                                ),
                              ),
                            // remove button
                            if (status != 'uploading')
                              Positioned(
                                bottom: 4,
                                left: 4,
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => photoQueue.removeAt(i)),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(2),
                                    child: const Icon(Icons.close,
                                        size: 12, color: Colors.white),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                  ],
                  // Add more photos button
                  GestureDetector(
                    onTap: pickPhotos,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: app_theme.surfaceElevated,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: app_theme.cyanGlow.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_photo_alternate_outlined,
                              color: app_theme.cyanGlow, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            photoQueue.isEmpty ? 'Pilih Foto' : 'Tambah Foto',
                            style: const TextStyle(
                                color: app_theme.cyanGlow,
                                fontWeight: FontWeight.w600,
                                fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }

            // ── single-file status widget ─────────────────────────────
            Widget buildSingleFileStatus() {
              return Container(
                alignment: Alignment.center,
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.08,
                decoration: BoxDecoration(
                  color: app_theme.surfaceElevated,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                      color: const Color.fromRGBO(167, 223, 255, 0.16)),
                ),
                child: selectImageTap == null
                    ? GestureDetector(
                        onTap: pickSingleFile,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          alignment: Alignment.center,
                          child: Text(
                            uploadTitle ?? 'Select File',
                            style: TextStyle(
                              color: app_theme.secondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      )
                    : selectImageTap == false
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 7),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    uploadingFileName ??
                                        context.lwTranslate.uploading,
                                    style: const TextStyle(
                                        color: app_theme.lavenderWhite,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 11),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(context.lwTranslate.uploading,
                                    style: const TextStyle(
                                        color: app_theme.secondary,
                                        fontSize: 10)),
                                const SizedBox(width: 4),
                                SizedBox(
                                  width: 15,
                                  height: 15,
                                  child: LoadingAnimationWidget.inkDrop(
                                    color: app_theme.cyanGlow,
                                    size: 15,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 7),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    uploadingFileName ??
                                        context.lwTranslate.uploading,
                                    style: const TextStyle(
                                        color: app_theme.cyanGlow,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 11),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(context.lwTranslate.uploadComplete,
                                    style: const TextStyle(
                                        color: app_theme.cyanGlow,
                                        fontSize: 10)),
                                const SizedBox(width: 4),
                                const Icon(Icons.check_circle,
                                    color: app_theme.cyanGlow, size: 16),
                              ],
                            ),
                          ),
              );
            }

            // ── build ─────────────────────────────────────────────────
            final bool canSend = isImage ? allDone : selectImageTap == true;

            return AlertDialog(
              backgroundColor: app_theme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24.0),
                side: const BorderSide(
                  color: Color.fromRGBO(167, 223, 255, 0.16),
                ),
              ),
              actionsPadding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 15),
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
                    const SizedBox(height: 8),
                    // File picker area
                    isImage ? buildPhotoGrid() : buildSingleFileStatus(),
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
                        minLines: 5,
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
              // Cancel left, Send right
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Cancel
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        backgroundColor: app_theme.surfaceElevated,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        context.lwTranslate.cancel,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                    // Send
                    LoadingButton(
                      defaultWidget: Text(
                        context.lwTranslate.send,
                        style: TextStyle(
                          color:
                              canSend ? app_theme.black : app_theme.secondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      color: canSend
                          ? app_theme.cyanGlow
                          : app_theme.surfaceElevated,
                      width: 90,
                      height: 40,
                      onPressed: canSend
                          ? () async {
                              if (isImage) {
                                // Send each uploaded photo as separate message.
                                bool allSent = true;
                                for (final entry in photoQueue) {
                                  final d =
                                      entry['data'] as Map<String, dynamic>?;
                                  if (d == null) continue;
                                  final sent = await controller.sendMediaN(
                                    uploadingFileNameMedia:
                                        d['fileName']?.toString() ?? '',
                                    caption: textController.text,
                                    data: d,
                                    label: label,
                                    context: context,
                                  );
                                  if (!sent) allSent = false;
                                }
                                if (allSent && context.mounted) {
                                  Navigator.pop(context);
                                }
                              } else {
                                if (uploadedData == null) {
                                  showToastMessage(
                                    context,
                                    context.lwTranslate.pleaseUploadFile,
                                    type: context.lwTranslate.error,
                                  );
                                  return;
                                }
                                final isSent = await controller.sendMediaN(
                                  uploadingFileNameMedia:
                                      uploadingFileName.toString(),
                                  caption: textController.text,
                                  data: uploadedData!,
                                  label: label,
                                  context: context,
                                );
                                if (isSent && context.mounted) {
                                  Navigator.pop(context);
                                }
                              }
                            }
                          : null,
                    ),
                  ],
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

  void _showTemplateSelectorDialog(BuildContext context) {
    controller.loadTemplates();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        String? selectedTemplateUid;

        return Dialog(
          elevation: 24,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: app_theme.surface,
          child: StatefulBuilder(
            builder: (context, setDialogState) {
              return Container(
                width: MediaQuery.of(context).size.width * 0.85,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.7,
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with Icon
                    Row(
                      children: [
                        const Icon(
                          CupertinoIcons.info_circle_fill,
                          color: app_theme.cyanGlow,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Mengaktifkan Obrolan',
                            style: TextStyle(
                              color: app_theme.lavenderWhite,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Explanation Text
                    const Text(
                      'Skema 24 Jam WhatsApp:\nUntuk menjaga kualitas layanan pelanggan, WhatsApp membatasi jendela percakapan selama 24 jam sejak pesan terakhir dari pelanggan.\n\nKarena jendela telah tertutup, Anda harus mengirimkan Pesan Template WhatsApp resmi untuk mengaktifkan obrolan kembali. Obrolan biasa akan terbuka kembali setelah pelanggan membalas pesan Anda.',
                      style: TextStyle(
                        color: app_theme.secondary,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'Pilih Template Message',
                      style: TextStyle(
                        color: app_theme.lavenderWhite,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Selector/Dropdown
                    Obx(() {
                      if (controller.isLoadingTemplates.value) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: CircularProgressIndicator(
                              color: app_theme.cyanGlow,
                            ),
                          ),
                        );
                      }

                      if (controller.templatesList.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Colors.red.withValues(alpha: 0.2)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.error_outline, color: Colors.red),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Tidak ada template yang disetujui WhatsApp. Silakan buat atau sinkronkan template di web panel.',
                                  style: TextStyle(
                                      color: Colors.red, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: app_theme.surfaceElevated,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: app_theme.cyanGlow.withValues(alpha: 0.2),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButtonFormField<String>(
                            dropdownColor: app_theme.surface,
                            initialValue: selectedTemplateUid,
                            hint: const Text(
                              'Pilih salah satu template...',
                              style: TextStyle(
                                  color: app_theme.secondary, fontSize: 13),
                            ),
                            icon: const Icon(CupertinoIcons.chevron_down,
                                color: app_theme.iceBlue, size: 18),
                            items: controller.templatesList.map((template) {
                              final name =
                                  template['template_name']?.toString() ??
                                      'Unnamed';
                              final lang =
                                  template['language']?.toString() ?? '';
                              final category =
                                  template['category']?.toString() ?? '';
                              return DropdownMenuItem<String>(
                                value: template['_uid']?.toString(),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      name,
                                      style: const TextStyle(
                                        color: app_theme.lavenderWhite,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '$category • $lang',
                                      style: const TextStyle(
                                        color: app_theme.secondary,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setDialogState(() {
                                selectedTemplateUid = val;
                              });
                            },
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 24),

                    // Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: const Text(
                            'Batal',
                            style: TextStyle(
                              color: app_theme.secondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: selectedTemplateUid != null
                                ? app_theme.cyanGlow
                                : app_theme.surfaceElevated,
                            foregroundColor: selectedTemplateUid != null
                                ? Colors.black
                                : app_theme.secondary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                          onPressed: selectedTemplateUid == null
                              ? null
                              : () async {
                                  Navigator.pop(dialogContext);

                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) => Center(
                                      child:
                                          LoadingAnimationWidget.discreteCircle(
                                        color: Colors.white,
                                        size: 40,
                                      ),
                                    ),
                                  );

                                  final success =
                                      await controller.sendTemplateMessage(
                                    context,
                                    selectedTemplateUid!,
                                  );

                                  if (context.mounted) {
                                    Navigator.pop(context); // Pop loader
                                    if (success) {
                                      showToastMessage(
                                        context,
                                        'Pesan template berhasil dikirim!',
                                        type: 'success',
                                      );
                                    }
                                  }
                                },
                          child: const Text(
                            'Kirim Template',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

/// Compact icon button used in the chat AppBar actions.
class _AppBarIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _AppBarIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.05),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.07),
                width: 1,
              ),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: app_theme.iceBlue, size: 17),
          ),
        ),
      ),
    );
  }
}
