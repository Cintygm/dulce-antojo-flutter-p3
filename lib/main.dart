import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'data/repositories/catalogo_repository.dart';
import 'data/repositories/reserva_repository.dart';
import 'providers/catalogo_provider.dart';
import 'providers/reserva_provider.dart';
import 'screens/detail_screen.dart';
import 'screens/home_screen.dart';
import 'screens/reservas_screen.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    // Inyección de dependencias: la UI recibe los providers ya construidos.
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CatalogoProvider(CatalogoRepository()),
        ),
        ChangeNotifierProvider(
          create: (_) => ReservaProvider(ReservaRepository()),
        ),
      ],
      child: const MoraYMielApp(),
    ),
  );
}

class MoraYMielApp extends StatelessWidget {
  const MoraYMielApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mora & Miel',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => const HomeScreen(),
        '/detalle': (context) => const DetailScreen(),
        '/reservas': (context) => const ReservasScreen(),
      },
    );
  }
}
