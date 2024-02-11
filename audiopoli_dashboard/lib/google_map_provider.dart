class GoogleMapProvider {

  static final GoogleMapProvider _instance = GoogleMapProvider._internal();

  factory GoogleMapProvider() {
    return _instance;
  }

  GoogleMapProvider._internal();

}