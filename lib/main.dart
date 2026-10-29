import 'package:flutter/material.dart';

import 'screens/detail_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const DulceAntojoApp());
}

class DulceAntojoApp extends StatelessWidget {
  const DulceAntojoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dulce Antojo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.pink),
      // Rutas con nombre de la app
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/detalle': (context) => const DetailScreen(),
      },
    );
  }
}
