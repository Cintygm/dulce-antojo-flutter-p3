import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../data/models/reserva.dart';
import '../providers/reserva_provider.dart';

/// Pantalla 3: historial de reservas guardadas en el dispositivo.
class ReservasScreen extends StatelessWidget {
  const ReservasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reservas = context.watch<ReservaProvider>().reservas;

    return Scaffold(
      appBar: AppBar(title: const Text('Mis reservas')),
      body: reservas.isEmpty
          ? const Center(child: Text('Aún no tienes reservas'))
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: reservas.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) => _ReservaTile(reserva: reservas[i]),
            ),
    );
  }
}

class _ReservaTile extends StatelessWidget {
  final Reserva reserva;

  const _ReservaTile({required this.reserva});

  @override
  Widget build(BuildContext context) {
    final pendiente = reserva.estado == EstadoReserva.pendiente;
    final foto = reserva.fotoPath;
    final f = reserva.fecha;
    final fecha =
        '${f.day.toString().padLeft(2, '0')}/${f.month.toString().padLeft(2, '0')} '
        '${f.hour.toString().padLeft(2, '0')}:${f.minute.toString().padLeft(2, '0')}';

    return Card(
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: foto != null && File(foto).existsSync()
              ? Image.file(File(foto), width: 52, height: 52, fit: BoxFit.cover)
              : Container(
                  width: 52,
                  height: 52,
                  color: AppColors.mora.withValues(alpha: 0.1),
                  child: const Icon(Icons.cake, color: AppColors.mora),
                ),
        ),
        title: Text('${reserva.cantidad} × ${reserva.nombrePostre}'),
        subtitle: Text(
          '${reserva.cliente} · $fecha · \$${reserva.total.toStringAsFixed(2)}',
        ),
        trailing: Chip(
          visualDensity: VisualDensity.compact,
          label: Text(pendiente ? 'Pendiente' : 'Confirmada'),
          labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
          backgroundColor: pendiente ? AppColors.miel : AppColors.hoja,
          side: BorderSide.none,
        ),
      ),
    );
  }
}
