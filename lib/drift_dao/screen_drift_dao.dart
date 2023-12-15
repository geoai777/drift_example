import 'dart:math';

import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'db/database.dart';

class DriftDaoScreen extends StatefulWidget {
  final String title;
  final Color color;

  const DriftDaoScreen({super.key, required this.title, required this.color});

  @override
  State<DriftDaoScreen> createState() => _DriftDaoScreenState();
}

class _DriftDaoScreenState extends State<DriftDaoScreen> {

  /// In real life, widget [Consumer] should be removed
  /// and daoProvider replaced with _db from below
  // final BooksDao _db = BooksDao(DatabaseCoreDao());


  @override
  Widget build(BuildContext context) {
    return Consumer<BooksDao>(builder: (context, daoProvider, child) {
      /// Use [FutureBuilder] class to run async functions inside sync widget
      return FutureBuilder<List<Widget>>(

          /// under [future] we pass function that will return data
          future: databaseInteractionExample(daoProvider),

          /// [builder] handles state changes
          builder:
              (BuildContext context, AsyncSnapshot<List<Widget>> snapshot) {
            /// variable to store data returned from widget
            /// in this case it's list of widgets to be displayed
            List<Widget> printMe = [];

            /// as long as we have sync widget we need to get snapshot
            /// of function state. i.e. we periodically get function state,
            /// errors and data if available
            ///
            /// While function have not completed execution, we display
            /// 'waiting for data'
            if (snapshot.connectionState == ConnectionState.waiting) {
              printMe.add(const Text('Waiting for data...'));
            } else {
              /// in case of error we display error information
              /// for example if we try to write two items with equal ids
              /// we get error
              if (snapshot.hasError) {
                printMe.add(Text('Error! ${snapshot.error}'));
              } else {
                /// return data or text message if no data is available
                printMe =
                    snapshot.data ?? [const Text('no data was returned!')];
              }
            }

            /// Simple theming stuff
            return Scaffold(
                appBar: AppBar(
                  title: Text(widget.title),
                  backgroundColor: widget.color,
                ),
                body: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      /// here output is printed
                      children: printMe),
                ));
          });
    });
  }
}

/// Function that illustrates database interactions
/// requires database instance as argument
Future<List<Text>> databaseInteractionExample(BooksDao booksDao) async {
  /// List of Text widgets to return for display
  List<Text> output = <Text>[];

  const Book book = Book(id: 0, name: 'Drift in databases');
  const List<String> bookNames = [
    'Drift in action',
    'Flutter database absctractions with Drift',
    'Drift, dart and flutter',
    'Reactive programming for everyone'
  ];
  final random = Random();

  final String bookName = bookNames[random.nextInt(bookNames.length)];

  output.add(const Text('-[ Initial database contents: ]--'));
  output.add(Text((await booksDao.getAll()).toString()));
  output.add(const Text('-[ removing ]--'));
  await booksDao.remove(book);
  output.add(const Text('-[ Adding ]--'));
  output.add(Text(book.toString()));
  await booksDao.insert(name: bookName);
  output.add(const Text('-[ New database contents ]--'));
  output.add(Text((await booksDao.getAll()).toString()));

  return output;
}
