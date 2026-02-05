import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/entities/bovino_entity.dart';
import '../../../data/repositories/livestock_repository_impl.dart';
import '../../../core/theme/app_theme.dart';

/// Provider para obtener la lista de bovinos.
/// 
/// Utiliza el [livestockRepositoryProvider] para obtener los bovinos
/// de la UPP activa.
final bovinosProvider = FutureProvider.family<List<BovinoEntity>, String?>((ref, uppId) async {
  final repository = ref.watch(livestockRepositoryProvider(uppId));
  return await repository.getBovinos();
});

/// Pantalla de inventario de bovinos.
/// 
/// Muestra un GridView de 2 columnas con tarjetas elegantes para cada bovino.
/// Incluye skeleton loader mientras carga y estado vacío profesional.
class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchVisible = false;
  String? _uppId; // TODO: Obtener de la UPP activa del usuario

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Filtra los bovinos por arete de trabajo.
  List<BovinoEntity> _filterBovinos(
    List<BovinoEntity> bovinos,
    String query,
  ) {
    if (query.isEmpty) return bovinos;
    final lowerQuery = query.toLowerCase();
    return bovinos.where((bovino) {
      return bovino.areteTrabajo.toLowerCase().contains(lowerQuery) ||
          (bovino.areteSiniiga?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final bovinosAsync = ref.watch(bovinosProvider(_uppId));

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: _isSearchVisible
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Buscar por arete...',
                  border: InputBorder.none,
                ),
                style: const TextStyle(fontSize: 18, color: Colors.black),
                onChanged: (_) => setState(() {}),
              )
            : Text(
                'Animales',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
        actions: [
          if (_isSearchVisible)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.black87),
              onPressed: () {
                setState(() {
                  _isSearchVisible = false;
                  _searchController.clear();
                });
              },
              tooltip: 'Cerrar búsqueda',
            )
          else
            IconButton(
              icon: const Icon(Icons.search, color: Colors.black87),
              onPressed: () {
                setState(() {
                  _isSearchVisible = true;
                });
              },
              tooltip: 'Buscar',
            ),
        ],
      ),
      body: bovinosAsync.when(
        data: (bovinos) {
          final filteredBovinos = _filterBovinos(
            bovinos,
            _searchController.text,
          );

          if (filteredBovinos.isEmpty) {
            return _buildEmptyState(context);
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(bovinosProvider(_uppId));
            },
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              itemCount: filteredBovinos.length,
              itemBuilder: (context, index) {
                return _buildBovinoCard(context, filteredBovinos[index]);
              },
            ),
          );
        },
        loading: () => _buildSkeletonLoader(),
        error: (error, stackTrace) => _buildErrorState(context, error, stackTrace),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Navegar a pantalla de registro de bovino
        },
        backgroundColor: AppColors.emeraldGreen,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_circle_outline, size: 28),
        label: const Text(
          'Registrar Animal',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// Construye el skeleton loader mientras carga.
  Widget _buildSkeletonLoader() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const Spacer(),
                Container(
                  width: double.infinity,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 100,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Construye el estado vacío elegante.
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _searchController.text.isEmpty
                  ? Icons.pets_outlined
                  : Icons.search_off,
              size: 120,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 32),
            Text(
              _searchController.text.isEmpty
                  ? 'Aún no tienes animales registrados'
                  : 'No se encontraron resultados',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (_searchController.text.isEmpty) ...[
              Text(
                'Comienza registrando tu primer animal',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.black87,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Navegar a pantalla de registro de bovino
                },
                icon: const Icon(Icons.add_circle_outline, size: 28),
                label: const Text(
                  'Registrar primer animal',
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
            ] else ...[
              Text(
                'Intenta con otro número de arete',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.black87,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Construye el estado de error.
  Widget _buildErrorState(BuildContext context, Object error, StackTrace stackTrace) {
    String errorMessage = 'Error al cargar los animales';
    
    if (error.toString().contains('UPP')) {
      errorMessage = 'No se ha seleccionado una UPP activa';
    } else if (error.toString().contains('internet') ||
        error.toString().contains('conexión')) {
      errorMessage = 'No hay conexión a internet';
    } else {
      errorMessage = 'Error al cargar los datos';
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 120,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 32),
            Text(
              'Error',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.black87,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              onPressed: () {
                ref.invalidate(bovinosProvider(_uppId));
              },
              icon: const Icon(Icons.refresh, size: 24),
              label: const Text(
                'Reintentar',
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

  /// Construye una tarjeta elegante para un bovino.
  Widget _buildBovinoCard(BuildContext context, BovinoEntity bovino) {
    final isActivo = bovino.estatusSistema == 'ACTIVO';
    final displayName = bovino.areteTrabajo;

    return Card(
      elevation: 2,
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
          context.push('/bovino/${bovino.id}');
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Indicador de estado activo
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (isActivo)
                    Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: AppColors.emeraldGreen,
                        shape: BoxShape.circle,
                      ),
                    )
                  else
                    const SizedBox(width: 12),
                  Hero(
                    tag: 'bovino-image-${bovino.id}',
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.emeraldGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.pets,
                        size: 32,
                        color: AppColors.emeraldGreen,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Nombre/Arete en grande
              Text(
                displayName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Colors.black,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              // Raza
              Text(
                bovino.razaPredominante,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // Estado productivo
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  bovino.estadoProductivo.replaceAll('_', ' '),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
