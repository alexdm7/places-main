import 'package:flutter/material.dart';
import 'package:places/models/place.dart';
import 'package:places/screens/map.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';


class PlaceDetailScreen extends StatefulWidget {
  const PlaceDetailScreen({super.key, required this.place});

  final Place place; // The Place object passed to this screen

  @override
  State<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen> {
  final GlobalKey _mapKey = GlobalKey(); // Key to identify the map in the tutorial

  @override
  void initState() {
    super.initState();
    _checkAndShowTutorial(); // Call to check if the tutorial needs to be shown
  }

  // Check if this is the first time the screen is being viewed, and show the tutorial if needed
  Future<void> _checkAndShowTutorial() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstTime = prefs.getBool('isFirstTimePlaceDetailScreen') ?? true; // Check if it's the user's first time on this screen

    if (isFirstTime) {
      _createTutorial(); // Create and display the tutorial
      await prefs.setBool('isFirstTimePlaceDetailScreen', false); // Mark that the tutorial has been shown
    }
  }

  // Create the tutorial targets and display them
  Future<void> _createTutorial() async {
    final targets = [
      TargetFocus(
        identify: 'mapFocus', // Identifier for this tutorial target
        keyTarget: _mapKey, // Use the _mapKey to focus the map widget
        alignSkip: Alignment.topCenter,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) => Text(
              'Use this button to show the location on the map.', // Instruction for the user
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

  // Generate the URL for the static map image based on the location's latitude and longitude
  String get locationImage {
    final lat = widget.place.location.latitude;
    final lng = widget.place.location.longitude;
    return 'https://maps.googleapis.com/maps/api/staticmap?center=$lat,$lng=&zoom=16&size=600x300&maptype=roadmap&markers=color:red%7Clabel:A%7C$lat,$lng&key=AIzaSyBmp4UPrqAOf_4WP2-SeQLkyqEWQnBnEqg';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.place.title), // Display the place title in the AppBar
      ),
      body: Stack(
        children: [
          // Display the image associated with the place
          Image.file(
            widget.place.image,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    // Navigate to the MapScreen when the user taps on the map
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => MapScreen(
                          location: widget.place.location, // Pass the place's location
                          isSelected: false, // Disable selection mode
                        ),
                      ),
                    );
                  },
                  child: CircleAvatar(
                    radius: 70, // Circular image with a fixed radius
                    key: _mapKey, // Key for the tutorial to focus on
                    backgroundImage: NetworkImage(locationImage), // Display the static map image
                  ),
                ),
                // Display the location's address with some styling
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black38,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Text(
                    widget.place.location.address, // Show the place's address
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge!
                        .copyWith(color: Theme.of(context).colorScheme.onSurface),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
