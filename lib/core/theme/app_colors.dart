import 'package:flutter/material.dart';

/// Paleta oficial de la marca "Mora & Miel".
///
/// Todos los colores de la app salen de aquí: ninguna pantalla usa
/// colores "sueltos" (antes se usaba Colors.pink en cada widget).
class AppColors {
  AppColors._();

  /// Morado mora: color principal (AppBar, botones, splash).
  static const Color mora = Color(0xFF5B1E4B);

  /// Variante clara de la mora (contenedores, chips).
  static const Color moraClaro = Color(0xFF8E3B78);

  /// Dorado miel: color secundario y de acento (precios, íconos).
  static const Color miel = Color(0xFFE8A33D);

  /// Fondo cálido tipo crema.
  static const Color crema = Color(0xFFFFF8EE);

  /// Texto principal (cacao oscuro).
  static const Color cacao = Color(0xFF2E1A24);

  /// Verde hoja: estados correctos / en línea.
  static const Color hoja = Color(0xFF4F7A4A);

  /// Rojo para errores y modo sin conexión.
  static const Color alerta = Color(0xFFB3261E);
}
