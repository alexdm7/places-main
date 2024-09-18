import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:places/screens/add_place.dart';
import 'package:places/widgets/places_list.dart';
import 'package:places/providers/user_places.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:shared_preferences/shared_preferences.dart'; // استيراد الحزمة

class PlacesScreen extends ConsumerStatefulWidget {
  const PlacesScreen({super.key});

  @override
  ConsumerState<PlacesScreen> createState() {
    return _PlacesScreenState();
  }
}

class _PlacesScreenState extends ConsumerState<PlacesScreen> {
  final GlobalKey _addedKey = GlobalKey(); // Key for the "Add" button, used in the tutorial
  late Future<void> _placesFuture; // Future to load places data

  @override
  void initState() {
    super.initState();
    _checkAndShowTutorial(); // Call to check if the tutorial should be displayed
    _placesFuture = ref.read(userPlacesProvider.notifier).loadedPlaces(); // Load places from provider
  }

  // Check if this is the user's first time on the screen and show the tutorial if needed
  Future<void> _checkAndShowTutorial() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstTime = prefs.getBool('isFirstTimePlacesScreen') ?? true; // Check if it's the user's first visit

    if (isFirstTime) {
      _createTutorial(); // Create and show the tutorial
      await prefs.setBool('isFirstTimePlacesScreen', false); // Mark that the tutorial has been shown
    }
  }

  // Create and display the tutorial
  Future<void> _createTutorial() async {
    final targets = [
      TargetFocus(
        identify: 'floatingButton', // Identifier for the target
        keyTarget: _addedKey, // Key to focus the "Add" button
        alignSkip: Alignment.topCenter, // Skip button position
        contents: [
          TargetContent(
            align: ContentAlign.bottom, // Position of the tutorial text
            builder: (context, controller) => Text(
              'Use this button to add new Place to the list', // Instruction for the user
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    ];

    final tutorial = TutorialCoachMark(
      targets: targets, // Define the tutorial targets
    );

    // Display the tutorial after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      tutorial.show(context: context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final userPlaces = ref.watch(userPlacesProvider); // Watch the userPlacesProvider for changes

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Places'), // AppBar title
        actions: [
          IconButton(
            key: _addedKey, // Key for the "Add" button
            icon: const Icon(Icons.add), // Icon for the button
            onPressed: () {
              // Navigate to the AddPlaceScreen when the button is pressed
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => const AddPlaceScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0), // Padding for the content
        child: FutureBuilder(
          future: _placesFuture, // Future that loads the places
          builder: (context, snapshot) => snapshot.connectionState ==
              ConnectionState.waiting // Check if the data is still loading
              ? const Center(child: CircularProgressIndicator()) // Show a loading spinner while waiting
              : PlacesList(
            places: userPlaces, // Display the list of places
          ),
        ),
      ),
    );
  }
}
