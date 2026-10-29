import 'package:flutter/material.dart';

import '../models/postre.dart';

// Tarjeta que muestra un postre (se usa varias veces en la lista)
class PostreCard extends StatelessWidget {
  final Postre postre;
  final VoidCallback onVerMas;

  const PostreCard({super.key, required this.postre, required this.onVerMas});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Image.asset(
              postre.foto,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  postre.nombre,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    const Icon(Icons.sell, size: 14, color: Colors.pink),
                    const SizedBox(width: 4),
                    Text('\$${postre.precio.toStringAsFixed(2)}'),
                  ],
                ),
              ],
            ),
          ),
          Center(
            child: TextButton(
              onPressed: onVerMas,
              child: const Text('Ver más'),
            ),
          ),
        ],
      ),
    );
  }
}
