import 'dart:convert';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:flutter_html/flutter_html.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:stundaa/services/utils.dart';
import 'package:stundaa/common/widgets/appinio_video_player.dart';
import 'package:stundaa/services/html_formatter.dart';
import 'package:stundaa/support/app_theme.dart' as app_theme;
import 'package:stundaa/screens/user/user_common.dart';
import 'package:stundaa/screens/whatsapp/componets/imagedetails.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:just_audio/just_audio.dart';
import 'package:get/get.dart';
import 'package:stundaa/screens/whatsapp/controller/chatbox_controller.dart';
import 'package:stundaa/screens/whatsapp/controller/audio_controller.dart';

class MessageBubble extends StatefulWidget {
  final String? message;
  final String? status;
  final String? messagedAt;
  final String? formattedMessagedAt;
  final String? templateMessage;
  final String? whatsAppError;
  final String? formattedTime;
  final bool? isCurrentUser;
  final bool isIncoming;
  final bool isSystem;
  final String? errorDetails;
  final String? statusCode;
  final String? mediaLink;
  final String? mediaType;
  final String? mediaCaption;
  final String? mediaFileName;
  final String? mediaMimeType;
  final String? mediaoOriginalFileName;
  final Map<String, dynamic>? media;
  final Map<String, dynamic>? data;
  final Map<String, dynamic>? quotedMessage;
  final String? quotedSenderName;
  final bool hasQuotedMessage;
  final VoidCallback? onQuotedMessageTap;

  const MessageBubble({
    super.key,
    this.message,
    this.status,
    this.messagedAt,
    this.formattedMessagedAt,
    this.templateMessage,
    this.whatsAppError,
    this.formattedTime,
    this.isCurrentUser,
    required this.isIncoming,
    required this.isSystem,
    this.errorDetails,
    this.statusCode,
    this.mediaLink,
    this.mediaType,
    this.mediaCaption,
    this.mediaFileName,
    this.mediaMimeType,
    this.mediaoOriginalFileName,
    this.media,
    this.data,
    this.quotedMessage,
    this.quotedSenderName,
    this.hasQuotedMessage = false,
    this.onQuotedMessageTap,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble>
    with AutomaticKeepAliveClientMixin {
  static const Color _replyAccent = Color(0xFF69B7FF);
  static const Color _incomingBubble = Color(0xFF0F2034);
  static const Color _outgoingBubble = Color(0xFF18395B);
  static const Color _replySurfaceLight = Color(0xFF142A41);
  static const Color _replySurfaceDark = Color(0xFF173754);
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  final ChatboxController controller = Get.put(ChatboxController());
  GlobalAudioManager get _audioManager {
    if (!Get.isRegistered<GlobalAudioManager>()) {
      Get.put(GlobalAudioManager());
    }
    return Get.find<GlobalAudioManager>();
  }
  Map<String, dynamic>? parsedData = {};

  @override
  bool get wantKeepAlive => true;
  bool _isLoading = true;
  @override
  void initState() {
    _initializeMedia();
    _simulateLoading();
    if (widget.data!.isNotEmpty) {
      if (widget.data is String) {
        try {
          parsedData =
              jsonDecode(widget.data as String) as Map<String, dynamic>;
        } catch (e) {
          pr("Failed to decode message data: $e");
        }
      } else if (widget.data is Map<String, dynamic>) {
        parsedData = widget.data!;
      }
    }
    super.initState();
  }

  void _simulateLoading() async {
    await Future.delayed(Duration(seconds: 3));
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _launchURL(String? url) async {
    if (url == null) return;
    try {
      Uri uri = Uri.parse(url);
      if (isImageUrl(uri)) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileImageView(imageUrl: uri.toString()),
          ),
        );
      } else {
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      }
    } catch (e) {
      pr("Failed to open media link: $e");
    }
  }

  bool isImageUrl(Uri uri) {
    return RegExp(r'\.(jpeg|jpg|png|gif|bmp|svg|webp)$', caseSensitive: false)
        .hasMatch(uri.path);
  }

  bool _mediaError = false;

  void _initializeMedia() async {
    if (widget.mediaType == 'video' && widget.mediaLink != null) {
      await _disposeVideoController();

      try {
        _videoController =
            VideoPlayerController.networkUrl(Uri.parse(widget.mediaLink!));

        await _videoController!.initialize();

        if (mounted) {
          setState(() {
            _mediaError = false;
            _chewieController = ChewieController(
              videoPlayerController: _videoController!,
              aspectRatio: _videoController!.value.aspectRatio,
              placeholder: Center(
                child: LoadingAnimationWidget.hexagonDots(
                  color: Colors.white,
                  size: 30,
                ),
              ),
              autoInitialize: true,
              errorBuilder: (context, errorMessage) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.white, size: 42),
                      const SizedBox(height: 8),
                      const Text('Failed to load video',
                          style: TextStyle(color: Colors.white)),
                    ],
                  ),
                );
              },
            );
          });
        }
      } catch (e) {
        pr("Failed to initialize video player: $e");
        if (mounted) {
          setState(() {
            _mediaError = true;
          });
        }
      }
    } else if (widget.mediaType == 'audio' && widget.mediaLink != null) {
      if (mounted) {
        setState(() {
          _mediaError = false;
        });
      }
    }
  }

  Future<void> _disposeVideoController() async {
    if (_chewieController != null) {
      _chewieController!.dispose();
      _chewieController = null;
    }
    if (_videoController != null) {
      await _videoController!.dispose();
      _videoController = null;
    }
  }

  Widget _buildMediaWidget() {
    if (_mediaError) {
      return Container(
        height: 100,
        decoration: BoxDecoration(
          color: app_theme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: app_theme.outlineSoft),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.broken_image_outlined,
                  color: app_theme.error, size: 32),
              SizedBox(height: 8),
              Text('Media unavailable',
                  style: TextStyle(color: app_theme.secondary, fontSize: 12)),
            ],
          ),
        ),
      );
    }
    if (widget.mediaType == 'video' && widget.mediaLink != null) {
      return Container(
        decoration: BoxDecoration(
          color: app_theme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: app_theme.outlineSoft),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: app_theme.surfaceElevated,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppinioVideoPlayer(
                  videoUrl: widget.mediaLink!,
                  caption: "",
                  autoPlay: false,
                  looping: true,
                ),
                if (widget.mediaCaption != null &&
                    widget.mediaCaption!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 8, top: 5),
                    child: Text(
                      widget.mediaCaption!,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: app_theme.lavenderWhite,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    } else if (widget.mediaType == 'audio' && widget.mediaLink != null) {
      return Container(
        decoration: BoxDecoration(
          color: app_theme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: app_theme.outlineSoft),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: app_theme.surfaceElevated,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: app_theme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: app_theme.outlineSoft),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        Text(
                          widget.mediaoOriginalFileName ?? 'Audio File',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: app_theme.lavenderWhite,
                          ),
                        ),
                        SizedBox(height: 5),
                        Obx(() {
                          final mgr = _audioManager;
                          final isThisUrl = mgr.currentUrl.value == widget.mediaLink;
                          return StreamBuilder<Duration>(
                            stream: mgr.positionStream,
                            builder: (context, positionSnapshot) {
                              return StreamBuilder<Duration?>(
                                stream: mgr.durationStream,
                                builder: (context, durationSnapshot) {
                                  final position = isThisUrl
                                      ? (positionSnapshot.data ?? Duration.zero)
                                      : Duration.zero;
                                  final duration = isThisUrl
                                      ? (durationSnapshot.data ?? Duration.zero)
                                      : Duration.zero;
                                  return Column(
                                    children: [
                                      Slider(
                                        inactiveColor: app_theme.secondary
                                            .withValues(alpha: 0.35),
                                        activeColor: app_theme.cyanGlow,
                                        value: position.inSeconds.toDouble(),
                                        min: 0,
                                        max: duration.inSeconds > 0
                                            ? duration.inSeconds.toDouble()
                                            : 1.0,
                                        onChanged: (value) {
                                          if (isThisUrl) {
                                            mgr.seek(Duration(seconds: value.toInt()));
                                          }
                                        },
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(_formatDuration(position)),
                                            StreamBuilder<PlayerState>(
                                              stream: mgr.playerStateStream,
                                              builder: (context, snapshot) {
                                                final playerState = snapshot.data;
                                                final processingState =
                                                    playerState?.processingState;
                                                final playing = isThisUrl &&
                                                    (playerState?.playing ?? false);
                                                if (isThisUrl &&
                                                    (processingState ==
                                                            ProcessingState.loading ||
                                                        processingState ==
                                                            ProcessingState.buffering)) {
                                                  return const SizedBox(
                                                      height: 20,
                                                      width: 20,
                                                      child: CircularProgressIndicator(
                                                        color: app_theme.cyanGlow,
                                                      ));
                                                }
                                                return IconButton(
                                                  icon: Icon(
                                                    playing
                                                        ? CupertinoIcons.pause_circle_fill
                                                        : CupertinoIcons.play_circle_fill,
                                                  ),
                                                  onPressed: () {
                                                    mgr.playUrl(widget.mediaLink!);
                                                  },
                                                );
                                              },
                                            ),
                                            Text(_formatDuration(duration)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                if (widget.mediaCaption != null &&
                    widget.mediaCaption!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, top: 2, bottom: 3),
                    child: Text(
                      widget.mediaCaption!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: app_theme.lavenderWhite,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    } else if (widget.mediaType == 'image' && widget.mediaLink != null) {
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => Imagedetails(imageUrl: widget.mediaLink),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: app_theme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: app_theme.outlineSoft),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(17),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  widget.mediaLink!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      height: 180,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        color: app_theme.cyanGlow,
                        value: progress.expectedTotalBytes != null
                            ? progress.cumulativeBytesLoaded /
                                progress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 120,
                    alignment: Alignment.center,
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.broken_image_outlined,
                            color: app_theme.error, size: 32),
                        SizedBox(height: 4),
                        Text('Image unavailable',
                            style: TextStyle(
                                color: app_theme.secondary, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
                if (widget.mediaCaption != null &&
                    widget.mediaCaption!.isNotEmpty)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: Text(
                      widget.mediaCaption!,
                      style: const TextStyle(
                        color: app_theme.lavenderWhite,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    } else if (widget.mediaType == 'document' && widget.mediaLink != null) {
      return Container(
        decoration: BoxDecoration(
          color: app_theme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: app_theme.outlineSoft),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: app_theme.surfaceElevated,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: app_theme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: app_theme.outlineSoft),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Document: ${widget.mediaoOriginalFileName}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: app_theme.lavenderWhite,
                          ),
                        ),
                        SizedBox(height: 8),
                        Center(
                          child: Icon(
                            _getFileIcon(widget.mediaMimeType),
                            size: 40,
                            color: app_theme.cyanGlow,
                          ),
                        ),
                        SizedBox(height: 8),
                        Center(
                          child: ElevatedButton(
                            onPressed: () => _launchURL(widget.mediaLink),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: app_theme.cyanGlow,
                            ),
                            child: Text(
                              context.lwTranslate.openDocument,
                              style: const TextStyle(color: app_theme.black),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (widget.mediaCaption != null &&
                    widget.mediaCaption!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 8, top: 5),
                    child: Text(
                      widget.mediaCaption!,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: app_theme.lavenderWhite,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }
    return Container();
  }

  IconData _getFileIcon(String? mimeType) {
    if (mimeType == null) return CupertinoIcons.doc;
    if (mimeType.contains('pdf')) return CupertinoIcons.doc_richtext;
    if (mimeType.contains('word')) return CupertinoIcons.doc_text;
    if (mimeType.contains('excel')) return CupertinoIcons.table;
    return CupertinoIcons.doc;
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  Widget _buildQuotedMessage() {
    if (!widget.hasQuotedMessage) {
      return const SizedBox.shrink();
    }

    final quotedMessage = widget.quotedMessage;
    final previewController = controller;
    final senderName = quotedMessage == null
        ? 'Original message'
        : widget.quotedSenderName ?? 'Original message';
    final preview = quotedMessage == null
        ? 'Original message is not loaded'
        : previewController.buildReplyPreviewText(
            quotedMessage,
            fallback: 'Original message is not loaded',
          );

    return InkWell(
      onTap: widget.onQuotedMessageTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 9),
        decoration: BoxDecoration(
          color: widget.isIncoming ? _replySurfaceLight : _replySurfaceDark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _replyAccent.withValues(alpha: 0.35),
          ),
          boxShadow: [
            BoxShadow(
              color: _replyAccent.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: _replyAccent,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        CupertinoIcons.arrowshape_turn_up_left_fill,
                        size: 14,
                        color: _replyAccent,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Replying to $senderName',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _replyAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    preview,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF35506B),
                      fontSize: 12,
                      height: 1.25,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _videoController?.removeListener(() {});
    _videoController?.pause();
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    Alignment alignment;
    if (widget.isSystem && widget.isIncoming) {
      alignment = Alignment.centerLeft;
    } else if (!widget.isIncoming) {
      alignment = Alignment.centerRight;
    } else {
      alignment = Alignment.centerLeft;
    }

    return Align(
      alignment: widget.isSystem ? Alignment.center : alignment,
      child: Column(
        children: [
          if (widget.isSystem)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: app_theme.surfaceElevated,
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                border: Border.all(color: app_theme.outlineSoft),
              ),
              child: Text(
                widget.formattedMessagedAt.toString(),
                style: const TextStyle(
                  fontSize: 10,
                  color: app_theme.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          SizedBox(
            height: 5,
          ),
          Container(
              padding: !widget.isIncoming
                  ? widget.isSystem
                      ? EdgeInsets.all(2)
                      : EdgeInsets.all(5)
                  : EdgeInsets.all(3),
              width: widget.isIncoming
                  ? MediaQuery.of(context).size.width * 0.6
                  : widget.isSystem
                      ? MediaQuery.of(context).size.width * 0.8
                      : MediaQuery.of(context).size.width * 0.6,
              decoration: BoxDecoration(
                color: !widget.isIncoming
                    ? widget.isSystem
                        ? Colors.grey.shade100
                        : _outgoingBubble
                    : _incomingBubble,
                borderRadius: widget.isSystem
                    ? const BorderRadius.all(Radius.circular(12))
                    : BorderRadius.circular(22),
                border: Border.all(
                  color: widget.isIncoming
                      ? const Color.fromRGBO(167, 223, 255, 0.18)
                      : const Color.fromRGBO(73, 200, 255, 0.24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2F86FF).withValues(alpha: 0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),

              // elevation: widget.isSystem ? 0.3 : 0.5,
              // shape: RoundedRectangleBorder(borderRadius: widget.isSystem ? BorderRadius.circular(4) : BorderRadius.circular(8)),

              margin: widget.isSystem
                  ? EdgeInsets.only(right: 20)
                  : EdgeInsets.only(left: 5),
              child: Padding(
                padding: widget.isSystem
                    ? EdgeInsets.symmetric(vertical: 3, horizontal: 20)
                    : const EdgeInsets.all(6.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: widget.isSystem
                          ? CrossAxisAlignment.center
                          : CrossAxisAlignment.start,
                      children: [
                        _buildQuotedMessage(),
                        _buildMediaWidget(),
                        if (widget.data?["template_proforma"] != null &&
                            widget.data!["template_proforma"]["components"]
                                is List)
                          _buildTemplateProformaContent(
                              widget.data!["template_proforma"]),
                        widget.templateMessage == null ||
                                widget.templateMessage == "" ||
                                widget.mediaType == 'document' ||
                                widget.mediaType == 'audio' ||
                                widget.mediaType == 'video' ||
                                (widget.data?["template_proforma"] != null &&
                                    widget.data!["template_proforma"]
                                        ["components"] is List &&
                                    widget.data!["template_proforma"]
                                            ["components"]
                                        .any((c) => c["type"] == "CAROUSEL"))
                            ? Container()
                            : Container(
                                color: Colors.transparent,
                                child: _isLoading
                                    ? Center(
                                        child:
                                            LoadingAnimationWidget.hexagonDots(
                                          color: app_theme.cyanGlow,
                                          size: 20,
                                        ),
                                      )
                                    : Html(
                                        data: widget.templateMessage ?? "",
                                        style: {
                                          "body": Style(
                                            color: app_theme.lavenderWhite,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          "h3": Style(
                                            color: app_theme.lavenderWhite,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          "div": Style(
                                              color: app_theme.lavenderWhite,
                                              fontSize: FontSize(13),
                                              fontWeight: FontWeight.w400),
                                          "div.lw-whatsapp-buttons .list-group-item":
                                              Style(
                                                  padding: HtmlPaddings.all(3),
                                                  fontSize: FontSize(14),
                                                  backgroundColor:
                                                      app_theme.surfaceElevated,
                                                  color: app_theme.cyanGlow,
                                                  textAlign: TextAlign.center,
                                                  fontWeight: FontWeight.w800),
                                          "div.list-group.list-group-flush.lw-whatsapp-buttons":
                                              Style(
                                                  padding: HtmlPaddings.all(3),
                                                  margin: Margins.symmetric(
                                                      horizontal: 5),
                                                  fontSize: FontSize(14),
                                                  backgroundColor:
                                                      app_theme.surface,
                                                  border: Border.all(
                                                      color: app_theme.cyanGlow,
                                                      width: 0.2),
                                                  color: app_theme.cyanGlow,
                                                  textAlign: TextAlign.center,
                                                  fontWeight: FontWeight.w800),
                                          "div .list-group-item": Style(
                                            padding: HtmlPaddings.all(3),
                                            fontSize: FontSize(14),
                                            backgroundColor:
                                                app_theme.surfaceElevated,
                                            color: app_theme.cyanGlow,
                                            textAlign: TextAlign.center,
                                            fontWeight: FontWeight.w800,
                                            textDecoration: TextDecoration.none,
                                            border: Border.all(
                                                color: Colors.transparent),
                                          ),
                                          "div .list-group.list-group-flush .lw-whatsapp-buttons":
                                              Style(
                                                  backgroundColor:
                                                      app_theme.surface,
                                                  fontSize: FontSize(13),
                                                  fontWeight: FontWeight.w800),
                                          "div .fa-reply:before": Style(
                                              backgroundColor:
                                                  app_theme.surface,
                                              fontSize: FontSize(13),
                                              fontWeight: FontWeight.w800),
                                          "div.card": Style(
                                              padding: HtmlPaddings.all(3),
                                              backgroundColor:
                                                  app_theme.surfaceElevated,
                                              fontSize: FontSize(13),
                                              fontWeight: FontWeight.w800),
                                          "div.lw-whatsapp-footer.text-muted":
                                              Style(
                                            color: app_theme.secondary,
                                            fontSize: FontSize(13),
                                            fontWeight: FontWeight.w600,
                                          ),
                                          "img": Style(
                                            display: Display.inlineBlock,
                                          ),
                                        },
                                        extensions: [
                                          TagExtension(
                                            tagsToExtend: {"strong"},
                                            builder: (extensionContext) {
                                              final element =
                                                  extensionContext.element;
                                              final text =
                                                  element?.innerHtml ?? "";
                                              return Text(
                                                text,
                                                style: const TextStyle(
                                                  color:
                                                      app_theme.lavenderWhite,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              );
                                            },
                                          ),
                                          TagExtension(
                                            tagsToExtend: {"i"},
                                            builder: (extensionContext) {
                                              final text = extensionContext
                                                      .element?.innerHtml ??
                                                  "";
                                              return Text(
                                                text,
                                                style: const TextStyle(
                                                  color: app_theme.error,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                        onLinkTap:
                                            (url, attributes, element) async {
                                          if (url != null) {
                                            _launchURL(url);
                                          }
                                        },
                                      ),
                              ),
                        if (widget.message != null &&
                            widget.message!.isNotEmpty &&
                            widget.templateMessage!.isEmpty)
                          RichText(
                            text: WhatsAppHtmlFormatter.format(
                              widget.message
                                      ?.replaceAll('<em>', '')
                                      .replaceAll('</em>', '') ??
                                  "",
                              baseStyle: widget.isSystem
                                  ? TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w100,
                                      color: app_theme.secondary)
                                  : TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w100,
                                      color: app_theme.lavenderWhite,
                                    ),
                            ),
                          ),
                        if (widget.isIncoming)
                          widget.whatsAppError.toString() != ""
                              ? Row(
                                  children: [
                                    widget.whatsAppError.toString() != ""
                                        ? const Icon(
                                            Icons.error,
                                            color: Colors.red,
                                            size: 15,
                                          )
                                        : Container(),
                                    const SizedBox(
                                      width: 4,
                                    ),
                                    Expanded(
                                      child: Text(
                                        widget.whatsAppError.toString(),
                                        style: GoogleFonts.roboto(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.red,
                                            fontStyle: FontStyle.italic),
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                  ],
                                )
                              : Container(),

                        // widget.data?["template_proforma"]!= null
                      ],
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        widget.isSystem
                            ? Container()
                            : Text(
                                widget.formattedMessagedAt.toString(),
                                style: const TextStyle(
                                  fontSize: 8,
                                  color: Color(0xFF5C738F),
                                ),
                              ),
                        const SizedBox(width: 10),
                        if (!widget.isIncoming)
                          widget.status == "sent"
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.grey,
                                  size: 15,
                                )
                              : widget.status == "failed"
                                  ? GestureDetector(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => Dialog(
                                            elevation: 24,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            backgroundColor: app_theme.surface,
                                            child: Padding(
                                              padding: const EdgeInsets.all(24),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  // Animated error icon
                                                  const Icon(
                                                    Icons.error,
                                                    color: Colors.red,
                                                    size: 45,
                                                  ),

                                                  const SizedBox(height: 16),

                                                  // Title
                                                  Text(
                                                    context.lwTranslate
                                                        .errorDetaila,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headlineSmall
                                                        ?.copyWith(
                                                          color:
                                                              app_theme.error,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                    textAlign: TextAlign.center,
                                                  ),

                                                  const SizedBox(height: 16),

                                                  // Error message
                                                  Text(
                                                    widget.whatsAppError
                                                        .toString(),
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium,
                                                    textAlign: TextAlign.center,
                                                  ),

                                                  const SizedBox(height: 24),

                                                  // Action button
                                                  SizedBox(
                                                    width: double.infinity,
                                                    child: ElevatedButton(
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            app_theme.error,
                                                        foregroundColor:
                                                            Colors.white,
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 16),
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                        ),
                                                      ),
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context),
                                                      child: Text(context
                                                          .lwTranslate.close
                                                          .toUpperCase()),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      child: const Icon(
                                        Icons.error,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                    )
                                  : widget.status == "pending"
                                      ? const Icon(
                                          Icons.watch_later_outlined,
                                          color: Colors.grey,
                                          size: 15,
                                        )
                                      : widget.status == "failed"
                                          ? const Icon(
                                              Icons.error_outline,
                                              color: Colors.red,
                                              size: 15,
                                            )
                                          : widget.status == "delivered" ||
                                                  widget.status == "sent"
                                              ? const Icon(
                                                  Icons.done_all,
                                                  color: Colors.grey,
                                                  size: 15,
                                                )
                                              : widget.status == "read"
                                                  ? const Icon(
                                                      Icons.done_all,
                                                      color: app_theme.cyanGlow,
                                                      size: 15,
                                                    )
                                                  : widget.status == "initialize"
                                                      ? Container()
                                                      : const Icon(
                                                          Icons.done,
                                                          color: Colors.grey,
                                                          size: 15,
                                                        )
                      ],
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildCarouselSlider(List<dynamic> cards) {
    final pageController = PageController();
    int currentPage = 0;
    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          children: [
            SizedBox(
              height: 300, // Increased height for better display
              child: Stack(
                children: [
                  PageView.builder(
                    controller: pageController,
                    itemCount: cards.length,
                    onPageChanged: (index) =>
                        setState(() => currentPage = index),
                    itemBuilder: (context, index) {
                      final card = cards[index];
                      final components = (card["components"] as List?) ?? [];
                      // Extract content
                      String? bodyText;
                      String? imageUrl;
                      String? videoUrl;
                      String? buttonText;
                      String? phoneNumber;
                      String? headerFormat;

                      for (var component in components) {
                        if (component["type"] == "BODY") {
                          bodyText = component["text"]?.toString();
                        } else if (component["type"] == "HEADER") {
                          headerFormat = component["format"]?.toString();
                          final example = component["example"];
                          if (example is Map &&
                              example["header_handle"] is List) {
                            final url = example["header_handle"][0]?.toString();
                            if (headerFormat == "IMAGE") {
                              imageUrl = url?.replaceAll('\\/', '/');
                            } else if (headerFormat == "VIDEO") {
                              videoUrl = url?.replaceAll('\\/', '/');
                            }
                          }
                        } else if (component["type"] == "BUTTONS") {
                          final buttons = component["buttons"] as List? ?? [];
                          if (buttons.isNotEmpty) {
                            final button = buttons[0];
                            buttonText = button["text"]?.toString();
                            if (button["type"] == "PHONE_NUMBER") {
                              phoneNumber = button["phone_number"]?.toString();
                            }
                          }
                        }
                      }

                      // Check template_component_values for actual media URLs
                      final templateValues =
                          widget.data?["template_component_values"] as List?;
                      if (templateValues != null && templateValues.isNotEmpty) {
                        final carouselValues = templateValues.firstWhere(
                          (value) => value["type"] == "carousel",
                          orElse: () => null,
                        );

                        if (carouselValues != null &&
                            carouselValues["cards"] is List) {
                          final cardValues = carouselValues["cards"][index];
                          if (cardValues != null) {
                            final headerParams =
                                cardValues["components"]?.firstWhere(
                              (comp) => comp["type"] == "header",
                              orElse: () => null,
                            )?["parameters"] as List?;

                            if (headerParams != null &&
                                headerParams.isNotEmpty) {
                              final mediaParam = headerParams[0];
                              if (mediaParam["type"] == "image") {
                                imageUrl =
                                    mediaParam["image"]?["link"]?.toString();
                              } else if (mediaParam["type"] == "video") {
                                videoUrl =
                                    mediaParam["video"]?["link"]?.toString();
                              }
                            }
                          }
                        }
                      }

                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: 0),
                        decoration: BoxDecoration(
                          color: app_theme.surface,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withValues(alpha: 0.2),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header media (image or video)
                            if (imageUrl != null || videoUrl != null)
                              ClipRRect(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20),
                                  bottom: Radius.circular(20),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: app_theme.surfaceElevated,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    height: 170,
                                    width: double.infinity,
                                    child: Stack(
                                      children: [
                                        if (imageUrl != null)
                                          GestureDetector(
                                            onTap: () => _launchURL(imageUrl),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(15.0),
                                              child: Image.network(
                                                imageUrl,
                                                fit: BoxFit.fill,
                                                loadingBuilder:
                                                    (context, child, progress) {
                                                  if (progress == null) {
                                                    return child;
                                                  }
                                                  return Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                      color: app_theme.cyanGlow,
                                                    ),
                                                  );
                                                },
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  return Center(
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(Icons.image,
                                                            size: 40),
                                                        SizedBox(height: 8),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        if (videoUrl != null)
                                          SizedBox(
                                            height: 150,
                                            child: AppinioVideoPlayer(
                                              videoUrl: videoUrl,
                                              caption: "",
                                              autoPlay: false,
                                              looping: true,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                            // Body text
                            if (bodyText != null)
                              Padding(
                                padding: EdgeInsets.fromLTRB(12, 12, 12, 8),
                                child: Text(
                                  bodyText,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: app_theme.lavenderWhite,
                                  ),
                                ),
                              ),
                            Divider(
                              thickness: 1,
                              color: const Color.fromRGBO(167, 223, 255, 0.12),
                            ),
                            // Button
                            if (buttonText != null)
                              Padding(
                                padding: EdgeInsets.only(bottom: 0),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      // backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      // padding: EdgeInsets.symmetric(
                                      //     vertical: 10),
                                    ),
                                    onPressed: () {
                                      // final uri = Uri.parse('tel:$phoneNumber');
                                      // launchUrl(uri);
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        if (phoneNumber != null)
                                          Icon(Icons.phone,
                                              size: 18,
                                              color: app_theme.cyanGlow),
                                        SizedBox(width: 0),
                                        Text(
                                          buttonText,
                                          style: const TextStyle(
                                            color: app_theme.cyanGlow,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),

                  // Navigation arrows
                  if (cards.length > 1) ...[
                    Positioned(
                      left: -10,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: IconButton(
                          icon: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            color: Colors
                                .transparent, // Make card background transparent
                            elevation: 2,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: 5.0, // Adjust blur intensity
                                  sigmaY: 5.0, // Adjust blur intensity
                                ),
                                child: Container(
                                  color: Colors.white.withValues(
                                      alpha: 0.5), // Semi-transparent white
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Icon(
                                      Icons.chevron_left,
                                      color: Colors.black54,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          onPressed: currentPage > 0
                              ? () {
                                  setState(() {
                                    pageController.previousPage(
                                      duration: Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    );
                                  });
                                }
                              : null,
                        ),
                      ),
                    ),
                    Positioned(
                      right: -12,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: IconButton(
                          icon: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            color: Colors.transparent,
                            elevation: 2,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: 5.0,
                                  sigmaY: 5.0,
                                ),
                                child: Container(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Icon(
                                      Icons.chevron_right,
                                      color: Colors.black54,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          onPressed: currentPage < cards.length - 1
                              ? () {
                                  pageController.nextPage(
                                    duration: Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              : null,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Page indicators
            // if (cards.length > 1)
            //   Padding(
            //     padding: EdgeInsets.only(top: 8),
            //     child: Row(
            //       mainAxisAlignment: MainAxisAlignment.center,
            //       children: List.generate(cards.length, (index) {
            //         return Container(
            //           width: 8,
            //           height: 8,
            //           margin: EdgeInsets.symmetric(horizontal: 4),
            //           decoration: BoxDecoration(
            //             shape: BoxShape.circle,
            //             color: currentPage == index
            //                 ? Colors.grey[800]
            //                 : Colors.grey[300],
            //           ),
            //         );
            //       }),
            //     ),
            //   ),
          ],
        );
      },
    );
  }

  Widget _buildTemplateProformaContent(Map<String, dynamic> templateProforma) {
    final components = templateProforma["components"] as List;

    // Find CAROUSEL component
    final carouselComponent = components.firstWhere(
      (component) =>
          component is Map &&
          component["type"] == "CAROUSEL" &&
          component["cards"] is List,
      orElse: () => null,
    );

    // If we have a carousel, show only that
    if (carouselComponent != null && carouselComponent["cards"].isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Display the main body text if exists
          if (components.any((c) => c["type"] == "BODY"))
            Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text(
                components.firstWhere((c) => c["type"] == "BODY")["text"],
                style: const TextStyle(
                  fontSize: 14,
                  color: app_theme.lavenderWhite,
                ),
              ),
            ),

          // Display the carousel
          _buildCarouselSlider(carouselComponent["cards"]),
        ],
      );
    }

    // If no carousel, return empty container (the HTML will be shown by the parent widget)
    return Container();
  }
}
