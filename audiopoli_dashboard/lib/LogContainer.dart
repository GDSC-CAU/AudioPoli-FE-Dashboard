import 'package:flutter/material.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'incidentData.dart';

class LogContainer extends StatefulWidget {
  LogContainer({super.key, required this.logMap});
  Map<String, dynamic> logMap;
  @override
  State<LogContainer> createState() => _LogContainerState();
}

class _LogContainerState extends State<LogContainer> {
  var incidentDatas = new Map<String, dynamic>();
  @override
  void initState() {
    super.initState();
    setState(() {
      updateDatas();
    });
  }

  @override
  void didUpdateWidget(LogContainer oldWidget) {

    print('Update LogContainer Widget');
    super.didUpdateWidget(oldWidget);
    updateDatas();
  }


  void updateDatas() {
    setState(() {
      incidentDatas.clear();
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
        incidentDatas[key] = incident;
      });
    });
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
            offset: Offset(0, 1),
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
                fontWeight: FontWeight.bold,
                fontSize: 12.0
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
                DataColumn(label: Container(width: 50, child: Text('Is Crime'))),
                DataColumn(label: Container(width: 80, child: Text('Departure'))),
                DataColumn(label: Container(width: 80, child: Text('Case End'))),
                DataColumn(label: Container(width: 300, child: Text('Bigo'))),
              ],
              rows: [],
            ),
          ),
          content: Container(
            width: double.infinity,
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: DataTable(
                border: TableBorder(
                  verticalInside: BorderSide(
                    width: 0.5,
                    color: Colors.grey
                  ),
                  horizontalInside: BorderSide(
                    color: Colors.transparent,
                    style: BorderStyle.solid
                  )
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
                  DataColumn(label: Container(width: 50,)),
                  DataColumn(label: Container(width: 80,)),
                  DataColumn(label: Container(width: 80,)),
                  DataColumn(label: Container(width: 300,)),
                ],
                rows: incidentDatas.entries.map((entry) {
                  return DataRow(
                    color: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
                      if (incidentDatas.keys.toList().indexOf(entry.key) % 2 != 0) {
                        return Colors.grey.withOpacity(0.3);
                      }
                      return null;
                    }),
                    cells: [
                      DataCell(Text(entry.value.date ?? '')),
                      DataCell(Text(entry.value.time ?? '')),
                      DataCell(Text(entry.value.latitude .toString() ?? '')),
                      DataCell(Text(entry.value.longitude.toString() ?? '')),
                      DataCell(Text(entry.value.sound ?? '')),
                      DataCell(Text(entry.value.category.toString() ?? '')),
                      DataCell(Text(entry.value.detail.toString() ?? '')),
                      DataCell(Text(entry.value.isCrime == true ? 'Yes' : 'No')),
                      DataCell(Text(entry.value.departureTime ?? '')),
                      DataCell(Text(entry.value.caseEndTime ?? '')),
                      DataCell(Text(entry.key.toString())), //임시로 데이터 key값 출력
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


