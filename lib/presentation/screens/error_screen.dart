import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Pantalla de error 404.
/// 
/// Se muestra cuando se intenta acceder a una ruta que no existe.
class ErrorScreen extends StatelessWidget {
  final String? error;
  final String? path;

  const ErrorScreen({
    super.key,
    this.error,
    this.path,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.red,
              ),
              const SizedBox(height: 32),
              Text(
                'Página no encontrada',
                style: Theme.of(context).textTheme.displaySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'La ruta solicitada no existe o no está disponible.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              if (path != null) ...[
                const SizedBox(height: 16),
                Text(
                  'Ruta: $path',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () {
                  context.go('/inventario');
                },
                child: const Text('Ir al Inventario'),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {
                  context.go('/login');
                },
                child: const Text('Volver al Inicio'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

