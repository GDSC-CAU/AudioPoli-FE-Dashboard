import 'dart:async';
import 'dart:js' as js;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_web/google_maps_flutter_web.dart' as google_map_flutter;
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

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

class mapContainer extends StatelessWidget {
  mapContainer({super.key});
  late GoogleMapController mapController;
  GoogleMapsFlutterPlatform mapsImplementation = GoogleMapsFlutterPlatform.instance =  google_map_flutter.GoogleMapsPlugin();

  final LatLng _center = const LatLng(45.521563, -122.677433);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }
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
      child:FutureBuilder(
        future: loadGoogleMapsApi(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 11.0,
              ),
            );
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
    );
  }
}