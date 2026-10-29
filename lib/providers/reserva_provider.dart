import 'package:flutter/foundation.dart';

import '../data/models/postre.dart';
import '../data/models/reserva.dart';
import '../data/repositories/reserva_repository.dart';

/// Gestiona las reservas: crear, listar y guardar en el dispositivo.
class ReservaProvider extends ChangeNotifier {
  final ReservaRepository _repo;

  ReservaProvider(this._repo);

  List<Reserva> _reservas = [];
  List<Reserva> get reservas => List.unmodifiable(_reservas.reversed);

  Future<void> cargar() async {
    _reservas = await _repo.cargar();
    notifyListeners();
  }

  Future<Reserva> crearReserva({
    required Postre postre,
    required String cliente,
    required int cantidad,
    String? fotoPath,
  }) async {
    final reserva = Reserva(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      codigoPostre: postre.codigo,
      nombrePostre: postre.nombre,
      cliente: cliente,
      cantidad: cantidad,
      total: postre.precio * cantidad,
      fecha: DateTime.now(),
      estado: EstadoReserva.confirmada,
      fotoPath: fotoPath,
    );
    _reservas.add(reserva);
    await _repo.guardarTodas(_reservas);
    notifyListeners();
    return reserva;
  }
}
