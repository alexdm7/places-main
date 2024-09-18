import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:places/screens/places.dart';

// Define a color scheme with a dark theme and a seed color
final colorScheme = ColorScheme.fromSeed(
  brightness: Brightness.dark,
  seedColor: const Color.fromARGB(255, 102, 6, 247), // Seed color for the theme
  surface: const Color.fromARGB(255, 56, 49, 66), // Color for the background surface
);

// Define a custom theme data that uses the color scheme and Google Fonts
final theme = ThemeData().copyWith(
  scaffoldBackgroundColor: colorScheme.surface, // Background color of the scaffold
  colorScheme: colorScheme, // Apply the color scheme
  textTheme: GoogleFonts.ubuntuCondensedTextTheme().copyWith(
    titleSmall: GoogleFonts.ubuntuCondensed(
      fontWeight: FontWeight.bold, // Apply bold font weight for small titles
    ),
    titleMedium: GoogleFonts.ubuntuCondensed(
      fontWeight: FontWeight.bold, // Apply bold font weight for medium titles
    ),
    titleLarge: GoogleFonts.ubuntuCondensed(
      fontWeight: FontWeight.bold, // Apply bold font weight for large titles
    ),
  ),
);

// Main entry point of the application
void main() {
  runApp(
    const ProviderScope(child: MyApp()), // Wrap the app in a ProviderScope for Riverpod
  );
}

// Main application widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Great Places', // Title of the application
      theme: theme, // Apply the custom theme
      home: const PlacesScreen(), // Set the home screen of the app
    );
  }
}
