import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimeContainer extends StatefulWidget {
  const TimeContainer({super.key});
  @override
  State<TimeContainer> createState() => _TimeContainerState();
}

class _TimeContainerState extends State<TimeContainer> {
  late DateTime time;
  late String timeStr;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    time = DateTime.now();
    updateTime();

    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) => updateTime());
  }

  void updateTime() {
    setState(() {
      time = DateTime.now();
      timeStr = DateFormat('yyyy/MM/dd kk:mm:ss').format(time);
    });
  }

  @override
  void dispose() {
    timer.cancel(); // 위젯이 해제될 때 타이머 취소
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(5.0),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(100),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1.5,
            blurRadius: 1.5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        timeStr,
        style: const TextStyle(fontSize: 28, color: Colors.black, fontWeight: FontWeight.bold),
      ),
    );
  }
}
