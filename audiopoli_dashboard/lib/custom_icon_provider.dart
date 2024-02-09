import 'dart:ui' as dart_ui;
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class IconProvider {
  BitmapDescriptor? customIcon;
  static final IconProvider _instance = IconProvider._internal();

  factory IconProvider() {
    return _instance;
  }

  IconProvider._internal();

  Future<void> loadCustomIcon() async {
    if (customIcon == null) {
      final ByteData byteData = await rootBundle.load('assets/img/custom_marker.png');
      final Uint8List imageData = byteData.buffer.asUint8List();
      dart_ui.Codec codec = await dart_ui.instantiateImageCodec(imageData, targetWidth: 48);
      dart_ui.FrameInfo fi = await codec.getNextFrame();
      final Uint8List markerIcon = (await fi.image.toByteData(format: dart_ui.ImageByteFormat.png))!.buffer.asUint8List();
      customIcon = BitmapDescriptor.fromBytes(markerIcon);
    }
  }

  BitmapDescriptor? getIcon() {
    return customIcon;
  }
}