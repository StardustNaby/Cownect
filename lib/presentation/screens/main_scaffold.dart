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
              Icons.home_outlined,
              size: 28, // Ícono grande
              color: isDark ? AppColors.darkSecondary : AppColors.lightSecondary,
            ),
            selectedIcon: Icon(
              Icons.home,
              size: 28,
              color: AppColors.emeraldGreen,
            ),
            label: 'Inicio',
            tooltip: 'Inicio del predio',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.map_outlined,
              size: 28, // Ícono grande
              color: isDark ? AppColors.darkSecondary : AppColors.lightSecondary,
            ),
            selectedIcon: Icon(
              Icons.map,
              size: 28,
              color: AppColors.emeraldGreen,
            ),
            label: 'Sectores',
            tooltip: 'Sectores del predio',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.pets_outlined,
              size: 28, // Ícono grande
              color: isDark ? AppColors.darkSecondary : AppColors.lightSecondary,
            ),
            selectedIcon: Icon(
              Icons.pets,
              size: 28,
              color: AppColors.emeraldGreen,
            ),
            label: 'Animales',
            tooltip: 'Animales del predio',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.people_outline,
              size: 28, // Ícono grande
              color: isDark ? AppColors.darkSecondary : AppColors.lightSecondary,
            ),
            selectedIcon: Icon(
              Icons.people,
              size: 28,
              color: AppColors.emeraldGreen,
            ),
            label: 'Colaboradores',
            tooltip: 'Colaboradores del predio',
          ),
        ],
      ),
    );
  }
}

