import 'package:flutter/material.dart';
import 'PetOwner.dart';
import 'PetOwnerDao.dart';
import 'app_database.dart';

class PetOwnerListPage extends StatefulWidget {
  const PetOwnerListPage({super.key});

  @override
  State<PetOwnerListPage> createState() => _PetOwnerListPageState();
}

class _PetOwnerListPageState extends State<PetOwnerListPage> {
  late PetOwnerDao dao;

  List<PetOwner> owners = [];
  PetOwner? selectedOwner;
  bool isEditing = false;

  final fName = TextEditingController();
  final lName = TextEditingController();
  final addr = TextEditingController();
  final dob = TextEditingController();
  final insurance = TextEditingController();

  @override
  void initState() {
    super.initState();
    initDb();
  }

  Future<void> initDb() async {
    final db =
    await $FloorAppDatabase.databaseBuilder('app.db').build();

    dao = db.petOwnerDao;
    loadOwners();
  }

  Future<void> loadOwners() async {
    final data = await dao.findAllOwners();
    setState(() => owners = data);
  }

  // ✅ CALENDAR FUNCTION
  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 20)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      dob.text =
      "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      setState(() {});
    }
  }

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

  // Instructions dialog
  void showInstructions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('How to Use'),
        content: const Text(
          '• Tap + to add a new pet owner\n'
              '• Fill in all required fields\n'
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

  Future<void> save() async {
    if (fName.text.isEmpty ||
        lName.text.isEmpty ||
        addr.text.isEmpty ||
        dob.text.isEmpty) return;

    final owner = PetOwner(
      id: selectedOwner?.id,
      firstName: fName.text,
      lastName: lName.text,
      address: addr.text,
      dob: dob.text,
      insurance: insurance.text,
    );

    if (selectedOwner == null) {
      await dao.insertOwner(owner);
    } else {
      await dao.updateOwner(owner);
    }

    clear();
    loadOwners();
    setState(() => isEditing = false);
  }

  Future<void> delete() async {
    await dao.deleteOwner(selectedOwner!);
    clear();
    loadOwners();
    setState(() => isEditing = false);
  }

  void clear() {
    selectedOwner = null;
    fName.clear();
    lName.clear();
    addr.clear();
    dob.clear();
    insurance.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet Owners'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: showInstructions,
          ),
        ],
      ),
      body: isEditing ? form() : list(),
      floatingActionButton: !isEditing
          ? FloatingActionButton(
        onPressed: () => setState(() => isEditing = true),
        child: const Icon(Icons.add),
      )
          : null,
    );
  }

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

  Widget form() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          TextField(controller: fName, decoration: inputStyle('First Name')),
          const SizedBox(height: 10),
          TextField(controller: lName, decoration: inputStyle('Last Name')),
          const SizedBox(height: 10),
          TextField(controller: addr, decoration: inputStyle('Address')),
          const SizedBox(height: 10),

          // ✅ UPDATED DOB FIELD WITH CALENDAR
          TextField(
            controller: dob,
            readOnly: true,
            onTap: _selectDate,
            decoration: inputStyle('Date of Birth').copyWith(
              suffixIcon: const Icon(Icons.calendar_today),
            ),
          ),

          const SizedBox(height: 10),
          TextField(
              controller: insurance,
              decoration: inputStyle('Insurance (Optional)')),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: save, child: const Text('Save')),
          if (selectedOwner != null)
            ElevatedButton(onPressed: delete, child: const Text('Delete')),
          TextButton(
            onPressed: () => setState(() => isEditing = false),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}