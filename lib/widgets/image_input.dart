import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageInput extends StatefulWidget {
  const ImageInput({
    super.key,
    this.initialImage, // Optional initial image to display
    required this.onPickImage, // Callback function to handle the picked image
  });

  final File? initialImage; // The initial image to be displayed
  final void Function(File image) onPickImage; // Callback for when an image is picked

  @override
  State<ImageInput> createState() {
    return _ImageInputState();
  }
}

class _ImageInputState extends State<ImageInput> {
  File? _selectedImage; // Currently selected image

  @override
  void initState() {
    super.initState();
    _selectedImage = widget.initialImage; // Set the initial image if provided
  }

  // Method to take a picture using the camera
  void _takePicture() async {
    final imagePicker = ImagePicker(); // Create an instance of ImagePicker
    final pickedImage = await imagePicker.pickImage(
      source: ImageSource.camera, // Specify that we want to use the camera
      maxWidth: 600, // Limit the maximum width of the picked image
    );
    if (pickedImage == null) {
      return; // If no image was picked, exit the function
    }
    setState(() {
      _selectedImage = File(pickedImage.path); // Set the picked image
    });
    widget.onPickImage(_selectedImage!); // Pass the selected image to the parent widget
  }

  @override
  Widget build(BuildContext context) {
    // Default content when no image is selected
    Widget content = TextButton.icon(
      onPressed: _takePicture, // Trigger image picking when pressed
      icon: const Icon(Icons.camera), // Camera icon
      label: const Text('Add Image'), // Button label
    );

    // If an image is selected, display it
    if (_selectedImage != null) {
      content = GestureDetector(
        onTap: _takePicture, // Allow re-taking the picture when the image is tapped
        child: Image.file(
          _selectedImage!,
          fit: BoxFit.cover, // Fit the image to cover the available space
          width: double.infinity, // Fill the width of the container
          height: double.infinity, // Fill the height of the container
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2), // Border color with opacity
          width: 1, // Border width
        ),
      ),
      height: 250, // Fixed height for the container
      width: double.infinity, // Fill the width of the parent widget
      alignment: Alignment.center, // Center the content within the container
      child: content, // Display the content (either button or image)
    );
  }
}
