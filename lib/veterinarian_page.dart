import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';

import 'app_database.dart';
import 'veterinarian.dart';

// Name:Wassily Nshuti Mpunga
// student no.:041199211
// Project's Topic : vet
//CST2335| Mr Fedor | Final project

/// This page manages the Veterinarian module for the final project.
///
/// It allows the user to:
/// - add a veterinarian
/// - view saved veterinarians
/// - update a selected veterinarian
/// - delete a selected veterinarian
/// - reuse the previously entered veterinarian information
/// - switch between English and French
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

  /// Tracks the current language mode.
  ///
  /// false = English
  /// true = French
  bool _isFrench = false;

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
          content: Text(
            _text(
              english: 'No previous veterinarian information was found.',
              french: 'Aucune information précédente sur le vétérinaire n’a été trouvée.',
            ),
          ),
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
    if (_nameController.text.trim().isEmpty ||
        _birthdayController.text.trim().isEmpty ||
        _addressController.text.trim().isEmpty ||
        _universityController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _text(
              english: 'Please fill in all fields.',
              french: 'Veuillez remplir tous les champs.',
            ),
          ),
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
          title: Text(
            _text(
              english: 'Success',
              french: 'Succès',
            ),
          ),
          content: Text(
            _text(
              english: 'Veterinarian saved successfully.',
              french: 'Le vétérinaire a été enregistré avec succès.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                _text(
                  english: 'OK',
                  french: 'OK',
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Updates the selected veterinarian using the values currently in the form.
  Future<void> _updateVeterinarian() async {
    if (_selectedVet == null) return;

    if (_nameController.text.trim().isEmpty ||
        _birthdayController.text.trim().isEmpty ||
        _addressController.text.trim().isEmpty ||
        _universityController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _text(
              english: 'Please fill in all fields.',
              french: 'Veuillez remplir tous les champs.',
            ),
          ),
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
        content: Text(
          _text(
            english: 'Veterinarian updated successfully.',
            french: 'Le vétérinaire a été modifié avec succès.',
          ),
        ),
      ),
    );
  }

  /// Shows a confirmation dialog before deleting the selected veterinarian.
  Future<void> _confirmDeleteVeterinarian() async {
    if (_selectedVet == null) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            _text(
              english: 'Delete Veterinarian',
              french: 'Supprimer le vétérinaire',
            ),
          ),
          content: Text(
            _text(
              english: 'Are you sure you want to delete this veterinarian?',
              french: 'Êtes-vous sûr de vouloir supprimer ce vétérinaire ?',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                _text(
                  english: 'Cancel',
                  french: 'Annuler',
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _deleteVeterinarian();
              },
              child: Text(
                _text(
                  english: 'Delete',
                  french: 'Supprimer',
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Deletes the selected veterinarian from the database.
  Future<void> _deleteVeterinarian() async {
    if (_selectedVet == null) return;

    await database.veterinarianDao.deleteVeterinarian(_selectedVet!);
    await _loadVeterinarians();
    _clearFields();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _text(
            english: 'Veterinarian deleted successfully.',
            french: 'Le vétérinaire a été supprimé avec succès.',
          ),
        ),
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

  /// Returns text based on the currently selected language.
  String _text({
    required String english,
    required String french,
  }) {
    return _isFrench ? french : english;
  }

  /// Shows the instructions dialog from the app bar menu.
  void _showInstructions() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            _text(
              english: 'Instructions',
              french: 'Instructions',
            ),
          ),
          content: Text(
            _text(
              english:
              'To use this page:\n\n'
                  '- Fill in all veterinarian fields\n'
                  '- Click Save Veterinarian to add a record\n'
                  '- Tap a veterinarian in the list to update or delete it\n'
                  '- Use Copy Previous Veterinarian to reuse old information\n'
                  '- Use Clear Form to reset the page\n'
                  '- Use the top-right menu to switch language',
              french:
              'Pour utiliser cette page :\n\n'
                  '- Remplissez tous les champs du vétérinaire\n'
                  '- Cliquez sur Enregistrer pour ajouter un dossier\n'
                  '- Touchez un vétérinaire dans la liste pour le modifier ou le supprimer\n'
                  '- Utilisez Copier le vétérinaire précédent pour réutiliser les informations\n'
                  '- Utilisez Effacer le formulaire pour réinitialiser la page\n'
                  '- Utilisez le menu en haut à droite pour changer la langue',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                _text(
                  english: 'OK',
                  french: 'OK',
                ),
              ),
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _text(
            english: 'Veterinarian Records',
            french: 'Dossiers des vétérinaires',
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'instructions') {
                _showInstructions();
              } else if (value == 'language') {
                setState(() {
                  _isFrench = !_isFrench;
                });
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'instructions',
                child: Text(
                  _text(
                    english: 'Instructions',
                    french: 'Instructions',
                  ),
                ),
              ),
              PopupMenuItem(
                value: 'language',
                child: Text(
                  _text(
                    english: 'Switch Language',
                    french: 'Changer la langue',
                  ),
                ),
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
              _text(
                english: 'Veterinarian Information',
                french: 'Informations sur le vétérinaire',
              ),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            _buildInputField(
              controller: _nameController,
              label: _text(
                english: 'Name',
                french: 'Nom',
              ),
            ),
            _buildInputField(
              controller: _birthdayController,
              label: _text(
                english: 'Birthday',
                french: 'Date de naissance',
              ),
              hint: _text(
                english: 'YYYY-MM-DD',
                french: 'AAAA-MM-JJ',
              ),
            ),
            _buildInputField(
              controller: _addressController,
              label: _text(
                english: 'Address',
                french: 'Adresse',
              ),
            ),
            _buildInputField(
              controller: _universityController,
              label: _text(
                english: 'University',
                french: 'Université',
              ),
            ),
            const SizedBox(height: 10),
            if (_selectedVet == null)
              ElevatedButton(
                onPressed: _addVeterinarian,
                child: Text(
                  _text(
                    english: 'Save Veterinarian',
                    french: 'Enregistrer le vétérinaire',
                  ),
                ),
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _updateVeterinarian,
                    child: Text(
                      _text(
                        english: 'Update Veterinarian',
                        french: 'Modifier le vétérinaire',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _confirmDeleteVeterinarian,
                    child: Text(
                      _text(
                        english: 'Delete Veterinarian',
                        french: 'Supprimer le vétérinaire',
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _copyPreviousVeterinarian,
                  child: Text(
                    _text(
                      english: 'Copy Previous Veterinarian',
                      french: 'Copier le vétérinaire précédent',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _clearFields,
                  child: Text(
                    _text(
                      english: 'Clear Form',
                      french: 'Effacer le formulaire',
                    ),
                  ),
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