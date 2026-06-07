import 'package:stundaa/screens/whatsapp/controller/audio_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomAudioPlayer extends StatelessWidget {
  final String file;
  final String filename;

  const CustomAudioPlayer(
      {super.key, required this.file, required this.filename});

  @override
  Widget build(BuildContext context) {
    final AudioController audioController = Get.put(AudioController());
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Obx(() => Icon(
                      audioController.isPlaying.value
                          ? Icons.pause
                          : Icons.play_arrow,
                      size: 22,
                    )),
                onPressed: () => audioController.playPause(file),
              ),
              Expanded(
                flex: 8,
                child: Obx(() => SliderTheme(
                      data: const SliderThemeData(
                        thumbShape:
                            RoundSliderThumbShape(enabledThumbRadius: 5),
                        trackHeight: 2,
                      ),
                      child: Slider(
                        min: 0.0,
                        max:
                            audioController.duration.value.inSeconds.toDouble(),
                        value:
                            audioController.position.value.inSeconds.toDouble(),
                        onChanged: (value) {
                          audioController.isSliderBeingDragged.value = true;
                          audioController.position.value =
                              Duration(seconds: value.toInt());
                        },
                        onChangeEnd: (value) {
                          audioController.isSliderBeingDragged.value = false;
                          audioController.seek(audioController.position.value);
                        },
                      ),
                    )),
              ),
            ],
          ),
          Row(
            children: [
              Flexible(
                  child: Text(
                filename,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 10),
              )),
              Obx(() => Text(
                    '${audioController.position.value.inMinutes}:${audioController.position.value.inSeconds.remainder(60).toString().padLeft(2, '0')} / ${audioController.duration.value.inMinutes}:${audioController.duration.value.inSeconds.remainder(60).toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 10),
                  )),
            ],
          ),
        ],
      ),
    );
  }
}
