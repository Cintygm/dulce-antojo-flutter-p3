/// Errores que puede producir una petición a la API de recetas.
///
/// La fuente de datos traduce las excepciones técnicas de Dart
/// (SocketException, TimeoutException, FormatException...) a este tipo,
/// para que el resto de la app solo maneje mensajes claros en español.
class ApiException implements Exception {
  const ApiException(this.tipo, this.mensaje);

  final TipoErrorApi tipo;
  final String mensaje;

  /// El usuario puede solucionarlo revisando su conexión.
  bool get esDeRed => tipo == TipoErrorApi.sinConexion;

  @override
  String toString() => mensaje;
}

enum TipoErrorApi {
  /// No hay internet o el servidor tardó demasiado en responder.
  sinConexion,

  /// El servidor respondió con un código HTTP de error (4xx / 5xx).
  servidor,

  /// La respuesta llegó, pero el JSON no tiene la forma esperada.
  formato,

  /// La API respondió bien pero no encontró el recurso pedido.
  noEncontrado,
}
