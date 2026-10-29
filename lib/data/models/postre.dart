/// Modelo de un postre del catálogo.
///
/// Incluye conversión a/desde JSON para poder guardarlo en la caché local
/// (SharedPreferences) y leerlo cuando no hay internet.
class Postre {
  final int codigo;
  final String nombre;
  final String detalle;
  final double precio;
  final String foto;

  const Postre({
    required this.codigo,
    required this.nombre,
    required this.detalle,
    required this.precio,
    required this.foto,
  });

  factory Postre.fromJson(Map<String, dynamic> json) => Postre(
    codigo: json['codigo'] as int,
    nombre: json['nombre'] as String,
    detalle: json['detalle'] as String,
    precio: (json['precio'] as num).toDouble(),
    foto: json['foto'] as String,
  );

  Map<String, dynamic> toJson() => {
    'codigo': codigo,
    'nombre': nombre,
    'detalle': detalle,
    'precio': precio,
    'foto': foto,
  };
}
