import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../providers/connectivity_provider.dart';

/// Banner global de conectividad.
///
/// Se coloca una sola vez en `MaterialApp.builder`, así aparece sobre
/// TODAS las pantallas sin repetir código:
/// - Rojo mientras no hay internet ("Sin conexión · modo offline").
/// - Verde durante 3 s cuando la conexión vuelve.
class OfflineBanner extends StatefulWidget {
  final Widget child;

  const OfflineBanner({super.key, required this.child});

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner> {
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final red = context.watch<ConnectivityProvider>();
    final mostrarOffline = !red.enLinea;
    final mostrarOnline = red.enLinea && red.recienReconectado;

    if (mostrarOnline) {
      _timer?.cancel();
      _timer = Timer(const Duration(seconds: 3), () {
        if (mounted) red.ocultarAvisoReconexion();
      });
    }

    return Stack(
      children: [
        widget.child,
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: SafeArea(
            top: false,
            child: AnimatedSlide(
              offset: (mostrarOffline || mostrarOnline)
                  ? Offset.zero
                  : const Offset(0, 2),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Material(
                  elevation: 6,
                  borderRadius: BorderRadius.circular(30),
                  color: mostrarOffline ? AppColors.alerta : AppColors.hoja,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          mostrarOffline ? Icons.wifi_off : Icons.wifi,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            mostrarOffline
                                ? 'Sin conexión · trabajando en modo offline'
                                : 'Conexión restablecida',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
