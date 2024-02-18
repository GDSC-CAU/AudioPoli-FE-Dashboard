import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class DayStatisticContainer extends StatefulWidget {
  DayStatisticContainer({super.key, required this.list});
  final List<int> list;
  @override
  State<DayStatisticContainer> createState() => _DayStatisticContainerState();
}

class _DayStatisticContainerState extends State<DayStatisticContainer> {
  late List<TimeData> timeData;

  @override
  void initState() {
    super.initState();
    timeData = TimeData.createTimeDataList(widget.list);
  }

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      primaryXAxis: CategoryAxis(),
      title: ChartTitle(text: 'Incidents by Hour Yesterday'),
      series: <CartesianSeries>[
        LineSeries<TimeData, String>(
          dataSource: timeData,
          xValueMapper: (TimeData incidents, _) => incidents.hour,
          yValueMapper: (TimeData incidents, _) => incidents.incidents,
          name: 'Incidents',
        )
      ],
    );
  }
}

class TimeData {
  final String hour;
  final int incidents;

  TimeData(this.hour, this.incidents);

  static List<TimeData> createTimeDataList(List<int> yesterdayTime) {
    List<TimeData> timeDataList = [];
    for (int i = 0; i < yesterdayTime.length; i++) {
      String hourLabel = "${i.toString().padLeft(2, '0')}:00";
      timeDataList.add(TimeData(hourLabel, yesterdayTime[i]));
    }
    return timeDataList;
  }
}


