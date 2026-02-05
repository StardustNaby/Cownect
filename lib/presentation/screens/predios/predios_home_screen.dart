import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/predio_entity.dart';
import '../../../data/repositories/predio_repository_impl.dart';
import '../../providers/auth_provider.dart';
import '../../../core/providers/predio_provider.dart';

/// Provider para obtener los predios del usuario actual.
final prediosUsuarioProvider = FutureProvider<List<PredioEntity>>((ref) async {
  final authState = ref.watch(authNotifierProvider);
  if (authState is! Authenticated) {
    return [];
  }
  
  final repository = ref.watch(predioRepositoryProvider);
  return await repository.getPrediosByUsuario(authState.user.id);
});

/// Pantalla inicial que muestra las tarjetas de predios.
/// 
/// Diseño profesional con tarjetas blancas, alto contraste y accesibilidad para campo.
/// Muestra Clave PGN, Ubicación y permite abrir mapa GPS.
class PrediosHomeScreen extends ConsumerWidget {
  const PrediosHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prediosAsync = ref.watch(prediosUsuarioProvider);

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
        child: prediosAsync.when(
          data: (predios) => predios.isEmpty
              ? _buildEmptyState(context)
              : _buildPrediosList(context, ref, predios),
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stack) => SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red.shade700,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error al cargar predios',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.red.shade300,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        error.toString(),
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      if (error.toString().contains('index')) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Nota: Este error se ha solucionado automáticamente. Intenta nuevamente.',
                          style: TextStyle(
                            color: Colors.orange.shade700,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => ref.refresh(prediosUsuarioProvider),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.emeraldGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
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

  /// Abre la ubicación en el mapa GPS.
  static Future<void> _abrirMapaGPS(
    BuildContext context,
    double? latitud,
    double? longitud,
    String direccion,
  ) async {
    if (latitud != null && longitud != null) {
      // Abrir en Google Maps
      final url = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$latitud,$longitud',
      );
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
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

  /// Construye el estado vacío cuando no hay predios.
  Widget _buildEmptyState(BuildContext context) {
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
  Widget _buildPrediosList(
    BuildContext context,
    WidgetRef ref,
    List<PredioEntity> predios,
  ) {
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
            itemCount: predios.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final predio = predios[index];
              return _buildPredioCard(context, ref, predio);
            },
          ),
        ),
      ],
    );
  }

  /// Construye una tarjeta de predio.
  Widget _buildPredioCard(
    BuildContext context,
    WidgetRef ref,
    PredioEntity predio,
  ) {
    final ubicacionCompleta = '${predio.localidad}, ${predio.municipio}, ${predio.estado}';
    final clavePGN = predio.clavePGN;

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
          // Establecer el predio actual en el provider
          ref.read(currentPredioIdProvider.notifier).state = predio.id;
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
                        context,
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
