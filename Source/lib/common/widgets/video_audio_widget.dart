import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import "package:video_player/video_player.dart";

class VideoPlayerControls extends StatefulWidget {
  final VideoPlayerController controller;

  const VideoPlayerControls({Key? key, required this.controller})
      : super(key: key);

  @override
  _VideoPlayerControlsState createState() => _VideoPlayerControlsState();
}

class _VideoPlayerControlsState extends State<VideoPlayerControls> {
  late bool _isPlaying;
  late Duration _currentPosition;
  late Duration _videoDuration;

  @override
  void initState() {
    super.initState();
    _isPlaying = widget.controller.value.isPlaying;
    _currentPosition = Duration.zero;
    _videoDuration = widget.controller.value.duration;
    widget.controller.addListener(_videoPlayerListener);
  }
  @override
  void dispose() {
    widget.controller.removeListener(_videoPlayerListener);
    super.dispose();
  }
  void _videoPlayerListener() {
    if (!mounted) return;

    setState(() {
      _isPlaying = widget.controller.value.isPlaying;
      _currentPosition = widget.controller.value.position;
      _videoDuration = widget.controller.value.duration;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Progress bar
        Row(
          children: [
            Expanded(
              flex: 8,
              child: Slider(
                activeColor: Colors.green,
                inactiveColor: Colors.green.shade100,
                value: _currentPosition.inSeconds.toDouble(),
                max: _videoDuration.inSeconds.toDouble(),
                onChanged: (value) {
                  setState(() {
                    widget.controller.seekTo(Duration(seconds: value.toInt()));
                  });
                },
              ),
            ),
            Flexible(
              flex: 2,
              child: IconButton(
                icon: Icon(
                  widget.controller.value.volume > 0
                      ? Icons.volume_up
                      : Icons.volume_off,
                ),
                onPressed: () {
                  setState(() {
                    if (widget.controller.value.volume > 0) {
                      widget.controller.setVolume(0);
                    } else {
                      widget.controller.setVolume(1.0);
                    }
                  });
                },
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(
                _isPlaying
                    ? Icons.pause_circle_outline
                    : Icons.play_circle_outline,
              ),
              onPressed: () {
                setState(() {
                  if (_isPlaying) {
                    widget.controller.pause();
                  } else {
                    widget.controller.play();
                  }
                });
              },
            ),

            Text(
              "${_formatDuration(_currentPosition)} / ${_formatDuration(_videoDuration)}",
              style: const TextStyle(fontSize: 10, color: Colors.black),
            ),

            IconButton(
              icon: const Icon(Icons.fullscreen),
              onPressed: () {
                _showFullscreen(context,widget.controller);
              },
            ),
          ],
        )
      ],
    );
  }

  // Helper to format durations
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }


  void _showFullscreen(BuildContext context, VideoPlayerController controller) {
    Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => FullscreenVideoPlayer(controller: controller),
        ));
  }

}

class FullscreenVideoPlayer extends StatefulWidget {
  final VideoPlayerController controller;

  const FullscreenVideoPlayer({super.key, required this.controller});

  @override
  _FullscreenVideoPlayerState createState() => _FullscreenVideoPlayerState();
}

class _FullscreenVideoPlayerState extends State<FullscreenVideoPlayer> {
  late VideoPlayerController controller;
  double _currentSliderValue = 0.0;

  @override
  void initState() {
    super.initState();
    controller = widget.controller;
    controller.addListener(_updateSliderValue);
  }

  void _updateSliderValue() {
    if (controller.value.isInitialized) {
      setState(() {
        _currentSliderValue = controller.value.position.inMilliseconds.toDouble();
      });
    }
  }

  String _getCurrentTime(VideoPlayerController controller) {
    Duration duration = controller.value.position;
    return _formatDuration(duration);
  }

  String _getTotalTime(VideoPlayerController controller) {
    Duration duration = controller.value.duration;
    return _formatDuration(duration);
  }

  String _formatDuration(Duration duration) {
    return '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    controller.removeListener(_updateSliderValue);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () {
          setState(() {});
        },
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Center(
              child: Flexible(
                // height: MediaQuery.of(context).size.height*0.3,
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: VideoPlayer(controller),
                ),
              ),
            ),
            if (controller.value.isInitialized)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Slider(
                      value: _currentSliderValue,
                      min: 0.0,
                      max: controller.value.duration.inMilliseconds.toDouble(),
                      onChanged: (newValue) {
                        setState(() {
                          _currentSliderValue = newValue;
                          controller.seekTo(Duration(milliseconds: newValue.toInt()));
                        });
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(
                            controller.value.isPlaying
                                ? Icons.pause_circle_outline
                                : Icons.play_circle_outline,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              if (controller.value.isPlaying) {
                                controller.pause();
                              } else {
                                controller.play();
                              }
                            });
                          },
                        ),
                        Text(
                          "${_getCurrentTime(controller)} / ${_getTotalTime(controller)}",
                          style: const TextStyle(color: Colors.white),
                        ),
                        IconButton(
                          icon: Icon(
                            controller.value.volume == 0
                                ? Icons.volume_off
                                : Icons.volume_up,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              controller.setVolume(controller.value.volume == 0 ? 1 : 0);
                            });
                          },
                        ),
                      ],
                    ),
                    // Slider for time

                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}



class AudioPlayerWidget extends StatefulWidget {
  final String url;

  const AudioPlayerWidget({super.key, required this.url});

  @override
  _AudioPlayerWidgetState createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  PlayerState _playerState = PlayerState.stopped;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  double _volume = 1.0;
  bool _isDurationSet = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        _playerState = state;
      });
    });

    _audioPlayer.onPositionChanged.listen((position) {
      setState(() {
        _currentPosition = position;
      });
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      setState(() {
        _totalDuration = duration;
        _isDurationSet = true;
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _seekAudio(double value) {
    _audioPlayer.seek(Duration(seconds: value.toInt()));
  }

  void _changeVolume(double value) {
    setState(() {
      _volume = value;
      _audioPlayer.setVolume(_volume);
    });
  }

  @override
  Widget build(BuildContext context) {
    String formattedTime(Duration duration) {
      String minutes = duration.inMinutes.toString().padLeft(2, '0');
      String seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
      return '$minutes:$seconds';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Slider(
          inactiveColor: Colors.green.shade100,
          value: _currentPosition.inSeconds.toDouble(),
          min: 0,
          max: _isDurationSet ? _totalDuration.inSeconds.toDouble() : 1.0,  // Use max of 1.0 until duration is set
          onChanged: (value) => _seekAudio(value),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(
                _playerState == PlayerState.playing ? Icons.pause_circle_outline : Icons.play_circle_outline,
              ),
              onPressed: () {
                setState(() {
                  if (_playerState == PlayerState.playing) {
                    _audioPlayer.pause();
                  } else {
                    _audioPlayer.play(UrlSource(widget.url));
                  }
                });
              },
            ),
            Text(
              _isDurationSet
                  ? "${formattedTime(_currentPosition)} / ${formattedTime(_totalDuration)}"
                  : "00:00 / 00:00", // Show 00:00 if duration is not yet set
              style: const TextStyle(fontSize: 12),
            ),
            IconButton(
              icon: Icon(
                _volume == 0.0 ? Icons.volume_off : Icons.volume_up,
              ),
              onPressed: () {
                setState(() {
                  _volume = _volume == 0.0 ? 1.0 : 0.0; // Toggle between mute/unmute
                });
                _changeVolume(_volume);
              },
            ),
          ],
        ),
      ],
    );
  }
}

