import 'package:audiopoli_dashboard/data_function.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class CategoryStatisticContainer extends StatefulWidget {
  CategoryStatisticContainer(
      {super.key, required this.yesterdayList, required this.todayList});
  final List<int> yesterdayList;
  final List<int> todayList;
  @override
  State<CategoryStatisticContainer> createState() =>
      _CategoryStatisticContainerState();
}

class _CategoryStatisticContainerState
    extends State<CategoryStatisticContainer> {
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(bottom: 5),
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 0.5, color: Colors.grey))),
          height: 25,
          alignment: Alignment.centerLeft,
          child: Text(
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              'Category statistic'),
        ),
        Expanded(
          child: SfCartesianChart(
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
                xValueMapper: (CategoryData incidents, _) =>
                    DataFunction.categoryToGraph(incidents.category),
                yValueMapper: (CategoryData incidents, _) =>
                    incidents.incidents,
                pointColorMapper: (CategoryData incidents, _) =>
                    incidents.color.withAlpha(95),
                name: 'Yesterday',
              ),
              ColumnSeries<CategoryData, String>(
                dataSource: todayData,
                xValueMapper: (CategoryData incidents, _) =>
                    DataFunction.categoryToGraph(incidents.category),
                yValueMapper: (CategoryData incidents, _) =>
                    incidents.incidents,
                pointColorMapper: (CategoryData incidents, _) =>
                    incidents.color,
                name: 'Today',
              )
            ],
            trackballBehavior: TrackballBehavior(
              enable: true,
              lineType: TrackballLineType.vertical,
              activationMode: ActivationMode.singleTap,
              tooltipDisplayMode: TrackballDisplayMode.groupAllPoints
            ),
          ),
        ),
      ],
    );
  }
}

class CategoryData {
  final int category;
  final int incidents;
  final Color color;

  CategoryData(this.category, this.incidents, this.color);

  static List<CategoryData> createCategoryDataList(
      List<int> yesterdayCategory) {
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
    }
    return categoryDataList;
  }
}
