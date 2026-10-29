import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../services/image_service.dart';
import '../services/permission_service.dart';

/// Sección "Foto de referencia" del formulario de reserva.
///
/// Flujo: pedir permiso → abrir cámara/galería → recortar y comprimir
/// → previsualizar. Avisa al padre con [onCambio] la ruta final (o null).
class FotoReferenciaPicker extends StatefulWidget {
  final ValueChanged<String?> onCambio;

  const FotoReferenciaPicker({super.key, required this.onCambio});

  @override
  State<FotoReferenciaPicker> createState() => _FotoReferenciaPickerState();
}

class _FotoReferenciaPickerState extends State<FotoReferenciaPicker> {
  ImagenProcesada? _imagen;
  bool _procesando = false;
  bool _recorteCuadrado = true;

  @override
  void initState() {
    super.initState();
    _recuperarSiSePerdio();
  }

  /// Si Android cerró la app mientras la cámara estaba abierta,
  /// recuperamos la foto al volver (ciclo de vida de la Activity).
  Future<void> _recuperarSiSePerdio() async {
    final servicio = context.read<ImageService>();
    try {
      final perdida = await servicio.recuperarFotoPerdida();
      if (perdida != null && mounted) await _procesar(perdida);
    } catch (_) {
      // No es crítico: si falla, el usuario puede volver a tomar la foto.
    }
  }

  Future<void> _obtener(ImageSource origen) async {
    final permisos = context.read<PermissionService>();
    final imagenes = context.read<ImageService>();
    final tipo = origen == ImageSource.camera
        ? TipoPermiso.camara
        : TipoPermiso.galeria;

    // 1) Permiso en tiempo de ejecución.
    final resultado = await permisos.solicitar(tipo);
    if (!mounted) return;
    if (resultado != ResultadoPermiso.concedido) {
      await _manejarPermisoNegado(resultado, tipo, permisos);
      return;
    }

    // 2) Captura / selección nativa.
    try {
      final foto = await imagenes.seleccionar(origen);
      if (foto == null) return; // el usuario canceló
      await _procesar(foto);
    } catch (e) {
      _mensaje('No se pudo obtener la imagen: $e');
    }
  }

  Future<void> _procesar(XFile foto) async {
    setState(() => _procesando = true);
    try {
      // 3) Recorte + compresión en un Isolate secundario.
      final imagen = await context.read<ImageService>().procesar(
        foto,
        recorteCuadrado: _recorteCuadrado,
      );
      if (!mounted) return;
      setState(() => _imagen = imagen);
      widget.onCambio(imagen.archivo.path);
    } on FormatException catch (e) {
      _mensaje(e.message);
    } catch (e) {
      _mensaje('Error al procesar la imagen: $e');
    } finally {
      if (mounted) setState(() => _procesando = false);
    }
  }

  Future<void> _manejarPermisoNegado(
    ResultadoPermiso resultado,
    TipoPermiso tipo,
    PermissionService permisos,
  ) async {
    final recurso = tipo == TipoPermiso.camara ? 'la cámara' : 'tus fotos';
    switch (resultado) {
      case ResultadoPermiso.denegado:
        _mensaje('Permiso denegado: no podemos acceder a $recurso.');
      case ResultadoPermiso.restringido:
        _mensaje('El acceso a $recurso está restringido en este dispositivo.');
      case ResultadoPermiso.denegadoPermanente:
        final abrir = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            icon: const Icon(Icons.lock_outline, color: AppColors.mora),
            title: const Text('Permiso desactivado'),
            content: Text(
              'Negaste el acceso a $recurso de forma permanente. '
              'Para adjuntar una foto de referencia actívalo en Ajustes.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Ahora no'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Abrir Ajustes'),
              ),
            ],
          ),
        );
        if (abrir == true) await permisos.abrirAjustes();
      case ResultadoPermiso.concedido:
        break;
    }
  }

  void _quitar() {
    setState(() => _imagen = null);
    widget.onCambio(null);
  }

  void _mensaje(String texto) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  String _kb(int bytes) => '${(bytes / 1024).toStringAsFixed(0)} KB';

  @override
  Widget build(BuildContext context) {
    final imagen = _imagen;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Foto de referencia (opcional)',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const Text(
          '¿Tienes un diseño en mente? Toma una foto o elígela de tu galería.',
          style: TextStyle(fontSize: 12, color: Colors.black54),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          activeThumbColor: AppColors.mora,
          title: const Text('Recortar en cuadrado (1:1)'),
          value: _recorteCuadrado,
          onChanged: _procesando
              ? null
              : (v) => setState(() => _recorteCuadrado = v),
        ),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _procesando
                    ? null
                    : () => _obtener(ImageSource.camera),
                icon: const Icon(Icons.photo_camera),
                label: const Text('Cámara'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _procesando
                    ? null
                    : () => _obtener(ImageSource.gallery),
                icon: const Icon(Icons.photo_library),
                label: const Text('Galería'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (_procesando)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 8),
                  Text('Recortando y comprimiendo...'),
                ],
              ),
            ),
          )
        else if (imagen != null)
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      imagen.archivo,
                      width: 96,
                      height: 96,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${imagen.ancho} × ${imagen.alto} px · JPG',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '${_kb(imagen.bytesOriginal)} → ${_kb(imagen.bytesFinal)}',
                        ),
                        Text(
                          'Ahorro: ${imagen.ahorroPorcentaje}%',
                          style: const TextStyle(color: AppColors.hoja),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Quitar foto',
                    onPressed: _quitar,
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
