import '../models/receta.dart';
import '../sources/recetas_api.dart';

/// Repositorio de recetas de inspiración.
///
/// Es la única puerta de entrada a los datos para los providers: si mañana
/// se cambia TheMealDB por otra API (o `http` por `dio`), solo cambia la
/// fuente de datos y la interfaz no se entera.
///
/// No usa caché a propósito: el objetivo de esta pantalla es mostrar datos
/// en vivo y demostrar el manejo explícito del estado de error.
class RecetasRepository {
  RecetasRepository({RecetasApi? api}) : _api = api ?? RecetasApi();

  final RecetasApi _api;

  Future<List<RecetaResumen>> postres() => _api.obtenerPostres();

  Future<RecetaDetalle> detalle(int id) => _api.obtenerDetalle(id);
}
