import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/receta.dart';
import 'api_exception.dart';

/// Fuente remota REAL de recetas: API pública TheMealDB.
///
/// - Sitio:   https://www.themealdb.com/api.php
/// - Listado: GET https://www.themealdb.com/api/json/v1/1/filter.php?c=Dessert
/// - Detalle: GET https://www.themealdb.com/api/json/v1/1/lookup.php?i=52768
///
/// Es gratuita y no requiere registro, sesión ni token: el "1" de la URL
/// es la clave pública de prueba que la propia API publica para todos.
class RecetasApi {
  RecetasApi({http.Client? cliente}) : _cliente = cliente ?? http.Client();

  static const String baseUrl = 'https://www.themealdb.com/api/json/v1/1';
  static const Duration tiempoMaximo = Duration(seconds: 10);

  final http.Client _cliente;

  /// Lista de postres (solo id, nombre y foto).
  Future<List<RecetaResumen>> obtenerPostres() async {
    final json = await _get('/filter.php?c=Dessert');
    try {
      final meals = json['meals'] as List<dynamic>?;
      if (meals == null) return const [];
      return meals
          .map((e) => RecetaResumen.fromJson(e as Map<String, dynamic>))
          .toList(growable: false);
    } on TypeError {
      throw const ApiException(
        TipoErrorApi.formato,
        'La respuesta del servidor no tiene el formato esperado.',
      );
    } on FormatException {
      throw const ApiException(
        TipoErrorApi.formato,
        'La respuesta del servidor no tiene el formato esperado.',
      );
    }
  }

  /// Receta completa con ingredientes e instrucciones.
  Future<RecetaDetalle> obtenerDetalle(int id) async {
    final json = await _get('/lookup.php?i=$id');
    try {
      final meals = json['meals'] as List<dynamic>?;
      if (meals == null || meals.isEmpty) {
        throw const ApiException(
          TipoErrorApi.noEncontrado,
          'No encontramos esta receta.',
        );
      }
      return RecetaDetalle.fromJson(meals.first as Map<String, dynamic>);
    } on TypeError {
      throw const ApiException(
        TipoErrorApi.formato,
        'La receta llegó incompleta o con un formato inesperado.',
      );
    } on FormatException {
      throw const ApiException(
        TipoErrorApi.formato,
        'La receta llegó incompleta o con un formato inesperado.',
      );
    }
  }

  /// GET asíncrono con tiempo máximo y traducción de errores.
  Future<Map<String, dynamic>> _get(String ruta) async {
    final http.Response respuesta;
    try {
      respuesta = await _cliente
          .get(Uri.parse('$baseUrl$ruta'))
          .timeout(tiempoMaximo);
    } on SocketException {
      throw const ApiException(
        TipoErrorApi.sinConexion,
        'Sin conexión a internet. Revisa tu Wi-Fi o datos móviles.',
      );
    } on TimeoutException {
      throw const ApiException(
        TipoErrorApi.sinConexion,
        'El servidor tardó demasiado en responder.',
      );
    } on http.ClientException {
      throw const ApiException(
        TipoErrorApi.sinConexion,
        'No se pudo conectar con el servidor de recetas.',
      );
    }

    if (respuesta.statusCode != 200) {
      throw ApiException(
        TipoErrorApi.servidor,
        'El servidor respondió con el código ${respuesta.statusCode}.',
      );
    }
    try {
      // utf8.decode: algunas recetas traen tildes y caracteres especiales.
      return jsonDecode(utf8.decode(respuesta.bodyBytes))
          as Map<String, dynamic>;
    } on FormatException {
      throw const ApiException(
        TipoErrorApi.formato,
        'La respuesta del servidor no es un JSON válido.',
      );
    } on TypeError {
      throw const ApiException(
        TipoErrorApi.formato,
        'La respuesta del servidor no es un JSON válido.',
      );
    }
  }
}
