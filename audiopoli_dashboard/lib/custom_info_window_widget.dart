import 'package:audiopoli_dashboard/sound_container.dart';
import 'package:audiopoli_dashboard/data_function.dart';
import 'package:flutter/material.dart';

import 'custom_info_window.dart';

class CustomInfoWindowWidget extends StatefulWidget {
   const CustomInfoWindowWidget({super.key, required this.data, required this.controller});

  final dynamic data;
  final CustomInfoWindowController controller;

  @override
  State<CustomInfoWindowWidget> createState() => _CustomInfoWindowWidgetState();
}

class _CustomInfoWindowWidgetState extends State<CustomInfoWindowWidget> {

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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.only(left: 10, right: 5, top: 5),
            width: double.infinity,
            child:Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), DataFunction.detailToString(widget.data.detail) ?? ''),
                IconButton(
                  onPressed: () {widget.controller.hideInfoWindow!();},
                  icon: const Icon(Icons.close), iconSize: 16, padding: EdgeInsets.zero, constraints: BoxConstraints(minWidth: 24, minHeight: 24),)
              ],
            ),
          ),
          SoundContainer()
        ],
      )
    );
  }
}
