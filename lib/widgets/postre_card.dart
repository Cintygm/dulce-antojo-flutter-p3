import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../data/models/postre.dart';

/// Tarjeta reutilizable que muestra un postre del catálogo.
class PostreCard extends StatelessWidget {
  final Postre postre;
  final VoidCallback onVerMas;

  const PostreCard({super.key, required this.postre, required this.onVerMas});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onVerMas,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Hero(
                tag: 'postre-${postre.codigo}',
                child: Image.asset(
                  postre.foto,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    postre.nombre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.sell, size: 14, color: AppColors.miel),
                      const SizedBox(width: 4),
                      Text(
                        '\$${postre.precio.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppColors.mora,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
      ),
    );
  }
}
