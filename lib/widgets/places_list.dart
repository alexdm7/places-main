import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:places/screens/place_detail.dart';
import 'package:flutter/material.dart';
import 'package:places/models/place.dart';
import 'package:places/screens/update.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

// create database
Future<Database> _getDatabase() async {
  final dbPath = await sql.getDatabasesPath();
  final db = await sql.openDatabase(
    path.join(dbPath, 'places.db'),
    onCreate: (db, version) {
      return db.execute(
          'CREATE TABLE user_places(id TEXT PRIMARY KEY,title TEXT,image TEXT,lat REAL,lng REAL,address TEXT)');
    },
    version: 1,
  );
  return db;
}

class PlacesList extends ConsumerStatefulWidget {
  const PlacesList({super.key, required this.places});

  final List<Place> places;

  @override
  ConsumerState<PlacesList> createState() => _PlacesListState();
}

class _PlacesListState extends ConsumerState<PlacesList> {
  // Delete 1 row from SQLite method
  Future<void> _removeItem(Place place) async {
    final db = await _getDatabase();
    await db.delete('user_places', where: 'id = ?', whereArgs: [place.id]);

    setState(() {
      widget.places.remove(place);
    });
  }

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
                _removeItem(place); // Perform the delete
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

    return ListView.builder(
      itemCount: widget.places.length,
      itemBuilder: (ctx, index) {
        return ListTile(
          leading: CircleAvatar(
            radius: 26,
            backgroundImage: FileImage(widget.places[index].image),
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

          trailing:
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () =>    Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => UpdatePlaceScreen(place: widget.places[index]),
                  ),
                )
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _showConfirmationDialog(widget.places[index], index),
              ),
            ],
          ),
          // IconButton(
          //   icon: Icon(Icons.delete, color: Colors.red),
          //   onPressed: () => _showConfirmationDialog(widget.places[index], index),
          // ),
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

void main() => runApp(const MaterialApp(home: PlacesList(places: [])));
