import 'package:floor/floor.dart';
import 'veterinarian.dart';
// Name:Wassily Nshuti Mpunga
// student no.:041199211
// Project's Topic : vet
//CST2335| Mr Fedor | Final project
/// Data access object for veterinarian database operations.
@dao
abstract class VeterinarianDao {
  /// Retrieves all veterinarians from the database.
  @Query('SELECT * FROM Veterinarian')
  Future<List<Veterinarian>> findAllVeterinarians();

  /// Inserts a veterinarian into the database.
  @insert
  Future<void> insertVeterinarian(Veterinarian veterinarian);

  /// Updates an existing veterinarian in the database.
  @update
  Future<void> updateVeterinarian(Veterinarian veterinarian);

  /// Deletes a veterinarian from the database.
  @delete
  Future<void> deleteVeterinarian(Veterinarian veterinarian);
}