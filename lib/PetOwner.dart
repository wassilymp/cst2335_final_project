import 'package:floor/floor.dart';

// Name: Izzy (Your Name)
// Student Number: (your student number)
// Project Topic: Pet Owner
// Course: CST2335 | Final Project
//
// This class represents a Pet Owner entity in the database.
// It defines the structure of the PetOwner table using Floor ORM.



// Primary key for the petowner table
//
@entity
class PetOwner {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  // the first name, last name, address, DOB, and insurance of the pet owner
  final String firstName;
  final String lastName;
  final String address;
  //dob format: YYYY-MM-DD
  final String dob;

  // optional insurance number for petowner object
  final String? insurance;

  // Constructor used to create a PetOwner object.
  // Required fields must be provided when creating a new instance.
  PetOwner({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.address,
    required this.dob,
    this.insurance,
  });
}