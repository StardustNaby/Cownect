import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Pantalla de inicio del predio.
/// 
/// Dashboard de resumen ganadero con tarjetas de resumen y accesos rápidos.
/// Diseño elegante y comprensible para rancheros.
class InicioScreen extends StatelessWidget {
  const InicioScreen({super.key});

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
              // Título
              Text(
                'Panel de Control',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: 32),

              // Resumen Superior - 3 tarjetas pequeñas
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      context: context,
                      icon: Icons.pets_outlined,
                      title: 'Total Animales',
                      value: '0',
                      color: const Color(0xFF8B6F47), // Color tierra
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSummaryCard(
                      context: context,
                      icon: Icons.medical_services_outlined,
                      title: 'Vacunas Pendientes',
                      value: '0',
                      color: const Color(0xFF9B7A5A), // Color tierra
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSummaryCard(
                      context: context,
                      icon: Icons.landscape_outlined,
                      title: 'Sectores Ocupados',
                      value: '0',
                      color: const Color(0xFF7A5F3F), // Color tierra
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Accesos Rápidos
              Text(
                'Accesos Rápidos',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 16),

              // Botones grandes con iconos
              _buildQuickAccessButton(
                context: context,
                icon: Icons.scale_outlined,
                title: 'Pesar Animal',
                subtitle: 'Registrar peso de ganado',
                onTap: () {
                  // TODO: Navegar a pantalla de pesaje
                },
              ),
              const SizedBox(height: 16),
              _buildQuickAccessButton(
                context: context,
                icon: Icons.medical_services_outlined,
                title: 'Aplicar Vacuna',
                subtitle: 'Registrar vacunación',
                onTap: () {
                  // TODO: Navegar a pantalla de vacunación
                },
              ),
              const SizedBox(height: 16),
              _buildQuickAccessButton(
                context: context,
                icon: Icons.local_shipping_outlined,
                title: 'Registrar Movimiento',
                subtitle: 'Entrada o salida de ganado',
                onTap: () {
                  // TODO: Navegar a pantalla de movimiento
                },
              ),
              const SizedBox(height: 16),
              _buildQuickAccessButton(
                context: context,
                icon: Icons.pets_outlined,
                title: 'Registrar Animal',
                subtitle: 'Agregar nuevo bovino',
                onTap: () {
                  // TODO: Navegar a pantalla de registro
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Construye una tarjeta de resumen pequeña.
  Widget _buildSummaryCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// Construye un botón de acceso rápido grande.
  Widget _buildQuickAccessButton({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
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
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.emeraldGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  icon,
                  color: AppColors.emeraldGreen,
                  size: 36,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.black54,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
