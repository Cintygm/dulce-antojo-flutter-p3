import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../data/models/postre.dart';
import '../providers/reserva_provider.dart';

/// Pantalla 2: detalle del postre y formulario de reserva.
class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final nombreCtrl = TextEditingController();
  int cantidad = 1;
  bool enviando = false;

  @override
  void dispose() {
    nombreCtrl.dispose();
    super.dispose();
  }

  void restar() {
    if (cantidad > 1) setState(() => cantidad--);
  }

  void sumar() => setState(() => cantidad++);

  Future<void> reservar(Postre postre) async {
    final nombre = nombreCtrl.text.trim();
    if (nombre.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Escribe tu nombre')));
      return;
    }
    setState(() => enviando = true);
    await context.read<ReservaProvider>().crearReserva(
      postre: postre,
      cliente: nombre,
      cantidad: cantidad,
    );
    if (!mounted) return;
    // Regresamos a la Pantalla 1 con un mensaje.
    Navigator.pop(context, '$nombre reservó $cantidad ${postre.nombre}');
  }

  @override
  Widget build(BuildContext context) {
    // Recibimos el postre que se envió desde la Pantalla 1.
    final postre = ModalRoute.of(context)!.settings.arguments as Postre;
    final total = postre.precio * cantidad;

    return Scaffold(
      appBar: AppBar(title: Text(postre.nombre)),
      body: ListView(
        children: [
          Hero(
            tag: 'postre-${postre.codigo}',
            child: Image.asset(postre.foto, height: 220, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  postre.nombre,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text(
                  'Código: ${postre.codigo}',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(postre.detalle),
                const Divider(height: 30),
                Text(
                  'Reservar postre',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: nombreCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Tu nombre',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text('Cantidad:'),
                    IconButton(
                      onPressed: restar,
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    Text('$cantidad', style: const TextStyle(fontSize: 18)),
                    IconButton(
                      onPressed: sumar,
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                    const Spacer(),
                    Text(
                      'Total: \$${total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.mora,
                      ),
                    ),
                  ],
                ),
                // @foto-referencia
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: enviando ? null : () => reservar(postre),
                    icon: enviando
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check),
                    label: const Text('Reservar'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
