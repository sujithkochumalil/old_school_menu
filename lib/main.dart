import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'screens/menu_screen.dart';
import 'theme/app_theme.dart';

const defaultRestaurant = 'old-school-tea';

void main() {
  usePathUrlStrategy();
  runApp(const MenuApp());
}

class MenuApp extends StatelessWidget {
  const MenuApp({super.key});

  @override
  Widget build(BuildContext context) {
    // URL looks like  /r/old-school-tea?t=5
    final segments = Uri.base.pathSegments.where((s) => s.isNotEmpty).toList();
    String id = defaultRestaurant;
    if (segments.isNotEmpty) id = '';
    if (segments.length == 2 && segments[0] == 'r') id = segments[1];
    final table = Uri.base.queryParameters['t'];

    return MaterialApp(
      title: 'Menu',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      onGenerateInitialRoutes: (_) => [
        MaterialPageRoute(builder: (_) => MenuScreen(restaurantId: id, table: table)),
      ],
      onGenerateRoute: (_) => MaterialPageRoute(
        builder: (_) => MenuScreen(restaurantId: id, table: table),
      ),
    );
  }
}
