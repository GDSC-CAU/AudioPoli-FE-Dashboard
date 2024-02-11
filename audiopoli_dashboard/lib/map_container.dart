import 'dart:async';
import 'package:audiopoli_dashboard/custom_info_window_widget.dart';
import 'package:audiopoli_dashboard/sound_container.dart';
import 'package:audiopoli_dashboard/styled_container.dart';
import './custom_info_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_web/google_maps_flutter_web.dart' as google_map_flutter;
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import './incident_data.dart';
import 'custom_marker_provider.dart';
import 'google_map_api_loader.dart';

class MapContainer extends StatefulWidget {
  const MapContainer({super.key, required this.logMap});
  final Map<String, dynamic> logMap;

  @override
  State<MapContainer> createState() => _MapContainerState();
}

class _MapContainerState extends State<MapContainer> {
  late Future<void> _loadMapFuture;

  late GoogleMapController mapController;

  var incidentMap = <String, dynamic>{};
  Set<Marker> markers = {};

  GoogleMapsFlutterPlatform mapsImplementation = GoogleMapsFlutterPlatform.instance =  google_map_flutter.GoogleMapsPlugin();
  final CustomInfoWindowController _customInfoWindowController = CustomInfoWindowController();

  final LatLng _center = const LatLng(37.5058, 126.956);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  void initState() {
    super.initState();
    _loadMapFuture = GoogleMapApiLoader().loadGoogleMapApi();
    updateData();
    updateMarkers();
  }

  @override
  void didUpdateWidget(MapContainer oldWidget) {

    if (kDebugMode) {
      print('Update MapContainer Widget');
    }
    super.didUpdateWidget(oldWidget);
    updateData();
    updateMarkers();
  }


  Future<void> _addMarker(Set<Marker> newMarkers, dynamic entry, String markerId) async {
    newMarkers.add(
      Marker(
        icon: MarkerProvider().getMarker(entry.detail) ?? BitmapDescriptor.defaultMarker,
        markerId: MarkerId(markerId),
        position: LatLng(entry.latitude, entry.longitude),
        onTap: () {
          _customInfoWindowController.addInfoWindow!(
            CustomInfoWindowWidget(),
            LatLng(entry.latitude, entry.longitude),
          );
        },
      ),
    );
  }

  void updateMarkers() {
    Set<Marker> newMarkers = {};
    widget.logMap.forEach((key, value) {
      _addMarker(newMarkers, incidentMap[key], key);
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
        future: _loadMapFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: <Widget> [
                GoogleMap(
                  onMapCreated: (GoogleMapController controller) {
                    _customInfoWindowController.googleMapController = controller;
                    _onMapCreated(controller);
                  },
                  onTap: (LatLng latLng) {
                    _customInfoWindowController.hideInfoWindow!();
                  },
                  initialCameraPosition: CameraPosition(
                    target: _center,
                    zoom: 17.0,
                  ),
                  onCameraMove: (CameraPosition position) {
                    _customInfoWindowController.onCameraMove!();
                  },
                  markers: markers,
                ),
                CustomInfoWindow(
                  controller: _customInfoWindowController,
                  height: 100,
                  width: 150,
                  offset: 50,
                ),
              ]
            );
          } else {
            return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}