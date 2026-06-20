import 'package:audioplayers/audioplayers.dart';
import 'package:just_audio/just_audio.dart' as ja;
import 'package:get/get.dart';

/// Single global just_audio player for all network audio bubbles.
/// Ensures only one audio plays at a time across all MessageBubble instances.
class GlobalAudioManager extends GetxController {
  static GlobalAudioManager get to => Get.find<GlobalAudioManager>();

  final ja.AudioPlayer _player = ja.AudioPlayer();
  final currentUrl = RxnString();
  late final Stream<ja.PlayerState> playerStateStream;
  late final Stream<Duration> positionStream;
  late final Stream<Duration?> durationStream;

  @override
  void onInit() {
    super.onInit();
    playerStateStream = _player.playerStateStream;
    positionStream = _player.positionStream;
    durationStream = _player.durationStream;
  }

  bool isPlayingUrl(String url) =>
      currentUrl.value == url && (_player.playing);

  Future<void> playUrl(String url) async {
    // stop local file player if active
    if (Get.isRegistered<AudioController>()) {
      final ac = Get.find<AudioController>();
      if (ac.isPlaying.value) ac.stop();
    }
    if (currentUrl.value == url) {
      if (_player.playing) {
        await _player.pause();
      } else {
        await _player.play();
      }
      return;
    }
    await _player.stop();
    currentUrl.value = url;
    await _player.setAudioSource(ja.AudioSource.uri(Uri.parse(url)));
    await _player.play();
  }

  Future<void> pause() async => _player.pause();

  Future<void> seek(Duration position) async => _player.seek(position);

  @override
  void onClose() {
    _player.dispose();
    super.onClose();
  }
}

class AudioController extends GetxController {
  final AudioPlayer _player = AudioPlayer();
  var isPlaying = false.obs;
  var duration = Duration.zero.obs;
  var position = Duration.zero.obs;
  var isSliderBeingDragged = false.obs;

  @override
  void onInit() {
    super.onInit();
    _player.onDurationChanged.listen((d) {
      duration.value = d;
    });
    _player.onPositionChanged.listen((p) {
      if (!isSliderBeingDragged.value) {
        position.value = p;
      }
    });
  }

  void playPause(String file) async {
    if (isPlaying.value) {
      await _player.pause();
    } else {
      // stop network audio before playing local file
      if (Get.isRegistered<GlobalAudioManager>()) {
        await Get.find<GlobalAudioManager>().pause();
      }
      await _player.play(DeviceFileSource(file));
    }
    isPlaying.value = !isPlaying.value;
  }

  void seek(Duration newPosition) {
    _player.seek(newPosition);
  }

   void stop() {
    _player.stop();
    isPlaying.value = false;
    position.value = Duration.zero;
  }

  @override
  void onClose() {
    stop();
    _player.dispose();
    super.onClose();
  }
}

class MessageAudioController extends GetxController {
  bool isChatboxScreenActive = false;

  void setChatboxScreenState(bool isActive) {
    isChatboxScreenActive = isActive;
  }

  void playNotificationSound() async {
    if (!isChatboxScreenActive) {
      final AudioPlayer player = AudioPlayer();
      await player.play(AssetSource('audio/receivesound.mp3'));
    }
  }
}
