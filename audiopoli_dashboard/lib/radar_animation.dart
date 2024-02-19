import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
class RadarAnimation extends StatefulWidget {
  RadarAnimation({Key? key}) : super(key: key);

  @override
  RadarAnimationState createState() => RadarAnimationState();
}
class RadarAnimationState extends State<RadarAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final AudioPlayer _audioPlayer = AudioPlayer();
  int _animationCount = 0;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 50.0,
      end: 350.0,
    ).animate(_controller)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _animationCount++;
          if (_animationCount >= 5) {
            setState(() {
              _isVisible = false;
            });
          } else {
            _controller.reset();
            _controller.forward();
          }
        }
      });
  }

  void startAnimation() async {
    _animationCount = 0;
    await _audioPlayer.setAsset('assets/audio/siren.mp3');
    _isVisible = true;
    _controller.reset();
    _controller.forward();
    _audioPlayer.play();
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double opacity = 1.0 - (_animation.value - 50.0) / (350.0 - 50.0);
    return Visibility(
      visible: _isVisible,
      child: Container(
        alignment: Alignment.center,
        child: Opacity(
          opacity: opacity,
          child: Container(
            width: _animation.value,
            height: _animation.value,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.redAccent.withOpacity(0.5),
              border: Border.all(
                color: Colors.redAccent,
                width: 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
