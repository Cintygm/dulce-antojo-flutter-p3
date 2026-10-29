import 'package:flutter/material.dart';

/// Llave global del Navigator. Permite navegar desde servicios que no
/// tienen BuildContext (p. ej. al tocar una notificación).
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
