import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/models/postre.dart';
import '../data/models/reserva.dart';
import '../data/repositories/reserva_repository.dart';
import '../services/connectivity_service.dart';
import '../services/notification_service.dart';

/// Gestiona las reservas: crear, listar, guardar y sincronizar.
///
/// Estrategia offline-first:
/// - Con internet la reserva se "envía" y queda [EstadoReserva.confirmada].
/// - Sin internet se guarda como [EstadoReserva.pendiente] en el dispositivo.
/// - Al volver la conexión, las pendientes se sincronizan automáticamente.
class ReservaProvider extends ChangeNotifier {
  final ReservaRepository _repo;
  final ConnectivityService _red;
  final NotificationService _notificaciones;
  late final StreamSubscription<EstadoRed> _sub;
  bool _sincronizando = false;

  ReservaProvider(this._repo, this._red, this._notificaciones) {
    _sub = _red.cambios.listen((estado) {
      if (estado == EstadoRed.enLinea) sincronizarPendientes();
    });
  }

  List<Reserva> _reservas = [];
  List<Reserva> get reservas => List.unmodifiable(_reservas.reversed);
  int get pendientes =>
      _reservas.where((r) => r.estado == EstadoReserva.pendiente).length;

  Future<void> cargar() async {
    _reservas = await _repo.cargar();
    notifyListeners();
    if (_red.enLinea) await sincronizarPendientes();
  }

  Future<Reserva> crearReserva({
    required Postre postre,
    required String cliente,
    required int cantidad,
    String? fotoPath,
  }) async {
    final online = _red.enLinea;
    if (online) await _enviarAlServidor();

    final reserva = Reserva(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      codigoPostre: postre.codigo,
      nombrePostre: postre.nombre,
      cliente: cliente,
      cantidad: cantidad,
      total: postre.precio * cantidad,
      fecha: DateTime.now(),
      estado: online ? EstadoReserva.confirmada : EstadoReserva.pendiente,
      fotoPath: fotoPath,
    );
    _reservas.add(reserva);
    await _repo.guardarTodas(_reservas);
    notifyListeners();

    // Notificación local según el resultado.
    if (online) {
      await _notificaciones.reservaConfirmada(
        postre: postre.nombre,
        cantidad: cantidad,
        cliente: cliente,
        total: reserva.total,
      );
    } else {
      await _notificaciones.reservaGuardadaOffline(postre: postre.nombre);
    }
    return reserva;
  }

  /// Envía las reservas pendientes. Devuelve cuántas se sincronizaron.
  Future<int> sincronizarPendientes() async {
    // Bandera para evitar dos sincronizaciones simultáneas (concurrencia).
    if (_sincronizando || pendientes == 0) return 0;
    _sincronizando = true;
    var enviadas = 0;
    try {
      for (var i = 0; i < _reservas.length; i++) {
        if (_reservas[i].estado != EstadoReserva.pendiente) continue;
        if (!_red.enLinea) break; // se volvió a caer la red
        await _enviarAlServidor();
        _reservas[i] = _reservas[i].copyWith(estado: EstadoReserva.confirmada);
        enviadas++;
      }
      if (enviadas > 0) {
        await _repo.guardarTodas(_reservas);
        notifyListeners();
        await _notificaciones.reservasSincronizadas(enviadas);
      }
    } finally {
      _sincronizando = false;
    }
    return enviadas;
  }

  /// Simula la latencia de enviar la reserva a un servidor.
  Future<void> _enviarAlServidor() =>
      Future.delayed(const Duration(milliseconds: 600));

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
