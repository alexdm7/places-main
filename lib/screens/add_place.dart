import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:places/models/place.dart';
import 'dart:io';
import 'package:places/widgets/image_input.dart';
import 'package:places/providers/user_places.dart';
import 'package:places/widgets/location_input.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:shared_preferences/shared_preferences.dart'; // استيراد الحزمة

class AddPlaceScreen extends ConsumerStatefulWidget {
  const AddPlaceScreen({super.key});

  @override
  ConsumerState<AddPlaceScreen> createState() {
    return _AddPlaceScreenState();
  }
}

class _AddPlaceScreenState extends ConsumerState<AddPlaceScreen> {
  final GlobalKey _editButtonKey = GlobalKey();
  final _titleController = TextEditingController();
  File? _selctedImage;
  final _formKey = GlobalKey<FormState>();
  PlaceLocation? _selecteLocation;

  @override
  void initState() {
    super.initState();
    _checkAndShowTutorial(); // استدعاء الدالة للتحقق من عرض التعليمات
  }

  // الدالة لحفظ مكان
  void _savePlace() {
    final enteredTitle = _titleController.text;

    if (!_formKey.currentState!.validate() || _selctedImage == null || _selecteLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields.'),
        ),
      );
      return;
    }
    ref
        .read(userPlacesProvider.notifier)
        .addPlace(enteredTitle, _selctedImage!, _selecteLocation!);

    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  // التحقق من إذا كان يجب عرض التعليمات
  Future<void> _checkAndShowTutorial() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstTime = prefs.getBool('isFirstTimeAddPlaceScreen') ?? true;

    if (isFirstTime) {
      _createTutorial();
      await prefs.setBool('isFirstTimeAddPlaceScreen', false);
    }
  }

  // إنشاء التعليمات
  Future<void> _createTutorial() async {
    final targets = [
      TargetFocus(
        identify: 'floatingButton',
        keyTarget: _editButtonKey,
        alignSkip: Alignment.topCenter,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) => Text(
              'Use This Button To Add New Elements To The List',
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add new Place'),
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
                onPickImage: (image) {
                  _selctedImage = image;
                },
              ),
              const SizedBox(height: 10),
              LocationInput(
                onSelecteLocation: (location) {
                  _selecteLocation = location;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                key: _editButtonKey,
                onPressed: _savePlace,
                icon: const Icon(Icons.add),
                label: const Text('Add Place'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
