import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:firebase_storage/firebase_storage.dart';

class SoundContainer extends StatefulWidget {
  SoundContainer({Key? key, required this.filePath}) : super(key: key);
  final String filePath;

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

  Future<String> getAudioUrl(String filePath) async {
    String downloadUrl = await FirebaseStorage.instance
        .ref(filePath)
        .getDownloadURL();
    return downloadUrl;
  }

  Future<void> initAudioPlayer() async {
    String audioUrl = await getAudioUrl(widget.filePath);
    try {
      await audioPlayer.setUrl(audioUrl);
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
