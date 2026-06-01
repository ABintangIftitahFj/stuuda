import 'package:flutter/material.dart';
import 'package:appinio_video_player/appinio_video_player.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class AppinioVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String? caption;
  final bool autoPlay;
  final bool looping;

  const AppinioVideoPlayer({
    super.key,
    required this.videoUrl,
    this.caption,
    this.autoPlay = false,
    this.looping = false,
  });

  @override
  State<AppinioVideoPlayer> createState() => _AppinioVideoPlayerState();
}

class _AppinioVideoPlayerState extends State<AppinioVideoPlayer> {
  CustomVideoPlayerController? _videoPlayerController;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      final videoPlayerController = VideoPlayerController.network(widget.videoUrl);

      await videoPlayerController.initialize();

      _videoPlayerController = CustomVideoPlayerController(
        context: context,
        videoPlayerController: videoPlayerController,
        customVideoPlayerSettings: CustomVideoPlayerSettings(
          placeholderWidget: Container(
            color: Colors.black,
            child: Center(
              child: LoadingAnimationWidget.hexagonDots(
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
          settingsButtonAvailable: true,
          // autoPlay: widget.autoPlay,
          // loopVideo: widget.looping,
          showFullscreenButton: true,
          // deviceOrientationsOnFullscreen: [
          //   DeviceOrientation.landscapeLeft,
          //   DeviceOrientation.landscapeRight,
          //   DeviceOrientation.portraitUp,
          // ],
        ),
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        color: Colors.black,
        height: 200,
        child: Center(
          child: LoadingAnimationWidget.hexagonDots(
            color: Colors.white,
            size: 30,
          ),
        ),
      );
    }

    if (_hasError) {
      return Container(
        color: Colors.black,
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, color: Colors.white, size: 50),
              const SizedBox(height: 10),
              const Text(
                'Failed to load video',
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _initializePlayer,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 16 / 9, // Standard aspect ratio, adjust as needed
          child: CustomVideoPlayer(
            customVideoPlayerController: _videoPlayerController!,
          ),
        ),
        if (widget.caption != null && widget.caption!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              widget.caption!,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }
}