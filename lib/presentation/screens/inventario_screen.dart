import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Pantalla de inventario de animales.
/// 
/// Muestra la lista de bovinos registrados.
class InventarioScreen extends StatelessWidget {
  const InventarioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventario'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implementar búsqueda
            },
            tooltip: 'Buscar',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Implementar filtros
            },
            tooltip: 'Filtrar',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Bovinos Registrados',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          // Ejemplo de items
          _buildBovinoCard(
            context,
            id: 'bovino-001',
            areteTrabajo: '504',
            nombre: 'Bovino 504',
            raza: 'Holstein',
            estado: 'ACTIVO',
          ),
          const SizedBox(height: 12),
          _buildBovinoCard(
            context,
            id: 'bovino-002',
            areteTrabajo: '505',
            nombre: 'Bovino 505',
            raza: 'Angus',
            estado: 'ACTIVO',
          ),
          const SizedBox(height: 12),
          _buildBovinoCard(
            context,
            id: 'bovino-003',
            areteTrabajo: '506',
            nombre: 'Bovino 506',
            raza: 'Hereford',
            estado: 'VENDIDO',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Implementar agregar nuevo bovino
        },
        icon: const Icon(Icons.add),
        label: const Text('Agregar Bovino'),
      ),
    );
  }

  Widget _buildBovinoCard(
    BuildContext context, {
    required String id,
    required String areteTrabajo,
    required String nombre,
    required String raza,
    required String estado,
  }) {
    return Card(
      child: InkWell(
        onTap: () {
          context.push('/bovino/$id');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Hero(
                tag: 'bovino-image-$id',
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.pets,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombre,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Arete: $areteTrabajo • $raza',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Chip(
                      label: Text(estado),
                      backgroundColor: estado == 'ACTIVO'
                          ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)
                          : Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2),
                      labelStyle: const TextStyle(fontSize: 12),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

