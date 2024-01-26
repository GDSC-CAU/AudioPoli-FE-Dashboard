

import 'dart:io';

import 'package:flutter/material.dart';

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
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(7.0),
      height: 200,
      width: double.infinity,
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
        child: DataTable(
          columns: [
          DataColumn(label: Text('Date')),
          DataColumn(label: Text('Time')),
          DataColumn(label: Text('Latitude')),
          DataColumn(label: Text('Longitude')),
          DataColumn(label: Text('Sound')),
          DataColumn(label: Text('Category')),
          DataColumn(label: Text('Detail')),
          DataColumn(label: Text('Is Crime?')),
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
          ]);
          }).toList(),
        ),
      ),
    );
  }
}


