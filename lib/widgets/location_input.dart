import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:places/models/place.dart';
import 'package:places/screens/map.dart';

class LocationInput extends StatefulWidget {
  const LocationInput({super.key, required this.onSelecteLocation, this.initialLocation});

  // Callback function to pass the selected location back to the parent widget
  final void Function(PlaceLocation location) onSelecteLocation;

  // Optional initial location to be displayed
  final PlaceLocation? initialLocation;

  @override
  State<LocationInput> createState() {
    return _LocationInputState();
  }
}

class _LocationInputState extends State<LocationInput> {
  PlaceLocation? _pickedLocation; // Stores the currently picked location

  // Generates a URL for a static map image of the selected location
  String get locationImage {
    if (_pickedLocation == null) {
      return '';
    }
    final lat = _pickedLocation!.latitude;
    final lng = _pickedLocation!.longitude;
    return 'https://maps.googleapis.com/maps/api/staticmap?center=$lat,$lng=&zoom=16&size=600x300&maptype=roadmap&markers=color:red%7Clabel:A%7C$lat,$lng&key=AIzaSyBmp4UPrqAOf_4WP2-SeQLkyqEWQnBnEqg';
  }

  @override
  void initState() {
    super.initState();
    _pickedLocation = widget.initialLocation; // Initialize with the provided location if any
  }

  // Method to save the place by fetching its address using Google Geocoding API
  void _savePlace(double latitude, double longitude) async {
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=AIzaSyBmp4UPrqAOf_4WP2-SeQLkyqEWQnBnEqg');
    final response = await http.get(url);
    final resData = json.decode(response.body);
    final address = resData['results'][0]['formatted_address']; // Extract address from the response

    setState(() {
      _pickedLocation = PlaceLocation(latitude: latitude, longitude: longitude, address: address);
      _isGettingLocation = false;
    });

    widget.onSelecteLocation(_pickedLocation!); // Notify parent widget with the selected location
  }

  var _isGettingLocation = false; // Flag to indicate if the location is being fetched

  // Method to get the current location of the device
  void _getCurrentLocation() async {
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    setState(() {
      _isGettingLocation = true; // Set flag to indicate fetching location
    });

    locationData = await location.getLocation();

    final lat = locationData.latitude;
    final lng = locationData.longitude;
    if (lat == null || lng == null) {
      return;
    }
    _savePlace(lat, lng); // Save the location after fetching
  }

  // Method to select location from the map
  void _selectOnMap() async {
    final pickedLocation = await Navigator.of(context).push<LatLng>(
        MaterialPageRoute(builder: (ctx) => const MapScreen(),)
    );
    if (pickedLocation == null) {
      return;
    }
    _savePlace(pickedLocation.latitude, pickedLocation.longitude); // Save the location selected on the map
  }

  @override
  Widget build(BuildContext context) {
    // Widget to display preview content (location image or loading spinner)
    Widget previewContent = Text(
      'no location',
      textAlign: TextAlign.center,
      style: Theme.of(context)
          .textTheme
          .bodyLarge!
          .copyWith(color: Theme.of(context).colorScheme.onSurface),
    );
    if (_pickedLocation != null) {
      previewContent = Image.network(
        locationImage,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }
    if (_isGettingLocation) {
      previewContent = const CircularProgressIndicator();
    }
    return Column(
      children: [
        Container(
          height: 170,
          alignment: Alignment.center,
          width: double.infinity,
          decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                width: 1,
              )
          ),
          child: previewContent,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              onPressed: _getCurrentLocation, // Trigger current location fetching
              icon: const Icon(Icons.location_on),
              label: const Text('Get current location'),
            ),
            TextButton.icon(
              onPressed: _selectOnMap, // Trigger map selection
              icon: const Icon(Icons.map),
              label: const Text('Get from map'),
            ),
          ],
        )
      ],
    );
  }
}
