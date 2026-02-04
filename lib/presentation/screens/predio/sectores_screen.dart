import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Pantalla de sectores del predio.
class SectoresScreen extends StatelessWidget {
  const SectoresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Sectores',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              // TODO: Agregar contenido de sectores
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.map_outlined,
                        size: 64,
                        color: AppColors.emeraldGreen,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Gestión de Sectores',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


