import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../providers/catalogo_provider.dart';
import '../providers/reserva_provider.dart';
import '../services/connectivity_service.dart';

/// Pantalla de carga de la marca.
///
/// Continúa visualmente el splash nativo (mismo fondo mora y mismo logo)
/// y muestra una animación corta antes de abrir el catálogo.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();

  late final Animation<double> _escala = CurvedAnimation(
    parent: _ctrl,
    curve: Curves.easeOutBack,
  );

  @override
  void initState() {
    super.initState();
    // Se inicia después del primer frame para no notificar cambios
    // de estado mientras el árbol de widgets se está construyendo.
    WidgetsBinding.instance.addPostFrameCallback((_) => _iniciar());
  }

  /// Carga inicial mientras se muestra la animación: catálogo y reservas
  /// guardadas. Se esperan en paralelo con Future.wait.
  Future<void> _iniciar() async {
    final red = context.read<ConnectivityService>();
    final catalogo = context.read<CatalogoProvider>();
    final reservas = context.read<ReservaProvider>();
    // Primero sabemos si hay internet para decidir red o caché.
    await red.iniciar();
    await Future.wait([
      Future.delayed(const Duration(milliseconds: 1600)),
      catalogo.cargar(),
      reservas.cargar(),
    ]);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mora,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: _escala,
              child: Image.asset('assets/branding/logo.png', width: 160),
            ),
            const SizedBox(height: 20),
            FadeTransition(
              opacity: _ctrl,
              child: const Column(
                children: [
                  Text(
                    'Mora & Miel',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Pastelería artesanal',
                    style: TextStyle(color: AppColors.miel, fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                color: AppColors.miel,
                strokeWidth: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
