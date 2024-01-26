

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sticky_headers/sticky_headers.dart';

import 'incidentData.dart';

import 'package:socket_io_client/socket_io_client.dart' as IO;

class LogContainer extends StatefulWidget {
  late IO.Socket socket;
  LogContainer({super.key, required this.socket});

  @override
  State<LogContainer> createState() => _LogContainerState();
}

class _LogContainerState extends State<LogContainer> {
  IncidentData sampleData0 = IncidentData(
      date: "2012-01-26",
      time: "13:51:50",
      latitude: 37.5058,
      longitude: 126.956,
      sound: "대충 base64",
      category: 5,
      detail: 3,
      isCrime: true
  );
  IncidentData sampleData1 = IncidentData(
      date: "2012-01-26",
      time: "13:51:50",
      latitude: 37.5068,
      longitude: 126.957,
      sound: "대충 base64",
      category: 3,
      detail: 3,
      isCrime: true
  );

  List<IncidentData> incidentDatas = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    incidentDatas.add(sampleData0);
    incidentDatas.add(sampleData1);
    incidentDatas.add(sampleData0);
    incidentDatas.add(sampleData1);
    incidentDatas.add(sampleData0);
    incidentDatas.add(sampleData1);
    incidentDatas.add(sampleData0);
    incidentDatas.add(sampleData1);
    incidentDatas.add(sampleData0);
    incidentDatas.add(sampleData1);
    incidentDatas.add(sampleData0);
    incidentDatas.add(sampleData1);
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      margin: EdgeInsets.all(7.0),
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1.5,
            blurRadius: 1.5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: StickyHeader(
          header: Container(
            color: Colors.white,
            width: double.infinity,
            child: DataTable(
              border: TableBorder(
                verticalInside: BorderSide(width: 0.5, color: Colors.grey),
              ),
              headingRowHeight: 20,
              headingTextStyle: TextStyle(
                fontWeight: FontWeight.bold
              ),
              columnSpacing: 20,

              columns: [
                DataColumn(label: Container(width: 100, child: Text('Date'))),
                DataColumn(label: Container(width: 100, child: Text('Time'))),
                DataColumn(label: Container(width: 100, child: Text('Latitude'))),
                DataColumn(label: Container(width: 100, child: Text('Longitude'))),
                DataColumn(label: Container(width: 100, child: Text('Sound'))),
                DataColumn(label: Container(width: 60, child: Text('Category'))),
                DataColumn(label: Container(width: 50, child: Text('Detail'))),
                DataColumn(label: Container(width: 100, child: Text('Is Crime?'))),
                DataColumn(label: Container(width: 300, child: Text('Bigo'))),
              ],
              rows: [],
            ),
          ),
          content: Container(
            width: double.infinity,
            child: DataTable(
              border: TableBorder.all(
                width: 0.5,
                color: Colors.grey,
              ),
              columnSpacing: 20,
              headingRowHeight: 0,
              dataRowMinHeight: 24,
              dataRowMaxHeight: 24,
              columns: [
                DataColumn(label: Container(width: 100,)),
                DataColumn(label: Container(width: 100,)),
                DataColumn(label: Container(width: 100,)),
                DataColumn(label: Container(width: 100,)),
                DataColumn(label: Container(width: 100,)),
                DataColumn(label: Container(width: 60,)),
                DataColumn(label: Container(width: 50,)),
                DataColumn(label: Container(width: 100,)),
                DataColumn(label: Container(width: 300,)),
              ],
              rows: incidentDatas.map((incident) {
                return DataRow(cells: [
                    DataCell(Text(incident.date)),
                    DataCell(Text(incident.time)),
                    DataCell(Text(incident.latitude.toString())),
                    DataCell(Text(incident.longitude.toString())),
                    DataCell(Text(incident.sound)), // You might want to create a widget to play the sound
                    DataCell(Text(incident.category.toString())),
                    DataCell(Text(incident.detail.toString())),
                    DataCell(Text(incident.isCrime ? 'Yes' : 'No')),
                    DataCell(Text('')),
                  ]
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}


