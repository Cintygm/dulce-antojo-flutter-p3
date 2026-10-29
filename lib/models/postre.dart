// Clase con los datos de cada postre
class Postre {
  final int codigo;
  final String nombre;
  final String detalle;
  final double precio;
  final String foto;

  Postre({
    required this.codigo,
    required this.nombre,
    required this.detalle,
    required this.precio,
    required this.foto,
  });
}

// Postres que se muestran en la pantalla principal
List<Postre> postres = [
  Postre(
    codigo: 1,
    nombre: 'Tiramisú',
    detalle: 'Capas de bizcocho, crema suave y cacao en polvo por encima.',
    precio: 3.50,
    foto: 'assets/images/torta_chocolate.jpg',
  ),
  Postre(
    codigo: 2,
    nombre: 'Cupcakes',
    detalle: 'Caja de 4 cupcakes de chocolate con crema de vainilla.',
    precio: 5.00,
    foto: 'assets/images/cupcakes.jpg',
  ),
  Postre(
    codigo: 3,
    nombre: 'Cheesecake',
    detalle: 'Pastel de queso con salsa de frutos rojos y crema batida.',
    precio: 4.25,
    foto: 'assets/images/cheesecake.jpg',
  ),
  Postre(
    codigo: 4,
    nombre: 'Tres leches',
    detalle: 'Bizcocho húmedo en tres tipos de leche con caramelo.',
    precio: 3.00,
    foto: 'assets/images/tres_leches.jpg',
  ),
];
