import 'dart:async';
import 'dart:math';

import 'package:audiopoli_dashboard/LogContainer.dart';
import 'package:audiopoli_dashboard/incidentData.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import './mapContainer.dart';
import './TimeContainer.dart';
import './LogContainer.dart';
import './StyledContainer.dart';
import './SoundContainer.dart';
import 'firebase_options.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

var now = DateTime.now();
// "date": DateFormat('yyyy-MM-dd').format(now),

IncidentData sampleData = IncidentData(date: DateFormat('yyyy-MM-dd').format(now), time: DateFormat('kk:mm:ss').format(now), latitude: 37.5058, longitude: 126.956, sound: "대충 base64", category: 1, detail: 5, isCrime: false, id: 35, departureTime: "", caseEndTime: "");

void main() async {
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

bool compareDate(String date) {
  List<String> yearMonthDay = date.split('-');
  var dateDate = DateTime(int.parse(yearMonthDay[0]), int.parse(yearMonthDay[1]), int.parse(yearMonthDay[2]) );

  var nowDate = DateTime.now();

  Duration diff = nowDate.difference(dateDate);

  if (diff.inDays == 1) { return true; }
  else { return false; }
}

void updateDepartureTime(IncidentData data, String time)
{
  final ref = FirebaseDatabase.instance.ref("/${data.id.toString()}");

  ref.update({"departureTime": time})
      .then((_) {
    print('success!');
  })
      .catchError((error) {
    print(error);
  });
}

void updateCaseEndTime(IncidentData data, String time)
{
  final ref = FirebaseDatabase.instance.ref("/${data.id.toString()}");

  ref.update({"caseEndTime": time})
      .then((_) {
    print('success!');
  })
      .catchError((error) {
    print(error);
  });
}

void updateIsCrime(IncidentData data, bool TF) {
  final ref = FirebaseDatabase.instance.ref("/${data.id.toString()}");

  ref.update({"isCrime": TF})
      .then((_) {
    print('success!');
  })
      .catchError((error) {
    print(error);
  });
}

void sendDataToDB() {
  final now = DateTime.now();
  final dateFormatter = DateFormat('yyyy-MM-dd');
  final timeFormatter = DateFormat('HH:mm:ss');
  final date = dateFormatter.format(now);
  final time = timeFormatter.format(now);
  final latitude = double.parse((Random().nextDouble() * (37.506700 - 37.504241) + 37.504241).toStringAsFixed(6));
  final longitude = double.parse((Random().nextDouble() * (126.959567 - 126.951557) + 126.951557).toStringAsFixed(6));
  final detail = Random().nextInt(16) + 1;
  Map<int, int> detailToCategory = {
    1: 1, 2: 1, 3: 1, 4: 1,
    5: 2, 6: 2, 7: 2, 8: 2, 9: 2,
    10: 4, 11: 4,
    12: 3, 13: 3,
    14: 5,
    15: 6, 16: 6,
  };
  final category = detailToCategory[detail]!;

  IncidentData sampleData = IncidentData(
      date: date,
      time: time,
      latitude: latitude,
      longitude: longitude,
      sound: "대충 base64",
      category: category,
      detail: detail,
      isCrime: false,
      id: Random().nextInt(10000),
      departureTime: "00:00:00",
      caseEndTime: "11:11:11"
  );

  final ref = FirebaseDatabase.instance.ref('/');
  final Map<String, Map> updates = {};
  updates[sampleData.id.toString()] = sampleData.toMap();
  ref.update(updates)
      .then((_) {
    print('success!');
    // Data saved successfully!
  })
      .catchError((error) {
    print(error);
    // The write failed…
  });
}

class _MyAppState extends State<MyApp> {
  final ref = FirebaseDatabase.instance.ref('/');
  var logMap = new Map<String, dynamic>();
  var yesterdayCrime = new List<int>.filled(7, 0);
  var yesterdayTime = new List<int>.filled(24,0);
  final StreamController<Map<String, dynamic>> _logMapController = StreamController.broadcast();


  @override
  void initState() {
    super.initState();
    // updateIsCrime(sampleData, true);
    // updateDepartureTime(sampleData, "23:40");
    // updateCaseEndTime(sampleData, "2:20");
    sendDataToDB();
    ref.onValue.listen((DatabaseEvent event) {
      loadDataFromDB(event);
      print('Data reload');
    });
  }

  void loadDataFromDB(DatabaseEvent event) async {
    DataSnapshot snapshot = event.snapshot;
    if(snapshot.exists)
    {
      var data = snapshot.value;
      if(data is Map) {
        data.forEach((key, value) {
          IncidentData incident = IncidentData(
              date: value['date'],
              time: value['time'],
              latitude: value['latitude'],
              longitude: value['longitude'],
              sound: value['sound'],
              category: value['category'],
              detail: value['detail'],
              id: value['id'],
              isCrime: value['isCrime'],
              departureTime: value['departureTime'],
              caseEndTime: value['caseEndTime']
          );
          logMap[key] = incident;
          if(compareDate(value['date'])) {
            yesterdayCrime[incident.category]++;
            yesterdayTime[int.parse(incident.time.split(":")[0])]++;
          }
        });
      }
      _logMapController.add(logMap);
    } else {
      print('No data available');
    }
  }

  @override
  void dispose() {
    _logMapController.close();
    super.dispose();
  }


    @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 1.5,
                  blurRadius: 1.5,
                  offset: Offset(0, 1.5),
                ),
              ],
            ),
            child: AppBar(
              backgroundColor: Colors.white,
              centerTitle: false,
              leading: Container(color: Colors.white, child: Image.asset("img/logo.png"),),
              titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 22.0),
              title: Text("AudioPoli"),
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: SoundContainer(),
                        ),
                        Expanded(
                          child: StyledContainer(widget: Container(),),
                        ),
                      ],
                    ),
                  ),
                StreamBuilder<Map<String, dynamic>>(
                  stream: _logMapController.stream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final updatedMap = snapshot.data!;
                      return Expanded(
                        flex: 3,
                        child: Stack(
                          children: [
                            mapContainer(logMap: updatedMap),
                            Positioned(
                              top: 10,
                              right: 10,
                              child: TimeContainer()
                            )
                          ]
                        ),
                      );
                    } else {
                      return Expanded(
                        child: StyledContainer(
                          widget: CircularProgressIndicator(),
                        ),
                      );
                    }
                  },),
                ],
              ),
            ),
            StreamBuilder<Map<String, dynamic>>(
              stream: _logMapController.stream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final updatedMap = snapshot.data!;
                  return Stack(
                    children: [
                      LogContainer(logMap: updatedMap),
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            sendDataToDB();
                          },
                        )
                      )
                    ],
                  );
                } else {
                  return Expanded(
                    child: StyledContainer(
                      widget: CircularProgressIndicator(),
                    ),
                  );
                }
              },
            )
          ],
        ),
      ),
    );
  }
}