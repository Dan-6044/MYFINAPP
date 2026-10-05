import 'package:sqflite/sqflite.dart';

import 'database_schema.dart';

Future<void> migrate(Database db, int oldVersion, int newVersion) async {
  if (oldVersion < 1) {
    for (final statement in DatabaseSchema.createStatements) {
      await db.execute(statement);
    }
    for (final statement in DatabaseSchema.createIndexStatements) {
      await db.execute(statement);
    }
  }

  if (oldVersion < 2) {
    // Future non-destructive migration for version 2.
  }
}
