import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class SoundContainer extends StatefulWidget {
  const SoundContainer({Key? key}) : super(key: key);

  @override
  State<SoundContainer> createState() => _SoundContainerState();
}

class _SoundContainerState extends State<SoundContainer> {
  final audioPlayer = AudioPlayer();
  bool isPlaying = false;
  double currentPosition = 0.0;
  double totalDuration = 0.0;

  @override
  void initState() {
    super.initState();
    initAudioPlayer();
  }

  Future<void> initAudioPlayer() async {
    try {
      await audioPlayer.setAsset('assets/audio/sample_audio.wav');
      audioPlayer.durationStream.listen((duration) {
        setState(() {
          totalDuration = duration?.inMilliseconds.toDouble() ?? 0.0;
        });
      });
      audioPlayer.positionStream.listen((position) {
        setState(() {
          currentPosition = position.inMilliseconds.toDouble();
        });
      });
      audioPlayer.playerStateStream.listen((playerState) {
        setState(() {
          isPlaying = playerState.playing;
        });
      });
    } catch (e) {
      if (kDebugMode) {
        print("An error occurred: $e");
      }
    }
  }

  Future<void> togglePlayPause() async {
    if (isPlaying) {
      await audioPlayer.pause();
    } else {
      await audioPlayer.play();
    }
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
            iconSize: 20.0,
            onPressed: () => togglePlayPause(),
            padding: EdgeInsets.zero,
          ),
          Flexible(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5.0),
                thumbColor: Colors.blueAccent,
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 10.0),
                overlayColor: Colors.blueAccent.withOpacity(0.2),
                activeTrackColor: Colors.blue
              ),
              child: Slider(
                value: currentPosition,
                min: 0.0,
                max: totalDuration,
                onChanged: (value) async {
                  await audioPlayer.seek(Duration(milliseconds: value.toInt()));
                },
              ),
            ),
          ),
        ],
      );
  }
}
