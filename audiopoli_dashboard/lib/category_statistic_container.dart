import 'package:audiopoli_dashboard/data_function.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class CategoryStatisticContainer extends StatefulWidget {
  CategoryStatisticContainer({super.key, required this.yesterdayList, required this.todayList});
  final List<int> yesterdayList;
  final List<int> todayList;
  @override
  State<CategoryStatisticContainer> createState() => _CategoryStatisticContainerState();
}

class _CategoryStatisticContainerState extends State<CategoryStatisticContainer> {
  late List<CategoryData> yesterdayData;
  late List<CategoryData> todayData;

  @override
  void initState() {
    super.initState();
    yesterdayData = CategoryData.createCategoryDataList(widget.yesterdayList);
    todayData = CategoryData.createCategoryDataList(widget.todayList);
  }

  @override
  void didUpdateWidget(CategoryStatisticContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {
      yesterdayData = CategoryData.createCategoryDataList(widget.yesterdayList);
      todayData = CategoryData.createCategoryDataList(widget.todayList);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      primaryXAxis: CategoryAxis(
        interval: 1,
        edgeLabelPlacement: EdgeLabelPlacement.shift,
        labelStyle: TextStyle(fontWeight: FontWeight.bold),
      ),
      primaryYAxis: NumericAxis(
        labelFormat: '{value}',
        interval: 1,
      ),
      series: <CartesianSeries>[
        ColumnSeries<CategoryData, String>(
          dataSource: yesterdayData,
          xValueMapper: (CategoryData incidents, _) => DataFunction.categoryToGraph(incidents.category),
          yValueMapper: (CategoryData incidents, _) => incidents.incidents,
          pointColorMapper: (CategoryData incidents, _) => incidents.color.withAlpha(95),
          name: 'Yesterday',
        ),
        ColumnSeries<CategoryData, String>(
          dataSource: todayData,
          xValueMapper: (CategoryData incidents, _) => DataFunction.categoryToGraph(incidents.category),
          yValueMapper: (CategoryData incidents, _) => incidents.incidents,
          pointColorMapper: (CategoryData incidents, _) => incidents.color,
          name: 'Today',
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

class CategoryData {
  final int category;
  final int incidents;
  final Color color;

  CategoryData(this.category, this.incidents, this.color);

  static List<CategoryData> createCategoryDataList(List<int> yesterdayCategory) {
    Color _color = Colors.black;
    List<CategoryData> categoryDataList = [];
    for (int i = 1; i < yesterdayCategory.length - 1; i++) {
      switch (i) {
        case 1:
          _color = Colors.orangeAccent;
          break;
        case 2:
          _color = Colors.redAccent;
          break;
        case 3:
          _color = Colors.deepPurpleAccent;
          break;
        case 4:
          _color = Colors.blueAccent;
          break;
        case 5:
          _color = Colors.green;
      }
      categoryDataList.add(CategoryData(i, yesterdayCategory[i], _color));
      print(yesterdayCategory[i]);
    }
    return categoryDataList;
  }
}


