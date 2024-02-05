import 'dart:async';
import 'dart:js' as js;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_web/google_maps_flutter_web.dart' as google_map_flutter;
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import './incidentData.dart';

Future<void> loadGoogleMapsApi() {
  var completer = Completer<void>();

  String apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? "API 키가 없습니다";
  js.context.callMethod('setGoogleMapsApiKey', [apiKey]);

  Timer.periodic(Duration(milliseconds: 100), (Timer timer) {
    if (js.context.hasProperty('google')) {
      timer.cancel();
      completer.complete();
    }
  });

  return completer.future;
}

class mapContainer extends StatefulWidget {
  mapContainer({super.key});

  @override
  State<mapContainer> createState() => _mapContainerState();
}

class _mapContainerState extends State<mapContainer> {
  late GoogleMapController mapController;

  GoogleMapsFlutterPlatform mapsImplementation = GoogleMapsFlutterPlatform.instance =  google_map_flutter.GoogleMapsPlugin();

  final LatLng _center = const LatLng(37.5058, 126.956);

  //그저 샘플 데이터. incidentData.dart에서 받아와야함 실제 서버에서 받을 땐
  IncidentData sampleData0 = IncidentData(
      date: "2012-01-26",
      time: "13:51:50",
      latitude: 37.5058,
      longitude: 126.956,
      sound: "대충 base64",
      category: 5,
      detail: 3,
      isCrime: true,
      id: 1,
      departureTime: "",
      caseEndTime: "",
  );

  IncidentData sampleData1 = IncidentData(
      date: "2012-01-26",
      time: "13:51:50",
      latitude: 37.5068,
      longitude: 126.957,
      sound: "대충 base64",
      category: 3,
      detail: 3,
      isCrime: true,
      id: 1,
      departureTime: "",
      caseEndTime: "",
  );

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Set<Marker> markers = {};
  List<IncidentData> incidentDatas = [];

  @override
  void initState() {
    super.initState();
    // widget.channel.stream.listen((data) {
    //   var incidentData = IncidentData.fromJson(json.decode(data));
    //   _addMarker(incidentData);
    // });
    incidentDatas.add(sampleData0);
    incidentDatas.add(sampleData1);
    setState(() {
      for(int i = 0; i < incidentDatas.length; i++){
        _addMarker(incidentDatas[i]);
      }
    });
  }

  void _addMarker(IncidentData incidentData) {
    setState(() {
      markers.add(
        Marker(
          markerId: MarkerId(incidentData.time),
          position: LatLng(incidentData.latitude, incidentData.longitude),
          infoWindow: InfoWindow(
            title: 'Incident Category: ${incidentData.category}',
            snippet: 'Detail: ${incidentData.detail}, Is Crime: ${incidentData.isCrime}',
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      margin: EdgeInsets.all(7.0),
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
      child:FutureBuilder(
        future: loadGoogleMapsApi(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 17.0,
              ),
              markers: markers,
            );
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
    );
  }
}