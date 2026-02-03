import 'package:flutter/material.dart';

/// Pantalla de infraestructura y mapa.
/// 
/// Muestra el mapa de la UPP y la infraestructura disponible (corrales, etc.).
class InfraestructuraScreen extends StatelessWidget {
  const InfraestructuraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Infraestructura'),
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () {
              // TODO: Implementar vista de mapa
            },
            tooltip: 'Vista de Mapa',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Corrales e Instalaciones',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.fence),
              title: const Text('Corral 1'),
              subtitle: const Text('Capacidad: 50 bovinos'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Navegar a detalle de corral
              },
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.fence),
              title: const Text('Corral 2'),
              subtitle: const Text('Capacidad: 30 bovinos'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Navegar a detalle de corral
              },
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.warehouse),
              title: const Text('Almacén de Forraje'),
              subtitle: const Text('Capacidad: 100 toneladas'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Navegar a detalle de almacén
              },
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                // TODO: Implementar agregar infraestructura
              },
              icon: const Icon(Icons.add),
              label: const Text('Agregar Infraestructura'),
            ),
          ),
        ],
      ),
    );
  }
}

