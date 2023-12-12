import 'dart:math';

import 'package:drift_postgres/drift_postgres.dart';
import 'package:postgres/postgres.dart';
import 'package:flutter/material.dart';

import '/db_postgres/database.dart';
import '/db_postgres/db_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// Run flutter application
  runApp(DriftPostgresExample());
}

/// /!\ WARNING! This will NOT work on Web component

class DriftPostgresExample extends StatelessWidget {
  final DatabaseCore databaseCore = DatabaseCore(
    PgDatabase(
      endpoint: Endpoint(
        host: pgHost,
        database: pgDatabase,
        username: pgUser,
        password: pgPassword
      )
    )
  );

  DriftPostgresExample({super.key});

  @override
  Widget build(BuildContext context) {
    /// Use [FutureBuilder] class to run async functions inside sync widget
    return FutureBuilder<List<Widget>>(

        /// under [future] we pass function that will return data
        future: databaseInteractionExample(databaseCore),

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
          return MaterialApp(
              title: 'Drift example',
              theme: ThemeData(
                  useMaterial3: true,
                  textTheme: const TextTheme(
                      bodyMedium:
                          TextStyle(fontSize: 24.0, fontFamily: 'RobotoMono')),
                  colorScheme: ColorScheme.fromSeed(
                      seedColor: Colors.green, brightness: Brightness.dark)),
              builder: (_, __) {
                return Scaffold(
                    appBar: AppBar(
                      title: const Text('Drift example'),
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
Future<List<Text>> databaseInteractionExample(DatabaseCore databaseCore) async {
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
