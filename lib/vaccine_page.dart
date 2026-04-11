
import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Vaccine model class
class Vaccine {
  int? id;
  String name;
  String dosage;
  String lotNumber;
  String expirationDate;

  Vaccine({
    this.id,
    required this.name,
    required this.dosage,
    required this.lotNumber,
    required this.expirationDate,
  });

  /// Convert object to Map for database insert/update
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'lotNumber': lotNumber,
      'expirationDate': expirationDate,
    };
  }

  /// Convert Map from database into Vaccine object
  factory Vaccine.fromMap(Map<String, dynamic> map) {
    return Vaccine(
      id: map['id'] as int?,
      name: map['name'] as String,
      dosage: map['dosage'] as String,
      lotNumber: map['lotNumber'] as String,
      expirationDate: map['expirationDate'] as String,
    );
  }
}

/// Database helper class
class VaccineDatabase {
  static Database? _database;

  /// Return database instance
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Create/open database
  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'vaccines.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE vaccines(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            dosage TEXT NOT NULL,
            lotNumber TEXT NOT NULL,
            expirationDate TEXT NOT NULL
          )
        ''');
      },
    );
  }

  /// Insert vaccine into database
  static Future<void> insertVaccine(Vaccine vaccine) async {
    final db = await database;
    await db.insert('vaccines', vaccine.toMap());
  }

  /// Read all vaccines from database
  static Future<List<Vaccine>> getAllVaccines() async {
    final db = await database;
    final result = await db.query('vaccines', orderBy: 'id DESC');
    return result.map((e) => Vaccine.fromMap(e)).toList();
  }

  /// Update vaccine in database
  static Future<void> updateVaccine(Vaccine vaccine) async {
    final db = await database;
    await db.update(
      'vaccines',
      vaccine.toMap(),
      where: 'id = ?',
      whereArgs: [vaccine.id],
    );
  }

  /// Delete vaccine from database
  static Future<void> deleteVaccine(int id) async {
    final db = await database;
    await db.delete(
      'vaccines',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

class VaccinePage extends StatefulWidget {
  const VaccinePage({super.key});

  @override
  State<VaccinePage> createState() => _VaccinePageState();
}

class _VaccinePageState extends State<VaccinePage> {
  /// Controllers for the 4 required fields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dosageController = TextEditingController();
  final TextEditingController lotNumberController = TextEditingController();
  final TextEditingController expirationDateController =
  TextEditingController();

  /// Encrypted Shared Preferences for previous entry
  final EncryptedSharedPreferences encryptedPrefs =
  EncryptedSharedPreferences();

  /// Vaccines loaded from database
  List<Vaccine> vaccines = [];

  /// Selected vaccine for update/delete
  Vaccine? selectedVaccine;

  @override
  void initState() {
    super.initState();
    loadVaccines();
  }

  @override
  void dispose() {
    nameController.dispose();
    dosageController.dispose();
    lotNumberController.dispose();
    expirationDateController.dispose();
    super.dispose();
  }

  /// Load all vaccines from database
  Future<void> loadVaccines() async {
    final data = await VaccineDatabase.getAllVaccines();
    setState(() {
      vaccines = data;
    });
  }

  /// Check that all fields are filled
  bool fieldsAreValid() {
    return nameController.text.trim().isNotEmpty &&
        dosageController.text.trim().isNotEmpty &&
        lotNumberController.text.trim().isNotEmpty &&
        expirationDateController.text.trim().isNotEmpty;
  }

  /// Clear all fields
  void clearFields() {
    nameController.clear();
    dosageController.clear();
    lotNumberController.clear();
    expirationDateController.clear();

    setState(() {
      selectedVaccine = null;
    });
  }

  /// Show snack bar message
  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  /// Save previous entry for copy feature
  Future<void> savePreviousEntry() async {
    await encryptedPrefs.setString('previous_name', nameController.text.trim());
    await encryptedPrefs.setString(
      'previous_dosage',
      dosageController.text.trim(),
    );
    await encryptedPrefs.setString(
      'previous_lotNumber',
      lotNumberController.text.trim(),
    );
    await encryptedPrefs.setString(
      'previous_expirationDate',
      expirationDateController.text.trim(),
    );
  }

  /// Load previous entry into form
  Future<void> copyPreviousEntry() async {
    final name = await encryptedPrefs.getString('previous_name');
    final dosage = await encryptedPrefs.getString('previous_dosage');
    final lotNumber = await encryptedPrefs.getString('previous_lotNumber');
    final expirationDate =
    await encryptedPrefs.getString('previous_expirationDate');

    if ((name ?? '').isEmpty) {
      showMessage('No previous vaccine saved yet.');
      return;
    }

    setState(() {
      selectedVaccine = null;
      nameController.text = name ?? '';
      dosageController.text = dosage ?? '';
      lotNumberController.text = lotNumber ?? '';
      expirationDateController.text = expirationDate ?? '';
    });
  }

  /// Show dialog for blank form or copy previous
  void showNewVaccineDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('New Vaccine'),
          content: const Text(
            'Choose Blank Form or Copy Previous.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                clearFields();
              },
              child: const Text('Blank Form'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await copyPreviousEntry();
              },
              child: const Text('Copy Previous'),
            ),
          ],
        );
      },
    );
  }

  /// Add vaccine
  Future<void> addVaccine() async {
    if (!fieldsAreValid()) {
      showMessage('Please fill in all fields.');
      return;
    }

    final vaccine = Vaccine(
      name: nameController.text.trim(),
      dosage: dosageController.text.trim(),
      lotNumber: lotNumberController.text.trim(),
      expirationDate: expirationDateController.text.trim(),
    );

    await VaccineDatabase.insertVaccine(vaccine);
    await savePreviousEntry();
    await loadVaccines();
    clearFields();
    showMessage('Vaccine added successfully.');
  }

  /// Select vaccine from list and load details into form
  void selectVaccine(Vaccine vaccine) {
    setState(() {
      selectedVaccine = vaccine;
      nameController.text = vaccine.name;
      dosageController.text = vaccine.dosage;
      lotNumberController.text = vaccine.lotNumber;
      expirationDateController.text = vaccine.expirationDate;
    });
  }

  /// Update selected vaccine
  Future<void> updateSelectedVaccine() async {
    if (selectedVaccine == null) {
      showMessage('Please tap a vaccine from the list first.');
      return;
    }

    if (!fieldsAreValid()) {
      showMessage('Please fill in all fields.');
      return;
    }

    final updatedVaccine = Vaccine(
      id: selectedVaccine!.id,
      name: nameController.text.trim(),
      dosage: dosageController.text.trim(),
      lotNumber: lotNumberController.text.trim(),
      expirationDate: expirationDateController.text.trim(),
    );

    await VaccineDatabase.updateVaccine(updatedVaccine);
    await savePreviousEntry();
    await loadVaccines();
    clearFields();
    showMessage('Vaccine updated successfully.');
  }

  /// Delete selected vaccine from top button
  void confirmDeleteSelectedVaccine() {
    if (selectedVaccine == null) {
      showMessage('Please tap a vaccine from the list first.');
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Vaccine'),
          content: const Text('Are you sure you want to delete this vaccine?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await VaccineDatabase.deleteVaccine(selectedVaccine!.id!);
                if (!mounted) return;
                Navigator.pop(dialogContext);
                await loadVaccines();
                clearFields();
                showMessage('Vaccine deleted successfully.');
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  /// Delete directly from list using trash icon
  void deleteFromList(Vaccine vaccine) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Vaccine'),
          content: Text('Delete ${vaccine.name}?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await VaccineDatabase.deleteVaccine(vaccine.id!);
                if (!mounted) return;
                Navigator.pop(dialogContext);
                await loadVaccines();

                if (selectedVaccine?.id == vaccine.id) {
                  clearFields();
                }

                showMessage('Vaccine deleted successfully.');
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  /// Show instructions in help button
  void showInstructions() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Instructions'),
          content: const Text(
            '1. Tap New Vaccine.\n'
                '2. Choose Blank Form or Copy Previous.\n'
                '3. Fill Vaccine Name, Dosage, Lot Number, and Expiration Date.\n'
                '4. Tap Add Vaccine.\n'
                '5. Tap a vaccine in the list to load it into the form.\n'
                '6. Use Update or Delete.\n'
                '7. You can also delete directly with the trash icon.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  /// Pick expiration date
  Future<void> pickExpirationDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      final formattedDate =
          '${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}';

      setState(() {
        expirationDateController.text = formattedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vaccine Module'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: showInstructions,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// New Vaccine button
            ElevatedButton(
              onPressed: showNewVaccineDialog,
              child: const Text('New Vaccine'),
            ),
            const SizedBox(height: 12),

            /// Vaccine Name
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Vaccine Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),

            /// Dosage
            TextField(
              controller: dosageController,
              decoration: const InputDecoration(
                labelText: 'Dosage',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),

            /// Lot Number
            TextField(
              controller: lotNumberController,
              decoration: const InputDecoration(
                labelText: 'Lot Number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),

            /// Expiration Date
            TextField(
              controller: expirationDateController,
              readOnly: true,
              onTap: pickExpirationDate,
              decoration: const InputDecoration(
                labelText: 'Expiration Date',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
            ),
            const SizedBox(height: 12),

            /// Buttons always visible
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: addVaccine,
                  child: const Text('Add Vaccine'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: updateSelectedVaccine,
                  child: const Text('Update'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: confirmDeleteSelectedVaccine,
                  child: const Text('Delete'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            /// Vaccine list
            Expanded(
              child: vaccines.isEmpty
                  ? const Center(
                child: Text('No vaccines added yet.'),
              )
                  : ListView.builder(
                itemCount: vaccines.length,
                itemBuilder: (BuildContext context, int index) {
                  final vaccine = vaccines[index];

                  return Card(
                    child: ListTile(
                      title: Text(vaccine.name),
                      subtitle: Text(
                        'Dosage: ${vaccine.dosage}\n'
                            'Lot Number: ${vaccine.lotNumber}\n'
                            'Expiry: ${vaccine.expirationDate}',
                      ),
                      onTap: () => selectVaccine(vaccine),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deleteFromList(vaccine),
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