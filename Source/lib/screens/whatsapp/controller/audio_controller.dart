import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';

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
