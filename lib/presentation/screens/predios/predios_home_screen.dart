import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

/// Pantalla inicial que muestra las tarjetas de predios y ajustes.
/// 
/// Si no hay predios, muestra opción para registrar uno.
class PrediosHomeScreen extends ConsumerStatefulWidget {
  const PrediosHomeScreen({super.key});

  @override
  ConsumerState<PrediosHomeScreen> createState() => _PrediosHomeScreenState();
}

class _PrediosHomeScreenState extends ConsumerState<PrediosHomeScreen> {
  // TODO: Obtener predios del usuario desde el provider/repository
  final List<Map<String, String>> _predios = []; // Lista vacía por ahora

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Cownect',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black87),
            onPressed: () => context.push('/ajustes'),
            tooltip: 'Ajustes',
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.black87),
            onPressed: () => context.push('/perfil'),
            tooltip: 'Perfil',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              // Título
              Text(
                'Mis Predios',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),

              // Lista de predios o mensaje si no hay
              if (_predios.isEmpty)
                // Tarjeta para registrar nuevo predio
                _buildPredioCard(
                  context: context,
                  nombre: 'Registrar Predio',
                  upp: 'Nuevo',
                  ubicacion: 'Toca para crear',
                  isNew: true,
                  onTap: () => context.push('/predio/registro'),
                )
              else
                // Lista de predios existentes
                ..._predios.map((predio) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildPredioCard(
                    context: context,
                    nombre: predio['nombre'] ?? 'Sin nombre',
                    upp: predio['upp'] ?? 'Sin UPP',
                    ubicacion: predio['ubicacion'] ?? 'Sin ubicación',
                    isNew: false,
                    onTap: () {
                      // Navegar al predio seleccionado
                      context.go('/predio/${predio['id']}');
                    },
                  ),
                )),

              const SizedBox(height: 32),

              // Tarjeta de Ajustes
              _buildAjustesCard(context),
            ],
          ),
        ),
      ),
    );
  }

  /// Construye una tarjeta de predio.
  Widget _buildPredioCard({
    required BuildContext context,
    required String nombre,
    required String upp,
    required String ubicacion,
    required bool isNew,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isNew 
              ? AppColors.emeraldGreen.withOpacity(0.3)
              : Colors.grey.shade300,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isNew
                          ? AppColors.emeraldGreen.withOpacity(0.1)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isNew ? Icons.add_circle_outline : Icons.agriculture_outlined,
                      color: isNew ? AppColors.emeraldGreen : Colors.black87,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nombre,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'UPP: $upp',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (!isNew) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 20,
                      color: Colors.black54,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        ubicacion,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Construye la tarjeta de ajustes.
  Widget _buildAjustesCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.grey.shade300,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () => context.push('/ajustes'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.settings_outlined,
                  color: Colors.black87,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Ajustes',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.black54,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

