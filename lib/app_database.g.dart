// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $AppDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $AppDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<AppDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder implements $AppDatabaseBuilderContract {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $AppDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  PetDao? _petDaoInstance;

  VeterinarianDao? _veterinarianDaoInstance;

  PetOwnerDao? _petOwnerDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Pet` (`id` INTEGER NOT NULL, `name` TEXT NOT NULL, `birthday` TEXT NOT NULL, `species` TEXT NOT NULL, `colour` TEXT NOT NULL, `ownerId` TEXT NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Veterinarian` (`id` INTEGER NOT NULL, `name` TEXT NOT NULL, `birthday` TEXT NOT NULL, `address` TEXT NOT NULL, `university` TEXT NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `PetOwner` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `firstName` TEXT NOT NULL, `lastName` TEXT NOT NULL, `address` TEXT NOT NULL, `dob` TEXT NOT NULL, `insurance` TEXT)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  PetDao get petDao {
    return _petDaoInstance ??= _$PetDao(database, changeListener);
  }

  @override
  VeterinarianDao get veterinarianDao {
    return _veterinarianDaoInstance ??=
        _$VeterinarianDao(database, changeListener);
  }

  @override
  PetOwnerDao get petOwnerDao {
    return _petOwnerDaoInstance ??= _$PetOwnerDao(database, changeListener);
  }
}

class _$PetDao extends PetDao {
  _$PetDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _petInsertionAdapter = InsertionAdapter(
            database,
            'Pet',
            (Pet item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'birthday': item.birthday,
                  'species': item.species,
                  'colour': item.colour,
                  'ownerId': item.ownerId
                }),
        _petUpdateAdapter = UpdateAdapter(
            database,
            'Pet',
            ['id'],
            (Pet item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'birthday': item.birthday,
                  'species': item.species,
                  'colour': item.colour,
                  'ownerId': item.ownerId
                }),
        _petDeletionAdapter = DeletionAdapter(
            database,
            'Pet',
            ['id'],
            (Pet item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'birthday': item.birthday,
                  'species': item.species,
                  'colour': item.colour,
                  'ownerId': item.ownerId
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Pet> _petInsertionAdapter;

  final UpdateAdapter<Pet> _petUpdateAdapter;

  final DeletionAdapter<Pet> _petDeletionAdapter;

  @override
  Future<List<Pet>> findAllPets() async {
    return _queryAdapter.queryList('SELECT * FROM Pet',
        mapper: (Map<String, Object?> row) => Pet(
            id: row['id'] as int,
            name: row['name'] as String,
            birthday: row['birthday'] as String,
            species: row['species'] as String,
            colour: row['colour'] as String,
            ownerId: row['ownerId'] as String));
  }

  @override
  Future<void> insertPet(Pet pet) async {
    await _petInsertionAdapter.insert(pet, OnConflictStrategy.abort);
  }

  @override
  Future<void> updatePet(Pet pet) async {
    await _petUpdateAdapter.update(pet, OnConflictStrategy.abort);
  }

  @override
  Future<void> deletePet(Pet pet) async {
    await _petDeletionAdapter.delete(pet);
  }
}

class _$VeterinarianDao extends VeterinarianDao {
  _$VeterinarianDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _veterinarianInsertionAdapter = InsertionAdapter(
            database,
            'Veterinarian',
            (Veterinarian item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'birthday': item.birthday,
                  'address': item.address,
                  'university': item.university
                }),
        _veterinarianUpdateAdapter = UpdateAdapter(
            database,
            'Veterinarian',
            ['id'],
            (Veterinarian item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'birthday': item.birthday,
                  'address': item.address,
                  'university': item.university
                }),
        _veterinarianDeletionAdapter = DeletionAdapter(
            database,
            'Veterinarian',
            ['id'],
            (Veterinarian item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'birthday': item.birthday,
                  'address': item.address,
                  'university': item.university
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Veterinarian> _veterinarianInsertionAdapter;

  final UpdateAdapter<Veterinarian> _veterinarianUpdateAdapter;

  final DeletionAdapter<Veterinarian> _veterinarianDeletionAdapter;

  @override
  Future<List<Veterinarian>> findAllVeterinarians() async {
    return _queryAdapter.queryList('SELECT * FROM Veterinarian',
        mapper: (Map<String, Object?> row) => Veterinarian(
            id: row['id'] as int,
            name: row['name'] as String,
            birthday: row['birthday'] as String,
            address: row['address'] as String,
            university: row['university'] as String));
  }

  @override
  Future<void> insertVeterinarian(Veterinarian veterinarian) async {
    await _veterinarianInsertionAdapter.insert(
        veterinarian, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateVeterinarian(Veterinarian veterinarian) async {
    await _veterinarianUpdateAdapter.update(
        veterinarian, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteVeterinarian(Veterinarian veterinarian) async {
    await _veterinarianDeletionAdapter.delete(veterinarian);
  }
}

class _$PetOwnerDao extends PetOwnerDao {
  _$PetOwnerDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _petOwnerInsertionAdapter = InsertionAdapter(
            database,
            'PetOwner',
            (PetOwner item) => <String, Object?>{
                  'id': item.id,
                  'firstName': item.firstName,
                  'lastName': item.lastName,
                  'address': item.address,
                  'dob': item.dob,
                  'insurance': item.insurance
                }),
        _petOwnerUpdateAdapter = UpdateAdapter(
            database,
            'PetOwner',
            ['id'],
            (PetOwner item) => <String, Object?>{
                  'id': item.id,
                  'firstName': item.firstName,
                  'lastName': item.lastName,
                  'address': item.address,
                  'dob': item.dob,
                  'insurance': item.insurance
                }),
        _petOwnerDeletionAdapter = DeletionAdapter(
            database,
            'PetOwner',
            ['id'],
            (PetOwner item) => <String, Object?>{
                  'id': item.id,
                  'firstName': item.firstName,
                  'lastName': item.lastName,
                  'address': item.address,
                  'dob': item.dob,
                  'insurance': item.insurance
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<PetOwner> _petOwnerInsertionAdapter;

  final UpdateAdapter<PetOwner> _petOwnerUpdateAdapter;

  final DeletionAdapter<PetOwner> _petOwnerDeletionAdapter;

  @override
  Future<List<PetOwner>> findAllOwners() async {
    return _queryAdapter.queryList('SELECT * FROM PetOwner',
        mapper: (Map<String, Object?> row) => PetOwner(
            id: row['id'] as int?,
            firstName: row['firstName'] as String,
            lastName: row['lastName'] as String,
            address: row['address'] as String,
            dob: row['dob'] as String,
            insurance: row['insurance'] as String?));
  }

  @override
  Future<void> insertOwner(PetOwner owner) async {
    await _petOwnerInsertionAdapter.insert(owner, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateOwner(PetOwner owner) async {
    await _petOwnerUpdateAdapter.update(owner, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteOwner(PetOwner owner) async {
    await _petOwnerDeletionAdapter.delete(owner);
  }
}
