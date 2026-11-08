import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../data/models/receta.dart';
import '../providers/estado_peticion.dart';
import '../providers/recetas_provider.dart';
import '../widgets/estado_vistas.dart';
import '../widgets/receta_card.dart';

/// Pantalla 4: "Recetario dulce".
///
/// Muestra postres de la API pública TheMealDB como inspiración para
/// pedidos personalizados. Maneja los estados Cargando / Exito / Fallo y
/// se actualiza con pull-to-refresh.
class RecetasScreen extends StatelessWidget {
  const RecetasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final recetas = context.watch<RecetasProvider>();
    final estado = recetas.estado;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recetario dulce'),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            icon: const Icon(Icons.refresh),
            onPressed: recetas.actualizando ? null : () => recetas.cargar(),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.mora,
        onRefresh: () => recetas.cargar(refrescar: true),
        child: CustomScrollView(
          // Permite deslizar para actualizar en los tres estados,
          // incluso cuando el contenido no llena la pantalla.
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _Encabezado(recetas: recetas)),
            // switch exhaustivo sobre el estado sealed.
            ...switch (estado) {
              Cargando() => [
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: VistaCargando(mensaje: 'Horneando recetas...'),
                ),
              ],
              Exito() => _contenido(context, recetas.visibles),
              Fallo(:final mensaje, :final esDeRed) => [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: VistaError(
                    mensaje: mensaje,
                    esDeRed: esDeRed,
                    onReintentar: () => recetas.cargar(),
                  ),
                ),
              ],
            },
          ],
        ),
      ),
    );
  }

  List<Widget> _contenido(BuildContext context, List<RecetaResumen> lista) {
    if (lista.isEmpty) {
      return const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'No hay recetas con ese nombre.',
                style: TextStyle(color: AppColors.moraClaro),
              ),
            ),
          ),
        ),
      ];
    }
    return [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 24),
        sliver: SliverGrid.builder(
          itemCount: lista.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.8,
          ),
          itemBuilder: (context, i) => RecetaCard(
            receta: lista[i],
            onTap: () =>
                Navigator.pushNamed(context, '/receta', arguments: lista[i]),
          ),
        ),
      ),
    ];
  }
}

class _Encabezado extends StatelessWidget {
  const _Encabezado({required this.recetas});

  final RecetasProvider recetas;

  @override
  Widget build(BuildContext context) {
    final estado = recetas.estado;
    final total = estado is Exito<List<RecetaResumen>>
        ? estado.datos.length
        : null;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.mora, AppColors.moraClaro],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.menu_book_rounded, color: AppColors.miel),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Inspírate para tu próximo pedido',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            total == null
                ? 'Postres del mundo · TheMealDB'
                : '$total postres del mundo · TheMealDB',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 12),
          TextField(
            onChanged: recetas.buscar,
            enabled: total != null,
            textInputAction: TextInputAction.search,
            decoration: const InputDecoration(
              isDense: true,
              hintText: 'Buscar postre (ej. cake, pie, tart)',
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ],
      ),
    );
  }
}
