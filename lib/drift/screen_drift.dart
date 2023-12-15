import 'dart:math';

import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/core/snackbar.dart';
import 'db/database.dart';

class DriftScreen extends StatefulWidget {
  final String title;
  final Color color;

  const DriftScreen({
    super.key,
    required this.title,
    required this.color,
  });

  @override
  State<DriftScreen> createState() => _DriftScreenState();
}

class _DriftScreenState extends State<DriftScreen> {
  /// In real life, widget [Consumer] should be removed
  /// and databaseProvider replaced with _db from below
  // final databaseCore _db = DatabaseCore();

  @override
  Widget build(BuildContext context) {
    /// Use [FutureBuilder] class to run async functions inside sync widget
    return Consumer<DatabaseCore>(builder: (context, databaseProvider, child) {

      return FutureBuilder<List<Widget>>(

          /// under [future] we pass function that will return data
          future: databaseInteractionExample(databaseProvider),

          /// [builder] handles state changes
          builder:
              (BuildContext context, AsyncSnapshot<List<Widget>> snapshot) {

            String connectionState = '';
            List<Widget> dbContent = <Widget>[];

            /// as long as we have sync widget we need to get snapshot
            /// of function state. i.e. we periodically get function state,
            /// errors and data if available
            ///
            /// While function have not completed execution, we display
            /// 'waiting for data'
            connectionState = snapshot.connectionState.name;

            if (snapshot.connectionState != ConnectionState.waiting) {
              /// in case of error we display error information
              /// for example if we try to write two items with equal ids
              /// we get error
              if (snapshot.hasError) {
                connectionState = snapshot.error.toString();
              } else {
                if (snapshot.data == null) {
                  dbContent = [const Text('database is empty')];
                } else {
                  /// return data or text message if no data is available
                  dbContent = snapshot.data ?? [];
                }
              }
            }

            const double buttonBorder = 5.0;
            const double buttonHeight = 75.0;
            final double buttonWidth = (MediaQuery.of(context).size.width - 20) / 2;

            /// variable to store data returned from widget
            /// in this case it's list of widgets to be displayed
            List<Widget> printMe = [
              Row(
                children: <Widget>[
                  const Text('Connection: '),
                  Text(connectionState)
                ],
              ),
              const SizedBox(height: 20,),
              Container(
                height: MediaQuery.of(context).size.height /2,
                color: const Color(0xfff6ffeb),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: dbContent,
                ),
              ),
              const Spacer(),
              Row(
                /// control buttons here
                children: <Widget>[

                  /// Leftmost button to that will add random book to database
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(buttonBorder)
                          ),
                          minimumSize: Size(buttonWidth, buttonHeight)
                      ),
                      onPressed: () {

                        /// list of book names to add
                        const List<String> bookNames = [
                          'Drift in action',
                          'Flutter database abstractions with Drift',
                          'Drift, dart and flutter',
                          'Reactive programming for everyone'
                        ];
                        final random = Random();

                        final String bookName = bookNames[random.nextInt(bookNames.length)];

                        FutureBuilder(
                              future: databaseWrite(databaseProvider, context, bookName),
                              builder: (BuildContext context, snapshot) {
                                return const Text('');
                              }
                          );
                        setState(() {});
                      },
                      child: const Text('Add random book to database')
                  ),
                  const SizedBox(width: 10,),

                  /// button to remove item from database
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(buttonBorder)
                          ),
                          minimumSize: Size(buttonWidth, buttonHeight)
                      ),
                      onPressed: () {
                        FutureBuilder(
                          future: databaseRemove(databaseProvider, context),
                          builder: (BuildContext context, snapshot) {
                            return const Text('Text');
                          }
                        );
                        setState(() {});
                      },
                      child: const Text('Remove first book')
                  ),
                ],
              )
            ];



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

databaseWrite(DatabaseCore databaseCore, BuildContext context, String name) async {

  if(!context.mounted) return;
  try {
    await databaseCore.insert(name: name);
    if(!context.mounted) return;
    showSnackBar(context, text: 'Book $name added', duration: 1);
  } catch (e) {
    if(!context.mounted) return;
    showSnackBar(context, text: e.toString(), duration: 2);
  }
}

databaseRemove(DatabaseCore databaseCore, BuildContext context) async {
  try {
    List<Book> allBooks = await databaseCore.getAll();
    if (allBooks.isNotEmpty) {
      await databaseCore.remove(allBooks[0]);
      if(!context.mounted) return;
      showSnackBar(context, text: 'Book ${allBooks[0].toString()} removed', duration: 1);
    }
  } catch (e) {
    if(!context.mounted) return;
    showSnackBar(context, text: e.toString(), duration: 2);
  }
}

/// Function that illustrates database interactions
/// requires database instance as argument
Future<List<Widget>> databaseInteractionExample(
    DatabaseCore databaseCore) async {
  /// List of Text widgets to return for display
  List<Widget> output = [];

  /// get current database contents and transform to list of widgets
  final List<Book> allBooksInDb = await databaseCore.getAll();
  List<Widget> bookWidgetList = List.generate(
      allBooksInDb.length,
      (index) => Text(allBooksInDb[index].toString())
  );

  output = bookWidgetList;
  ///


  // for(dynamic item in await (databaseCore.getAll())){
  //   databaseContents.add(Text(item.toString()));
  // }
  // output.add(
  //   ListView(
  //     children: databaseContents,
  //   )
  // );

  // output.add(const Text('-[ Initial database contents: ]--'));
  // output.add(Text((await databaseCore.getAll()).toString()));
  // output.add(const Text('-[ removing ]--'));
  // await databaseCore.remove(book);
  // output.add(const Text('-[ Adding ]--'));
  // output.add(Text(book.toString()));
  // await databaseCore.insert(name: bookName);
  // output.add(const Text('-[ New database contents ]--'));
  // output.add(Text((await databaseCore.getAll()).toString()));

  return output;
}
