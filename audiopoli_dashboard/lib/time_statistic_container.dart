import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class TimeStatisticContainer extends StatefulWidget {
  TimeStatisticContainer({super.key, required this.yesterdayList, required this.todayList});
  final List<int> yesterdayList;
  final List<int> todayList;
  @override
  State<TimeStatisticContainer> createState() => _TimeStatisticContainerState();
}

class _TimeStatisticContainerState extends State<TimeStatisticContainer> {
  late List<TimeData> yesterdayData;
  late List<TimeData> todayData;

  @override
  void initState() {
    super.initState();
    yesterdayData = TimeData.createTimeDataList(widget.yesterdayList);
    todayData = TimeData.createTimeDataList(widget.todayList);
  }

  @override
  void didUpdateWidget(TimeStatisticContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {
      yesterdayData = TimeData.createTimeDataList(widget.yesterdayList);
      todayData = TimeData.createTimeDataList(widget.todayList);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      primaryXAxis: CategoryAxis(
        interval: 2,
        edgeLabelPlacement: EdgeLabelPlacement.shift,
      ),
      primaryYAxis: NumericAxis(
        labelFormat: '{value}',
        interval: 1,
      ),
      series: <CartesianSeries>[
        AreaSeries<TimeData, String>(
          borderColor: Colors.deepPurpleAccent,
          color: Colors.deepPurpleAccent.withOpacity(0.3),
          dataSource: yesterdayData,
          xValueMapper: (TimeData incidents, _) => incidents.hour,
          yValueMapper: (TimeData incidents, _) => incidents.incidents,
          name: 'Today',
        ),
        AreaSeries<TimeData, String>(
          borderColor: Colors.blueAccent,
          color: Colors.blueAccent.withOpacity(0.3),
          dataSource: todayData,
          xValueMapper: (TimeData incidents, _) => incidents.hour,
          yValueMapper: (TimeData incidents, _) => incidents.incidents,
          name: 'Yesterday',
        )
      ],
      trackballBehavior: TrackballBehavior(
        enable: true, // Trackball을 활성화
        lineType: TrackballLineType.vertical, // 세로선으로 표시
        activationMode: ActivationMode.singleTap, // 탭으로 활성화
        tooltipSettings: InteractiveTooltip(
          enable: true, // 툴팁 활성화
        ),
      ),
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
      String hourLabel = "${i.toString().padLeft(2, '0')}";
      timeDataList.add(TimeData(hourLabel, yesterdayTime[i]));
    }
    return timeDataList;
  }
}


