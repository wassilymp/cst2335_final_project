import 'package:flutter/material.dart';

class VaccinePage extends StatefulWidget {
  const VaccinePage({super.key});

  @override
  State<VaccinePage> createState() => _VaccinePageState();
}

class _VaccinePageState extends State<VaccinePage> {

  // Controller for vaccine name
  TextEditingController nameController = TextEditingController();

  // Controller for dosage
  TextEditingController dosageController = TextEditingController();

  // List that stores vaccines
  List<String> vaccines = [];

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Vaccine Module"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(

          children: [

            // Vaccine name input
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Vaccine Name",
              ),
            ),

            const SizedBox(height: 10),

            // Dosage input
            TextField(
              controller: dosageController,
              decoration: const InputDecoration(
                labelText: "Dosage",
              ),
            ),

            const SizedBox(height: 10),

            // Button to add vaccine
            ElevatedButton(

              onPressed: () {

                setState(() {

                  vaccines.add(
                      "${nameController.text} - ${dosageController.text}");

                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Vaccine added"),
                  ),
                );

                nameController.clear();
                dosageController.clear();
              },

              child: const Text("Add Vaccine"),

            ),

            const SizedBox(height: 20),

            // List showing vaccines
            Expanded(

              child: ListView.builder(

                itemCount: vaccines.length,

                itemBuilder: (context, index) {

                  return ListTile(

                    title: Text(vaccines[index]),

                    trailing: IconButton(

                      icon: const Icon(Icons.delete),

                      onPressed: () {

                        setState(() {
                          vaccines.removeAt(index);
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Vaccine deleted"),
                          ),
                        );
                      },

                    ),

                  );

                },

              ),

            )

          ],

        ),

      ),

    );
  }
}
