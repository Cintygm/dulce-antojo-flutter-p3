import 'package:flutter/material.dart';

import '../models/postre.dart';
import '../widgets/postre_card.dart';

// Pantalla 1: catálogo de postres
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Abre la Pantalla 2 enviando el postre elegido
  void abrirDetalle(BuildContext context, Postre postre) async {
    final respuesta = await Navigator.pushNamed(
      context,
      '/detalle',
      arguments: postre,
    );

    // Si la Pantalla 2 devolvió un mensaje, lo mostramos abajo
    if (respuesta != null && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(respuesta.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dulce Antojo'),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.pink[50],
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Icon(Icons.cake, size: 36, color: Colors.pink),
                SizedBox(width: 10),
                Text('Postres hechos en casa'),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: postres.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.72,
              ),
              itemBuilder: (context, i) {
                return PostreCard(
                  postre: postres[i],
                  onVerMas: () => abrirDetalle(context, postres[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
