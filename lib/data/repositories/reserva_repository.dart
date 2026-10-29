import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/reserva.dart';

/// Persistencia local de las reservas (sobrevive al cierre de la app).
class ReservaRepository {
  static const _kReservas = 'reservas';

  Future<List<Reserva>> cargar() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kReservas);
    if (raw == null) return [];
    return (jsonDecode(raw) as List<dynamic>)
        .map((e) => Reserva.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> guardarTodas(List<Reserva> reservas) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kReservas,
      jsonEncode(reservas.map((r) => r.toJson()).toList()),
    );
  }
}
