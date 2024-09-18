import 'package:uuid/uuid.dart'; // Importing the 'uuid' package for generating unique IDs
import 'dart:io'; // Importing 'dart:io' for handling file input/output, specifically for images

const uuid = Uuid(); // Creating a constant 'uuid' instance to generate unique identifiers

// This class represents the location of a place with its latitude, longitude, and address
class PlaceLocation {
  const PlaceLocation({
    required this.latitude, // Latitude coordinate of the place
    required this.longitude, // Longitude coordinate of the place
    required this.address, // Physical address of the place
  });

  final double latitude; // Variable to store the latitude value
  final double longitude; // Variable to store the longitude value
  final String address; // Variable to store the address as a string
}

// This class represents a Place with its title, image, location, and an optional ID
class Place {
  Place({
    required this.title, // Title/name of the place
    required this.image, // Image file associated with the place
    required this.location, // Location information of the place
    String? id, // Optional ID field, will auto-generate if not provided
  }) : id = id ?? uuid.v4(); // If no ID is provided, generate a unique one using uuid

  final String id; // Unique identifier for the place
  final String title; // Title/name of the place
  final File image; // Image file of the place
  final PlaceLocation location; // Location information of the place
}
