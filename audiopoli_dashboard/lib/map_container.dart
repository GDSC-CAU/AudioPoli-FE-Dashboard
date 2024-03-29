import 'dart:async';
import 'package:audiopoli_dashboard/custom_info_window_widget.dart';
import 'package:audiopoli_dashboard/radar_animation.dart';
import 'package:audiopoli_dashboard/styled_container.dart';
import './custom_info_window.dart';
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
  final GlobalKey<RadarAnimationState> radarKey = GlobalKey<RadarAnimationState>();


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
    super.didUpdateWidget(oldWidget);
    updateData();
    updateMarkers();
    print("newMarkerAdded");
  }

  void updateMarkers() async {
    Set<String> currentMarkerIds = markers.map((m) => m.markerId.value).toSet();
    Set<String> logMapMarkerIds = widget.logMap.keys.toSet();
    Set<String> newMarkerIds = logMapMarkerIds.difference(currentMarkerIds);
    Set<String> removedMarkerIds = currentMarkerIds.difference(logMapMarkerIds);

    for (String markerId in newMarkerIds) {
      var newMarkerData = widget.logMap[markerId];
      _addMarker(newMarkerData, markerId);
    }

    setState(() {
      markers.removeWhere((m) => removedMarkerIds.contains(m.markerId.value));
    });
  }

  Future<void> _addMarker(dynamic entry, String markerId) async {
    final Marker newMarker =  Marker(
              icon: MarkerProvider().getMarker(entry.detail) ?? BitmapDescriptor.defaultMarker,
              markerId: MarkerId(markerId),
              position: LatLng(entry.latitude, entry.longitude),
              onTap: () {
                _customInfoWindowController.addInfoWindow!(
                  CustomInfoWindowWidget(data: entry, controller: _customInfoWindowController,),
                  LatLng(entry.latitude, entry.longitude),
                );
                mapController!.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(
                      target: LatLng(entry.latitude + 0.0005, entry.longitude),
                      zoom: 17.0,
                    ),
                  ),
                );
              },
            );

    setState(() {
      if(entry.caseEndTime[0] == '9') {
        markers.add(newMarker);
      }
    });

    if(entry.caseEndTime[0] == '9') {
      _customInfoWindowController.addInfoWindow!(
        CustomInfoWindowWidget(
          data: entry, controller: _customInfoWindowController,),
        LatLng(entry.latitude, entry.longitude),
      );
      mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(entry.latitude + 0.0005, entry.longitude),
            zoom: 17.0,
          ),
        ),
      );
      radarKey.currentState?.startAnimation();
    }
  }
  void updateData() {
    Set<String> toRemove = {};

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

        // 조건 확인: caseEndTime의 첫 문자가 '9'가 아닌 경우
        if (incident.caseEndTime != null && incident.caseEndTime!.startsWith('9')) {
          incidentMap[key] = incident;
        } else {
          toRemove.add(key);
        }
      });

      // 삭제 대상 마커 제거
      markers.removeWhere((marker) => toRemove.contains(marker.markerId.value));
    });
  }
  //
  // void updateData() {
  //   setState(() {
  //     incidentMap.clear();
  //     widget.logMap.forEach((key, value) {
  //       IncidentData incident = IncidentData(
  //           date: value.date,
  //           time: value.time,
  //           latitude: value.latitude,
  //           longitude: value.longitude,
  //           sound: value.sound,
  //           category: value.category,
  //           detail: value.detail,
  //           id: value.id,
  //           isCrime: value.isCrime,
  //           departureTime: value.departureTime,
  //           caseEndTime: value.caseEndTime
  //       );
  //       incidentMap[key] = incident;
  //     });
  //   });
  // }

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
                    controller.setMapStyle("""[
                      {
                        "featureType": "poi",
                        "elementType": "labels",
                        "stylers": [
                          { "visibility": "off" }
                        ]
                      }
                    ]""");
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
                Center(child: Padding(
                  padding: const EdgeInsets.only(top:100.0),
                  child: RadarAnimation(key: radarKey),
                )),
                CustomInfoWindow(
                  controller: _customInfoWindowController,
                  height: 130,
                  width: 270,
                  offset: 70,
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