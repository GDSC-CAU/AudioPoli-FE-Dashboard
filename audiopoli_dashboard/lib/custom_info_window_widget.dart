import 'package:audiopoli_dashboard/sound_container.dart';
import 'package:audiopoli_dashboard/styled_container.dart';
import 'package:flutter/material.dart';

class CustomInfoWindowWidget extends StatelessWidget {
  const CustomInfoWindowWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1.5,
            blurRadius: 1.5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 0, horizontal: 5),
            width: double.infinity,
            child:Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(style: TextStyle(fontSize: 12),'Info Window'),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.close), iconSize: 12, padding: EdgeInsets.zero, constraints: BoxConstraints(minWidth: 24, minHeight: 24),)
              ],
            ),
          ),
          SoundContainer()
        ],
      )
    );
  }
}
