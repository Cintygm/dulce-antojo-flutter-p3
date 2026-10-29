import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/postre.dart';

/// Fuente "remota" del catálogo.
///
/// Para la actividad no existe un backend real, así que se simula un
/// servidor: se espera un pequeño retardo de red y se lee un JSON.
/// El repositorio solo llama a esta clase cuando hay internet.
class CatalogoApi {
  Future<List<Postre>> obtenerPostres() async {
    await Future.delayed(const Duration(milliseconds: 700));
    final raw = await rootBundle.loadString('assets/data/catalogo.json');
    final lista = jsonDecode(raw) as List<dynamic>;
    return lista
        .map((e) => Postre.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
