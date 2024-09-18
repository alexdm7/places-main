import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:places/models/place.dart';
import 'dart:io';
import 'package:places/widgets/image_input.dart';
import 'package:places/providers/user_places.dart';
import 'package:places/widgets/location_input.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Stateful widget to add a new place
class AddPlaceScreen extends ConsumerStatefulWidget {
  const AddPlaceScreen({super.key});

  @override
  ConsumerState<AddPlaceScreen> createState() {
    return _AddPlaceScreenState(); // Return the state of the screen
  }
}

class _AddPlaceScreenState extends ConsumerState<AddPlaceScreen> {
  final GlobalKey _editButtonKey = GlobalKey(); // Global key for tutorial target
  final _titleController = TextEditingController(); // Controller for title input
  File? _selctedImage; // Variable to store the selected image
  final _formKey = GlobalKey<FormState>(); // Global key for form validation
  PlaceLocation? _selecteLocation; // Variable to store the selected location

  @override
  void initState() {
    super.initState();
    _checkAndShowTutorial(); // Call the method to check and show the tutorial
  }

  // Method to save the place
  void _savePlace() {
    final enteredTitle = _titleController.text;

    // Validate form and check if image and location are selected
    if (!_formKey.currentState!.validate() || _selctedImage == null || _selecteLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields.'), // Show message if validation fails
        ),
      );
      return;
    }
    // Add the place using the provider
    ref
        .read(userPlacesProvider.notifier)
        .addPlace(enteredTitle, _selctedImage!, _selecteLocation!);

    Navigator.of(context).pop(); // Return to the previous screen
  }

  @override
  void dispose() {
    _titleController.dispose(); // Dispose of the controller when the widget is disposed
    super.dispose();
  }

  // Method to check if the tutorial should be shown
  Future<void> _checkAndShowTutorial() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstTime = prefs.getBool('isFirstTimeAddPlaceScreen') ?? true; // Check if it's the first time on this screen

    if (isFirstTime) {
      _createTutorial(); // If first time, create the tutorial
      await prefs.setBool('isFirstTimeAddPlaceScreen', false); // Set first time flag to false
    }
  }

  // Method to create and display the tutorial
  Future<void> _createTutorial() async {
    final targets = [
      TargetFocus(
        identify: 'floatingButton', // Identify the button for the tutorial
        keyTarget: _editButtonKey, // Set the target key
        alignSkip: Alignment.topCenter, // Alignment for the skip button
        contents: [
          TargetContent(
            align: ContentAlign.top, // Align the content of the tutorial
            builder: (context, controller) => Text(
              'Use This Button To Add New Elements To The List', // Instruction text
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Colors.white), // Styling the instruction text
            ),
          ),
        ],
      ),
    ];

    final tutorial = TutorialCoachMark(
      targets: targets, // Set the tutorial targets
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      tutorial.show(context: context); // Show the tutorial after a delay
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add new Place'), // App bar title
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12), // Padding around the content
        child: Form(
          key: _formKey, // Assign the form key
          child: Column(
            children: [
              // Text input for the place title
              TextFormField(
                decoration: const InputDecoration(labelText: 'Title'), // Input decoration
                controller: _titleController, // Assign the text controller
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface, // Style the text
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please Enter a Title'; // Show error message if title is empty
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10), // Space between elements
              // Widget for selecting an image
              ImageInput(
                onPickImage: (image) {
                  _selctedImage = image; // Store the selected image
                },
              ),
              const SizedBox(height: 10), // Space between elements
              // Widget for selecting a location
              LocationInput(
                onSelecteLocation: (location) {
                  _selecteLocation = location; // Store the selected location
                },
              ),
              const SizedBox(height: 16), // Space between elements
              // Button to save the place
              ElevatedButton.icon(
                key: _editButtonKey, // Assign the key for the tutorial
                onPressed: _savePlace, // Call the save method when pressed
                icon: const Icon(Icons.add), // Button icon
                label: const Text('Add Place'), // Button label
              ),
            ],
          ),
        ),
      ),
    );
  }
}
