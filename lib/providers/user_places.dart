import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart' as syspaths;
import 'dart:io';
import 'package:sqflite/sqflite.dart' as sql; // SQLite package for database operations
import 'package:path/path.dart' as path; // Path package to manipulate file paths
import 'package:places/models/place.dart';

// Method to initialize and open the SQLite database
Future<sql.Database> _getDatabase() async {
  const tableName = 'user_places'; // Table name to store user places
  final dbPath = await sql.getDatabasesPath(); // Get the path to store the database
  final db = await sql.openDatabase(
    path.join(dbPath, 'places.db'), // Open the 'places.db' database
    onCreate: (db, version) {
      // Create the table if it doesn't exist when the database is created
      return db.execute(
        'CREATE TABLE $tableName(id TEXT PRIMARY KEY, title TEXT, image TEXT, lat REAL, lng REAL, address TEXT)',
      );
    },
    version: 1, // Database version
  );
  return db; // Return the database instance
}

// StateNotifier to manage the list of user places
class UserPlacesNotifier extends StateNotifier<List<Place>> {
  // Initializing with an empty list of places
  UserPlacesNotifier() : super(const []);

  // Method to load places from the SQLite database
  Future<void> loadedPlaces() async {
    final db = await _getDatabase(); // Get the database instance
    final data = await db.query('user_places'); // Query the 'user_places' table
    // Map the queried data to a list of Place objects
    final places = data.map((row) => Place(
      id: row['id'] as String,
      title: row['title'] as String,
      image: File(row['image'] as String), // Convert image path to a File object
      location: PlaceLocation(
        latitude: row['lat'] as double,
        longitude: row['lng'] as double,
        address: row['address'] as String,
      ),
    )).toList();
    state = places; // Update the state with the list of places
  }

  // Method to add a new place
  void addPlace(String title, File image, PlaceLocation location) async {
    final appDir = await syspaths.getApplicationDocumentsDirectory(); // Get the directory for storing files
    final fileName = path.basename(image.path); // Get the file name of the image
    final copiedImage = await image.copy('${appDir.path}/$fileName'); // Copy the image to the directory
    // Create a new Place object with a generated ID
    final newPlace = Place(
      id: DateTime.now().toString(), // Generate a unique ID using the current timestamp
      title: title,
      image: copiedImage, // Use the copied image
      location: location,
    );
    final db = await _getDatabase(); // Get the database instance

    // Insert the new place into the database
    await db.insert(
      'user_places',
      {
        'id': newPlace.id,
        'title': newPlace.title,
        'image': newPlace.image.path, // Store the image path
        'lat': newPlace.location.latitude,
        'lng': newPlace.location.longitude,
        'address': newPlace.location.address,
      },
      conflictAlgorithm: sql.ConflictAlgorithm.replace, // Replace the entry if an ID conflict occurs
    );

    state = [newPlace, ...state]; // Add the new place to the current state
  }

  // Method to update an existing place
  void updatePlace(String id, String title, File image, PlaceLocation location) async {
    final appDir = await syspaths.getApplicationDocumentsDirectory(); // Get the directory for storing files
    final fileName = path.basename(image.path); // Get the file name of the image
    final copiedImage = await image.copy('${appDir.path}/$fileName'); // Copy the image to the directory
    // Create an updated Place object
    final updatedPlace = Place(
      id: id,
      title: title,
      image: copiedImage, // Use the copied image
      location: location,
    );
    final db = await _getDatabase(); // Get the database instance

    try {
      // Update the place in the database where the ID matches
      await db.update(
        'user_places',
        {
          'title': updatedPlace.title,
          'image': updatedPlace.image.path, // Update the image path
          'lat': updatedPlace.location.latitude,
          'lng': updatedPlace.location.longitude,
          'address': updatedPlace.location.address,
        },
        where: 'id = ?', // Update the row where the ID matches
        whereArgs: [updatedPlace.id], // Pass the ID as an argument
      );
      // Update the state by replacing the old place with the updated one
      state = state.map((place) => place.id == id ? updatedPlace : place).toList();
    } catch (error) {
      if (kDebugMode) {
        print('Error updating place: $error'); // Print an error message in debug mode
      }
    }
  }
}

// Riverpod provider for managing the state of user places
final userPlacesProvider = StateNotifierProvider<UserPlacesNotifier, List<Place>>(
      (ref) => UserPlacesNotifier(), // Provide an instance of UserPlacesNotifier
);
