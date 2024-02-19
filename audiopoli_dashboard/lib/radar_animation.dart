import 'package:flutter/material.dart';
class RadarAnimation extends StatefulWidget {
  @override
  _RadarAnimationState createState() => _RadarAnimationState();
}

class _RadarAnimationState extends State<RadarAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 50.0, // 초기 원의 크기
      end: 300.0, // 최대 원의 크기
    ).animate(_controller)
      ..addListener(() {
        setState(() {});
        if (_controller.status == AnimationStatus.completed) {
          _controller.reset(); // 애니메이션 완료 시 컨트롤러 리셋
          _controller.forward(); // 애니메이션 다시 시작
        }
      });

    _controller.forward(); // 첫 애니메이션 시작
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Container(
        width: _animation.value,
        height: _animation.value,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.redAccent.withOpacity(0.1),
          border: Border.all(
            color: Colors.redAccent, // 테두리 색상
            width: 3.0, // 테두리 두께
          ),
        ),
      ),
    );
  }
}