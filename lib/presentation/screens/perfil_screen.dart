import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Pantalla de perfil y configuración.
/// 
/// Muestra la información del usuario y opciones de configuración de UPP.
class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Navegar a configuración avanzada
            },
            tooltip: 'Configuración',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: const Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Usuario Propietario',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  'usuario@ejemplo.com',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Información Personal',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Editar Perfil'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Navegar a edición de perfil
              },
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Unidades de Producción',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.business),
              title: const Text('Mis UPPs'),
              subtitle: const Text('Gestionar unidades de producción'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Navegar a lista de UPPs
              },
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Configuración',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.notifications_outlined),
              title: const Text('Notificaciones'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Navegar a configuración de notificaciones
              },
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text('Tema'),
              subtitle: const Text('Modo claro / Modo oscuro'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Implementar cambio de tema
              },
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // Cerrar sesión y volver al login
                context.go('/login');
              },
              icon: const Icon(Icons.logout),
              label: const Text('Cerrar Sesión'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

