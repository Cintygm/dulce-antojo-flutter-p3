/// Estado de una petición HTTP, reutilizable para cualquier tipo de dato.
///
/// Al ser `sealed`, un `switch` sobre este tipo debe cubrir los tres casos
/// (Cargando, Exito y Fallo); si falta uno, el código no compila. Así
/// ninguna pantalla puede olvidarse de mostrar el error de red.
sealed class EstadoPeticion<T> {
  const EstadoPeticion();
}

/// La petición está en curso y todavía no hay datos.
final class Cargando<T> extends EstadoPeticion<T> {
  const Cargando();
}

/// La API respondió y el JSON se convirtió al modelo [T].
final class Exito<T> extends EstadoPeticion<T> {
  const Exito(this.datos);
  final T datos;
}

/// La petición falló. [esDeRed] indica si fue por falta de conexión.
final class Fallo<T> extends EstadoPeticion<T> {
  const Fallo(this.mensaje, {this.esDeRed = false});
  final String mensaje;
  final bool esDeRed;
}
