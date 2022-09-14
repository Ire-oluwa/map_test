import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class Location extends StatefulWidget {
  const Location({Key? key}) : super(key: key);

  @override
  State<Location> createState() => _LocationState();
}

class _LocationState extends State<Location> {
  //check if the device can use gps
  Future<bool> _handleLocationPermission() async {
    late bool serviceEnabled;
    late LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      //snackbar should be here instead
      const Text('No location service');
      return false;
    }
    //if permission to use location service is disabled
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      // if location is still disabled
      if (permission == LocationPermission.denied) {
        //snackbar
        const Text("Location permission is denied");
        return false;
      }
    }
    //if permission is denied foreevr
    if (permission == LocationPermission.deniedForever) {
      //snackbar
      const Text("Permission denied forever");
      return false;
    }
    return true;
  }

  //to get lat and long
  Position? _currentPosition;
  late double? latitude;
  late double? longitude;
  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = position;
      latitude = _currentPosition?.latitude;
      longitude = _currentPosition?.longitude;
    });
  }

  @override
  void initState() {
    latitude = _currentPosition?.latitude ?? 7.4111;
    longitude = _currentPosition?.longitude ?? 3.9088;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "The latitude is: $latitude",
                //style: const TextStyle(fontSize: 12.0),
              ),
              Text("The Longitude is $longitude"),
              Center(
                child: ElevatedButton(
                  onPressed: _getCurrentPosition,
                  child: const Text("Get Location"),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context, Coordinates(latitude!, longitude!));
                },
                child: const Text("Go back"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class Coordinates {
  final double latitude;
  final double longitude;
  const Coordinates(this.latitude, this.longitude);
}