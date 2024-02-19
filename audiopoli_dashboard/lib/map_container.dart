import 'dart:async';
import 'package:audiopoli_dashboard/custom_info_window_widget.dart';
import 'package:audiopoli_dashboard/radar_animation.dart';
import 'package:audiopoli_dashboard/sound_container.dart';
import 'package:audiopoli_dashboard/styled_container.dart';
import 'package:collection/collection.dart';
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
  //
  //
  // Future<void> _addMarker(Set<Marker> newMarkers, dynamic entry, String markerId) async {
  //   newMarkers.add(
  //     Marker(
  //       icon: MarkerProvider().getMarker(entry.detail) ?? BitmapDescriptor.defaultMarker,
  //       markerId: MarkerId(markerId),
  //       position: LatLng(entry.latitude, entry.longitude),
  //       onTap: () {
  //         _customInfoWindowController.addInfoWindow!(
  //           CustomInfoWindowWidget(data: entry, controller: _customInfoWindowController,),
  //           LatLng(entry.latitude, entry.longitude),
  //         );
  //       },
  //     ),
  //   );
  // }

  // void updateMarkers() {
  //   Set<Marker> newMarkers = {};
  //   widget.logMap.forEach((key, value) {
  //     _addMarker(newMarkers, incidentMap[key], key);
  //   });
  //   setState(() {
  //     markers = newMarkers;
  //   });
  // }

  void updateMarkers() async {
    // 현재 markers 세트의 마커 ID 추출
    Set<String> currentMarkerIds = markers.map((m) => m.markerId.value).toSet();

    // logMap에서의 마커 ID
    Set<String> logMapMarkerIds = widget.logMap.keys.toSet();

    // 새로 추가될 마커 ID (logMap에는 있지만 현재 마커 세트에는 없는 ID)
    Set<String> newMarkerIds = logMapMarkerIds.difference(currentMarkerIds);

    // 제거될 마커 ID (현재 마커 세트에는 있지만 logMap에는 없는 ID)
    Set<String> removedMarkerIds = currentMarkerIds.difference(logMapMarkerIds);

    // 새로 추가될 마커 처리
    for (String markerId in newMarkerIds) {
      var newMarkerData = widget.logMap[markerId];
      _addMarker(newMarkerData, markerId);
    }

    setState(() {
      markers.removeWhere((m) => removedMarkerIds.contains(m.markerId.value));
    });
  }

// _addMarker 함수는 비동기로 마커를 추가하는 로직 포함
  Future<void> _addMarker(dynamic entry, String markerId) async {
    // 마커 생성 로직 (markerData와 markerId를 기반으로 마커 생성)
    final Marker newMarker =  Marker(
              icon: MarkerProvider().getMarker(entry.detail) ?? BitmapDescriptor.defaultMarker,
              markerId: MarkerId(markerId),
              position: LatLng(entry.latitude, entry.longitude),
              onTap: () {
                _customInfoWindowController.addInfoWindow!(
                  CustomInfoWindowWidget(data: entry, controller: _customInfoWindowController,),
                  LatLng(entry.latitude, entry.longitude),
                );
              },
            );

    setState(() {
      markers.add(newMarker);
    });
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
    radarKey.currentState?.startAnimation();
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


  // ㅓㄹㄴ아;ㅣ러;미ㅏㄹㄴ허;ㅣㅁㅇ
  // void updateExistingMarker(String id, IncidentData entry) {
  //   Marker? existingMarker = markers.firstWhereOrNull((marker) => marker.markerId.value == id);
  //   if (existingMarker != null) {
  //     final updatedMarker = Marker(
  //       icon: MarkerProvider().getMarker(entry.detail) ?? BitmapDescriptor.defaultMarker,
  //       markerId: MarkerId(id),
  //       position: LatLng(entry.latitude, entry.longitude),
  //       onTap: () {
  //         _customInfoWindowController.addInfoWindow!(
  //           CustomInfoWindowWidget(data: entry, controller: _customInfoWindowController,),
  //           LatLng(entry.latitude, entry.longitude),
  //         );
  //       },
  //     );
  //
  //     setState(() {
  //       markers.remove(existingMarker);
  //       markers.add(updatedMarker);
  //     });
  //   }
  // }
  //
  // Future<void> addNewMarkerAndShowInfoWindow(String id, IncidentData entry) async {
  //   final Marker newMarker = Marker(
  //     icon: MarkerProvider().getMarker(entry.detail) ??
  //         BitmapDescriptor.defaultMarker,
  //     markerId: MarkerId(id),
  //     position: LatLng(entry.latitude, entry.longitude),
  //     onTap: () {
  //       _customInfoWindowController.addInfoWindow!(
  //         CustomInfoWindowWidget(
  //           data: entry, controller: _customInfoWindowController,),
  //         LatLng(entry.latitude, entry.longitude),
  //       );
  //     },
  //   );
  //
  //   setState(() {
  //     markers.add(newMarker);
  //
  //   });
  //
  // }
  //
  // void updateData() {
  //   Set<String> currentMarkerIds = markers.map((m) => m.markerId.value).toSet();
  //   var isNew = false;
  //   var newData;
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
  //
  //       if (currentMarkerIds.contains(key)) {
  //         // 기존 마커 업데이트
  //         updateExistingMarker(key, incidentMap[key]);
  //       } else {
  //         addNewMarkerAndShowInfoWindow(key, incidentMap[key]);
  //         isNew = true;
  //         newData = incidentMap[key];
  //       }
  //     });
  //   });
  //   if(isNew) {
  //     _customInfoWindowController.addInfoWindow!(
  //       CustomInfoWindowWidget(
  //         data: newData, controller: _customInfoWindowController,),
  //       LatLng(newData.latitude, newData.longitude),
  //     );
  //     mapController.animateCamera(
  //       CameraUpdate.newCameraPosition(
  //         CameraPosition(
  //           target: LatLng(newData.latitude + 0.0005, newData.longitude),
  //           zoom: 17.0,
  //         ),
  //       ),
  //     );
  //   }
  //
  // }
  //ㅓ아ㅣㄹ;ㅓㅁㅇ나ㅣ러;ㅣ만허ㅏㅁ;ㅇㄹㅎ

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
                  height: 140,
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