import 'package:floor/floor.dart';
// Name:Keren-grace Niragi Muyangayanga
// student no.:041173528
// Project's Topic : Pet
//CST2335| Mr Fedor | Final project

// Entity class used to store pet information in the database.
@entity
class Pet {
  // Simple counter used to assign ids to pets.
  static int idCounter = 1;

  // Unique id for each pet.
  @primaryKey
  final int id;

  // Pet name.
  final String name;

  // Pet birthday.
  final String birthday;

  // Pet species.
  final String species;

  // Pet colour.
  final String colour;

  // This links the pet to its owner.
  final String ownerId;

  // Creates one pet object with all required fields.
  Pet({
    required this.id,
    required this.name,
    required this.birthday,
    required this.species,
    required this.colour,
    required this.ownerId,
  });
}