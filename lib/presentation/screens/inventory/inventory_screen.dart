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
/// Incluye funcionalidad de pull-to-refresh y búsqueda por arete de trabajo.
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
      appBar: AppBar(
        title: _isSearchVisible
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Buscar por arete...',
                  border: InputBorder.none,
                ),
                style: const TextStyle(fontSize: 16),
                onChanged: (_) => setState(() {}),
              )
            : const Text('Inventario'),
        actions: [
          if (_isSearchVisible)
            IconButton(
              icon: const Icon(Icons.close),
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
              icon: const Icon(Icons.search),
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _searchController.text.isEmpty
                        ? Icons.inventory_2_outlined
                        : Icons.search_off,
                    size: 64,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _searchController.text.isEmpty
                        ? 'No hay bovinos registrados'
                        : 'No se encontraron resultados',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  if (_searchController.text.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Intenta con otro número de arete',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
            );
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
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: AppColors.emeraldGreen,
          ),
        ),
        error: (error, stackTrace) {
          String errorMessage = 'Error al cargar los bovinos';
          
          if (error.toString().contains('UPP')) {
            errorMessage = 'No se ha seleccionado una UPP activa';
          } else if (error.toString().contains('internet') ||
              error.toString().contains('conexión')) {
            errorMessage = 'No hay conexión a internet';
          } else {
            errorMessage = error.toString();
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    errorMessage,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    ref.invalidate(bovinosProvider(_uppId));
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                ),
              ],
            ),
          );
        },
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
      ),
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
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.emeraldGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.pets,
                        size: 28,
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
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              // Raza
              Text(
                bovino.razaPredominante,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // Estado productivo
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  bovino.estadoProductivo.replaceAll('_', ' '),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
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

