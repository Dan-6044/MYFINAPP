import 'package:sqflite/sqflite.dart';

import 'app_database.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._();

  DatabaseService._();

  Database? _database;

  Future<Database?> get database async => _database;

  Future<void> initialize() async {
    _database = await AppDatabase.instance.database;
  }
}
