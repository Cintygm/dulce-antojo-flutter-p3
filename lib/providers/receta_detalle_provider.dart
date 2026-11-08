import 'package:flutter/foundation.dart';

import '../data/models/receta.dart';
import '../data/repositories/recetas_repository.dart';
import '../data/sources/api_exception.dart';
import 'estado_peticion.dart';

/// Estado del detalle de UNA receta.
///
/// Se crea al abrir la pantalla de detalle y se destruye al cerrarla
/// (ChangeNotifierProvider local en la ruta), por eso recibe el [id].
class RecetaDetalleProvider extends ChangeNotifier {
  RecetaDetalleProvider(this._repo, this.id);

  final RecetasRepository _repo;
  final int id;

  EstadoPeticion<RecetaDetalle> _estado = const Cargando();
  bool _actualizando = false;
  bool _cerrado = false;

  EstadoPeticion<RecetaDetalle> get estado => _estado;
  bool get actualizando => _actualizando;

  Future<void> cargar({bool refrescar = false}) async {
    if (_actualizando) return;
    _actualizando = true;
    if (!refrescar || _estado is! Exito) _estado = const Cargando();
    _avisar();

    try {
      _estado = Exito(await _repo.detalle(id));
    } on ApiException catch (e) {
      _estado = Fallo(e.mensaje, esDeRed: e.esDeRed);
    } catch (_) {
      _estado = const Fallo('Ocurrió un error inesperado. Intenta de nuevo.');
    } finally {
      _actualizando = false;
      _avisar();
    }
  }

  // Si el usuario sale de la pantalla antes de que llegue la respuesta,
  // el provider ya fue destruido y no se debe notificar.
  void _avisar() {
    if (!_cerrado) notifyListeners();
  }

  @override
  void dispose() {
    _cerrado = true;
    super.dispose();
  }
}
