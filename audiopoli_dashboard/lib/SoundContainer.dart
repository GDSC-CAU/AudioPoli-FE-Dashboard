
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import './StyledContainer.dart';

class SoundContainer extends StatefulWidget {
  SoundContainer({super.key});

  @override
  State<SoundContainer> createState() => _SoundContainerState();
}

class _SoundContainerState extends State<SoundContainer> {
  final audioPlayer = AudioPlayer();
  String path = './assets/audio/sample_audio.wav';
  bool isPlaying = false;
  bool isPaused = false;
  double currentPosition = 0.0;
  double totalDuration = 0.0;

  @override
  void initState() {
    super.initState();
    initAudioPlayer();
  }
  Future<void> initAudioPlayer() async {
    await audioPlayer.setAsset(path);
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
  }

  Future<void> togglePlayPause() async {
    if (audioPlayer.playing) {
      await audioPlayer.pause();
    } else {
      await audioPlayer.play();
    }
    setState(() {
      isPlaying = audioPlayer.playing;
    });
  }


  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Music Player with Slider'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Slider(
            value: currentPosition,
            min: 0.0,
            max: totalDuration,
            onChanged: (value) async {
              await audioPlayer.seek(Duration(milliseconds: value.toInt()));
              setState(() {
                currentPosition = value;
              });
            },
          ),
          IconButton(
            icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
            iconSize: 64.0,
            onPressed: () => togglePlayPause(),
          ),
        ],
      ),
    );
  }
}