import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'data/repositories/catalogo_repository.dart';
import 'data/repositories/reserva_repository.dart';
import 'providers/catalogo_provider.dart';
import 'providers/connectivity_provider.dart';
import 'providers/reserva_provider.dart';
import 'screens/detail_screen.dart';
import 'screens/home_screen.dart';
import 'screens/reservas_screen.dart';
import 'screens/splash_screen.dart';
import 'services/connectivity_service.dart';
import 'services/image_service.dart';
import 'services/permission_service.dart';
import 'widgets/offline_banner.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    // Inyección de dependencias: la UI recibe los providers ya construidos.
    MultiProvider(
      providers: [
        // Servicios nativos (capa de servicios, sin UI).
        Provider<ConnectivityService>(
          create: (_) => ConnectivityService()..iniciar(),
          dispose: (_, s) => s.dispose(),
        ),
        Provider(create: (_) => PermissionService()),
        Provider(create: (_) => ImageService()),
        // Estado para la UI (capa de providers).
        ChangeNotifierProvider(
          create: (ctx) => ConnectivityProvider(ctx.read<ConnectivityService>()),
        ),
        ChangeNotifierProvider(
          create: (ctx) => CatalogoProvider(
            CatalogoRepository(),
            ctx.read<ConnectivityService>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (ctx) => ReservaProvider(
            ReservaRepository(),
            ctx.read<ConnectivityService>(),
          ),
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
      // El banner de conectividad envuelve a todas las pantallas.
      builder: (context, child) => OfflineBanner(child: child!),
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
