import 'package:audiopoli_dashboard/LogContainer.dart';
import 'package:audiopoli_dashboard/incidentData.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import './mapContainer.dart';
import './TimeContainer.dart';
import './LogContainer.dart';
import 'firebase_options.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

var now = DateTime.now();
// "date": DateFormat('yyyy-MM-dd').format(now),

var sampleData = {
  "id": 1245,
  "date": DateFormat('yyyy-MM-dd').format(now),
  // "date" : "2024-01-28",
  "time": DateFormat('kk:mm:ss').format(now),
  "latitude": 37.5058,
  "longitude": 126.956,
  "sound": "대충 base64",
  "category": 1,
  "detail": 5,
  "isCrime": true
};

void main() async {
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(  options: DefaultFirebaseOptions.currentPlatform,);
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

class _MyAppState extends State<MyApp> {
  final ref = FirebaseDatabase.instance.ref('/');
  var logMap = new Map<String, dynamic>();
  var yesterdayCrime = new List<int>.filled(7, 0);
  var yesterdayTime = new List<int>.filled(23,0);

  @override
  void initState() {
    super.initState();

    // final Map<String, Map> updates = {};
    // updates[sampleData["id"].toString()] = sampleData as Map;
    // ref.update(updates)
    //     .then((_) {
    //   print('success!');
    //   // Data saved successfully!
    // })
    //     .catchError((error) {
    //   print(error);
    //   // The write failed...
    // });

    ref.onValue.listen((DatabaseEvent event) {

      DataSnapshot snapshot = event.snapshot;

      if(snapshot.exists)
      {
        var data = snapshot.value;
        if(data is Map) {
          data.forEach((key, value) {
            IncidentData incident = IncidentData(date: value['date'], time: value['time'], latitude: value['latitude'], longitude: value['longitude'], sound: value['sound'], category: value['category'], detail: value['detail'], id: value['id'], isCrime: value['isCrime']);
            logMap[key] = incident;
            if(compareDate(value['date'])) {
              yesterdayCrime[incident.category]++;
              yesterdayTime[int.parse(incident.time.split(":")[0])]++;
            }

          });
        }
      } else {
        print('No data available');
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: styledContainer()
                        ),
                        Expanded(
                          child: styledContainer(),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Stack(
                      children: [
                        mapContainer(),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: TimeContainer()
                        )
                      ]
                    ),
                  ),
                ],
              ),
            ),
            LogContainer()
          ],
        ),
      ),
    );
  }
}

class styledContainer extends StatelessWidget {
  styledContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(7.0),
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
    );
  }
}