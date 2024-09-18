import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart' as syspaths;
import 'dart:io';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;
import 'package:places/models/place.dart';

// Create Database method
Future<sql.Database> _getDatabase() async {
  const tableName = 'user_places';
  final dbPath = await sql.getDatabasesPath();
  final db = await sql.openDatabase(
    path.join(dbPath, 'places.db'),
    onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE $tableName(id TEXT PRIMARY KEY, title TEXT, image TEXT, lat REAL, lng REAL, address TEXT)',
      );
    },
    version: 1,
  );
  return db;
}

class UserPlacesNotifier extends StateNotifier<List<Place>> {
  UserPlacesNotifier() : super(const []);

  // Load places from database
  Future<void> loadedPlaces() async {
    final db = await _getDatabase();
    final data = await db.query('user_places');
    final places = data.map((row) => Place(
      id: row['id'] as String,
      title: row['title'] as String,
      image: File(row['image'] as String),
      location: PlaceLocation(
        latitude: row['lat'] as double,
        longitude: row['lng'] as double,
        address: row['address'] as String,
      ),
    )).toList();
    state = places;
  }

  // Add a new place
  void addPlace(String title, File image, PlaceLocation location) async {
    final appDir = await syspaths.getApplicationDocumentsDirectory();
    final fileName = path.basename(image.path);
    final copiedImage = await image.copy('${appDir.path}/$fileName');
    final newPlace = Place(
      id: DateTime.now().toString(), // Generate a unique ID for the new place
      title: title,
      image: copiedImage,
      location: location,
    );
    final db = await _getDatabase();

    await db.insert(
      'user_places',
      {
        'id': newPlace.id,
        'title': newPlace.title,
        'image': newPlace.image.path,
        'lat': newPlace.location.latitude,
        'lng': newPlace.location.longitude,
        'address': newPlace.location.address,
      },
      conflictAlgorithm: sql.ConflictAlgorithm.replace, // Replace existing entries with the same ID
    );

    state = [newPlace, ...state];
  }

  // Update an existing place
  void updatePlace(String id, String title, File image, PlaceLocation location) async {
    final appDir = await syspaths.getApplicationDocumentsDirectory();
    final fileName = path.basename(image.path);
    final copiedImage = await image.copy('${appDir.path}/$fileName');
    final updatedPlace = Place(
      id: id,
      title: title,
      image: copiedImage,
      location: location,
    );
    final db = await _getDatabase();

    try {
      await db.update(
        'user_places',
        {
          'title': updatedPlace.title,
          'image': updatedPlace.image.path,
          'lat': updatedPlace.location.latitude,
          'lng': updatedPlace.location.longitude,
          'address': updatedPlace.location.address,
        },
        where: 'id = ?',
        whereArgs: [updatedPlace.id],
      );
      // Update the state
      state = state.map((place) => place.id == id ? updatedPlace : place).toList();
    } catch (error) {
      if (kDebugMode) {
        print('Error updating place: $error');
      }
    }
  }
}

final userPlacesProvider = StateNotifierProvider<UserPlacesNotifier, List<Place>>(
      (ref) => UserPlacesNotifier(),
);
