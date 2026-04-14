import 'package:floor/floor.dart';
// Name:Wassily Nshuti Mpunga
// student no.:041199211
// Project's Topic : vet
//CST2335| Mr Fedor | Final project
/// Entity class representing a veterinarian record.
@entity
class Veterinarian {
  /// Unique ID for the veterinarian.
  @primaryKey
  final int id;

  /// Static counter for generating IDs manually.
  static int idCounter = 1;

  /// Veterinarian's full name.
  final String name;

  /// Veterinarian's date of birth.
  final String birthday;

  /// Veterinarian's address.
  final String address;

  /// Veterinarian's university of graduation.
  final String university;

  /// Creates a veterinarian object.
  Veterinarian({
    required this.id,
    required this.name,
    required this.birthday,
    required this.address,
    required this.university,
  }) {
    if (id >= idCounter) {
      idCounter = id + 1;
    }
  }
}