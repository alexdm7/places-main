import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:places/models/place.dart';
import 'dart:io';
import 'package:places/widgets/image_input.dart';
import 'package:places/providers/user_places.dart';
import 'package:places/widgets/location_input.dart';

class UpdatePlaceScreen extends ConsumerStatefulWidget {
  const UpdatePlaceScreen({super.key, required this.place});
  final Place place;

  @override
  ConsumerState<UpdatePlaceScreen> createState() {
    return _UpdatePlaceScreenState();
  }
}

class _UpdatePlaceScreenState extends ConsumerState<UpdatePlaceScreen> {
  final _titleController = TextEditingController();
  final _idController = TextEditingController();
  File? _selectedImage;
  final _formKey = GlobalKey<FormState>();
  PlaceLocation? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.place.title;
    _idController.text = widget.place.id;
    _selectedImage = widget.place.image;
    _selectedLocation = widget.place.location;
  }

  void _updatePlace() {
    final enteredTitle = _titleController.text;
    final enteredId = _idController.text;

    if (!_formKey.currentState!.validate() || _selectedImage == null || _selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields.'),
        ),
      );
      return;
    }
    ref.read(userPlacesProvider.notifier).updatePlace(
      enteredId,
      enteredTitle,
      _selectedImage!,
      _selectedLocation!,
    );

    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _idController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Place'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Title'),
                controller: _titleController,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please Enter a Title';
                }
                return null;
              },
              ),
              const SizedBox(height: 10),
              ImageInput(
                initialImage: _selectedImage,
                onPickImage: (image) {
                  _selectedImage = image;
                },
              ),
              const SizedBox(height: 10),
              LocationInput(
                initialLocation: _selectedLocation,
                onSelecteLocation: (location) {
                  _selectedLocation = location;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _updatePlace,
                icon: const Icon(Icons.update),
                label: const Text('Update Place'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
