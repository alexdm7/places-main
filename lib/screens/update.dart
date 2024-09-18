import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:places/models/place.dart';
import 'dart:io';
import 'package:places/widgets/image_input.dart';
import 'package:places/providers/user_places.dart';
import 'package:places/widgets/location_input.dart';


class UpdatePlaceScreen extends ConsumerStatefulWidget {
  const UpdatePlaceScreen({super.key, required this.place});
  final Place place; // The place object to be updated

  @override
  ConsumerState<UpdatePlaceScreen> createState() {
    return _UpdatePlaceScreenState();
  }
}

class _UpdatePlaceScreenState extends ConsumerState<UpdatePlaceScreen> {
  final _titleController = TextEditingController(); // Controller for the title field
  final _idController = TextEditingController(); // Controller for the ID field
  File? _selectedImage; // The currently selected image
  final _formKey = GlobalKey<FormState>(); // Key to manage the form state
  PlaceLocation? _selectedLocation; // The currently selected location

  @override
  void initState() {
    super.initState();
    // Initialize controllers and state with the existing place data
    _titleController.text = widget.place.title;
    _idController.text = widget.place.id;
    _selectedImage = widget.place.image;
    _selectedLocation = widget.place.location;
  }

  // Method to update the place details
  void _updatePlace() {
    final enteredTitle = _titleController.text;
    final enteredId = _idController.text;

    // Validate form fields and check if image and location are selected
    if (!_formKey.currentState!.validate() || _selectedImage == null || _selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields.'),
        ),
      );
      return;
    }
    // Update the place using the Riverpod provider
    ref.read(userPlacesProvider.notifier).updatePlace(
      enteredId,
      enteredTitle,
      _selectedImage!,
      _selectedLocation!,
    );

    Navigator.of(context).pop(); // Navigate back after updating
  }

  @override
  void dispose() {
    _titleController.dispose(); // Dispose of controllers to free up resources
    _idController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Place'), // AppBar title
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12), // Padding for the content
        child: Form(
          key: _formKey, // Assign form key for validation
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Title'), // Label for the title input
                controller: _titleController, // Use title controller
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface, // Set text color
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please Enter a Title'; // Validation message
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              ImageInput(
                initialImage: _selectedImage, // Initial image to show
                onPickImage: (image) {
                  _selectedImage = image; // Update selected image
                },
              ),
              const SizedBox(height: 10),
              LocationInput(
                initialLocation: _selectedLocation, // Initial location to show
                onSelecteLocation: (location) {
                  _selectedLocation = location; // Update selected location
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _updatePlace, // Call update method when pressed
                icon: const Icon(Icons.update), // Icon for the button
                label: const Text('Update Place'), // Button label
              ),
            ],
          ),
        ),
      ),
    );
  }
}
