import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:universal_html/js.dart' as js;

class GoogleMapApiLoader {

  static final GoogleMapApiLoader _instance = GoogleMapApiLoader._internal();

  factory GoogleMapApiLoader() {
    return _instance;
  }

  GoogleMapApiLoader._internal();

  Future<void> loadGoogleMapApi() {
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

}