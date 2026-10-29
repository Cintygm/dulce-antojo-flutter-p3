import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';

/// Estado de la conexión a internet que entiende el resto de la app.
enum EstadoRed { enLinea, sinConexion }

/// Servicio nativo de conectividad, desacoplado de la interfaz.
///
/// - Escucha en tiempo real el stream nativo `onConnectivityChanged`
///   (BroadcastReceiver/NetworkCallback en Android, NWPathMonitor en iOS).
/// - Como tener Wi-Fi no garantiza tener internet, verifica el acceso real
///   con una consulta DNS corta.
/// - Publica el resultado en su propio [Stream] para que cualquier capa
///   (providers, repositorios) reaccione sin depender de widgets.
class ConnectivityService {
  ConnectivityService({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;
  final _controller = StreamController<EstadoRed>.broadcast();
  StreamSubscription<EstadoRed>? _suscripcion;
  Timer? _reintento;
  Future<void>? _inicio;

  EstadoRed _actual = EstadoRed.enLinea;

  /// Último estado conocido.
  EstadoRed get actual => _actual;
  bool get enLinea => _actual == EstadoRed.enLinea;

  /// Stream reactivo con cada cambio de estado (sin repetidos).
  Stream<EstadoRed> get cambios => _controller.stream;

  /// Inicia el monitoreo. Es seguro llamarlo varias veces.
  Future<void> iniciar() => _inicio ??= _iniciar();

  Future<void> _iniciar() async {
    try {
      final inicial = await _connectivity.checkConnectivity();
      _emitir(await _evaluar(inicial));
    } catch (_) {
      // Si el plugin falla (p. ej. en un test), asumimos en línea.
      _emitir(EstadoRed.enLinea);
    }

    // asyncMap procesa los eventos en orden: un evento viejo no puede
    // sobrescribir a uno nuevo aunque su verificación DNS tarde más.
    _suscripcion = _connectivity.onConnectivityChanged
        .asyncMap(_evaluar)
        .listen(_emitir);
  }

  /// Convierte el resultado del plugin en un estado real de internet.
  Future<EstadoRed> _evaluar(List<ConnectivityResult> resultados) async {
    _reintento?.cancel();
    final sinInterfaz =
        resultados.isEmpty ||
        resultados.every((r) => r == ConnectivityResult.none);
    if (sinInterfaz) return EstadoRed.sinConexion;

    final hayInternet = await _hayInternetReal();
    if (!hayInternet) {
      // La red puede tardar unos segundos en estar lista (p. ej. al quitar
      // el modo avión). Volvemos a comprobar sin esperar otro evento.
      _reintento = Timer(const Duration(seconds: 5), () async {
        if (await _hayInternetReal()) _emitir(EstadoRed.enLinea);
      });
    }
    return hayInternet ? EstadoRed.enLinea : EstadoRed.sinConexion;
  }

  Future<bool> _hayInternetReal() async {
    try {
      final r = await InternetAddress.lookup(
        'example.com',
      ).timeout(const Duration(seconds: 3));
      return r.isNotEmpty && r.first.rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    } on TimeoutException {
      return false;
    }
  }

  void _emitir(EstadoRed estado) {
    final primeraVez = !_emitido;
    _emitido = true;
    if (!primeraVez && estado == _actual) return;
    _actual = estado;
    if (!_controller.isClosed) _controller.add(estado);
  }

  bool _emitido = false;

  /// Libera el listener nativo (evita fugas de memoria).
  Future<void> dispose() async {
    _reintento?.cancel();
    await _suscripcion?.cancel();
    await _controller.close();
  }
}
