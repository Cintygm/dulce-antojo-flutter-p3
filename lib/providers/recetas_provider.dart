import 'package:flutter/foundation.dart';

import '../data/models/receta.dart';
import '../data/repositories/recetas_repository.dart';
import '../data/sources/api_exception.dart';
import 'estado_peticion.dart';

/// Estado de la pantalla "Recetario" (Provider + ChangeNotifier).
///
/// La pantalla solo lee [estado] y llama a [cargar] o [buscar];
/// nunca toca `http` ni JSON.
class RecetasProvider extends ChangeNotifier {
  RecetasProvider(this._repo);

  final RecetasRepository _repo;

  EstadoPeticion<List<RecetaResumen>> _estado = const Cargando();
  bool _actualizando = false;
  String _filtro = '';

  EstadoPeticion<List<RecetaResumen>> get estado => _estado;

  /// true mientras hay una petición en curso (incluido pull-to-refresh).
  bool get actualizando => _actualizando;

  String get filtro => _filtro;

  /// Recetas del estado Exito filtradas por el texto de búsqueda.
  /// El filtro es local: no genera nuevas peticiones a la API.
  List<RecetaResumen> get visibles {
    final estado = _estado;
    if (estado is! Exito<List<RecetaResumen>>) return const [];
    if (_filtro.isEmpty) return estado.datos;
    final f = _filtro.toLowerCase();
    return estado.datos
        .where((r) => r.nombre.toLowerCase().contains(f))
        .toList();
  }

  /// Descarga el listado de postres.
  ///
  /// Con [refrescar] = true (pull-to-refresh) y una lista ya visible, se
  /// mantiene la lista en pantalla: el RefreshIndicator muestra el progreso.
  Future<void> cargar({bool refrescar = false}) async {
    if (_actualizando) return; // evita peticiones duplicadas
    _actualizando = true;
    if (!refrescar || _estado is! Exito) {
      _estado = const Cargando();
    }
    notifyListeners();

    try {
      final recetas = await _repo.postres();
      _estado = Exito(recetas);
    } on ApiException catch (e) {
      _estado = Fallo(e.mensaje, esDeRed: e.esDeRed);
    } catch (_) {
      _estado = const Fallo('Ocurrió un error inesperado. Intenta de nuevo.');
    } finally {
      _actualizando = false;
      notifyListeners();
    }
  }

  void buscar(String texto) {
    final limpio = texto.trim();
    if (limpio == _filtro) return;
    _filtro = limpio;
    notifyListeners();
  }
}
