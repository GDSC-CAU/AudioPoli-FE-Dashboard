import 'package:audiopoli_dashboard/StyledContainer.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class SoundContainer extends StatefulWidget {
  SoundContainer({Key? key}) : super(key: key);

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
      print("An error occurred: $e");
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
            iconSize: 16.0,
            onPressed: () => togglePlayPause(),
          ),
          Flexible(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 5.0),
              ),
              child: Slider(
                value: currentPosition,
                min: 0.0,
                max: totalDuration,
                activeColor: Colors.blueAccent,
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
