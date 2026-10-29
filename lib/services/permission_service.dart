import 'dart:io';

import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

/// Permisos que la app solicita en tiempo de ejecución.
enum TipoPermiso { camara, galeria, notificaciones }

/// Resultado simplificado para que la UI decida qué mostrar.
enum ResultadoPermiso {
  /// El usuario dio acceso (total o limitado en iOS).
  concedido,

  /// Lo negó esta vez; se puede volver a preguntar.
  denegado,

  /// Lo negó para siempre ("No volver a preguntar"): solo desde Ajustes.
  denegadoPermanente,

  /// Bloqueado por el sistema (control parental, MDM...).
  restringido,
}

/// Servicio de permisos nativos, independiente de la interfaz.
class PermissionService {
  /// Canal propio implementado en MainActivity.kt.
  static const _canal = MethodChannel('com.moraymiel.app/dispositivo');

  Future<int> _androidSdk() async {
    try {
      return await _canal.invokeMethod<int>('sdkInt') ?? 33;
    } on PlatformException {
      return 33;
    } on MissingPluginException {
      return 33;
    }
  }

  /// Android 13+ usa READ_MEDIA_IMAGES (Permission.photos);
  /// Android 12 o menor usa READ_EXTERNAL_STORAGE (Permission.storage).
  Future<Permission> _permisoGaleria() async {
    if (Platform.isAndroid && await _androidSdk() <= 32) {
      return Permission.storage;
    }
    return Permission.photos;
  }

  Future<Permission> _permisoDe(TipoPermiso tipo) async => switch (tipo) {
    TipoPermiso.camara => Permission.camera,
    TipoPermiso.galeria => await _permisoGaleria(),
    TipoPermiso.notificaciones => Permission.notification,
  };

  /// Consulta el estado y, si hace falta, muestra el diálogo del sistema.
  Future<ResultadoPermiso> solicitar(TipoPermiso tipo) async {
    final permiso = await _permisoDe(tipo);

    // Si ya está concedido no molestamos al usuario.
    final actual = await permiso.status;
    if (actual.isGranted || actual.isLimited) return ResultadoPermiso.concedido;
    if (actual.isRestricted) return ResultadoPermiso.restringido;

    // En Android el "denegado permanente" solo se detecta de forma fiable
    // con el resultado de request(): si ya fue bloqueado, el sistema no
    // muestra diálogo y devuelve permanentlyDenied de inmediato.
    final resultado = await permiso.request();
    return _mapear(resultado);
  }

  ResultadoPermiso _mapear(PermissionStatus estado) {
    if (estado.isGranted || estado.isLimited) return ResultadoPermiso.concedido;
    if (estado.isPermanentlyDenied) return ResultadoPermiso.denegadoPermanente;
    if (estado.isRestricted) return ResultadoPermiso.restringido;
    return ResultadoPermiso.denegado;
  }

  /// Abre la pantalla de ajustes de la app para activar el permiso a mano.
  Future<bool> abrirAjustes() => openAppSettings();
}
