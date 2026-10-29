import 'dart:async';

import 'package:flutter/foundation.dart';

import '../services/connectivity_service.dart';

/// Adapta el stream del [ConnectivityService] al patrón Provider
/// para que los widgets se reconstruyan cuando cambia la red.
class ConnectivityProvider extends ChangeNotifier {
  ConnectivityProvider(this._servicio) {
    _sub = _servicio.cambios.listen((estado) {
      _recienReconectado = estado == EstadoRed.enLinea;
      notifyListeners();
    });
  }

  final ConnectivityService _servicio;
  late final StreamSubscription<EstadoRed> _sub;
  bool _recienReconectado = false;

  bool get enLinea => _servicio.enLinea;

  /// true justo después de recuperar la conexión (para el aviso verde).
  bool get recienReconectado => _recienReconectado;

  void ocultarAvisoReconexion() {
    if (!_recienReconectado) return;
    _recienReconectado = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
