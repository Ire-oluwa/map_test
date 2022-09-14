import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
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
      home: const TestScreen(),
    );
  }
}

class TestScreen extends StatefulWidget {
  const TestScreen({Key? key}) : super(key: key);

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  Future<Position> _determinePosition() async {
    //check if device has gps enabled
    late bool serviceEnabled;
    late LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location Services are disabled');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        return Future.error("Location permission deniedd");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error("Location permission denied forever");
    }

    Position position = await Geolocator.getCurrentPosition();
    return position;
  }

  //

  late final Completer<GoogleMapController> _controller = Completer();

  //Oyo State Secretariat coordinates
  static const LatLng myLocation = LatLng(7.411163492, 3.908824592);

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  late Set<Marker> markers = {};

  Future<void> _disposeController() async {
    final GoogleMapController mapController = await _controller.future;
    mapController.dispose();
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Test Google Map")),
      body: Stack(
        children: [
          GoogleMap(
            compassEnabled: false,
            markers: markers,
            zoomControlsEnabled: false,
            mapType: MapType.normal,
            onMapCreated: _onMapCreated,
            initialCameraPosition: const CameraPosition(target: myLocation),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.location_history),
        label: const Text("Current Location"),
        onPressed: () async {
          Position position = await _determinePosition();

          final GoogleMapController mapController = await _controller.future;
          mapController.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(position.latitude, position.longitude),
                zoom: 14.0,
              ),
            ),
          );
          markers.clear();
          //you could add multiple markers
          markers.add(
            Marker(
              infoWindow: const InfoWindow(title: "My House"),
              //the location icon with green colour
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueGreen),
              markerId: const MarkerId("Current location"),
              position: LatLng(
                position.latitude,
                position.longitude,
              ),
            ),
          );
          setState(() {});
        },
      ),
    );
  }
}
