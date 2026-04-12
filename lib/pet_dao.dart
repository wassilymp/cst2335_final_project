import 'package:floor/floor.dart';
import 'pet.dart';

// Name:Keren-grace Niragi Muyangayanga
// student no.:041173528
// Project's Topic : Pet
//CST2335| Mr Fedor | Final project

// This is where I handle all database operations for pets.
@dao
abstract class PetDao {
  // Gets all pets from the database so I can display them.
  @Query('SELECT * FROM Pet')
  Future<List<Pet>> findAllPets();

  // Inserts one pet into the database.
  @insert
  Future<void> insertPet(Pet pet);

  // Updates an existing pet in the database.
  @update
  Future<void> updatePet(Pet pet);

  // Deletes one pet from the database.
  @delete
  Future<void> deletePet(Pet pet);
}