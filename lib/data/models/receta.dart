/// Modelos de la API pública TheMealDB (https://www.themealdb.com).
///
/// La API usa nombres en inglés con prefijo (`idMeal`, `strMeal`...).
/// Aquí se convierten a modelos en español con tipos de Dart correctos.

/// Receta resumida, tal como llega en el listado
/// `GET /filter.php?c=Dessert`:
/// ```json
/// { "strMeal": "Apple Frangipan Tart",
///   "strMealThumb": "https://www.themealdb.com/images/media/meals/xxx.jpg",
///   "idMeal": "52768" }
/// ```
class RecetaResumen {
  final int id;
  final String nombre;
  final String foto;

  const RecetaResumen({
    required this.id,
    required this.nombre,
    required this.foto,
  });

  factory RecetaResumen.fromJson(Map<String, dynamic> json) => RecetaResumen(
    // La API envía el id como texto: "52768".
    id: int.parse(json['idMeal'] as String),
    nombre: json['strMeal'] as String,
    foto: (json['strMealThumb'] as String?) ?? '',
  );

  Map<String, dynamic> toJson() => {
    'idMeal': '$id',
    'strMeal': nombre,
    'strMealThumb': foto,
  };

  /// Miniatura liviana que ofrece la API (agregando /preview a la URL).
  String get fotoPreview => foto.isEmpty ? '' : '$foto/preview';
}

/// Un ingrediente con su medida ("200g" de "Butter").
class Ingrediente {
  final String nombre;
  final String medida;

  const Ingrediente(this.nombre, this.medida);

  factory Ingrediente.fromJson(Map<String, dynamic> json) =>
      Ingrediente(json['nombre'] as String, json['medida'] as String);

  Map<String, dynamic> toJson() => {'nombre': nombre, 'medida': medida};
}

/// Receta completa de `GET /lookup.php?i={id}`.
///
/// La API no envía los ingredientes como lista, sino en 20 campos
/// separados: `strIngredient1..20` y `strMeasure1..20` (vacíos o null
/// cuando no se usan). [RecetaDetalle.fromJson] los junta en una lista.
class RecetaDetalle {
  final int id;
  final String nombre;
  final String categoria;
  final String origen;
  final String instrucciones;
  final String foto;
  final String? video;
  final List<Ingrediente> ingredientes;

  const RecetaDetalle({
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.origen,
    required this.instrucciones,
    required this.foto,
    required this.ingredientes,
    this.video,
  });

  static const int maxIngredientes = 20;

  factory RecetaDetalle.fromJson(Map<String, dynamic> json) {
    final ingredientes = <Ingrediente>[];
    for (var i = 1; i <= maxIngredientes; i++) {
      final nombre = (json['strIngredient$i'] as String?)?.trim() ?? '';
      if (nombre.isEmpty) continue;
      final medida = (json['strMeasure$i'] as String?)?.trim() ?? '';
      ingredientes.add(Ingrediente(nombre, medida));
    }
    final video = (json['strYoutube'] as String?)?.trim();
    return RecetaDetalle(
      id: int.parse(json['idMeal'] as String),
      nombre: json['strMeal'] as String,
      categoria: (json['strCategory'] as String?) ?? 'Dessert',
      origen: (json['strArea'] as String?) ?? '',
      instrucciones: (json['strInstructions'] as String?)?.trim() ?? '',
      foto: (json['strMealThumb'] as String?) ?? '',
      video: (video == null || video.isEmpty) ? null : video,
      ingredientes: List.unmodifiable(ingredientes),
    );
  }

  /// Vuelve al formato de la API (campos numerados), de modo que
  /// `RecetaDetalle.fromJson(r.toJson())` reconstruye la misma receta.
  Map<String, dynamic> toJson() => {
    'idMeal': '$id',
    'strMeal': nombre,
    'strCategory': categoria,
    'strArea': origen,
    'strInstructions': instrucciones,
    'strMealThumb': foto,
    'strYoutube': video ?? '',
    for (var i = 0; i < ingredientes.length; i++) ...{
      'strIngredient${i + 1}': ingredientes[i].nombre,
      'strMeasure${i + 1}': ingredientes[i].medida,
    },
  };

  /// Pasos de preparación: la API separa los párrafos con saltos de línea.
  List<String> get pasos => instrucciones
      .split(RegExp(r'\r?\n'))
      .map((p) => p.trim())
      .where((p) => p.isNotEmpty)
      .toList();
}
