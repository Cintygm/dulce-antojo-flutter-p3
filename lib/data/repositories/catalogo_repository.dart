import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/postre.dart';
import '../sources/catalogo_api.dart';

/// Resultado de cargar el catálogo: los datos y de dónde salieron.
class CatalogoResultado {
  final List<Postre> postres;
  final bool desdeCache;
  final DateTime? actualizado;

  const CatalogoResultado(this.postres, {required this.desdeCache, this.actualizado});
}

/// Repositorio del catálogo con estrategia "red primero, caché de respaldo".
///
/// 1. Si hay internet, pide los datos a la API y los guarda en caché.
/// 2. Si no hay internet (o la API falla), devuelve la última copia guardada.
class CatalogoRepository {
  static const _kCache = 'catalogo_cache';
  static const _kFecha = 'catalogo_cache_fecha';

  final CatalogoApi api;

  CatalogoRepository({CatalogoApi? api}) : api = api ?? CatalogoApi();

  Future<CatalogoResultado> obtener({required bool hayInternet}) async {
    final prefs = await SharedPreferences.getInstance();

    if (hayInternet) {
      try {
        final postres = await api.obtenerPostres();
        final ahora = DateTime.now();
        await prefs.setString(
          _kCache,
          jsonEncode(postres.map((p) => p.toJson()).toList()),
        );
        await prefs.setString(_kFecha, ahora.toIso8601String());
        return CatalogoResultado(postres, desdeCache: false, actualizado: ahora);
      } catch (_) {
        // Si la red falla a mitad de camino, seguimos con la caché.
      }
    }

    final raw = prefs.getString(_kCache);
    if (raw == null) {
      throw const CatalogoSinDatosException();
    }
    final fecha = prefs.getString(_kFecha);
    final postres = (jsonDecode(raw) as List<dynamic>)
        .map((e) => Postre.fromJson(e as Map<String, dynamic>))
        .toList();
    return CatalogoResultado(
      postres,
      desdeCache: true,
      actualizado: fecha == null ? null : DateTime.tryParse(fecha),
    );
  }
}

/// No hay internet y tampoco existe una copia guardada (primer uso offline).
class CatalogoSinDatosException implements Exception {
  const CatalogoSinDatosException();

  @override
  String toString() =>
      'Sin conexión y sin datos guardados. Conéctate una vez para descargar el catálogo.';
}
