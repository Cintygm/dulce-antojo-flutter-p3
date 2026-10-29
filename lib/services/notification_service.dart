import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../core/navegacion.dart';
import '../core/theme/app_colors.dart';

/// Servicio de notificaciones locales (Android e iOS), sin UI.
///
/// - Crea los canales nativos de Android (obligatorios desde Android 8).
/// - Pide el permiso POST_NOTIFICATIONS (Android 13+) / alertas en iOS.
/// - Expone métodos de alto nivel para los eventos clave de la app.
class NotificationService {
  NotificationService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _iniciado = false;
  int _siguienteId = 0;

  /// Canal para confirmaciones de reservas (importancia alta: heads-up).
  static const canalReservas = AndroidNotificationChannel(
    'reservas',
    'Reservas',
    description: 'Confirmación y estado de tus reservas en Mora & Miel',
    importance: Importance.high,
  );

  /// Canal para avisos de sincronización / conexión.
  static const canalSincronizacion = AndroidNotificationChannel(
    'sincronizacion',
    'Sincronización',
    description: 'Avisos cuando se envían reservas guardadas sin conexión',
    importance: Importance.defaultImportance,
  );

  /// Payload que indica abrir la pantalla "Mis reservas".
  static const payloadReservas = 'reservas';

  Future<void> iniciar() async {
    if (_iniciado) return;

    const ajustes = InitializationSettings(
      // Ícono monocromo propio (res/drawable-*/ic_stat_mora.png).
      android: AndroidInitializationSettings('ic_stat_mora'),
      // En iOS el permiso se pide después, en un momento oportuno.
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );

    await _plugin.initialize(
      settings: ajustes,
      onDidReceiveNotificationResponse: _alTocarNotificacion,
    );

    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await android?.createNotificationChannel(canalReservas);
    await android?.createNotificationChannel(canalSincronizacion);

    _iniciado = true;
  }

  /// Solicita el permiso de notificaciones en tiempo de ejecución.
  Future<bool> solicitarPermiso() async {
    if (Platform.isAndroid) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      return await android?.requestNotificationsPermission() ?? false;
    }
    if (Platform.isIOS) {
      final ios = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      return await ios?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }
    return false;
  }

  /// Si la app se abrió tocando una notificación (app cerrada), devuelve
  /// su payload para navegar a la pantalla correcta.
  Future<String?> payloadDeArranque() async {
    final detalles = await _plugin.getNotificationAppLaunchDetails();
    if (detalles?.didNotificationLaunchApp ?? false) {
      return detalles!.notificationResponse?.payload;
    }
    return null;
  }

  // ---------------- Eventos clave de la app ----------------

  Future<void> reservaConfirmada({
    required String postre,
    required int cantidad,
    required String cliente,
    required double total,
  }) => _mostrar(
    canal: canalReservas,
    titulo: '¡Reserva confirmada! 🍰',
    cuerpo:
        '$cantidad × $postre para $cliente · Total \$${total.toStringAsFixed(2)}',
  );

  Future<void> reservaGuardadaOffline({required String postre}) => _mostrar(
    canal: canalReservas,
    titulo: 'Reserva guardada sin conexión',
    cuerpo: '$postre se enviará automáticamente cuando vuelva internet.',
  );

  Future<void> reservasSincronizadas(int cantidad) => _mostrar(
    canal: canalSincronizacion,
    titulo: 'Reservas sincronizadas',
    cuerpo: cantidad == 1
        ? 'Se envió 1 reserva que estaba pendiente.'
        : 'Se enviaron $cantidad reservas que estaban pendientes.',
  );

  // ----------------------------------------------------------

  Future<void> _mostrar({
    required AndroidNotificationChannel canal,
    required String titulo,
    required String cuerpo,
  }) async {
    try {
      await iniciar();
      final detalles = NotificationDetails(
        android: AndroidNotificationDetails(
          canal.id,
          canal.name,
          channelDescription: canal.description,
          importance: canal.importance,
          priority: canal.importance == Importance.high
              ? Priority.high
              : Priority.defaultPriority,
          color: AppColors.mora,
          styleInformation: BigTextStyleInformation(cuerpo),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBanner: true,
          presentSound: true,
        ),
      );
      await _plugin.show(
        id: _siguienteId++,
        title: titulo,
        body: cuerpo,
        notificationDetails: detalles,
        payload: payloadReservas,
      );
    } catch (e) {
      // Una notificación fallida nunca debe romper el flujo de la reserva.
      debugPrint('No se pudo mostrar la notificación: $e');
    }
  }

  void _alTocarNotificacion(NotificationResponse respuesta) {
    if (respuesta.payload == payloadReservas) {
      navigatorKey.currentState?.pushNamed('/reservas');
    }
  }
}
