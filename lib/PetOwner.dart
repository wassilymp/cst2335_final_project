import 'package:floor/floor.dart';

@entity
class PetOwner {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  final String firstName;
  final String lastName;
  final String address;
  final String dob;
  final String? insurance;

  PetOwner({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.address,
    required this.dob,
    this.insurance,
  });
}