import 'package:flutter/material.dart';
import '../screen_launcher.dart';
import '../drift/screen_drift.dart';
import '../drift_dao/screen_drift_dao.dart';
import '../drift_postgres/screen_postgres.dart';

class AppRouter{
  Route onGenerateRoute(RouteSettings routeSettings) {
    const fontSize = 24.0;

    switch (routeSettings.name) {
      case '/':
        return MaterialPageRoute(
            builder: (_) => const LauncherScreen(
              title: 'Drift usage example scenarios',
              color: Colors.grey,
            )
        );
        break;
      case '/common':
        return MaterialPageRoute(
            builder: (_) => const DriftScreen(
              title: 'Common dart usage example',
              color: Colors.lightGreen
            )
        );
        break;
      case '/dao':
        return MaterialPageRoute(
            builder: (_) => const DriftDaoScreen(
              title: 'Admin panel',
              color: Colors.orangeAccent,
            )
        );
        break;
      case '/postgres':
        return MaterialPageRoute(
            builder: (_) => const DriftPostgresScreen(
              title: 'Categories',
              color: Color(0xff30648c),
            )
        );
        break;
      default:
        throw UnimplementedError();
    }
  }
}