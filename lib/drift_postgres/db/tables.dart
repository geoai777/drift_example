import 'package:drift/drift.dart';
import 'package:drift_postgres/drift_postgres.dart';

/// -[ Sqlite3 Tables ]--
/// Data class
/// Use [@DataClassName] to define single unit name.
/// Example: multiple: Categories, single: Category (and not Categorie)
@DataClassName('Book')

/// - .withLength(max: n)
///   Due to architecture of relational databases it is generally a good idea
///   to have fixed max size text fields so memory allocation can be optimal
/// - .unique()
///   uniqueness of values in column can be controlled on SQL level
class Books extends Table with AutoIncrementingPrimaryKey {
  TextColumn get name => text()
      .withLength(max: 64)
      .unique()();

  /// - .nullable()
  ///   nullable fields can be left empty containing no data
  TextColumn get description => text()
      .withLength(max: 256)
      .nullable()();

  /// - .references()
  ///   add foreign key reference from this field
  ///   /!\ By default sqlite3 has this references disabled
  ///   enable in [MigrationStrategy] see database.dart
  ///   beforeOpen: (details) async {
  ///     await customStatement('PRAGMA foreign_keys = ON');
  ///   }
  IntColumn get category => integer()
      .nullable()();
}

@DataClassName('Category')
class Categories extends Table with AutoIncrementingPrimaryKey {
  TextColumn get name => text()
      .withLength(max: 32)();
}

/// To reduce code complexity, similar table columns can be defined via
/// mixins and then added to multiple tables.
/// Example: almost all tables need primary key which named [id] and is
/// auto incremental
mixin AutoIncrementingPrimaryKey on Table {
  UuidColumn get id => customType(PgTypes.uuid)
      .withDefault(genRandomUuid())();
}