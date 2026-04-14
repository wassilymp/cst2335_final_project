import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';

// Name: Israel Kabulu Tshunza
// Student Number: 041109599
// Project Topic: Pet Owner
// Course: CST2335 | Final Project
//
// This class handles secure local storage of the most recently
// entered PetOwner data using encrypted shared preferences.
// It allows the app to remember the last entered owner and reuse it.

class PetOwnerStorage {

  // Instance of encrypted shared preferences
  // used to securely store key-value data
  final EncryptedSharedPreferences _prefs = EncryptedSharedPreferences();

  // Saves the last entered pet owner information securely
  //
  // Parameters:
  // - fName: First name of the owner
  // - lName: Last name of the owner
  // - addr: Address of the owner
  // - dob: Date of birth (YYYY-MM-DD)
  // - insurance: Optional insurance number
  Future<void> saveLastOwner(
      String fName,
      String lName,
      String addr,
      String dob,
      String insurance,
      ) async {
    await _prefs.setString('last_fName', fName);
    await _prefs.setString('last_lName', lName);
    await _prefs.setString('last_addr', addr);
    await _prefs.setString('last_dob', dob);
    await _prefs.setString('last_insurance', insurance);
  }

  // Retrieves the last saved pet owner data
  //
  // Returns:
  // A Map containing the stored values (may be null if not set)
  // Keys:
  // - fName
  // - lName
  // - addr
  // - dob
  // - insurance
  Future<Map<String, String?>> getLastOwner() async {
    return {
      'fName': await _prefs.getString('last_fName'),
      'lName': await _prefs.getString('last_lName'),
      'addr': await _prefs.getString('last_addr'),
      'dob': await _prefs.getString('last_dob'),
      'insurance': await _prefs.getString('last_insurance'),
    };
  }
}