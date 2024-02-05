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
  mapContainer({super.key, required this.logMap});
  Map<String, dynamic> logMap;

  @override
  State<mapContainer> createState() => _mapContainerState();
}

class _mapContainerState extends State<mapContainer> {
  late GoogleMapController mapController;

  var incidentDatas = new Map<String, dynamic>();

  GoogleMapsFlutterPlatform mapsImplementation = GoogleMapsFlutterPlatform.instance =  google_map_flutter.GoogleMapsPlugin();

  final LatLng _center = const LatLng(37.5058, 126.956);


  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    setState(() {
      updateDatas();
      widget.logMap.forEach((key, value) {
        _addMarker(incidentDatas[key]);
      });
    });
  }

  void _addMarker(dynamic entry) {
    setState(() {
      markers.add(
        Marker(
          markerId: MarkerId(entry.time),
          position: LatLng(entry.latitude, entry.longitude),
          infoWindow: InfoWindow(
            title: 'Incident Category: ${entry.category}',
            snippet: 'Detail: ${entry.detail}, Is Crime: ${entry.isCrime}',
          ),
        ),
      );
    });
  }

  void didUpdateWidget(mapContainer oldWidget) {

    print('Update MapContainer Widget');
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