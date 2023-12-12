import 'package:drift/drift.dart';

import 'connection/connection.dart' as impl;

part 'books_dao.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [Books, Categories],
  daos: [booksDao]
)
class DatabaseCore extends _$DatabaseCore {
  DatabaseCore(): super(impl.connect());

  @override
  int get schemaVersion => 1;


}