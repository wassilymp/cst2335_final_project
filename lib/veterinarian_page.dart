import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';

import 'app_localizations.dart';
import 'main.dart';
import 'app_database.dart';
import 'veterinarian.dart';

/// This page manages the Veterinarian module for the final project.
///
/// It allows the user to:
/// - add a veterinarian
/// - view saved veterinarians
/// - update a selected veterinarian
/// - delete a selected veterinarian
/// - reuse the previously entered veterinarian information
/// - switch between English and French using app localization
class VeterinarianPage extends StatefulWidget {
  /// Creates the veterinarian page.
  const VeterinarianPage({super.key});

  @override
  State<VeterinarianPage> createState() => _VeterinarianPageState();
}

class _VeterinarianPageState extends State<VeterinarianPage> {
  /// Controller for the veterinarian's name.
  final TextEditingController _nameController = TextEditingController();

  /// Controller for the veterinarian's birthday.
  final TextEditingController _birthdayController = TextEditingController();

  /// Controller for the veterinarian's address.
  final TextEditingController _addressController = TextEditingController();

  /// Controller for the veterinarian's university.
  final TextEditingController _universityController = TextEditingController();

  /// Encrypted shared preferences used to save the previous entry.
  final EncryptedSharedPreferences _prefs = EncryptedSharedPreferences();

  /// Database instance for local Floor storage.
  late AppDatabase database;

  /// List of veterinarians loaded from the database.
  List<Veterinarian> _vets = [];

  /// Currently selected veterinarian from the list.
  ///
  /// If null, the page is in add mode.
  /// If not null, the page is in update/delete mode.
  Veterinarian? _selectedVet;

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  /// Initializes the Floor database and loads saved veterinarians.
  Future<void> _initializeDatabase() async {
    database = await $FloorAppDatabase
        .databaseBuilder('veterinarian_database.db')
        .build();

    await _loadVeterinarians();
  }

  /// Loads all veterinarians from the database into the page list.
  Future<void> _loadVeterinarians() async {
    final vets = await database.veterinarianDao.findAllVeterinarians();

    setState(() {
      _vets = vets;
    });
  }

  /// Saves the provided veterinarian as the previous entry.
  ///
  /// This is used for the "Copy Previous Veterinarian" feature.
  Future<void> _savePreviousVeterinarian(Veterinarian vet) async {
    await _prefs.setString('previous_vet_name', vet.name);
    await _prefs.setString('previous_vet_birthday', vet.birthday);
    await _prefs.setString('previous_vet_address', vet.address);
    await _prefs.setString('previous_vet_university', vet.university);
  }

  /// Loads the previously saved veterinarian information into the form.
  ///
  /// If no previous entry exists, a Snackbar is shown.
  Future<void> _copyPreviousVeterinarian() async {
    final t = AppLocalizations.of(context)!;

    final String? savedName = await _prefs.getString('previous_vet_name');
    final String? savedBirthday =
    await _prefs.getString('previous_vet_birthday');
    final String? savedAddress =
    await _prefs.getString('previous_vet_address');
    final String? savedUniversity =
    await _prefs.getString('previous_vet_university');

    if (savedName == null ||
        savedBirthday == null ||
        savedAddress == null ||
        savedUniversity == null) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.translate('no_previous_vet')),
        ),
      );
      return;
    }

    setState(() {
      _nameController.text = savedName;
      _birthdayController.text = savedBirthday;
      _addressController.text = savedAddress;
      _universityController.text = savedUniversity;
    });
  }

  /// Adds a new veterinarian to the database after validating all fields.
  Future<void> _addVeterinarian() async {
    final t = AppLocalizations.of(context)!;

    if (_nameController.text.trim().isEmpty ||
        _birthdayController.text.trim().isEmpty ||
        _addressController.text.trim().isEmpty ||
        _universityController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.translate('fill_all_fields')),
        ),
      );
      return;
    }

    final vet = Veterinarian(
      id: Veterinarian.idCounter++,
      name: _nameController.text.trim(),
      birthday: _birthdayController.text.trim(),
      address: _addressController.text.trim(),
      university: _universityController.text.trim(),
    );

    await database.veterinarianDao.insertVeterinarian(vet);
    await _savePreviousVeterinarian(vet);
    await _loadVeterinarians();
    _clearFields();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(t.translate('success')),
          content: Text(t.translate('vet_saved')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(t.translate('ok')),
            ),
          ],
        );
      },
    );
  }

  /// Updates the selected veterinarian using the values currently in the form.
  Future<void> _updateVeterinarian() async {
    final t = AppLocalizations.of(context)!;

    if (_selectedVet == null) return;

    if (_nameController.text.trim().isEmpty ||
        _birthdayController.text.trim().isEmpty ||
        _addressController.text.trim().isEmpty ||
        _universityController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.translate('fill_all_fields')),
        ),
      );
      return;
    }

    final updatedVet = Veterinarian(
      id: _selectedVet!.id,
      name: _nameController.text.trim(),
      birthday: _birthdayController.text.trim(),
      address: _addressController.text.trim(),
      university: _universityController.text.trim(),
    );

    await database.veterinarianDao.updateVeterinarian(updatedVet);
    await _savePreviousVeterinarian(updatedVet);
    await _loadVeterinarians();
    _clearFields();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(t.translate('vet_updated')),
      ),
    );
  }

  /// Shows a confirmation dialog before deleting the selected veterinarian.
  Future<void> _confirmDeleteVeterinarian() async {
    final t = AppLocalizations.of(context)!;

    if (_selectedVet == null) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(t.translate('delete_vet')),
          content: Text(t.translate('delete_confirm')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(t.translate('cancel')),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _deleteVeterinarian();
              },
              child: Text(t.translate('delete')),
            ),
          ],
        );
      },
    );
  }

  /// Deletes the selected veterinarian from the database.
  Future<void> _deleteVeterinarian() async {
    final t = AppLocalizations.of(context)!;

    if (_selectedVet == null) return;

    await database.veterinarianDao.deleteVeterinarian(_selectedVet!);
    await _loadVeterinarians();
    _clearFields();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(t.translate('vet_deleted')),
      ),
    );
  }

  /// Loads the selected veterinarian's details into the form.
  void _selectVeterinarian(Veterinarian vet) {
    setState(() {
      _selectedVet = vet;
      _nameController.text = vet.name;
      _birthdayController.text = vet.birthday;
      _addressController.text = vet.address;
      _universityController.text = vet.university;
    });
  }

  /// Clears all input fields and exits edit mode.
  void _clearFields() {
    _nameController.clear();
    _birthdayController.clear();
    _addressController.clear();
    _universityController.clear();

    setState(() {
      _selectedVet = null;
    });
  }

  /// Shows the instructions dialog from the app bar menu.
  void _showInstructions() {
    final t = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(t.translate('instructions')),
          content: Text(t.translate('instructions_text')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(t.translate('ok')),
            ),
          ],
        );
      },
    );
  }

  /// Builds a reusable styled text field.
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    String? hint,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.translate('vet_records')),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'instructions') {
                _showInstructions();
              } else if (value == 'language') {
                final currentCode =
                    Localizations.localeOf(context).languageCode;

                if (currentCode == 'en') {
                  MyApp.setLocale(context, const Locale('fr', 'CA'));
                } else {
                  MyApp.setLocale(context, const Locale('en', 'US'));
                }
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'instructions',
                child: Text(t.translate('instructions')),
              ),
              PopupMenuItem(
                value: 'language',
                child: Text(t.translate('switch_language')),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              t.translate('vet_information'),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            _buildInputField(
              controller: _nameController,
              label: t.translate('name'),
            ),
            _buildInputField(
              controller: _birthdayController,
              label: t.translate('birthday'),
              hint: t.translate('yyyy_mm_dd'),
            ),
            _buildInputField(
              controller: _addressController,
              label: t.translate('address'),
            ),
            _buildInputField(
              controller: _universityController,
              label: t.translate('university'),
            ),
            const SizedBox(height: 10),
            if (_selectedVet == null)
              ElevatedButton(
                onPressed: _addVeterinarian,
                child: Text(t.translate('save_vet')),
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _updateVeterinarian,
                    child: Text(t.translate('update_vet')),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _confirmDeleteVeterinarian,
                    child: Text(t.translate('delete_vet')),
                  ),
                ],
              ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _copyPreviousVeterinarian,
                  child: Text(t.translate('copy_previous_vet')),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _clearFields,
                  child: Text(t.translate('clear_form')),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Expanded(
              child: ListView.builder(
                itemCount: _vets.length,
                itemBuilder: (context, index) {
                  final vet = _vets[index];

                  return Card(
                    child: ListTile(
                      title: Text(vet.name),
                      subtitle: Text(vet.university),
                      onTap: () => _selectVeterinarian(vet),
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

  @override
  void dispose() {
    _nameController.dispose();
    _birthdayController.dispose();
    _addressController.dispose();
    _universityController.dispose();
    super.dispose();
  }
}