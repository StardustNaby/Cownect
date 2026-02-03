import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

/// Scaffold principal con navegación por tabs.
/// 
/// Usa NavigationShell de go_router para mantener el estado
/// de cada tab sin perder información al cambiar entre secciones.
class MainScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainScaffold({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            // Si la ruta ya está en la pila, no crear una nueva
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        // Alto contraste y diseño accesible
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        indicatorColor: AppColors.emeraldGreen.withValues(alpha: 0.2),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        height: 72, // Altura generosa para íconos grandes
        elevation: 8,
        destinations: [
          NavigationDestination(
            icon: Icon(
              Icons.table_rows_rounded,
              size: 28, // Ícono grande
              color: isDark ? AppColors.darkSecondary : AppColors.lightSecondary,
            ),
            selectedIcon: Icon(
              Icons.table_rows_rounded,
              size: 28,
              color: AppColors.emeraldGreen,
            ),
            label: 'Inventario',
            tooltip: 'Inventario de animales',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.map_rounded,
              size: 28, // Ícono grande
              color: isDark ? AppColors.darkSecondary : AppColors.lightSecondary,
            ),
            selectedIcon: Icon(
              Icons.map_rounded,
              size: 28,
              color: AppColors.emeraldGreen,
            ),
            label: 'Infraestructura',
            tooltip: 'Mapa e infraestructura',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.settings_suggest_rounded,
              size: 28, // Ícono grande
              color: isDark ? AppColors.darkSecondary : AppColors.lightSecondary,
            ),
            selectedIcon: Icon(
              Icons.settings_suggest_rounded,
              size: 28,
              color: AppColors.emeraldGreen,
            ),
            label: 'Perfil',
            tooltip: 'Perfil y configuración de UPP',
          ),
        ],
      ),
    );
  }
}

