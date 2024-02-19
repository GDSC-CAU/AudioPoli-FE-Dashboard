import 'package:flutter/material.dart';
class RadarAnimation extends StatefulWidget {
  RadarAnimation({Key? key}) : super(key: key);

  @override
  RadarAnimationState createState() => RadarAnimationState();
}
class RadarAnimationState extends State<RadarAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _animationCount = 0; // 애니메이션 실행 횟수를 추적
  bool _isVisible = false; // 위젯의 가시성을 제어

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 50.0,
      end: 300.0,
    ).animate(_controller)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _animationCount++;
          if (_animationCount >= 2) { // 두 번 실행 후
            setState(() {
              _isVisible = false; // 위젯 숨김
            });
          } else {
            _controller.reset();
            _controller.forward();
          }
        }
      });
  }

  void startAnimation() {
    _animationCount = 0; // 애니메이션 횟수 초기화
    _isVisible = true; // 애니메이션 시작 시 위젯 보이게 설정
    _controller.reset();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: _isVisible, // Visibility 위젯을 사용하여 가시성 제어
      child: Container(
        alignment: Alignment.center,
        child: Container(
          width: _animation.value,
          height: _animation.value,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.redAccent.withOpacity(0.1),
            border: Border.all(
              color: Colors.redAccent,
              width: 3.0,
            ),
          ),
        ),
      ),
    );
  }
}
