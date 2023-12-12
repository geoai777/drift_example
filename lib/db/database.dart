import 'package:drift/drift.dart';

// import connection handling libraries
import 'connection/connection.dart' as impl;

import 'tables.dart';

/// to speed up database operation `database.g.dart` needs to be pre compiled
/// actions:
/// - create all tables, dao and custom sql includes (see below)
/// - run `dart run build_runner build` in terminal
part 'database.g.dart';

/// primary database class should be annotated with @DriftDatabase
/// annotation should include:
/// - tables (mandatory)
/// - daos (optional)
/// - sql includes (optional)
@DriftDatabase(
  tables: [Books, Categories],
)
/// database class can have any name, this on called DatabaseCore
class DatabaseCore extends _$DatabaseCore {

  /// Constructor should pass to superclass means to connect database
  /// in this case it's function that allows auto detect which type of
  /// application is used: web or native
  /// /!\ In case of web database, sqlite will run in browser, this means
  /// - sqlite3.wasm and drift_worker.js files are required to be placed in
  ///   /web folder. (see https://drift.simonbinder.eu/web/)
  /// - database will exist only while app is running, it will not persist on
  ///   restart
  DatabaseCore(): super(impl.connect());

  /// getter [schemaVersion] is used to determine is database upgrade is requird
  @override
  int get schemaVersion => 1;

  /// Migration strategy controls:
  /// - how tables are filled with data initially
  /// - how database and data is altered during upgrade (i.e. when schemaVersion
  ///   is changed)
  /// - allows set custom options (here enable foreign keys in tables)
  @override
  MigrationStrategy get migration => MigrationStrategy(
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
      },
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from == 1) {
          // Todo: make migration rules sane
          print('Migration from version 1');
        }
      }
  );

  /// -[ data functions ]--
  /// common functions for data manipulations are:
  /// - get all items from database
  ///   in our case [OrderingTerm] sorts items by name
  Future<List<Book>> getAll() => (select(books)
    ..orderBy([(item) => OrderingTerm(expression: item.name)]))
    .get();

  /// - get single item from database
  Future getOne(name) {
    return (
        select(books)
          ..where((item) => item.name.equals(name))
    ).getSingle();
  }

  /// - insert item in database
  ///   /!\ Due to architecture drift creates data object with required parameters
  ///   this means, that even if in tables we specify AutoIncrement field,
  ///   our object (in this case Book) will have this field as required.
  ///   To insert data there is a Companion (here [BookCompanion]) method.
  ///   this method is generated for every table while database.g.dart is
  ///   compiled.
  ///
  ///   In example below name is passed as String, and optionals passed wrapped
  ///   in Value.
  insert({
    required String name,
    String? description,
    int? category}
  ) => into(books).insert(
          BooksCompanion.insert(
          name: name,
          description: Value(description),
          category: Value(category)
      )
    );

  /// - update item
  ///   To edit entry first we need to
  ///   - use [getOne] (see method above) and get item to be updated
  ///   - create new object (here new Book)
  ///   - use old book id and edit other fields required to be updated
  ///     see example below:
  ///     final Book oldBook = await getOne('dart in pictures');
  ///     final Book newBook = Book(
  ///       id: oldBook.id,
  ///       name: 'dart in colors',
  ///       description: oldBook.description  // we don't change it
  ///       category: oldBook.category
  ///     );
  ///     await edit(newBook); // update in database
  Future edit(Book item) => update(books).replace(item);

  /// - remove item
  Future remove(Book item) => delete(books).delete(item);

}