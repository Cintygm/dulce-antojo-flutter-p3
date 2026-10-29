import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'screens/detail_screen.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';

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
      theme: AppTheme.light,
      // Rutas con nombre de la app
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => const HomeScreen(),
        '/detalle': (context) => const DetailScreen(),
      },
    );
  }
}
