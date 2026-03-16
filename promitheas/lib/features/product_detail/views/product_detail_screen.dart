import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProductDetailScreen extends StatelessWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Producto'),
        // GoRouter y AppBar son tan listos que normalmente ponen el botón de atrás solos,
        // pero podemos forzar el comportamiento de la flecha si queremos.
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Esta es la forma correcta de volver atrás con go_router
            if (context.canPop()) {
              context.pop();
            } else {
              // Fallback por si acaso llegan aquí desde un enlace directo
              context.go('/home');
            }
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.construction, size: 80, color: Colors.orange),
            const SizedBox(height: 24),
            Text(
              'Pantalla en construcción',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            // Esto es clave para debuggear: comprobamos que el ID viaja bien
            Text(
              'Viendo producto ID: $productId',
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Volver a Home'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(
                  0xFFE8651A,
                ), // Tu naranja corporativo
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
