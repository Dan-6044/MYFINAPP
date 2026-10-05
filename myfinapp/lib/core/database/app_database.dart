import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'database_schema.dart';
import 'database_migrations.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  static const _databaseName = 'myfin.db';
  static const _databaseVersion = DatabaseSchema.version;

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    final documentsDirectory =
        await getApplicationDocumentsDirectory();

    final path = join(
      documentsDirectory.path,
      _databaseName,
    );

    _database = await openDatabase(
      path,
      version: _databaseVersion,
      onConfigure: (db) async {
        await db.execute(
          'PRAGMA foreign_keys = ON',
        );
      },
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );

    return _database!;
  }

  Future<void> _onCreate(
    Database db,
    int version,
  ) async {
    for (final statement
        in DatabaseSchema.createStatements) {
      await db.execute(statement);
    }

    for (final statement
        in DatabaseSchema.createIndexStatements) {
      await db.execute(statement);
    }
  }

  Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    await migrate(
      db,
      oldVersion,
      newVersion,
    );
  }

  Future<void> close() async {
    final db = _database;

    if (db != null && db.isOpen) {
      await db.close();
    }

    _database = null;
  }
}
