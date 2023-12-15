import 'dart:math';

/// this will be required if used without [provider]
// import 'package:drift_postgres/drift_postgres.dart';
// import 'package:postgres/postgres.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import 'db/database.dart';
import 'db/db_config.dart';

/// /!\ WARNING! This will NOT work on Web component

class DriftPostgresScreen extends StatefulWidget {
  final String title;
  final Color color;

  const DriftPostgresScreen(
      {super.key, required this.title, required this.color});

  @override
  State<DriftPostgresScreen> createState() => _DriftPostgresScreen();
}


class _DriftPostgresScreen extends State<DriftPostgresScreen> {
  /// In real life, widget [Consumer] should be removed
  /// and databasePostgres replaced with _db from below
  // final DatabasePostgres _db = DatabasePostgres(
  //   PgDatabase(
  //     endpoint: Endpoint(
  //       host: pgHost,
  //       database: pgDatabase,
  //       username: pgUser,
  //       password: pgPassword
  //     ),
  //     settings: const ConnectionSettings(
  //       /// If you expect to talk to a Postgres database over a public connection,
  //       /// please use SslMode.verifyFull instead.
  //       sslMode: SslMode.disable,
  //     ),
  //   )
  // );


  @override
  Widget build(BuildContext context) {

    return Consumer<DatabasePostgres>(
      builder: (context, databasePostgres, child) {

    /// Use [FutureBuilder] class to run async functions inside sync widget
    return FutureBuilder<List<Widget>>(

        /// under [future] we pass function that will return data
        future: databaseInteractionExample(databasePostgres),

        /// [builder] handles state changes
        builder: (BuildContext context, AsyncSnapshot<List<Widget>> snapshot) {
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
              printMe = snapshot.data ?? [const Text('no data was returned!')];
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
                child: SingleChildScrollView (
                  child:
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    /// here output is printed
                    children: printMe),
                )
              ));
        });
      }
    );

  }
}

/// Function that illustrates database interactions
/// requires database instance as argument
Future<List<Text>> databaseInteractionExample(DatabasePostgres databaseCore) async {
  /// List of Text widgets to return for display
  List<Text> output = <Text>[];

  Book book;

  const List<String> bookNames = [
    'Drift in action',
    'Flutter database absctractions with Drift',
    'Drift, dart and flutter',
    'Reactive programming for everyone'
  ];
  final random = Random();

  final String bookName = bookNames[random.nextInt(bookNames.length)];

  output.add(const Text('-[ Initial database contents: ]--'));
  output.add(Text((databaseCore.getAll().toString())));
  try {
    book = await databaseCore.getOne('Drift, dart and flutter');
    output.add(const Text('-[ removing ]--'));
    await databaseCore.remove(book);
    output.add(const Text('-[ Adding ]--'));
    output.add(Text(book.toString()));
  } catch (e){
    print(e);
  }
  await databaseCore.insert(name: bookName);
  output.add(const Text('-[ New database contents ]--'));
  output.add(Text((await databaseCore.getAll()).toString()));

  return output;
}
