import 'package:flutter/foundation.dart';

import '../data/models/postre.dart';
import '../data/repositories/catalogo_repository.dart';

/// Estado del catálogo para la interfaz (patrón Provider + ChangeNotifier).
/// La UI solo escucha este estado; no sabe nada de caché ni de red.
class CatalogoProvider extends ChangeNotifier {
  final CatalogoRepository _repo;

  CatalogoProvider(this._repo);

  List<Postre> _postres = [];
  bool _cargando = false;
  bool _desdeCache = false;
  DateTime? _actualizado;
  String? _error;

  List<Postre> get postres => _postres;
  bool get cargando => _cargando;
  bool get desdeCache => _desdeCache;
  DateTime? get actualizado => _actualizado;
  String? get error => _error;

  Future<void> cargar({bool hayInternet = true}) async {
    _cargando = true;
    _error = null;
    notifyListeners();
    try {
      final r = await _repo.obtener(hayInternet: hayInternet);
      _postres = r.postres;
      _desdeCache = r.desdeCache;
      _actualizado = r.actualizado;
    } catch (e) {
      _error = e.toString();
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }
}
