import 'package:flutter/material.dart';

import '../models/postre.dart';

// Pantalla 2: detalle del postre y formulario de reserva
class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final nombreCtrl = TextEditingController();
  int cantidad = 1;

  void restar() {
    if (cantidad > 1) {
      setState(() {
        cantidad--;
      });
    }
  }

  void sumar() {
    setState(() {
      cantidad++;
    });
  }

  void reservar(Postre postre) {
    if (nombreCtrl.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Escribe tu nombre')));
      return;
    }
    // Regresamos a la Pantalla 1 con un mensaje
    Navigator.pop(
      context,
      '${nombreCtrl.text} reservó $cantidad ${postre.nombre}',
    );
  }

  @override
  Widget build(BuildContext context) {
    // Recibimos el postre que se envió desde la Pantalla 1
    final postre = ModalRoute.of(context)!.settings.arguments as Postre;
    double total = postre.precio * cantidad;

    return Scaffold(
      appBar: AppBar(
        title: Text(postre.nombre),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          Image.asset(postre.foto, height: 220, fit: BoxFit.cover),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  postre.nombre,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Código: ${postre.codigo}',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(postre.detalle),
                const Divider(height: 30),
                const Text(
                  'Reservar postre',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: nombreCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Tu nombre',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
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
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => reservar(postre),
                    icon: const Icon(Icons.check),
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
