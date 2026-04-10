import 'package:flutter/material.dart';
import 'pet_page.dart';
import 'vaccine_page.dart';

// Main entry point of the group project application.
void main() {
  runApp(const MyApp());
}

// Root widget for the full group project.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pet Records Hub',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF5F5DC),
        ),
      ),
      home: const HomePage(),
    );
  }
}

// This is the shared home page for the final project.
// From here, the user can choose which module to open.
class HomePage extends StatelessWidget {
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

            // Izzy's module
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pet Owner module will be connected soon.'),
                  ),
                );
              },
              child: const Text('Pet Owner Module - Izzy'),
            ),
            const SizedBox(height: 15),

            // Wassily's module
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Veterinarian module will be connected soon.'),
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