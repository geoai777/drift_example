import 'package:drift/drift.dart';

import 'connection/connection.dart' as impl;

part 'books_dao.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [Books, Categories],
  daos: [BooksDao]
)
class DatabaseCoreDao extends _$DatabaseCoreDao {
  DatabaseCoreDao(): super(impl.connect());

  @override
  int get schemaVersion => 1;


}