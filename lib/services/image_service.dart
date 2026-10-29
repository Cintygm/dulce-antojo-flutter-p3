import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

/// Imagen ya recortada y comprimida, guardada en el dispositivo.
class ImagenProcesada {
  final File archivo;
  final int bytesOriginal;
  final int bytesFinal;
  final int ancho;
  final int alto;

  const ImagenProcesada({
    required this.archivo,
    required this.bytesOriginal,
    required this.bytesFinal,
    required this.ancho,
    required this.alto,
  });

  /// Porcentaje de reducción de tamaño logrado por la compresión.
  int get ahorroPorcentaje =>
      bytesOriginal == 0 ? 0 : (100 - bytesFinal * 100 / bytesOriginal).round();
}

/// Servicio de cámara/galería y procesamiento de imágenes (sin UI).
///
/// Los permisos se piden ANTES desde [PermissionService]; este servicio
/// solo captura, recorta, comprime y guarda.
class ImageService {
  ImageService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  /// Abre la cámara o la galería nativa. Devuelve null si el usuario cancela.
  Future<XFile?> seleccionar(ImageSource origen) => _picker.pickImage(
    source: origen,
    // Primer nivel de compresión: lo hace el lado nativo.
    maxWidth: 2048,
    maxHeight: 2048,
    imageQuality: 90,
    requestFullMetadata: false,
  );

  /// Android puede destruir la Activity mientras la cámara está abierta
  /// (poca memoria). Al volver, la foto se recupera con este método.
  Future<XFile?> recuperarFotoPerdida() async {
    if (!Platform.isAndroid) return null;
    final respuesta = await _picker.retrieveLostData();
    if (respuesta.isEmpty) return null;
    return respuesta.file;
  }

  /// Recorta (cuadrado 1:1 opcional), redimensiona y comprime a JPG.
  ///
  /// El trabajo pesado corre en otro Isolate con [compute] para no
  /// congelar la interfaz (la animación sigue fluida mientras procesa).
  Future<ImagenProcesada> procesar(
    XFile foto, {
    bool recorteCuadrado = true,
  }) async {
    final bytes = await foto.readAsBytes();
    final r = await compute(_recortarYComprimir, (bytes, recorteCuadrado));

    final docs = await getApplicationDocumentsDirectory();
    final carpeta = Directory('${docs.path}/referencias');
    await carpeta.create(recursive: true);
    final archivo = File(
      '${carpeta.path}/ref_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    await archivo.writeAsBytes(r.jpg, flush: true);

    return ImagenProcesada(
      archivo: archivo,
      bytesOriginal: bytes.length,
      bytesFinal: r.jpg.length,
      ancho: r.ancho,
      alto: r.alto,
    );
  }
}

/// Función de nivel superior: se ejecuta dentro del Isolate secundario.
({Uint8List jpg, int ancho, int alto}) _recortarYComprimir(
  (Uint8List, bool) args,
) {
  final (bytes, cuadrado) = args;
  final original = img.decodeImage(bytes);
  if (original == null) {
    throw const FormatException('Formato de imagen no soportado');
  }

  // Corrige la rotación EXIF (fotos de cámara giradas).
  var imagen = img.bakeOrientation(original);

  if (cuadrado) {
    final lado = math.min(1080, math.min(imagen.width, imagen.height));
    imagen = img.copyResizeCropSquare(
      imagen,
      size: lado,
      interpolation: img.Interpolation.average,
    );
  } else if (imagen.width > 1280) {
    imagen = img.copyResize(
      imagen,
      width: 1280,
      interpolation: img.Interpolation.average,
    );
  }

  return (
    jpg: img.encodeJpg(imagen, quality: 75),
    ancho: imagen.width,
    alto: imagen.height,
  );
}
