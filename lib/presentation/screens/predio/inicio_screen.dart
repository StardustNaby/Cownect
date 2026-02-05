import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/bovino_entity.dart';
import '../../../data/repositories/livestock_repository_impl.dart';
import '../../providers/auth_provider.dart';
import '../../../core/providers/predio_provider.dart';

/// Provider para obtener los bovinos de un predio específico.
final bovinosPredioProvider = FutureProvider.family<List<BovinoEntity>, String?>((ref, predioId) async {
  if (predioId == null || predioId.isEmpty) {
    return [];
  }
  
  final repository = ref.watch(livestockRepositoryProvider(predioId));
  return await repository.getBovinos(idUpp: predioId);
});

/// Pantalla de inicio del predio con tablero de estadísticas.
/// 
/// Dashboard de resumen ganadero con tarjetas de resumen y estadísticas detalladas.
/// Diseño elegante y comprensible para rancheros (Asistente Digital de Campo).
class InicioScreen extends ConsumerWidget {
  final String? predioId;
  
  const InicioScreen({super.key, this.predioId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Obtener predioId del parámetro o del provider
    final currentPredioId = predioId ?? ref.watch(currentPredioIdProvider);
    
    // Si se pasa predioId como parámetro, actualizar el provider
    if (predioId != null && predioId != currentPredioId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(currentPredioIdProvider.notifier).state = predioId;
      });
    }
    
    final bovinosAsync = ref.watch(bovinosPredioProvider(currentPredioId));

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: bovinosAsync.when(
          data: (bovinos) {
            if (bovinos.isEmpty) {
              return _buildEmptyState(context);
            }
            return _buildDashboard(context, bovinos);
          },
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stack) => Center(
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
                  'Error al cargar estadísticas',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => ref.refresh(bovinosPredioProvider(predioId)),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Construye el estado vacío cuando no hay animales.
  Widget _buildEmptyState(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          Icon(
            Icons.pets_outlined,
            size: 120,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 32),
          Text(
            'Registra tus animales para ver tus estadísticas',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Comienza agregando tu primer animal al inventario',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          ElevatedButton.icon(
            onPressed: () {
              // Navegar a la pantalla de animales para registrar
              context.go('/predio/animales');
            },
            icon: const Icon(Icons.add_circle_outline, size: 24),
            label: const Text(
              'Registrar mi primer animal',
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
    );
  }

  /// Construye el dashboard con estadísticas.
  Widget _buildDashboard(BuildContext context, List<BovinoEntity> bovinos) {
    // Calcular estadísticas
    final estadisticas = _calcularEstadisticas(bovinos);

    return SingleChildScrollView(
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
                  value: estadisticas.totalAnimales.toString(),
                  color: AppColors.emeraldGreen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  context: context,
                  icon: Icons.medical_services_outlined,
                  title: 'Vacunas Pendientes',
                  value: estadisticas.vacunasPendientes.toString(),
                  color: estadisticas.vacunasPendientes > 0 
                      ? Colors.orange 
                      : AppColors.emeraldGreen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  context: context,
                  icon: Icons.landscape_outlined,
                  title: 'Animales Activos',
                  value: estadisticas.animalesActivos.toString(),
                  color: AppColors.emeraldGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // 1. Resumen de Inventario (Estado del Hato)
          _buildSectionTitle(context, 'Resumen de Inventario'),
          const SizedBox(height: 16),
          
          // Distribución por Sexo
          Card(
            color: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.pets_outlined,
                        color: AppColors.emeraldGreen,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Distribución por Sexo',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          'Machos',
                          estadisticas.machos.toString(),
                          estadisticas.porcentajeMachos,
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatItem(
                          'Hembras',
                          estadisticas.hembras.toString(),
                          estadisticas.porcentajeHembras,
                          Colors.pink,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Conteo por Etapa Productiva
          Card(
            color: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.timeline_outlined,
                        color: AppColors.emeraldGreen,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Etapa Productiva',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...estadisticas.porEstadoProductivo.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _getEstadoProductivoLabel(entry.key),
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.emeraldGreen.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              entry.value.toString(),
                              style: TextStyle(
                                color: AppColors.emeraldGreen,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Estatus del Sistema
          Card(
            color: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.emeraldGreen,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Estatus del Sistema',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...estadisticas.porEstatusSistema.entries.map((entry) {
                    final color = _getColorEstatus(entry.key);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _getEstatusSistemaLabel(entry.key),
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Text(
                            entry.value.toString(),
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // 2. Control Sanitario y Trazabilidad
          _buildSectionTitle(context, 'Control Sanitario'),
          const SizedBox(height: 16),
          
          Card(
            color: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.medical_services_outlined,
                        color: AppColors.emeraldGreen,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Cobertura de Vacunación',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Barra de progreso de vacunación
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Animales con vacunas al día',
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '${estadisticas.porcentajeVacunacion.toStringAsFixed(0)}%',
                            style: TextStyle(
                              color: estadisticas.porcentajeVacunacion >= 80
                                  ? AppColors.emeraldGreen
                                  : estadisticas.porcentajeVacunacion >= 50
                                      ? Colors.orange
                                      : Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: estadisticas.porcentajeVacunacion / 100,
                          minHeight: 12,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            estadisticas.porcentajeVacunacion >= 80
                                ? AppColors.emeraldGreen
                                : estadisticas.porcentajeVacunacion >= 50
                                    ? Colors.orange
                                    : Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (estadisticas.vacunasPendientes > 0) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.orange.shade300,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.orange.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '${estadisticas.vacunasPendientes} animales requieren atención sanitaria',
                              style: TextStyle(
                                color: Colors.orange.shade700,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Tasa de Mortalidad
          Card(
            color: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.trending_down_outlined,
                        color: estadisticas.tasaMortalidad > 5 
                            ? Colors.red 
                            : estadisticas.tasaMortalidad > 2
                                ? Colors.orange
                                : AppColors.emeraldGreen,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Tasa de Mortalidad',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        estadisticas.tasaMortalidad.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: estadisticas.tasaMortalidad > 5 
                              ? Colors.red 
                              : estadisticas.tasaMortalidad > 2
                                  ? Colors.orange
                                  : AppColors.emeraldGreen,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '%',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${estadisticas.muertos} animales fallecidos de ${estadisticas.totalAnimales} totales',
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Accesos Rápidos
          _buildSectionTitle(context, 'Accesos Rápidos'),
          const SizedBox(height: 16),

          _buildQuickAccessButton(
            context: context,
            icon: Icons.pets_outlined,
            title: 'Registrar Animal',
            subtitle: 'Agregar nuevo bovino al inventario',
            onTap: () {
              context.go('/predio/animales');
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
            icon: Icons.local_shipping_outlined,
            title: 'Registrar Movimiento',
            subtitle: 'Entrada o salida de ganado',
            onTap: () {
              // TODO: Navegar a pantalla de movimiento
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  /// Calcula todas las estadísticas del hato.
  _EstadisticasHato _calcularEstadisticas(List<BovinoEntity> bovinos) {
    final totalAnimales = bovinos.length;
    final animalesActivos = bovinos.where((b) => b.estatusSistema == 'ACTIVO').length;
    
    // Distribución por sexo
    final machos = bovinos.where((b) => b.sexo == 'M').length;
    final hembras = bovinos.where((b) => b.sexo == 'H').length;
    final porcentajeMachos = totalAnimales > 0 ? (machos / totalAnimales * 100) : 0.0;
    final porcentajeHembras = totalAnimales > 0 ? (hembras / totalAnimales * 100) : 0.0;

    // Por estado productivo
    final porEstadoProductivo = <String, int>{};
    for (final estado in BovinoEntity.estadosProductivosValidos) {
      porEstadoProductivo[estado] = bovinos.where((b) => b.estadoProductivo == estado).length;
    }

    // Por estatus del sistema
    final porEstatusSistema = <String, int>{};
    for (final estatus in BovinoEntity.estatusSistemaValidos) {
      porEstatusSistema[estatus] = bovinos.where((b) => b.estatusSistema == estatus).length;
    }

    // Control sanitario (simulado - en producción se calcularía desde registros de vacunación)
    final vacunasPendientes = (totalAnimales * 0.15).round(); // 15% aproximado
    final porcentajeVacunacion = totalAnimales > 0 
        ? ((totalAnimales - vacunasPendientes) / totalAnimales * 100) 
        : 100.0;

    // Tasa de mortalidad
    final muertos = bovinos.where((b) => b.estatusSistema == 'MUERTO').length;
    final tasaMortalidad = totalAnimales > 0 ? (muertos / totalAnimales * 100) : 0.0;

    return _EstadisticasHato(
      totalAnimales: totalAnimales,
      animalesActivos: animalesActivos,
      machos: machos,
      hembras: hembras,
      porcentajeMachos: porcentajeMachos,
      porcentajeHembras: porcentajeHembras,
      porEstadoProductivo: porEstadoProductivo,
      porEstatusSistema: porEstatusSistema,
      vacunasPendientes: vacunasPendientes,
      porcentajeVacunacion: porcentajeVacunacion,
      muertos: muertos,
      tasaMortalidad: tasaMortalidad,
    );
  }

  /// Construye un título de sección.
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: 22,
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

  /// Construye un item de estadística.
  Widget _buildStatItem(String label, String value, double percentage, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage / 100,
            minHeight: 8,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${percentage.toStringAsFixed(1)}%',
          style: TextStyle(
            color: Colors.black54,
            fontSize: 12,
          ),
        ),
      ],
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

  /// Obtiene la etiqueta legible para el estado productivo.
  String _getEstadoProductivoLabel(String estado) {
    switch (estado) {
      case 'CRIA':
        return 'Cría';
      case 'DESTETADO':
        return 'Destetado';
      case 'VAQUILLA':
        return 'Vaquilla';
      case 'TORO_ENGORDA':
        return 'Toro de Engorda';
      case 'VACA_ORDENA':
        return 'Vaca de Ordeña';
      case 'VACA_SECA':
        return 'Vaca Seca';
      default:
        return estado;
    }
  }

  /// Obtiene la etiqueta legible para el estatus del sistema.
  String _getEstatusSistemaLabel(String estatus) {
    switch (estatus) {
      case 'ACTIVO':
        return 'Activo';
      case 'VENDIDO':
        return 'Vendido';
      case 'MUERTO':
        return 'Muerto';
      case 'ROBADO':
        return 'Robado';
      default:
        return estatus;
    }
  }

  /// Obtiene el color según el estatus del sistema.
  Color _getColorEstatus(String estatus) {
    switch (estatus) {
      case 'ACTIVO':
        return AppColors.emeraldGreen;
      case 'VENDIDO':
        return Colors.blue;
      case 'MUERTO':
        return Colors.red;
      case 'ROBADO':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}

/// Clase para almacenar las estadísticas calculadas del hato.
class _EstadisticasHato {
  final int totalAnimales;
  final int animalesActivos;
  final int machos;
  final int hembras;
  final double porcentajeMachos;
  final double porcentajeHembras;
  final Map<String, int> porEstadoProductivo;
  final Map<String, int> porEstatusSistema;
  final int vacunasPendientes;
  final double porcentajeVacunacion;
  final int muertos;
  final double tasaMortalidad;

  _EstadisticasHato({
    required this.totalAnimales,
    required this.animalesActivos,
    required this.machos,
    required this.hembras,
    required this.porcentajeMachos,
    required this.porcentajeHembras,
    required this.porEstadoProductivo,
    required this.porEstatusSistema,
    required this.vacunasPendientes,
    required this.porcentajeVacunacion,
    required this.muertos,
    required this.tasaMortalidad,
  });
}
