import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';

class HospitalsScreenContent extends StatefulWidget {
  const HospitalsScreenContent({super.key});

  @override
  _HospitalsScreenContentState createState() => _HospitalsScreenContentState();
}

class _HospitalsScreenContentState extends State<HospitalsScreenContent> {
  final List<Marker> _markers = [];
  final List<String> _lastVisitedHospitals = [];
  GoogleMapController? _mapController;
  Position? _currentPosition;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _error = 'Location services are disabled';
          _isLoading = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _error = 'Location permissions are denied';
            _isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _error = 'Location permissions are permanently denied';
          _isLoading = false;
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 5),
      );

      setState(() {
        _currentPosition = position;
        _isLoading = false;
      });

      _loadNearbyHospitals();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadNearbyHospitals() async {
    if (_currentPosition == null) return;

    final lat = _currentPosition!.latitude;
    final lng = _currentPosition!.longitude;
    const apiKey = 'AIzaSyDOKSfbngtNqTwvsixlJqCWNWsH5WetaGk';
    final url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$lat,$lng&radius=1500&type=hospital&key=$apiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final hospitals = data['results'] as List;

      setState(() {
        for (var hospital in hospitals) {
          final hospitalName = hospital['name'];
          final hospitalLat = hospital['geometry']['location']['lat'];
          final hospitalLng = hospital['geometry']['location']['lng'];

          _markers.add(
            Marker(
              markerId: MarkerId(hospitalName),
              position: LatLng(hospitalLat, hospitalLng),
              infoWindow: InfoWindow(
                title: hospitalName,
                onTap: () {
                  _openMapsApp(hospitalLat, hospitalLng);
                  _addToLastVisited(hospitalName);
                },
              ),
            ),
          );
        }
      });
    } else {
      throw Exception('Failed to load nearby hospitals');
    }
  }

  void _openMapsApp(double lat, double lng) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _addToLastVisited(String hospitalName) {
    setState(() {
      _lastVisitedHospitals.add(hospitalName);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Hospitals'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _error = null;
                  _isLoading = true;
                });
                _getCurrentLocation();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_currentPosition == null) {
      return const Center(child: Text('Unable to get location'));
    }

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
            zoom: 14,
          ),
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          markers: Set<Marker>.of(_markers),
          onMapCreated: (GoogleMapController controller) {
            _mapController = controller;
          },
        ),
        if (_markers.isEmpty)
          const Center(
            child: CircularProgressIndicator(),
          ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 150,
            color: Colors.white,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _lastVisitedHospitals.length,
              itemBuilder: (context, index) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Text(_lastVisitedHospitals[index]),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}