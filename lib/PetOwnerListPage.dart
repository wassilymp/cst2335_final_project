import 'package:flutter/material.dart';
import 'PetOwner.dart';
import 'PetOwnerDao.dart';
import 'app_database.dart';

// Name: Izzy (Your Name)
// Student Number: (your student number)
// Project Topic: Pet Owner
// Course: CST2335 | Final Project
//
// This page displays a list of pet owners and allows users to:
// - Add new pet owners
// - Edit existing pet owners
// - Delete pet owners
// - View instructions via the ActionBar

class PetOwnerListPage extends StatefulWidget {
  const PetOwnerListPage({super.key});

  @override
  State<PetOwnerListPage> createState() => _PetOwnerListPageState();
}

class _PetOwnerListPageState extends State<PetOwnerListPage> {

  // DAO used to interact with the database
  late PetOwnerDao dao;

  // List of all pet owners retrieved from database
  List<PetOwner> owners = [];

  // Currently selected owner (used for editing)
  PetOwner? selectedOwner;

  // Determines whether the form view is shown
  bool isEditing = false;

  // Controllers for input fields
  final fName = TextEditingController();
  final lName = TextEditingController();
  final addr = TextEditingController();
  final dob = TextEditingController();
  final insurance = TextEditingController();

  // Initializes the database when the page loads
  @override
  void initState() {
    super.initState();
    initDb();
  }

  // Builds the Floor database and initializes DAO
  Future<void> initDb() async {
    final db =
    await $FloorAppDatabase.databaseBuilder('app.db').build();

    dao = db.petOwnerDao;
    loadOwners();
  }

  // Loads all pet owners from the database
  Future<void> loadOwners() async {
    final data = await dao.findAllOwners();
    setState(() => owners = data);
  }

  // Styling for all input fields
  InputDecoration inputStyle(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xFFF5F5DC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  // Displays instructions dialog from the ActionBar
  void showInstructions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('How to Use'),
        content: const Text(
          '• Tap + to add a new pet owner\n'
              '• Fill in all required fields\n'
              '• Enter DOB as YYYY-MM-DD\n'
              '• Tap Save to store the owner\n'
              '• Tap an owner to edit or delete\n'
              '• Insurance is optional',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Saves a new or updated pet owner
  Future<void> save() async {

    // Regex to validate date format
    final dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');

    // Validates required fields and date format
    if (fName.text.isEmpty ||
        lName.text.isEmpty ||
        addr.text.isEmpty ||
        dob.text.isEmpty ||
        !dateRegex.hasMatch(dob.text)) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter DOB as YYYY-MM-DD')),
      );
      return;
    }

    // Creates PetOwner object
    final owner = PetOwner(
      id: selectedOwner?.id,
      firstName: fName.text,
      lastName: lName.text,
      address: addr.text,
      dob: dob.text,
      insurance: insurance.text,
    );

    // Inserts or updates based on selection
    if (selectedOwner == null) {
      await dao.insertOwner(owner);
    } else {
      await dao.updateOwner(owner);
    }

    clear();
    loadOwners();
    setState(() => isEditing = false);
  }

  // Deletes the selected pet owner
  Future<void> delete() async {
    await dao.deleteOwner(selectedOwner!);
    clear();
    loadOwners();
    setState(() => isEditing = false);
  }

  // Clears all input fields and resets selection
  void clear() {
    selectedOwner = null;
    fName.clear();
    lName.clear();
    addr.clear();
    dob.clear();
    insurance.clear();
  }

  // Builds the main
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet Owners'),

        // ActionBar button for instructions
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: showInstructions,
          ),
        ],
      ),

      // Switches between list view and form view
      body: isEditing ? form() : list(),

      // Floating button to add new owner
      floatingActionButton: !isEditing
          ? FloatingActionButton(
        onPressed: () => setState(() => isEditing = true),
        child: const Icon(Icons.add),
      )
          : null,
    );
  }

  // Displays list of pet owners
  Widget list() {
    if (owners.isEmpty) {
      return const Center(child: Text('No owners yet'));
    }

    return ListView.builder(
      itemCount: owners.length,
      itemBuilder: (context, i) {
        final o = owners[i];

        return ListTile(
          title: Text('${o.firstName} ${o.lastName}'),
          subtitle: Text(o.address),

          // Loads selected owner into form for editing
          onTap: () {
            selectedOwner = o;
            fName.text = o.firstName;
            lName.text = o.lastName;
            addr.text = o.address;
            dob.text = o.dob;
            insurance.text = o.insurance ?? '';

            setState(() => isEditing = true);
          },
        );
      },
    );
  }

  // Displays form for adding/editing owners
  Widget form() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [

          // First name input
          TextField(controller: fName, decoration: inputStyle('First Name')),
          const SizedBox(height: 10),

          // Last name input
          TextField(controller: lName, decoration: inputStyle('Last Name')),
          const SizedBox(height: 10),

          // Address input
          TextField(controller: addr, decoration: inputStyle('Address')),
          const SizedBox(height: 10),

          // Date of Birth input (manual format)
          TextField(
            controller: dob,
            keyboardType: TextInputType.datetime,
            decoration: inputStyle('Date of Birth (YYYY-MM-DD)').copyWith(
              hintText: 'YYYY-MM-DD',
            ),
          ),

          const SizedBox(height: 10),

          // Optional insurance field
          TextField(
            controller: insurance,
            decoration: inputStyle('Insurance (Optional)'),
          ),

          const SizedBox(height: 20),

          // Save button
          ElevatedButton(onPressed: save, child: const Text('Save')),

          // Delete button (only shown when editing)
          if (selectedOwner != null)
            ElevatedButton(onPressed: delete, child: const Text('Delete')),

          // Cancel button
          TextButton(
            onPressed: () => setState(() => isEditing = false),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}