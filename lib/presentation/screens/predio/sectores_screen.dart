import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Pantalla de sectores del predio.
/// 
/// Muestra los corrales/potreros como unidades de espacio con carga animal.
/// Diseño elegante con tarjetas horizontales y barras de progreso.
class SectoresScreen extends StatelessWidget {
  const SectoresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Obtener sectores del predio desde el provider/repository
    final List<Map<String, dynamic>> _sectores = []; // Lista vacía por ahora

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: _sectores.isEmpty
            ? _buildEmptyState(context)
            : _buildSectoresList(context, _sectores),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Navegar a pantalla de registro de sector
        },
        backgroundColor: AppColors.emeraldGreen,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_circle_outline, size: 28),
        label: const Text(
          'Registrar Sector',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// Construye el estado vacío.
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.landscape_outlined,
              size: 120,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 32),
            Text(
              'Aún no tienes sectores registrados',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Comienza registrando tu primer corral o potrero',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.black87,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Navegar a pantalla de registro de sector
              },
              icon: const Icon(Icons.add_circle_outline, size: 28),
              label: const Text(
                'Registrar primer sector',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.emeraldGreen,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 64),
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye la lista de sectores.
  Widget _buildSectoresList(BuildContext context, List<Map<String, dynamic>> sectores) {
    return Column(
      children: [
        // Título
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Row(
            children: [
              Text(
                'Sectores',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
              ),
            ],
          ),
        ),
        // Lista de sectores
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            itemCount: sectores.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final sector = sectores[index];
              return _buildSectorCard(
                context: context,
                nombre: sector['nombre'] ?? 'Sin nombre',
                capacidad: sector['capacidad'] ?? 0,
                ocupados: sector['ocupados'] ?? 0,
              );
            },
          ),
        ),
      ],
    );
  }

  /// Construye una tarjeta horizontal de sector.
  Widget _buildSectorCard({
    required BuildContext context,
    required String nombre,
    required int capacidad,
    required int ocupados,
  }) {
    final porcentaje = capacidad > 0 ? (ocupados / capacidad).clamp(0.0, 1.0) : 0.0;
    final porcentajeTexto = (porcentaje * 100).toInt();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      color: Colors.white,
      child: InkWell(
        onTap: () {
          // TODO: Navegar a detalle del sector
        },
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              // Icono de corral
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.emeraldGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.landscape_outlined,
                  color: AppColors.emeraldGreen,
                  size: 36,
                ),
              ),
              const SizedBox(width: 20),
              // Información del sector
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
                    const SizedBox(height: 12),
                    // Barra de progreso de carga animal
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Carga Animal',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              '$ocupados / $capacidad',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: porcentaje,
                            minHeight: 12,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              porcentaje >= 0.9
                                  ? Colors.red.shade400
                                  : porcentaje >= 0.7
                                      ? Colors.orange.shade400
                                      : AppColors.emeraldGreen,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$porcentajeTexto% ocupado',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Icono de mapa
              IconButton(
                icon: Icon(
                  Icons.map_outlined,
                  color: AppColors.emeraldGreen,
                  size: 28,
                ),
                onPressed: () {
                  // TODO: Abrir mapa del sector
                },
                tooltip: 'Ver ubicación',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
