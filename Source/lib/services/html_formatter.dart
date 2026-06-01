import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as html_parser;
import 'package:url_launcher/url_launcher.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';
import 'package:whatsjet_demo/services/utils.dart';

class WhatsAppHtmlFormatter {
  static TextSpan format(String htmlText,
      {TextStyle? baseStyle, BuildContext? context,
      }) {
    htmlText = _fixMalformedStrongTags(htmlText);
    final defaultStyle = (baseStyle ?? const TextStyle())
        .copyWith(
      fontWeight: FontWeight.w100,
      // fontSize: 15,
      // color: Colors.blueGrey,
    );

    final document = html_parser.parse(htmlText);
    return TextSpan(
      style: defaultStyle.copyWith(color: Colors.black,fontWeight: FontWeight.w100,fontSize: 10), // Default color here
      children: [
        _parseNode(document.body!, defaultStyle, context), // Pass style without color
      ],
    );
    // return _parseNode(document.body!, defaultStyle, context);
  }

  static String _fixMalformedStrongTags(String html) {
    // Fix patterns like <strong></strong>text<strong></strong>
    return html.replaceAllMapped(
        RegExp(r'<strong>\s*<\/strong>([^<]+)<strong>\s*<\/strong>'),
            (match) => '<strong>${match.group(1)}</strong>'
    );
  }
  static TextSpan _parseNode(
      html_parser.Node node, TextStyle parentStyle, BuildContext? context) {
    if (node is html_parser.Text) {
      return TextSpan(text: node.text, style: parentStyle);
    }

    if (node is html_parser.Element) {
      final children =
          node.nodes.map((n) => _parseNode(n, parentStyle, context)).toList();
      switch (node.localName) {
        case 'strong':
          return TextSpan(
            style:  TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.blueGrey.shade800,
            ),
            children: children,
          );

        case 'em':
          return TextSpan(
            style:
                parentStyle.merge(const TextStyle(fontStyle: FontStyle.italic)),
            children: children,
          );

        case 'del':
          return TextSpan(
            style: parentStyle
                .merge(const TextStyle(decoration: TextDecoration.lineThrough)),
            children: children,
          );

        case 'code':
          return TextSpan(
            style: parentStyle.merge(const TextStyle(
              fontFamily: 'monospace',
              backgroundColor: Colors.red,
            )),
            children: children,
          );

        case 'span':
          if (node.classes.contains('badge') &&
              node.classes.contains('badge-light')) {
            return TextSpan(
              style: parentStyle.merge(const TextStyle(
                fontFamily: 'monospace',
                backgroundColor: Colors.red,
              )),
              children: children,
            );
          }
          break;

        case 'a':
          final url = node.attributes['href'];
          if (url != null) {
            return TextSpan(
              text: node.text,
              style: parentStyle.merge( TextStyle(color: Colors.blue.shade600)),
              recognizer: TapGestureRecognizer()
                ..onTap = () async {
                  if (await canLaunchUrl(Uri.parse(url))) {
                    await launchUrl(Uri.parse(url));
                  }
                },
            );
          }
          break;

        case 'img':
          final src = node.attributes['src'] ?? '';
          final width = double.tryParse(node.attributes['width'] ?? '') ?? 300;
          final height =
              double.tryParse(node.attributes['height'] ?? '') ?? 200;

          return TextSpan(
            children: [
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: src,
                      width: width,
                      height: height,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: width,
                        height: height,
                        color: Colors.grey[200],
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: width,
                        height: height,
                        color: Colors.grey[200],
                        child: const Icon(Icons.error),
                      ),
                    ),
                  ),
                ),
              ),
              const TextSpan(text: '\n\n'),
            ],
          );

        case 'video':
          final src = node.attributes['src'] ?? '';
          return TextSpan(
            children: [
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: SizedBox(
                  width: 300,
                  height: 200,
                  child: SimpleVideoPlayer(videoUrl: src),
                ),
              ),
              const TextSpan(text: '\n\n'),
            ],
          );

        case 'audio':
          final src = node.attributes['src'] ?? '';
          return TextSpan(
            children: [
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: SimpleAudioPlayer(audioUrl: src),
                ),
              ),
              const TextSpan(text: '\n\n'),
            ],
          );

        case 'iframe':
          final src = node.attributes['src'] ?? '';
          if (src.contains('youtube.com') || src.contains('youtu.be')) {
            return TextSpan(
              children: [
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: SizedBox(
                    width: 300,
                    height: 200,
                    child: YouTubeThumbnailWidget(videoUrl: src),
                  ),
                ),
                const TextSpan(text: '\n\n'),
              ],
            );
          }
          return TextSpan(
            text: '[Embedded Content]',
            style: parentStyle.merge(const TextStyle(color: Colors.blue)),
            recognizer: TapGestureRecognizer()
              ..onTap = () async {
                if (await canLaunchUrl(Uri.parse(src))) {
                  await launchUrl(Uri.parse(src));
                }
              },
          );
      }

      return TextSpan(children: children, style: parentStyle);
    }

    return const TextSpan(text: '');
  }
}

class SimpleVideoPlayer extends StatefulWidget {
  final String videoUrl;

  const SimpleVideoPlayer({super.key, required this.videoUrl});

  @override
  State<SimpleVideoPlayer> createState() => _SimpleVideoPlayerState();
}

class _SimpleVideoPlayerState extends State<SimpleVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Container(
        color: Colors.grey[300],
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: VideoPlayer(_controller),
        ),
        IconButton(
          icon: Icon(
            _isPlaying ? Icons.pause : Icons.play_arrow,
            size: 50,
            color: Colors.white,
          ),
          onPressed: () {
            setState(() {
              _isPlaying = !_isPlaying;
              _isPlaying ? _controller.play() : _controller.pause();
            });
          },
        ),
      ],
    );
  }
}

class SimpleAudioPlayer extends StatefulWidget {
  final String audioUrl;

  const SimpleAudioPlayer({super.key, required this.audioUrl});

  @override
  State<SimpleAudioPlayer> createState() => _SimpleAudioPlayerState();
}

class _SimpleAudioPlayerState extends State<SimpleAudioPlayer> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.audioUrl)
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Container(
        color: Colors.grey[300],
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Row(
          children: [
            IconButton(
              icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
              onPressed: () {
                setState(() {
                  _isPlaying = !_isPlaying;
                  _isPlaying ? _controller.play() : _controller.pause();
                });
              },
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Audio Player',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: _controller.value.position.inSeconds.toDouble() /
                        _controller.value.duration.inSeconds.toDouble(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class YouTubeThumbnailWidget extends StatelessWidget {
  final String videoUrl;

  const YouTubeThumbnailWidget({super.key, required this.videoUrl});

  @override
  Widget build(BuildContext context) {
    final videoId = _getYouTubeId(videoUrl);
    final thumbnailUrl =
        videoId != null ? 'https://img.youtube.com/vi/$videoId/0.jpg' : '';

    return GestureDetector(
      onTap: () async {
        if (await canLaunchUrl(Uri.parse(videoUrl))) {
          await launchUrl(Uri.parse(videoUrl));
        }
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (thumbnailUrl.isNotEmpty)
            CachedNetworkImage(
              imageUrl: thumbnailUrl,
              width: 300,
              height: 200,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.black,
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.black,
                child: const Icon(Icons.error),
              ),
            ),
          Container(
            alignment: Alignment.center,
            width: 40,
            height: 28,
            decoration: BoxDecoration(
                color: Colors.redAccent,
              borderRadius: BorderRadius.all(Radius.circular(7.0))
            ),
            child:const Icon(Icons.play_arrow, size: 20, color: Colors.white) ,
          )
          // const Icon(Icons.play_circle_fill, size: 50, color: Colors.white),
        ],
      ),
    );
  }

  String? _getYouTubeId(String url) {
    final regExp = RegExp(
      r'.*(?:youtu.be\/|v\/|u\/\w\/|embed\/|watch\?v=)([^#\&\?]*).*',
      caseSensitive: false,
    );
    final match = regExp.firstMatch(url);
    return match?.group(1);
  }
}
