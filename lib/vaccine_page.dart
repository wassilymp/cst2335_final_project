import 'package:flutter/material.dart';

class VaccinePage extends StatefulWidget {
  const VaccinePage({super.key});

  @override
  State<VaccinePage> createState() => _VaccinePageState();
}

class _VaccinePageState extends State<VaccinePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dosageController = TextEditingController();

  final List<String> vaccines = [];

  void addVaccine() {
    String name = nameController.text.trim();
    String dosage = dosageController.text.trim();

    if (name.isNotEmpty && dosage.isNotEmpty) {
      setState(() {
        vaccines.add("$name - $dosage");
      });

      nameController.clear();
      dosageController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vaccine added")),
      );
    }
  }

  void deleteVaccine(int index) {
    setState(() {
      vaccines.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Vaccine deleted")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Vaccine Tracker"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Vaccine Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: dosageController,
              decoration: const InputDecoration(
                labelText: "Dosage",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: addVaccine,
              child: const Text("Add Vaccine"),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: vaccines.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Text(vaccines[index]),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deleteVaccine(index),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}