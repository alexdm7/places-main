import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:places/models/place.dart';
class MapScreen extends StatefulWidget {
  const MapScreen({
    super.key,
    this.location = const PlaceLocation(
        latitude: 23.6134868, longitude: 58.5414574, address: ''), // Default location for the map
    this.isSelected = true, // Determines if the user is selecting a location or viewing an existing one
  });
  final PlaceLocation location; // Location object for the map
  final bool isSelected; // Whether the user can select a location

  @override
  State<MapScreen> createState() => _MapScreenState(); // Create the state for this screen
}

class _MapScreenState extends State<MapScreen> {
  LatLng? _pickedLocation; // Variable to store the location picked by the user

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isSelected ? 'Pick Location' : 'Your Location'), // Set the title based on whether the user is selecting a location
        actions: [
          // Show the save button only if the user is selecting a location
          if (widget.isSelected)
            IconButton(
              onPressed: () {
                Navigator.of(context).pop(_pickedLocation); // Return the picked location when the save button is pressed
              },
              icon: const Icon(Icons.save), // Save icon
            ),
        ],
      ),
      body: GoogleMap(
        onLongPress: !widget.isSelected
            ? null // Disable long press if the user is only viewing a location
            : (position) {
          // Allow the user to pick a location by long pressing
          setState(() {
            _pickedLocation = position; // Update the picked location
          });
        },
        initialCameraPosition: CameraPosition(
          target: LatLng(widget.location.latitude, widget.location.longitude), // Set the initial camera position based on the provided location
          zoom: 13, // Zoom level
        ),
        markers: _pickedLocation == null && widget.isSelected
            ? {} // If no location is picked and the user is selecting, show no markers
            : {
          Marker(
            markerId: const MarkerId('m1'), // Marker ID
            position: _pickedLocation ?? // Use the picked location if available, otherwise use the provided location
                LatLng(
                  widget.location.latitude,
                  widget.location.longitude,
                ),
          ),
        },
      ),
    );
  }
}
