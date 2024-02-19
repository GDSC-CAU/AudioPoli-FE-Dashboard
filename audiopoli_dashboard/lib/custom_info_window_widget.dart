import 'package:audiopoli_dashboard/radar_animation.dart';
import 'package:audiopoli_dashboard/sound_container.dart';
import 'package:audiopoli_dashboard/data_function.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'custom_info_window.dart';
import 'incident_data.dart';

class CustomInfoWindowWidget extends StatefulWidget {
  const CustomInfoWindowWidget(
      {super.key, required this.data, required this.controller});

  final dynamic data;
  final CustomInfoWindowController controller;

  @override
  State<CustomInfoWindowWidget> createState() => _CustomInfoWindowWidgetState();
}

class _CustomInfoWindowWidgetState extends State<CustomInfoWindowWidget> {

  // String setCaseStatus() {
  //   if (widget.data.isCrime == -1) {
  //     return 'Verification Needed';
  //   } else if (widget.data.isCrime == 0) {
  //     return 'Not a Crime';
  //   } else {
  //     if(widget.data.departureTime[0] == '9') {
  //       return 'Awaiting Departure';
  //     } else {
  //       if(widget.data.caseEndTime[0] == '9') {
  //         return 'Departed';
  //       } else {
  //         return 'Case Closed';
  //       }
  //     }
  //   }
  // }


  void updateIsCrime(IncidentData data, int tf) {
    final ref = FirebaseDatabase.instance.ref("/crime/${data.id.toString()}");

    ref.update({"isCrime": tf})
        .then((_) {
      if (kDebugMode) {
        print('success!');
      }
    })
        .catchError((error) {
      if (kDebugMode) {
        print(error);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: [
          RadarAnimation(),
          Container(
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.only(left: 10, right: 5, top: 5),
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                          DataFunction.detailToString(widget.data.detail) ?? ''),
                      IconButton(
                        onPressed: () {
                          widget.controller.hideInfoWindow!();
                        },
                        icon: const Icon(Icons.close),
                        iconSize: 16,
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(minWidth: 24, minHeight: 24),
                      )
                    ],
                  ),
                ),
                Container(margin: EdgeInsets.symmetric(horizontal: 5), child: SoundContainer(filePath: widget.data.sound,)),
                // Container(
                //   alignment: Alignment.centerLeft,
                //   padding: EdgeInsets.only(left: 10),
                //   child: Text(
                //       style: TextStyle(
                //         fontSize: 12,
                //       ),
                //       'Status: ' + setCaseStatus()
                //   ),
                // ),
                Container(
                  padding: EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {updateIsCrime(widget.data, 1);},
                        child: Text('Report'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5)
                          )
                        )
                      ),
                      SizedBox(width: 10,),
                      OutlinedButton(
                        onPressed: () {updateIsCrime(widget.data, 0);},
                        child: Text('Clear'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)
                          )
                        )
                      )
                    ],
                  ),
                )
              ],
            )),
        ]
      ),
    );
  }
}
