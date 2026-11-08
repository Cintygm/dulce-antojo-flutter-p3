import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/navegacion.dart';
import 'core/theme/app_theme.dart';
import 'data/models/receta.dart';
import 'data/repositories/catalogo_repository.dart';
import 'data/repositories/recetas_repository.dart';
import 'data/repositories/reserva_repository.dart';
import 'providers/catalogo_provider.dart';
import 'providers/connectivity_provider.dart';
import 'providers/receta_detalle_provider.dart';
import 'providers/recetas_provider.dart';
import 'providers/reserva_provider.dart';
import 'screens/detail_screen.dart';
import 'screens/home_screen.dart';
import 'screens/receta_detalle_screen.dart';
import 'screens/recetas_screen.dart';
import 'screens/reservas_screen.dart';
import 'screens/splash_screen.dart';
import 'services/connectivity_service.dart';
import 'services/image_service.dart';
import 'services/notification_service.dart';
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
        Provider(create: (_) => NotificationService()),
        // Parte 3: API pública de recetas (capa de datos).
        Provider(create: (_) => RecetasRepository()),
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
            ctx.read<NotificationService>(),
          ),
        ),
        // Se crea al abrir el recetario por primera vez y descarga la lista.
        ChangeNotifierProvider(
          create: (ctx) =>
              RecetasProvider(ctx.read<RecetasRepository>())..cargar(),
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
      navigatorKey: navigatorKey,
      theme: AppTheme.light,
      // El banner de conectividad envuelve a todas las pantallas.
      builder: (context, child) => OfflineBanner(child: child!),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => const HomeScreen(),
        '/detalle': (context) => const DetailScreen(),
        '/reservas': (context) => const ReservasScreen(),
        '/recetas': (context) => const RecetasScreen(),
        '/receta': (context) {
          // Cada detalle tiene su propio provider: se crea al entrar y se
          // destruye al salir, junto con su petición HTTP.
          final resumen =
              ModalRoute.of(context)!.settings.arguments as RecetaResumen;
          return ChangeNotifierProvider(
            create: (ctx) => RecetaDetalleProvider(
              ctx.read<RecetasRepository>(),
              resumen.id,
            )..cargar(),
            child: RecetaDetalleScreen(resumen: resumen),
          );
        },
      },
    );
  }
}
