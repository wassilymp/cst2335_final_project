import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

// Name:Keren-grace Niragi Muyangayanga
// student no.:041173528
// Project's Topic : Pet
//CST2335| Mr Fedor | Final project

import 'pet.dart';
import 'pet_dao.dart';

part 'app_database.g.dart';

// Main database class for the Pet Tracker application.
// This is the main database class for my Pet feature.
// It connects the Pet entity with the PetDao.
@Database(version: 1, entities: [Pet])
abstract class AppDatabase extends FloorDatabase {
  // This lets me access all pet-related database actions.
  PetDao get petDao;
}