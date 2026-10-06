import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  GoogleMapController? _mapController;
  LatLng _currentPosition = const LatLng(20.5937, 78.9629); // Default to India center
  String _currentAddress = "Loading address...";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_currentPosition, 15),
      );
      _getAddressFromLatLng(_currentPosition);
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks = await Geocoding().placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          // Construct a nice address
          List<String> addressParts = [];
          if (place.name != null && place.name!.isNotEmpty) addressParts.add(place.name!);
          if (place.subLocality != null && place.subLocality!.isNotEmpty) addressParts.add(place.subLocality!);
          if (place.locality != null && place.locality!.isNotEmpty) addressParts.add(place.locality!);
          if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) addressParts.add(place.administrativeArea!);
          
          _currentAddress = addressParts.join(', ');
        });
      }
    } catch (e) {
      setState(() {
        _currentAddress = "Unable to fetch address";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Venue Location"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, _currentAddress);
            },
            child: const Text("CONFIRM", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition,
                    zoom: 15,
                  ),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  onMapCreated: (GoogleMapController controller) {
                    _mapController = controller;
                  },
                  onCameraMove: (CameraPosition position) {
                    _currentPosition = position.target;
                  },
                  onCameraIdle: () {
                    _getAddressFromLatLng(_currentPosition);
                  },
                ),
                // Center pin
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on, size: 50, color: Colors.red),
                      const SizedBox(height: 50), // Offset to put the pin point exactly at the center
                    ],
                  ),
                ),
                // Address Bar
                Positioned(
                  bottom: 30,
                  left: 20,
                  right: 20,
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "Selected Venue",
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _currentAddress,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context, _currentAddress);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text("Confirm Location"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
