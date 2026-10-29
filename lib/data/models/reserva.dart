/// Estado de una reserva.
/// - [confirmada]: se envió correctamente (había internet).
/// - [pendiente]: se creó sin conexión y espera ser sincronizada.
enum EstadoReserva { confirmada, pendiente }

/// Reserva hecha por un cliente. Se guarda en el almacenamiento local.
class Reserva {
  final String id;
  final int codigoPostre;
  final String nombrePostre;
  final String cliente;
  final int cantidad;
  final double total;
  final DateTime fecha;
  final EstadoReserva estado;

  /// Ruta local de la foto de referencia (opcional), ya recortada/comprimida.
  final String? fotoPath;

  const Reserva({
    required this.id,
    required this.codigoPostre,
    required this.nombrePostre,
    required this.cliente,
    required this.cantidad,
    required this.total,
    required this.fecha,
    required this.estado,
    this.fotoPath,
  });

  Reserva copyWith({EstadoReserva? estado}) => Reserva(
    id: id,
    codigoPostre: codigoPostre,
    nombrePostre: nombrePostre,
    cliente: cliente,
    cantidad: cantidad,
    total: total,
    fecha: fecha,
    estado: estado ?? this.estado,
    fotoPath: fotoPath,
  );

  factory Reserva.fromJson(Map<String, dynamic> json) => Reserva(
    id: json['id'] as String,
    codigoPostre: json['codigoPostre'] as int,
    nombrePostre: json['nombrePostre'] as String,
    cliente: json['cliente'] as String,
    cantidad: json['cantidad'] as int,
    total: (json['total'] as num).toDouble(),
    fecha: DateTime.parse(json['fecha'] as String),
    estado: EstadoReserva.values.byName(json['estado'] as String),
    fotoPath: json['fotoPath'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'codigoPostre': codigoPostre,
    'nombrePostre': nombrePostre,
    'cliente': cliente,
    'cantidad': cantidad,
    'total': total,
    'fecha': fecha.toIso8601String(),
    'estado': estado.name,
    'fotoPath': fotoPath,
  };
}
