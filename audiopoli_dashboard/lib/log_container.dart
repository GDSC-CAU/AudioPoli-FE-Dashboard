import 'package:audiopoli_dashboard/data_function.dart';
import 'package:audiopoli_dashboard/sound_container.dart';
import 'package:flutter/material.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'incident_data.dart';

class LogContainer extends StatefulWidget {
  const LogContainer({super.key, required this.logMap});
  final Map<String, dynamic> logMap;
  @override
  State<LogContainer> createState() => _LogContainerState();
}

class _LogContainerState extends State<LogContainer> {
  var incidentMap = <String, dynamic>{};
  @override
  void initState() {
    super.initState();
    setState(() {
      updateData();
    });
  }

  @override
  void didUpdateWidget(LogContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    updateData();
  }


  void updateData() {
    setState(() {
      incidentMap.clear();
      widget.logMap.forEach((key, value) {
        IncidentData incident = IncidentData(
            date: value.date,
            time: value.time,
            latitude: value.latitude,
            longitude: value.longitude,
            sound: value.sound,
            category: value.category,
            detail: value.detail,
            id: value.id,
            isCrime: value.isCrime,
            departureTime: value.departureTime,
            caseEndTime: value.caseEndTime
        );
        incidentMap[key] = incident;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      margin: const EdgeInsets.all(7.0),
      width: double.infinity,
      height: 150,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1.5,
            blurRadius: 1.5,
            offset: const Offset(0, 1),
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
              border: const TableBorder(
                verticalInside: BorderSide(width: 0.5, color: Colors.grey),
              ),
              headingRowHeight: 20,
              headingTextStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12.0
              ),
              columnSpacing: 20,

              columns: const [
                DataColumn(label: SizedBox(width: 80, child: Text('Date'))),
                DataColumn(label: SizedBox(width: 70, child: Text('Time'))),
                DataColumn(label: SizedBox(width: 100, child: Text('Latitude'))),
                DataColumn(label: SizedBox(width: 100, child: Text('Longitude'))),
                DataColumn(label: SizedBox(width: 150, child: Text('Category'))),
                DataColumn(label: SizedBox(width: 200, child: Text('Detail'))),
                DataColumn(label: SizedBox(width: 100, child: Text('Is Crime'))),
                DataColumn(label: SizedBox(width: 80, child: Text('Departure'))),
                DataColumn(label: SizedBox(width: 80, child: Text('Case End'))),
                DataColumn(label: SizedBox(width: 210, child: Text('Sound'))),
              ],
              rows: const [],
            ),
          ),
          content: SizedBox(
            width: double.infinity,
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: DataTable(
                border:  const TableBorder(
                    horizontalInside: BorderSide(
                        width: 0.5,
                        color: Colors.grey
                    ),
                    verticalInside: BorderSide(
                        width: 0.5,
                        color: Colors.grey
                    ),
                    bottom: BorderSide(
                        width: 0.5,
                        color: Colors.grey
                    )
                ),
                columnSpacing: 20,
                headingRowHeight: 0,
                dataRowMinHeight: 24,
                dataRowMaxHeight: 24,
                columns: [
                  DataColumn(label: Container(width: 80,)),
                  DataColumn(label: Container(width: 70,)),
                  DataColumn(label: Container(width: 100,)),
                  DataColumn(label: Container(width: 100,)),
                  DataColumn(label: Container(width: 150,)),
                  DataColumn(label: Container(width: 200,)),
                  DataColumn(label: Container(width: 100,)),
                  DataColumn(label: Container(width: 80,)),
                  DataColumn(label: Container(width: 80,)),
                  DataColumn(label: Container(width: 210,)),
                ],
                rows: incidentMap.entries.map((entry) {
                  return DataRow(
                    color: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
                      if (incidentMap.keys.toList().indexOf(entry.key) % 2 != 0) {
                        return Colors.grey.withOpacity(0.15);
                      }
                      return null;
                    }),
                    cells: [
                      DataCell(Text(entry.value.date ?? '')),
                      DataCell(Text(entry.value.time ?? '')),
                      DataCell(Text(entry.value.latitude .toString())),
                      DataCell(Text(entry.value.longitude.toString())),
                      DataCell(Text(DataFunction.categoryToString(entry.value.category) ?? '')),
                      DataCell(Text(DataFunction.detailToString(entry.value.detail) ?? '')),
                      DataCell(Text(entry.value.isCrime == -1 ? 'Checking...' : entry.value.isCrime == 0 ? 'No' : 'Yes')),
                      DataCell(Text(entry.value.departureTime[0] == '9' ? '' : entry.value.departureTime ?? '-')),
                      DataCell(Text(entry.value.caseEndTime[0] == '9' ? '' : entry.value.caseEndTime ?? '-')),
                      DataCell(SoundContainer(filePath: entry.value.sound,)),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


