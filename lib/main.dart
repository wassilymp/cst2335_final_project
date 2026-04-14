import  'package:flutter/material.dart';
import 'pet_page.dart';
import 'vaccine_page.dart';
import 'veterinarian_page.dart';
import 'PetOwnerListPage.dart';


/// Main entry point of the group project application.
void main() {
  runApp(const MyApp());
}

/// Root widget for the full group project.
class MyApp extends StatelessWidget {
  /// Creates the root application widget.
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pet Records Hub',
      home: const HomePage(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF5F5DC),
        ),
        useMaterial3: true,
      ),
    );
  }
}

/// Shared home page for the final project.
///
/// From this page, the user can choose which module to open.
class HomePage extends StatelessWidget {
  /// Creates the shared home page.
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet Records Hub'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Final Project Modules',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),

            // Keren-Grace's module
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PetPage(title: 'Pet Records'),
                  ),
                );
              },
              child: const Text('Pet Module - Keren-Grace'),
            ),
            const SizedBox(height: 15),

            // Israel's module

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PetOwnerListPage(),
                  ),
                );
              },
              child: const Text('Pet Owner Module - Israel'),
            ),
            const SizedBox(height: 15),

            // Wassily's module
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const VeterinarianPage(),
                  ),
                );
              },
              child: const Text('Veterinarian Module - Wassily'),
            ),
            const SizedBox(height: 15),

            // Khalil's module
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const VaccinePage(),
                  ),
                );
              },
              child: const Text('Vaccine Module - Khalil'),
            ),
          ],
        ),
      ),
    );
  }
}