import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';

import 'app_database.dart';
import 'pet.dart';

// Name: Keren-Grace Niragi Muyangayanga
// Student no.: 041173528
// Project Topic: Pet
// CST2335 | Mr Fedor | Final Project

// This page is my full Pet feature.
// It lets the user add, update, delete, view, and reuse pet information.
class PetPage extends StatefulWidget {
  final String title;

  const PetPage({super.key, required this.title});

  @override
  State<PetPage> createState() => _PetPageState();
}

class _PetPageState extends State<PetPage> {
  // These controllers read whatever the user types in the form.
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _speciesController = TextEditingController();
  final TextEditingController _colourController = TextEditingController();
  final TextEditingController _ownerIdController = TextEditingController();

  // I use this to store the previous pet so the user can copy it later.
  final EncryptedSharedPreferences _prefs = EncryptedSharedPreferences();

  // This is the database connection for my page.
  late AppDatabase database;

  // This list stores the pets that come from the database and appear on screen.
  List<Pet> _pets = [];

  // This keeps track of the pet selected from the list.
  // If it is null, the user is adding a new pet.
  // If it is not null, the user is editing or deleting a pet.
  Pet? _selectedPet;

  // This is for switching the page between English and French.
  bool _isFrench = false;

  // This runs once when the page opens.
  // I use it to prepare the database before the user starts using the page.
  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  // This opens the database and then loads the saved pets.
  Future<void> _initializeDatabase() async {
    database = await $FloorAppDatabase
        .databaseBuilder('pet_database.db')
        .build();

    await _loadPets();
  }

  // This gets all pets from the database and refreshes the list on screen.
  Future<void> _loadPets() async {
    final pets = await database.petDao.findAllPets();

    setState(() {
      _pets = pets;
    });
  }

  // After saving or updating a pet, I keep a copy of it here.
  // That way the user can press "Copy Previous Pet" instead of typing everything again.
  Future<void> _savePreviousPet(Pet pet) async {
    await _prefs.setString('previous_name', pet.name);
    await _prefs.setString('previous_birthday', pet.birthday);
    await _prefs.setString('previous_species', pet.species);
    await _prefs.setString('previous_colour', pet.colour);
    await _prefs.setString('previous_ownerId', pet.ownerId);
  }

  // This fills the form with the most recently saved pet.
  // If there is no saved pet yet, I show a message instead.
  Future<void> _copyPreviousPet() async {
    final String? savedName = await _prefs.getString('previous_name');
    final String? savedBirthday = await _prefs.getString('previous_birthday');
    final String? savedSpecies = await _prefs.getString('previous_species');
    final String? savedColour = await _prefs.getString('previous_colour');
    final String? savedOwnerId = await _prefs.getString('previous_ownerId');

    if (savedName == null ||
        savedBirthday == null ||
        savedSpecies == null ||
        savedColour == null ||
        savedOwnerId == null) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _text(
              english: 'No previous pet information was found.',
              french: 'Aucune information précédente sur l’animal n’a été trouvée.',
            ),
          ),
        ),
      );
      return;
    }

    setState(() {
      _nameController.text = savedName;
      _birthdayController.text = savedBirthday;
      _speciesController.text = savedSpecies;
      _colourController.text = savedColour;
      _ownerIdController.text = savedOwnerId;
    });
  }

  // This adds a new pet to the database.
  // First I check if the user filled in all the fields.
  Future<void> _addPet() async {
    if (_nameController.text.trim().isEmpty ||
        _birthdayController.text.trim().isEmpty ||
        _speciesController.text.trim().isEmpty ||
        _colourController.text.trim().isEmpty ||
        _ownerIdController.text.trim().isEmpty) {
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

    // Here I create the pet object using what the user typed.
    final pet = Pet(
      id: Pet.idCounter++,
      name: _nameController.text.trim(),
      birthday: _birthdayController.text.trim(),
      species: _speciesController.text.trim(),
      colour: _colourController.text.trim(),
      ownerId: _ownerIdController.text.trim(),
    );

    // Save the new pet into the database.
    await database.petDao.insertPet(pet);

    // Save a copy of it for the "copy previous" feature.
    await _savePreviousPet(pet);

    // Refresh the list on screen.
    await _loadPets();

    // Clear the form after saving.
    _clearFields();

    if (!mounted) return;

    // This dialog is just to confirm that the save worked.
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(_text(english: 'Success', french: 'Succès')),
          content: Text(
            _text(
              english: 'Pet saved successfully.',
              french: 'L’animal a été enregistré avec succès.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(_text(english: 'OK', french: 'OK')),
            ),
          ],
        );
      },
    );
  }

  // This updates the selected pet with the new values typed in the form.
  Future<void> _updatePet() async {
    if (_selectedPet == null) return;

    final updatedPet = Pet(
      id: _selectedPet!.id,
      name: _nameController.text.trim(),
      birthday: _birthdayController.text.trim(),
      species: _speciesController.text.trim(),
      colour: _colourController.text.trim(),
      ownerId: _ownerIdController.text.trim(),
    );

    await database.petDao.updatePet(updatedPet);
    await _savePreviousPet(updatedPet);
    await _loadPets();
    _clearFields();
  }

  // This deletes the selected pet from the database.
  Future<void> _deletePet() async {
    if (_selectedPet == null) return;

    await database.petDao.deletePet(_selectedPet!);
    await _loadPets();
    _clearFields();
  }

  // When the user taps a pet from the list, I load its details into the form.
  // This makes it easier to update or delete it.
  void _selectPet(Pet pet) {
    setState(() {
      _selectedPet = pet;
      _nameController.text = pet.name;
      _birthdayController.text = pet.birthday;
      _speciesController.text = pet.species;
      _colourController.text = pet.colour;
      _ownerIdController.text = pet.ownerId;
    });
  }

  // This clears all the text fields and removes the selected pet.
  // I use it after saving, updating, deleting, or when the user wants a blank form.
  void _clearFields() {
    _nameController.clear();
    _birthdayController.clear();
    _speciesController.clear();
    _colourController.clear();
    _ownerIdController.clear();

    setState(() {
      _selectedPet = null;
    });
  }

  // This helper chooses which text to show depending on the selected language.
  String _text({
    required String english,
    required String french,
  }) {
    return _isFrench ? french : english;
  }

  // This opens a small dialog that explains how to use the page.
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
                  '- Fill in all pet fields\n'
                  '- Click Save Pet to add a pet\n'
                  '- Tap a pet in the list to update or delete it\n'
                  '- Use Copy Previous Pet to reuse old information\n'
                  '- Use Clear Form to reset the page\n'
                  '- Use the menu in the top right to change language',
              french:
              'Pour utiliser cette page :\n\n'
                  '- Remplissez tous les champs\n'
                  '- Cliquez sur Enregistrer pour ajouter un animal\n'
                  '- Touchez un animal dans la liste pour le modifier ou le supprimer\n'
                  '- Utilisez Copier l’animal précédent pour réutiliser les informations\n'
                  '- Utilisez Effacer le formulaire pour réinitialiser la page\n'
                  '- Utilisez le menu en haut à droite pour changer la langue',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(_text(english: 'OK', french: 'OK')),
            ),
          ],
        );
      },
    );
  }

  // This builds one reusable text field so I do not repeat the same code many times.
  Widget buildInputField({
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

  // This builds the full page that the user sees.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App bar at the top of the page.
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(
          _text(
            english: widget.title,
            french: 'Dossiers des animaux',
          ),
        ),

        // These are the 3 dots options in the top right corner.
        // I use them for instructions and language switching.
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

      // Main page content starts here.
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Page heading
            Text(
              _text(
                english: 'Pet Information',
                french: 'Informations sur l’animal',
              ),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),

            // User input fields
            buildInputField(
              controller: _nameController,
              label: _text(
                english: 'Pet Name',
                french: 'Nom de l’animal',
              ),
            ),
            buildInputField(
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
            buildInputField(
              controller: _speciesController,
              label: _text(
                english: 'Species',
                french: 'Espèce',
              ),
            ),
            buildInputField(
              controller: _colourController,
              label: _text(
                english: 'Colour',
                french: 'Couleur',
              ),
            ),
            buildInputField(
              controller: _ownerIdController,
              label: _text(
                english: 'Owner ID',
                french: 'ID du propriétaire',
              ),
            ),

            const SizedBox(height: 10),

            // If no pet is selected, show the save button.
            // If a pet is selected, show update and delete instead.
            if (_selectedPet == null)
              ElevatedButton(
                onPressed: _addPet,
                child: Text(
                  _text(
                    english: 'Save Pet',
                    french: 'Enregistrer l’animal',
                  ),
                ),
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _updatePet,
                    child: Text(
                      _text(
                        english: 'Update Pet',
                        french: 'Modifier l’animal',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _deletePet,
                    child: Text(
                      _text(
                        english: 'Delete Pet',
                        french: 'Supprimer l’animal',
                      ),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 10),

            // Extra buttons under the main action buttons.
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _copyPreviousPet,
                  child: Text(
                    _text(
                      english: 'Copy Previous Pet',
                      french: 'Copier l’animal précédent',
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

            // This list shows all pets currently stored in the database.
            Expanded(
              child: ListView.builder(
                itemCount: _pets.length,
                itemBuilder: (context, index) {
                  final pet = _pets[index];

                  return Card(
                    child: ListTile(
                      title: Text(pet.name),
                      subtitle: Text('${pet.species} - ${pet.colour}'),
                      onTap: () => _selectPet(pet),
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