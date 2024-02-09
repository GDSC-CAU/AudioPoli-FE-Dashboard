import 'dart:async';
import 'package:audiopoli_dashboard/styled_container.dart';
import 'package:flutter/foundation.dart';
import 'package:universal_html/js.dart' as js;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_web/google_maps_flutter_web.dart' as google_map_flutter;
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import './incident_data.dart';

Future<void> loadGoogleMapsApi() {
  var completer = Completer<void>();

  String apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? "API 키가 없습니다";
  js.context.callMethod('setGoogleMapsApiKey', [apiKey]);

  Timer.periodic(const Duration(milliseconds: 100), (Timer timer) {
    if (js.context.hasProperty('google')) {
      timer.cancel();
      completer.complete();
    }
  });

  return completer.future;
}

class MapContainer extends StatefulWidget {
  const MapContainer({super.key, required this.logMap});
  final Map<String, dynamic> logMap;

  @override
  State<MapContainer> createState() => _MapContainerState();
}

class _MapContainerState extends State<MapContainer> {
  late GoogleMapController mapController;

  var incidentMap = <String, dynamic>{};

  GoogleMapsFlutterPlatform mapsImplementation = GoogleMapsFlutterPlatform.instance =  google_map_flutter.GoogleMapsPlugin();

  final LatLng _center = const LatLng(37.5058, 126.956);


  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    updateData();
    _updateMarkers();
  }

  @override
  void didUpdateWidget(MapContainer oldWidget) {

    if (kDebugMode) {
      print('Update MapContainer Widget');
    }
    super.didUpdateWidget(oldWidget);
    updateData();
    _updateMarkers();
  }

  void _addMarker(Set<Marker> newMarkers, dynamic entry) {
    setState(() {
      newMarkers.add(
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

  void _updateMarkers() {
    Set<Marker> newMarkers = {};
    widget.logMap.forEach((key, value) {
      _addMarker(newMarkers, incidentMap[key]);
    });
    setState(() {
      markers = newMarkers;
    });
  }

  void updateData() {
    setState(() {
      incidentMap.clear();
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
        incidentMap[key] = incident;
      });
    });
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StyledContainer(
      widget:FutureBuilder(
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
            return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}