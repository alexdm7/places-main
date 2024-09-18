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
  final GlobalKey _addedKey = GlobalKey();
  late Future<void> _placesFuture;

  @override
  void initState() {
    super.initState();
    _checkAndShowTutorial(); // استدعاء الدالة للتحقق من عرض التعليمات
    _placesFuture = ref.read(userPlacesProvider.notifier).loadedPlaces();
  }

  // التحقق من إذا كان يجب عرض التعليمات
  Future<void> _checkAndShowTutorial() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstTime = prefs.getBool('isFirstTimePlacesScreen') ?? true;

    if (isFirstTime) {
      _createTutorial();
      await prefs.setBool('isFirstTimePlacesScreen', false);
    }
  }

  // إنشاء التعليمات
  Future<void> _createTutorial() async {
    final targets = [
      TargetFocus(
        identify: 'floatingButton',
        keyTarget: _addedKey,
        alignSkip: Alignment.topCenter,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) => Text(
              'Use this button to add new Place to the list',
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
      targets: targets,
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      tutorial.show(context: context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final userPlaces = ref.watch(userPlacesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Places'),
        actions: [
          IconButton(
            key: _addedKey,
            icon: const Icon(Icons.add),
            onPressed: () {
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
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder(
          future: _placesFuture,
          builder: (context, snapshot) => snapshot.connectionState ==
              ConnectionState.waiting
              ? const Center(child: CircularProgressIndicator())
              : PlacesList(
            places: userPlaces,
          ),
        ),
      ),
    );
  }
}
