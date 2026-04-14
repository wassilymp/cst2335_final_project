import 'package:floor/floor.dart';
import 'PetOwner.dart';


// Name: Izzy (Your Name)
// Student Number: (your student number)
// Project Topic: Pet Owner
// Course: CST2335 | Final Project
//
// This DAO (Data Access Object) handles all database operations related to the PetOwner entity.
@dao
abstract class PetOwnerDao {

  // Retrieves all pet owners from the database.
  // Returns a list of PetOwner objects.
  @Query('SELECT * FROM PetOwner')
  Future<List<PetOwner>> findAllOwners();

  //this inserts the owner to the database
  @insert
  Future<void> insertOwner(PetOwner owner);

  //this updates the owner to the database
  @update
  Future<void> updateOwner(PetOwner owner);

  //this deletes the owner from the database
  @delete
  Future<void> deleteOwner(PetOwner owner);
}