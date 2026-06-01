import 'dart:convert';
import 'dart:ui';
import "package:flutter/material.dart";
import 'package:flutter_html/flutter_html.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:whatsjet_demo/services/utils.dart';
import '../../../common/widgets/appinio_video_player.dart';
import '../../../services/html_formatter.dart';
import '../../user/user_common.dart';
import 'package:appinio_video_player/appinio_video_player.dart';
import 'package:just_audio/just_audio.dart';
import 'package:get/get.dart';
import '../controller/chatbox_controller.dart';

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
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble>
    with AutomaticKeepAliveClientMixin {
  VideoPlayerController? _videoController;
  CustomVideoPlayerController? _customVideoPlayerController;
  final ChatboxController controller = Get.put(ChatboxController());
  AudioPlayer? _audioPlayer;
  Map<String, dynamic>? parsedData = {};

  @override
  bool get wantKeepAlive => true;
  bool _isLoading = true;
  @override
  void initState() {
    if (context.mounted) {
      _initializeMedia();
      _simulateLoading();
      if (widget.data!.isNotEmpty) {
        if (widget.data is String) {
          try {
            parsedData =
            jsonDecode(widget.data as String) as Map<String, dynamic>;
          } catch (e) {}
        } else if (widget.data is Map<String, dynamic>) {
          parsedData = widget.data!;
        }
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
        } else {}
      }
    } catch (e) {}
  }

  bool isImageUrl(Uri uri) {
    return RegExp(r'\.(jpeg|jpg|png|gif|bmp|svg|webp)$', caseSensitive: false)
        .hasMatch(uri.path);
  }

  void _initializeMedia() async {
    if (widget.mediaType == 'video' && widget.mediaLink != null) {
      await _disposeVideoController();

      try {
        _videoController = VideoPlayerController.network(widget.mediaLink!);

        // Add listener to track initialization
        _videoController!.addListener(() {
          if (_videoController!.value.isInitialized && mounted) {}
        });

        await _videoController!.initialize();

        if (mounted) {
          setState(() {
            _customVideoPlayerController = CustomVideoPlayerController(
              context: context,
              videoPlayerController: _videoController!,
              customVideoPlayerSettings: CustomVideoPlayerSettings(
                placeholderWidget: Center(
                  child: LoadingAnimationWidget.hexagonDots(
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                settingsButtonAvailable: true,
              ),
            );
          });
        }
      } catch (e) {
        if (mounted) {}
      }
    } else if (widget.mediaType == 'audio' && widget.mediaLink != null) {
      _audioPlayer = AudioPlayer();
      try {
        await _audioPlayer
            ?.setAudioSource(AudioSource.uri(Uri.parse(widget.mediaLink!)));
      } catch (e) {}
    }
  }

  Future<void> _disposeVideoController() async {
    if (_customVideoPlayerController != null) {
      _customVideoPlayerController!.dispose();
      _customVideoPlayerController = null;
    }
    if (_videoController != null) {
      await _videoController!.dispose();
      _videoController = null;
    }
    if (mounted) {}
  }

  Widget _buildMediaWidget() {
    if (widget.mediaType == 'video' && widget.mediaLink != null) {
      return Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            color: Color(0xDDEEFAEE),
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
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    } else if (widget.mediaType == 'audio' && widget.mediaLink != null) {
      return Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            color: Color(0xDDEEFAEE),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        Text(
                          widget.mediaoOriginalFileName ?? 'Audio File',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 5),
                        StreamBuilder<Duration>(
                          stream: _audioPlayer?.positionStream,
                          builder: (context, positionSnapshot) {
                            return StreamBuilder<Duration?>(
                              stream: _audioPlayer?.durationStream,
                              builder: (context, durationSnapshot) {
                                final position =
                                    positionSnapshot.data ?? Duration.zero;
                                final duration =
                                    durationSnapshot.data ?? Duration.zero;
                                return Column(
                                  children: [
                                    Slider(
                                      inactiveColor: Colors.green.shade100,
                                      value: position.inSeconds.toDouble(),
                                      min: 0,
                                      max: duration.inSeconds.toDouble(),
                                      onChanged: (value) {
                                        _audioPlayer?.seek(
                                            Duration(seconds: value.toInt()));
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
                                            stream:
                                            _audioPlayer?.playerStateStream,
                                            builder: (context, snapshot) {
                                              final playerState = snapshot.data;
                                              final processingState =
                                                  playerState?.processingState;
                                              final playing =
                                                  playerState?.playing ?? false;
                                              if (processingState ==
                                                  ProcessingState.loading ||
                                                  processingState ==
                                                      ProcessingState
                                                          .buffering) {
                                                return SizedBox(
                                                    height: 20,
                                                    width: 20,
                                                    child:
                                                    const CircularProgressIndicator(
                                                      color: Colors.black,
                                                    ));
                                              }

                                              return IconButton(
                                                icon: Icon(playing
                                                    ? Icons.pause_circle
                                                    : Icons.play_circle),
                                                onPressed: () {
                                                  playing
                                                      ? _audioPlayer?.pause()
                                                      : _audioPlayer?.play();
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
                        ),
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
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    } else if (widget.mediaType == 'document' && widget.mediaLink != null) {
      return Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            color: Color(0xDDEEFAEE),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Document: ${widget.mediaoOriginalFileName}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Center(
                          child: Icon(
                            _getFileIcon(widget.mediaMimeType),
                            size: 40,
                            color: Colors.blue,
                          ),
                        ),
                        SizedBox(height: 8),
                        Center(
                          child: ElevatedButton(
                            onPressed: () => _launchURL(widget.mediaLink),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            child: Text(
                              context.lwTranslate.openDocument,
                              style: TextStyle(color: Colors.white),
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
                      style: TextStyle(fontWeight: FontWeight.bold),
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
    if (mimeType == null) return Icons.insert_drive_file;
    if (mimeType.contains('pdf')) return Icons.picture_as_pdf;
    if (mimeType.contains('word')) return Icons.description;
    if (mimeType.contains('excel')) return Icons.table_chart;
    return Icons.insert_drive_file;
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  void dispose() {
    _videoController?.removeListener(() {});
    _videoController?.pause();
    _videoController?.dispose();
    _customVideoPlayerController?.dispose();
    _audioPlayer?.dispose();
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
              padding: EdgeInsets.all(8),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              child: Text(
                widget.formattedMessagedAt.toString(),
                style: const TextStyle(
                  fontSize: 8,
                  color: Colors.black87,
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
                  ? MediaQuery
                  .of(context)
                  .size
                  .width * 0.6
                  : widget.isSystem
                  ? MediaQuery
                  .of(context)
                  .size
                  .width * 0.8
                  : MediaQuery
                  .of(context)
                  .size
                  .width * 0.6,
              decoration: BoxDecoration(
                color: !widget.isIncoming
                    ? widget.isSystem
                    ?
                Colors.grey.shade100
                    : const Color(0xFFD3FFC3)
                // Color(0xffdcf8c6)
                    : Colors.white,
                borderRadius: widget.isSystem ? BorderRadius.all(Radius.circular(8)) :BorderRadius.all(Radius.circular(5)),
                border: Border.all(color: Colors.grey.shade200),
              ),

              // elevation: widget.isSystem ? 0.3 : 0.5,
              // shape: RoundedRectangleBorder(borderRadius: widget.isSystem ? BorderRadius.circular(4) : BorderRadius.circular(8)),

              margin: widget.isSystem
                  ? EdgeInsets.only(right: 20)
                  : EdgeInsets.only(left: 5),
              child: Padding(
                padding: widget.isSystem
                    ? EdgeInsets.symmetric(vertical: 3, horizontal: 20)
                    : EdgeInsets.all(4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: widget.isSystem
                          ? CrossAxisAlignment.center
                          : CrossAxisAlignment.start,
                      children: [
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
                                widget
                                    .data!["template_proforma"]["components"] is List &&
                                widget.data!["template_proforma"]["components"]
                                    .any((c) => c["type"] == "CAROUSEL"))
                            ? Container()
                            : Container(
                          color: Colors.white,
                          child: _isLoading
                              ? Center(
                            child:
                            LoadingAnimationWidget.hexagonDots(
                              color: Colors.grey,
                              size: 20,
                            ),
                          )
                              : Html(
                            data: widget.templateMessage ?? "",
                            style: {
                              "body": Style(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                              "h3": Style(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                              "div": Style(
                                  color: Colors.black,
                                  fontSize: FontSize(13),
                                  fontWeight: FontWeight.w400),
                              "div.lw-whatsapp-buttons .list-group-item":
                              Style(
                                  padding: HtmlPaddings.all(3),
                                  fontSize: FontSize(14),
                                  backgroundColor: Colors.white,
                                  color: Colors.blue.shade500,
                                  textAlign: TextAlign.center,
                                  fontWeight: FontWeight.w800),
                              "div.list-group.list-group-flush.lw-whatsapp-buttons":
                              Style(
                                  padding: HtmlPaddings.all(3),
                                  margin: Margins.symmetric(
                                      horizontal: 5),
                                  fontSize: FontSize(14),
                                  backgroundColor: Colors.white,
                                  border: Border.all(
                                      color: Colors.green,
                                      width: 0.2),
                                  color: Colors.blue.shade500,
                                  textAlign: TextAlign.center,
                                  fontWeight: FontWeight.w800),
                              "div .list-group-item": Style(
                                padding: HtmlPaddings.all(3),
                                fontSize: FontSize(14),
                                backgroundColor: Colors.white,
                                color: Colors.blue.shade500,
                                textAlign: TextAlign.center,
                                fontWeight: FontWeight.w800,
                                textDecoration: TextDecoration.none,
                                border: Border.all(
                                    color: Colors.transparent),
                              ),
                              "div .list-group.list-group-flush .lw-whatsapp-buttons":
                              Style(
                                  backgroundColor:
                                  Color(0xDDFAFFFA),
                                  fontSize: FontSize(13),
                                  fontWeight: FontWeight.w800),
                              "div .fa-reply:before": Style(
                                  backgroundColor:
                                  Color(0xDDFAFFFA),
                                  fontSize: FontSize(13),
                                  fontWeight: FontWeight.w800),
                              "div.card": Style(
                                  padding: HtmlPaddings.all(3),
                                  backgroundColor:
                                  Color(0xDDEEFAEE),
                                  fontSize: FontSize(13),
                                  fontWeight: FontWeight.w800),
                              "div.lw-whatsapp-footer.text-muted":
                              Style(
                                color: Colors.grey,
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
                                      color: Colors.black,
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
                                      color: Colors.red,
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
                                  color: Colors.black87)
                                  : TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w100,
                              ),
                            ),
                          ),
                        if (widget.isIncoming)
                          widget.whatsAppError.toString() != ""
                              ? Row(
                            children: [
                              widget.whatsAppError.toString() != ""
                                  ? Icon(
                                Icons.error,
                                color: Colors.red,
                                size: 15,
                              )
                                  : Container(),
                              const SizedBox(
                                width: 4,
                              ),
                              Text(
                                widget.whatsAppError.toString(),
                                style: GoogleFonts.roboto(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.red,
                                    fontStyle: FontStyle.italic),
                                textAlign: TextAlign.left,
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
                            color: Colors.black54,
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
                                builder: (context) =>
                                    Dialog(
                                      elevation: 24,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(16),
                                      ),
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
                                              style: Theme
                                                  .of(context)
                                                  .textTheme
                                                  .headlineSmall
                                                  ?.copyWith(
                                                color:
                                                Colors.red[700],
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
                                              style: Theme
                                                  .of(context)
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
                                                  Colors.red[700],
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
                              : widget.status == "delivered"
                              ? const Icon(
                            Icons.done_all,
                            color: Colors.grey,
                            size: 15,
                          )
                              : widget.status == "read"
                              ? const Icon(
                            Icons.done_all,
                            color: Colors.blue,
                            size: 15,
                          )
                              : widget.status == "initialize"
                              ? Container()
                              : const Icon(
                            Icons.watch_later_outlined,
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
                      final templateValues = widget
                          .data?["template_component_values"] as List?;
                      if (templateValues != null && templateValues.isNotEmpty) {
                        final carouselValues = templateValues.firstWhere(
                              (value) => value["type"] == "carousel",
                          orElse: () => null,
                        );

                        if (carouselValues != null &&
                            carouselValues["cards"] is List) {
                          final cardValues = carouselValues["cards"][index];
                          if (cardValues != null) {
                            final headerParams = cardValues["components"]
                                ?.firstWhere(
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
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
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
                                      color: Colors.grey[200],
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
                                              padding: const EdgeInsets.all(15.0),
                                              child: Image.network(
                                                imageUrl,
                                                fit: BoxFit.fill,
                                                loadingBuilder: (context, child,
                                                    progress) {
                                                  if (progress == null) return child;
                                                  return Center(
                                                    child: CircularProgressIndicator(color: Colors.grey,),
                                                  );
                                                },
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  return Center(
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment
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
                                            height : 150,
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
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            Divider(
                              thickness: 1,
                              color: Colors.grey.shade200,
                            ),
                            // Button
                            if (buttonText != null )
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
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        if ( phoneNumber != null)
                                        Icon(Icons.phone, size: 18,
                                            color: Colors.blue),
                                        SizedBox(width: 0),
                                        Text(
                                          buttonText,
                                          style: TextStyle(
                                            color: Colors.blue,
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
                            color: Colors.transparent, // Make card background transparent
                            elevation: 2,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: 5.0, // Adjust blur intensity
                                  sigmaY: 5.0, // Adjust blur intensity
                                ),
                                child: Container(
                                  color: Colors.white.withOpacity(0.5), // Semi-transparent white
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
                          onPressed:
                          currentPage > 0
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
                                  color: Colors.white.withOpacity(0.5),
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
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
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