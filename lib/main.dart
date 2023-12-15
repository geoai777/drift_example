import 'package:drift_postgres/drift_postgres.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:postgres/postgres.dart';

import 'core/router.dart';
import 'drift/db/database.dart';
import 'drift_dao/db/database.dart';
import 'drift_postgres/db/database.dart';
import 'drift_postgres/db/db_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// Run flutter application
  runApp(
    MultiProvider(providers: [
      Provider<DatabaseCore>(create: (_) => DatabaseCore()),
      Provider<BooksDao>(create: (_) => BooksDao(DatabaseCoreDao())),
      Provider<DatabasePostgres>(create: (_) => DatabasePostgres(
        PgDatabase(
          endpoint: Endpoint(
          host: pgHost,
          database: pgDatabase,
          username: pgUser,
          password: pgPassword
        ),
        settings: const ConnectionSettings(
        /// If you expect to talk to a Postgres database over a public connection,
        /// please use SslMode.verifyFull instead.
        sslMode: SslMode.disable,
  )
      ))),
    ],
      child: Launcher(
          appRouter: AppRouter()
      )
    )
  );
}

class Launcher extends StatelessWidget {
  final AppRouter appRouter;

  const Launcher({super.key, required this.appRouter});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(
              fontSize: 24.0,
              fontFamily: 'RobotoMono'
          ),
          labelLarge: TextStyle(
            fontSize: 22.0
          )


        )
      ),
      onGenerateRoute: appRouter.onGenerateRoute,
    );
  }
}
