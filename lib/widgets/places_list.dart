import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:places/screens/place_detail.dart';
import 'package:flutter/material.dart';
import 'package:places/models/place.dart';
import 'package:places/screens/update.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

// Function to create and open the SQLite database
Future<Database> _getDatabase() async {
  final dbPath = await sql.getDatabasesPath(); // Get the database path
  final db = await sql.openDatabase(
    path.join(dbPath, 'places.db'), // Open the database file
    onCreate: (db, version) {
      // Create the table when database is created
      return db.execute(
          'CREATE TABLE user_places(id TEXT PRIMARY KEY,title TEXT,image TEXT,lat REAL,lng REAL,address TEXT)');
    },
    version: 1,
  );
  return db;
}

class PlacesList extends ConsumerStatefulWidget {
  const PlacesList({super.key, required this.places});

  // List of places to be displayed
  final List<Place> places;

  @override
  ConsumerState<PlacesList> createState() => _PlacesListState();
}

class _PlacesListState extends ConsumerState<PlacesList> {
  // Method to remove a place from the database and the state
  Future<void> _removeItem(Place place) async {
    final db = await _getDatabase(); // Get the database instance
    await db.delete('user_places', where: 'id = ?', whereArgs: [place.id]); // Delete the place from the database

    setState(() {
      widget.places.remove(place); // Remove the place from the state list
    });
  }

  // Method to show a confirmation dialog before deleting a place
  void _showConfirmationDialog(Place place, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Are you sure?'),
          content: const Text('Do you really want to delete this item?'),
          actions: [
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            ElevatedButton(
              child: const Text('Yes'),
              onPressed: () {
                _removeItem(place); // Perform the delete operation
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Check if there are no places to display
    if (widget.places.isEmpty) {
      return Center(
        child: Text(
          'No places added yet',
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      );
    }

    // Build a list view of places
    return ListView.builder(
      itemCount: widget.places.length,
      itemBuilder: (ctx, index) {
        return ListTile(
          leading: CircleAvatar(
            radius: 26,
            backgroundImage: FileImage(widget.places[index].image), // Display place image
          ),
          title: Text(
            widget.places[index].title,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          subtitle: Text(
            widget.places[index].location.address,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => UpdatePlaceScreen(place: widget.places[index]),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _showConfirmationDialog(widget.places[index], index),
              ),
            ],
          ),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) => PlaceDetailScreen(place: widget.places[index]),
              ),
            );
          },
        );
      },
    );
  }
}

// Main entry point for testing the widget in isolation
void main() => runApp(const MaterialApp(home: PlacesList(places: [])));
