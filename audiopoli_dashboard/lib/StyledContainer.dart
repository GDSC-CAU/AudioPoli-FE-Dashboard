import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class StyledContainer extends StatelessWidget {
  StyledContainer({super.key, required this.widget});
  final Widget widget;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(7.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1.5,
            blurRadius: 1.5,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Center(child: widget),
    );
  }
}