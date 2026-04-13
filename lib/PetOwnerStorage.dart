import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';

// Name: Israel Kabulu Tsunza
// student no.:041173528
// Project's Topic : Pet
//CST2335| Mr Fedor | Final project




class PetOwnerStorage {
  final EncryptedSharedPreferences _prefs = EncryptedSharedPreferences();

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