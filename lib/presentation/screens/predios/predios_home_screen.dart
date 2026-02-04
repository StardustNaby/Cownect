import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/predio_entity.dart';

/// Pantalla inicial que muestra las tarjetas de predios.
/// 
/// Diseño profesional con tarjetas blancas, alto contraste y accesibilidad para campo.
/// Muestra Clave PGN, Ubicación y permite abrir mapa GPS.
class PrediosHomeScreen extends ConsumerStatefulWidget {
  const PrediosHomeScreen({super.key});

  @override
  ConsumerState<PrediosHomeScreen> createState() => _PrediosHomeScreenState();
}

class _PrediosHomeScreenState extends ConsumerState<PrediosHomeScreen> {
  // TODO: Obtener predios del usuario desde el provider/repository
  final List<PredioEntity> _predios = []; // Lista vacía por ahora

  /// Abre la ubicación en el mapa GPS.
  Future<void> _abrirMapaGPS(double? latitud, double? longitud, String direccion) async {
    if (latitud != null && longitud != null) {
      // Abrir en Google Maps
      final url = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$latitud,$longitud',
      );
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se pudo abrir el mapa'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      // Si no hay coordenadas, buscar por dirección
      final url = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(direccion)}',
      );
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground, // #f5f5f5
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
        child: _predios.isEmpty
            ? _buildEmptyState()
            : _buildPrediosList(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/predio/registro'),
        backgroundColor: AppColors.emeraldGreen,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_circle_outline, size: 28),
        label: const Text(
          'Registrar Predio',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// Construye el estado vacío cuando no hay predios.
  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.agriculture_outlined,
              size: 120,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 32),
            Text(
              'Aún no tienes predios registrados',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Comienza agregando el primero',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              onPressed: () => context.push('/predio/registro'),
              icon: const Icon(Icons.add_circle_outline, size: 24),
              label: const Text(
                'Registrar mi primer predio',
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

  /// Construye la lista de predios.
  Widget _buildPrediosList() {
    return Column(
      children: [
        // Título
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Row(
            children: [
              Text(
                'Mis Predios',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
              ),
            ],
          ),
        ),
        // Lista de predios
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            itemCount: _predios.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final predio = _predios[index];
              return _buildPredioCard(predio);
            },
          ),
        ),
      ],
    );
  }

  /// Construye una tarjeta de predio.
  Widget _buildPredioCard(PredioEntity predio) {
    final ubicacionCompleta = '${predio.localidad}, ${predio.municipio}, ${predio.estado}';
    final clavePGN = predio.claveCatastral ?? predio.upp;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      color: Colors.white,
      child: InkWell(
        onTap: () {
          // Navegar al predio seleccionado
          context.go('/predio/home');
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fila superior: Icono, Nombre y Badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.emeraldGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.agriculture_outlined,
                      color: AppColors.emeraldGreen,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          predio.nombre,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Badge Activo
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.emeraldGreen.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.emeraldGreen.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            'Activo',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.emeraldGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Icono de mapa
                  if (predio.latitud != null && predio.longitud != null)
                    IconButton(
                      icon: Icon(
                        Icons.map_outlined,
                        color: AppColors.emeraldGreen,
                        size: 24,
                      ),
                      onPressed: () => _abrirMapaGPS(
                        predio.latitud,
                        predio.longitud,
                        predio.direccion,
                      ),
                      tooltip: 'Abrir en mapa',
                    ),
                ],
              ),
              const SizedBox(height: 16),
              // Clave PGN
              Row(
                children: [
                  Icon(
                    Icons.badge_outlined,
                    size: 18,
                    color: Colors.black54,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Clave PGN: ',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    clavePGN,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Ubicación
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 18,
                    color: Colors.black54,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      ubicacionCompleta,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              if (predio.direccion.isNotEmpty) ...[
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(left: 26),
                  child: Text(
                    predio.direccion,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
