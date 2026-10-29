import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../data/models/postre.dart';
import '../providers/catalogo_provider.dart';
import '../widgets/postre_card.dart';

/// Pantalla 1: catálogo de postres.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Abre la Pantalla 2 enviando el postre elegido (paso de parámetros).
  Future<void> abrirDetalle(BuildContext context, Postre postre) async {
    final respuesta = await Navigator.pushNamed(
      context,
      '/detalle',
      arguments: postre,
    );

    // Si la Pantalla 2 devolvió un mensaje, lo mostramos abajo.
    if (respuesta != null && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(respuesta.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final catalogo = context.watch<CatalogoProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mora & Miel'),
        actions: [
          IconButton(
            tooltip: 'Mis reservas',
            icon: const Icon(Icons.receipt_long),
            onPressed: () => Navigator.pushNamed(context, '/reservas'),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.mora,
        onRefresh: () => context.read<CatalogoProvider>().cargar(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _Encabezado(catalogo: catalogo)),
            if (catalogo.cargando && catalogo.postres.isEmpty)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (catalogo.error != null && catalogo.postres.isEmpty)
              SliverFillRemaining(
                child: _MensajeError(mensaje: catalogo.error!),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
                sliver: SliverGrid.builder(
                  itemCount: catalogo.postres.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.68,
                  ),
                  itemBuilder: (context, i) {
                    final postre = catalogo.postres[i];
                    return PostreCard(
                      postre: postre,
                      onVerMas: () => abrirDetalle(context, postre),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Encabezado extends StatelessWidget {
  final CatalogoProvider catalogo;

  const _Encabezado({required this.catalogo});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.mora.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Image.asset('assets/branding/logo.png', width: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pastelería artesanal de la casa',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  catalogo.desdeCache
                      ? 'Mostrando catálogo guardado (caché local)'
                      : 'Catálogo actualizado',
                  style: TextStyle(
                    fontSize: 12,
                    color: catalogo.desdeCache
                        ? AppColors.alerta
                        : AppColors.hoja,
                  ),
                ),
              ],
            ),
          ),
          if (catalogo.cargando)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      ),
    );
  }
}

class _MensajeError extends StatelessWidget {
  final String mensaje;

  const _MensajeError({required this.mensaje});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off, size: 64, color: AppColors.moraClaro),
          const SizedBox(height: 12),
          Text(mensaje, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => context.read<CatalogoProvider>().cargar(),
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}
