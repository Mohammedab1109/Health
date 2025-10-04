import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart' as permission;
import 'package:http/http.dart' as http;

class LocationPickerDialog extends StatefulWidget {
  final void Function(LatLng location, String address) onLocationPicked;

  const LocationPickerDialog({
    super.key,
    required this.onLocationPicked,
  });

  @override
  State<LocationPickerDialog> createState() => _LocationPickerDialogState();
}

class _LocationPickerDialogState extends State<LocationPickerDialog> {
  final TextEditingController _searchController = TextEditingController();
  final MapController _mapController = MapController();
  final Location _location = Location();
  
  LatLng? _selectedLocation;
  String _selectedAddress = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    final permissionStatus = await permission.Permission.location.request();
    if (permissionStatus.isGranted) {
      try {
        final locationData = await _location.getLocation();
        setState(() {
          _selectedLocation = LatLng(
            locationData.latitude!,
            locationData.longitude!,
          );
          _isLoading = false;
        });
        
        _getReverseGeocode(_selectedLocation!);
      } catch (e) {
        print('Error getting location: $e');
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getReverseGeocode(LatLng location) async {
    try {
      final response = await http.get(Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=${location.latitude}&lon=${location.longitude}&zoom=18&addressdetails=1',
      ));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _selectedAddress = data['display_name'];
        });
      }
    } catch (e) {
      print('Error getting address: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search location...',
                prefixIcon: Icon(Icons.search),
              ),
              onSubmitted: (value) async {
                try {
                  final response = await http.get(Uri.parse(
                    'https://nominatim.openstreetmap.org/search?format=json&q=${Uri.encodeComponent(value)}',
                  ));

                  if (response.statusCode == 200) {
                    final results = jsonDecode(response.body);
                    if (results.isNotEmpty) {
                      final location = LatLng(
                        double.parse(results[0]['lat']),
                        double.parse(results[0]['lon']),
                      );
                      setState(() {
                        _selectedLocation = location;
                        _selectedAddress = results[0]['display_name'];
                      });
                    }
                  }
                } catch (e) {
                  print('Error searching location: $e');
                }
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                      ),
                      child: FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: _selectedLocation ?? const LatLng(0, 0),
                          initialZoom: 15,
                          onTap: (tapPosition, point) {
                            setState(() {
                              _selectedLocation = point;
                            });
                            _getReverseGeocode(point);
                          },
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.health',
                          ),
                          if (_selectedLocation != null)
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: _selectedLocation!,
                                  width: 32,
                                  height: 32,
                                  child: const Icon(
                                    Icons.location_pin,
                                    color: Colors.red,
                                    size: 32,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
            ),
            if (_selectedAddress.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  _selectedAddress,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ElevatedButton(
              onPressed: _selectedLocation != null
                  ? () {
                      widget.onLocationPicked(
                        _selectedLocation!,
                        _selectedAddress.isNotEmpty ? _selectedAddress : 'Selected Location',
                      );
                      Navigator.of(context).pop();
                    }
                  : null,
              child: const Text('Select Location'),
            ),
          ],
        ),
      ),
    );
  }
}