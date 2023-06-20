import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:zone_o_app/rating_bar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Zone'O",
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: "Zone'O"),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class ApartAttributes {
  final String price;
  final String date;
  final String location;
  final double finalMark;
  final double lat;
  final double lon;

  const ApartAttributes({required this.price, required this.date, required this.location, required this.finalMark, required this.lat, required this.lon});
}

class _MyHomePageState extends State<MyHomePage> {

  final _mapController = MapController.withUserPosition(
    trackUserLocation: UserTrackingOption(
      enableTracking: true,
      unFollowUser: false,
    )
  );

  final _cityTextController = TextEditingController();

  var apartsMarkerMap = <String, ApartAttributes>{};

  var qqveRequirements = <String, double>{};

  callback(key, newRating) {
    qqveRequirements[key] = newRating;
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void parseApartsResults(var res) async {
    double lat = 0;
    double lon = 0;
    var key = "";
    apartsMarkerMap.clear();
    for (var apart in res) {
      lat = double.parse(apart['lat']);
      lon = double.parse(apart['lon']);
      await _mapController.addMarker(
        GeoPoint(latitude: lat, longitude: lon),
        markerIcon: const MarkerIcon(icon: Icon(Icons.pin_drop, color: Colors.blue, size: 48))
      );
      key = apart['lat'] + '_' + apart['lon'];
      apartsMarkerMap[key] = ApartAttributes(price: apart['price'], date: apart['date'], location: apart['location'], finalMark: apart['finalMark'], lat: lat, lon: lon);
    }
  }

  void getQQVEApartsInCity(var city) async {
    String url = 'localhost:3000';
    final response = await http.post(Uri.http(url, '/qqveApartsInCity'), body: {
      'city': city,
      'markEssentials': qqveRequirements['Premières Nécessités'].toString(),
      'markWorkplaces': qqveRequirements['Lieux de Travails'].toString(),
      'markFoodServices': qqveRequirements['Bars - Restauration'].toString(),
      'markCulturalPlaces': qqveRequirements['Lieux Culturels'].toString(),
      'markTransports': qqveRequirements['Transports'].toString(),
      'markOfficeSupplies': qqveRequirements['Magasins de Fournitures'].toString(),

    });
    final body = response.body;
    final json = jsonDecode(body);
    parseApartsResults(json);
  }

  void getCityGeoPoint(var city) async {
    var url = 'https://nominatim.openstreetmap.org/search?format=json&q=' + city + ', France';
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    final body = response.body;
    final json = jsonDecode(body);
    double lat = double.parse(json[0]['lat']);
    double lon = double.parse(json[0]['lon']);
    await _mapController.goToLocation(GeoPoint(latitude: lat, longitude: lon));
    getQQVEApartsInCity(city);
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Expanded(
            child: TextField(
              controller: _cityTextController,
              decoration: InputDecoration(
                hintText: 'Saisir une ville...',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  onPressed: () {
                    if (_cityTextController.text != "") {
                      getCityGeoPoint(_cityTextController.text);
                    }
                  },
                  icon: const Icon(Icons.search_outlined)
                )
              ),
            ),
          ),
          Expanded(
            flex: 16,
            child: SizedBox(
              height: 780,
              child: OSMFlutter(
                controller: _mapController,
                userTrackingOption: UserTrackingOption(
                  enableTracking: true,
                  unFollowUser: false,
                ),
                initZoom: 12,
                minZoomLevel: 4,
                maxZoomLevel: 16,
                stepZoom: 1.0,
                userLocationMarker: UserLocationMaker(
                  personMarker: const MarkerIcon(
                    icon: Icon(Icons.location_history_rounded, color: Colors.red, size: 48)
                  ),
                  directionArrowMarker: const MarkerIcon(
                      icon: Icon(Icons.double_arrow, size: 48)
                  ),
                ),
                roadConfiguration: RoadOption(
                  roadColor: Colors.yellowAccent,
                ),
                markerOption: MarkerOption(
                  defaultMarker: MarkerIcon(
                    icon: Icon(
                      Icons.person_pin_circle,
                      color: Colors.blue,
                      size: 56,
                    ),
                  )
                ),
                onMapIsReady: (isReady) async {
                  if (isReady) {
                    await Future.delayed(const Duration(seconds: 1), () async {
                      await _mapController.currentLocation();
                    });
                  }
                },
                onGeoPointClicked: (geoPoint) {
                  var key = '${geoPoint.latitude}_${geoPoint.longitude}';
                  var finalMarkInt = apartsMarkerMap[key]?.finalMark.toStringAsFixed(1);
                  showModalBottomSheet(context: context, builder: (context) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Expanded(child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('${apartsMarkerMap[key]?.location}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.blue
                                ),),
                                Text('Price: ${apartsMarkerMap[key]?.price}',
                                style: const TextStyle(
                                    fontSize: 20,
                                    color: Colors.blue
                                ),),
                                Text('${apartsMarkerMap[key]?.date}',
                                style: const TextStyle(
                                    fontSize: 20,
                                    color: Colors.blue
                                ),),
                                Text('★ ${finalMarkInt}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.blue
                                ),)
                              ],
                            ),),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: const Icon(Icons.clear),
                            )
                          ],
                        ),
                      ),
                    );
                  });
                }
              ),
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomRatingBar(title: 'Premières Nécessités', defaultRating: 5, callback: callback),
                CustomRatingBar(title: 'Lieux de Travails', defaultRating: 5, callback: callback),
                CustomRatingBar(title: 'Bars - Restauration', defaultRating: 5, callback: callback),
                CustomRatingBar(title: 'Lieux Culturels', defaultRating: 5, callback: callback),
                CustomRatingBar(title: 'Transports', defaultRating: 5, callback: callback),
                /*CustomRatingBar(title: 'Sports', defaultRating: 1, callback: callback),
                CustomRatingBar(title: 'Espaces Naturels', defaultRating: 1, callback: callback),*/
                CustomRatingBar(title: 'Magasins de Fournitures', defaultRating: 1, callback: callback),
                /*CustomRatingBar(title: 'Soins Médicaux', defaultRating: 1, callback: callback),
                CustomRatingBar(title: 'Parkings', defaultRating: 1, callback: callback),
                CustomRatingBar(title: 'Lieux de Cultes', defaultRating: 1, callback: callback),*/
              ],
            ),
          ),
        ],
      ),
    );
  }
}
