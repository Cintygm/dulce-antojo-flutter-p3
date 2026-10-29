import 'package:flutter/material.dart';

import 'screens/detail_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MoraYMielApp());
}

class MoraYMielApp extends StatelessWidget {
  const MoraYMielApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mora & Miel',
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
