import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Vista del estado "Cargando": ícono de la marca, indicador y mensaje.
class VistaCargando extends StatelessWidget {
  const VistaCargando({super.key, this.mensaje = 'Cargando...'});

  final String mensaje;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              const SizedBox(
                width: 72,
                height: 72,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: AppColors.miel,
                ),
              ),
              Icon(
                Icons.cake_outlined,
                size: 32,
                color: AppColors.mora.withValues(alpha: 0.8),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            mensaje,
            style: const TextStyle(
              color: AppColors.moraClaro,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Vista del estado "Error": distingue la falta de internet de otros
/// fallos y ofrece una acción para recuperarse.
class VistaError extends StatelessWidget {
  const VistaError({
    super.key,
    required this.mensaje,
    required this.esDeRed,
    required this.onReintentar,
  });

  final String mensaje;
  final bool esDeRed;
  final VoidCallback onReintentar;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 44,
              backgroundColor: AppColors.alerta.withValues(alpha: 0.10),
              child: Icon(
                esDeRed ? Icons.wifi_off_rounded : Icons.error_outline,
                size: 44,
                color: AppColors.alerta,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              esDeRed ? 'Estás sin conexión' : 'Algo salió mal',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.cacao,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.cacao.withValues(alpha: 0.7)),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onReintentar,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'También puedes deslizar hacia abajo para actualizar',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.cacao.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
