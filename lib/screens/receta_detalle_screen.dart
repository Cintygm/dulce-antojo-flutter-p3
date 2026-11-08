import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../data/models/receta.dart';
import '../providers/estado_peticion.dart';
import '../providers/receta_detalle_provider.dart';
import '../widgets/estado_vistas.dart';
import '../widgets/receta_card.dart';

/// Pantalla 5: detalle de una receta (segunda petición a la API).
///
/// Recibe el [resumen] desde el recetario, así la foto y el nombre se ven
/// al instante mientras se descargan ingredientes e instrucciones.
class RecetaDetalleScreen extends StatelessWidget {
  const RecetaDetalleScreen({super.key, required this.resumen});

  final RecetaResumen resumen;

  @override
  Widget build(BuildContext context) {
    final detalle = context.watch<RecetaDetalleProvider>();

    return Scaffold(
      body: RefreshIndicator(
        color: AppColors.mora,
        edgeOffset: 280,
        onRefresh: () => detalle.cargar(refrescar: true),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: 260,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  resumen.nombre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Hero(
                      tag: 'receta-${resumen.id}',
                      child: FotoRed(url: resumen.foto),
                    ),
                    // Degradado para que el título se lea sobre la foto.
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Color(0xCC2E1A24)],
                          stops: [0.5, 1],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ...switch (detalle.estado) {
              Cargando() => const [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: VistaCargando(mensaje: 'Buscando la receta...'),
                ),
              ],
              Exito(:final datos) => [_Contenido(receta: datos)],
              Fallo(:final mensaje, :final esDeRed) => [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: VistaError(
                    mensaje: mensaje,
                    esDeRed: esDeRed,
                    onReintentar: () => detalle.cargar(),
                  ),
                ),
              ],
            },
          ],
        ),
      ),
    );
  }
}

class _Contenido extends StatelessWidget {
  const _Contenido({required this.receta});

  final RecetaDetalle receta;

  @override
  Widget build(BuildContext context) {
    final pasos = receta.pasos;
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      sliver: SliverList.list(
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Chip(icono: Icons.category_outlined, texto: receta.categoria),
              if (receta.origen.isNotEmpty)
                _Chip(icono: Icons.public, texto: receta.origen),
              _Chip(
                icono: Icons.shopping_basket_outlined,
                texto: '${receta.ingredientes.length} ingredientes',
              ),
            ],
          ),
          const SizedBox(height: 20),
          const _Titulo('Ingredientes'),
          Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                for (final ing in receta.ingredientes)
                  ListTile(
                    dense: true,
                    leading: const Icon(
                      Icons.check_circle_outline,
                      color: AppColors.hoja,
                      size: 20,
                    ),
                    title: Text(ing.nombre),
                    trailing: Text(
                      ing.medida,
                      style: const TextStyle(
                        color: AppColors.moraClaro,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const _Titulo('Preparación'),
          const Padding(
            padding: EdgeInsets.only(top: 2, bottom: 8),
            child: Text(
              'Receta original en inglés, tal como la publica TheMealDB.',
              style: TextStyle(fontSize: 12, color: AppColors.moraClaro),
            ),
          ),
          for (var i = 0; i < pasos.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 13,
                    backgroundColor: AppColors.miel,
                    child: Text(
                      '${i + 1}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.cacao,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(pasos[i], style: const TextStyle(height: 1.4)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Titulo extends StatelessWidget {
  const _Titulo(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) => Text(
    texto,
    style: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w800,
      color: AppColors.mora,
    ),
  );
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icono, required this.texto});

  final IconData icono;
  final String texto;

  @override
  Widget build(BuildContext context) => Chip(
    avatar: Icon(icono, size: 16, color: AppColors.mora),
    label: Text(texto),
    backgroundColor: AppColors.miel.withValues(alpha: 0.15),
    side: BorderSide.none,
  );
}
