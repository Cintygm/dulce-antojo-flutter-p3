import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../data/models/receta.dart';

/// Tarjeta de una receta del recetario (foto descargada de la API).
class RecetaCard extends StatelessWidget {
  const RecetaCard({super.key, required this.receta, required this.onTap});

  final RecetaResumen receta;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Hero(
                tag: 'receta-${receta.id}',
                child: FotoRed(url: receta.fotoPreview),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      receta.nombre,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.cacao,
                        height: 1.2,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: AppColors.miel,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Imagen de internet con su propio indicador de carga y un respaldo si
/// la foto no se puede descargar.
class FotoRed extends StatelessWidget {
  const FotoRed({super.key, required this.url, this.fit = BoxFit.cover});

  final String url;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final respaldo = Container(
      color: AppColors.moraClaro.withValues(alpha: 0.10),
      alignment: Alignment.center,
      child: const Icon(Icons.cake_outlined, color: AppColors.moraClaro),
    );
    if (url.isEmpty) return respaldo;
    return Image.network(
      url,
      fit: fit,
      width: double.infinity,
      loadingBuilder: (context, child, progreso) => progreso == null
          ? child
          : Container(
              color: AppColors.miel.withValues(alpha: 0.08),
              alignment: Alignment.center,
              child: const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.miel,
                ),
              ),
            ),
      errorBuilder: (context, error, stack) => respaldo,
    );
  }
}
