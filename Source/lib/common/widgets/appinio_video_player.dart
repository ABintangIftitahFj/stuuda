import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
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
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));

      await _videoPlayerController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: widget.autoPlay,
        looping: widget.looping,
        aspectRatio: _videoPlayerController!.value.aspectRatio,
        placeholder: Container(
          color: Colors.black,
          child: Center(
            child: LoadingAnimationWidget.hexagonDots(
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
        autoInitialize: true,
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Text(
              errorMessage,
              style: const TextStyle(color: Colors.white),
            ),
          );
        },
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error initializing video player: $e");
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
    _chewieController?.dispose();
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

    if (_hasError || _chewieController == null) {
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
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _hasError = false;
                  });
                  _initializePlayer();
                },
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
          aspectRatio: _videoPlayerController!.value.aspectRatio,
          child: Chewie(
            controller: _chewieController!,
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