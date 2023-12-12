import 'package:drift/drift.dart';
import 'package:drift_postgres/drift_postgres.dart';

import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(
    tables: [Books, Categories]
)
class DatabaseCore extends _$DatabaseCore {
  DatabaseCore(super.e);

  @override
  int get schemaVersion => 2023121201;

  /// -[ data functions ]--
  /// common functions for data manipulations are:
  /// - get all items from database
  ///   in our case [OrderingTerm] sorts items by name
  Future<List<Book>> getAll() => (select(books)
    ..orderBy([(item) => OrderingTerm(expression: item.name)]))
      .get();

  /// - get single item from database
  Future<Book> getOne(name) {
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