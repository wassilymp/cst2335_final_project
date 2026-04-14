import 'package:floor/floor.dart';
import 'PetOwner.dart';

@dao
abstract class PetOwnerDao {
  @Query('SELECT * FROM PetOwner')
  Future<List<PetOwner>> findAllOwners();

  @insert
  Future<void> insertOwner(PetOwner owner);

  @update
  Future<void> updateOwner(PetOwner owner);

  @delete
  Future<void> deleteOwner(PetOwner owner);
}