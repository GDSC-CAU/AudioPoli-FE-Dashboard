import 'dart:async';
import 'dart:math';
import 'package:audiopoli_dashboard/log_container.dart';
import 'package:audiopoli_dashboard/incident_data.dart';
import 'package:audiopoli_dashboard/time_container.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import './styled_container.dart';
import 'custom_marker_provider.dart';
import 'firebase_options.dart';
import 'package:firebase_database/firebase_database.dart';
import 'map_container.dart';
var now = DateTime.now();
// "date": DateFormat('yyyy-MM-dd').format(now),

IncidentData sampleData = IncidentData(date: DateFormat('yyyy-MM-dd').format(now), time: DateFormat('kk:mm:ss').format(now), latitude: 37.5058, longitude: 126.956, sound: "대충 base64", category: 1, detail: 5, isCrime: -1, id: 35, departureTime: "", caseEndTime: "");

void main() async {
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
  await MarkerProvider().loadCustomMarker();
  runApp(const MyApp());
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
  final ref = FirebaseDatabase.instance.ref("/crime/${data.id.toString()}");

  ref.update({"departureTime": time})
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

void updateCaseEndTime(IncidentData data, String time)
{
  final ref = FirebaseDatabase.instance.ref("/crime/${data.id.toString()}");

  ref.update({"caseEndTime": time})
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

void sendDataToDB() {
  final now = DateTime.now();
  final dateFormatter = DateFormat('yyyy-MM-dd');
  final timeFormatter = DateFormat('HH:mm:ss');
  final date = dateFormatter.format(now);
  final time = timeFormatter.format(now);
  final latitude = double.parse((Random().nextDouble() * (37.506700 - 37.504241) + 37.504241).toStringAsFixed(6));
  final longitude = double.parse((Random().nextDouble() * (126.959567 - 126.951557) + 126.951557).toStringAsFixed(6));
  final detail = Random().nextInt(14) + 1;
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
      isCrime: -1,
      id: Random().nextInt(10000),
      departureTime: "99:99:99",
      caseEndTime: "99:99:99"
  );

  final ref = FirebaseDatabase.instance.ref('/crime');
  final Map<String, Map> updates = {};
  updates[sampleData.id.toString()] = sampleData.toMap();
  ref.update(updates)
      .then((_) {
    if (kDebugMode) {
      print('success!');
    }
    // Data saved successfully!
  })
      .catchError((error) {
    if (kDebugMode) {
      print(error);
    }
    // The write failed…
  });
}

void deleteRecentData() {
  final DatabaseReference ref = FirebaseDatabase.instance.ref("/crime");

  // 가장 최근 항목에 대한 쿼리 생성
  Query lastItemQuery = ref.orderByKey().limitToLast(1);

  // 쿼리 실행 및 결과에 대한 스냅샷 가져오기
  lastItemQuery.get().then((DataSnapshot snapshot) {
    if (snapshot.exists) {
      // 스냅샷에서 첫 번째 항목의 키 가져오기
      Map<dynamic, dynamic> children = snapshot.value as Map<dynamic, dynamic>;
      String? lastItemKey = children.keys.first;

      if (lastItemKey != null) {
        // 가장 최근 항목 삭제
        ref.child(lastItemKey).remove().then((_) {
          if (kDebugMode) {
            print("가장 최근 항목이 성공적으로 삭제되었습니다.");
          }
        }).catchError((error) {
          if (kDebugMode) {
            print("삭제 중 오류 발생: $error");
          }
        });
      }
    } else {
      if (kDebugMode) {
        print("데이터가 존재하지 않습니다.");
      }
    }
  }).catchError((error) {
    if (kDebugMode) {
      print("쿼리 실행 중 오류 발생: $error");
    }
  });
}

class _MyAppState extends State<MyApp> {
  final ref = FirebaseDatabase.instance.ref('/crime/');
  var logMap = <String, dynamic>{};
  var yesterdayCrime = List<int>.filled(7, 0);
  var yesterdayTime = List<int>.filled(24,0);
  final StreamController<Map<String, dynamic>> _logMapController = StreamController.broadcast();


  @override
  void initState() {
    super.initState();
    // updateIsCrime(sampleData, true);
    // updateDepartureTime(sampleData, "23:40");
    // updateCaseEndTime(sampleData, "2:20");
    ref.onValue.listen((DatabaseEvent event) {
      loadDataFromDB(event);
      if (kDebugMode) {
        print('Data reload');
      }
    });
  }

  void loadDataFromDB(DatabaseEvent event) async {
    DataSnapshot snapshot = event.snapshot;
    if(snapshot.exists)
    {
      var data = snapshot.value;
      Map<String, IncidentData> newLogMap = {};
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
          newLogMap[key] = incident;
          if(compareDate(value['date'])) {
            yesterdayCrime[incident.category]++;
            yesterdayTime[int.parse(incident.time.split(":")[0])]++;
          }
        });
      }
      setState(() {
        logMap = newLogMap;
      });
      _logMapController.add(logMap);
    } else {
      if (kDebugMode) {
        print('No data available');
      }
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
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 1.5,
                  blurRadius: 1.5,
                  offset: const Offset(0, 1.5),
                ),
              ],
            ),
            child: AppBar(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              centerTitle: false,
              leadingWidth: 500,
              leading: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(padding: EdgeInsets.all(3), child: Image.asset("img/logo.png")),
                  Image.asset("img/logo_text.png", height: 28,),
                ]
              ),
              // titleTextStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 32.0),
              // title: const Text("AUDIO POLI"),
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
                          flex: 3,
                          child: StyledContainer(widget: Container(),),
                        ),
                        Expanded(
                          flex: 3,
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
                            MapContainer(logMap: updatedMap),
                            const Positioned(
                              top: 10,
                              right: 10,
                              child: TimeContainer()
                            )
                          ]
                        ),
                      );
                    } else {
                      return const Expanded(
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
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            sendDataToDB();
                          },
                        )
                      ),
                      Positioned(
                          bottom: 10,
                          right: 50,
                          child: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              deleteRecentData();
                            },
                          )
                      )
                    ],
                  );
                } else {
                  return const Expanded(
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