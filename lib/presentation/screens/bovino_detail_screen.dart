import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Pantalla de detalle de un bovino.
/// 
/// Muestra la información completa de un bovino específico.
/// Incluye Hero Animation para la transición de la imagen.
class BovinoDetailScreen extends StatelessWidget {
  final String bovinoId;

  const BovinoDetailScreen({
    super.key,
    required this.bovinoId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Bovino'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: Navegar a edición
            },
            tooltip: 'Editar',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Animation para la imagen
            Hero(
              tag: 'bovino-image-$bovinoId',
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.pets,
                  size: 100,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Bovino #504',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 8),
            Text(
              'ID: $bovinoId',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            Text(
              'Información General',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              context,
              icon: Icons.numbers,
              label: 'Arete SINIIGA',
              value: 'MX3100000123',
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              context,
              icon: Icons.tag,
              label: 'Arete de Trabajo',
              value: '504',
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              context,
              icon: Icons.wc,
              label: 'Sexo',
              value: 'Macho',
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              context,
              icon: Icons.calendar_today,
              label: 'Fecha de Nacimiento',
              value: '15/03/2020',
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              context,
              icon: Icons.category,
              label: 'Raza Predominante',
              value: 'Holstein',
            ),
            const SizedBox(height: 24),
            Text(
              'Estado',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              context,
              icon: Icons.work_outline,
              label: 'Estado Productivo',
              value: 'VACA_ORDENA',
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              context,
              icon: Icons.info_outline,
              label: 'Estatus Sistema',
              value: 'ACTIVO',
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implementar edición de bovino
                },
                icon: const Icon(Icons.edit),
                label: const Text('Editar Bovino'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

