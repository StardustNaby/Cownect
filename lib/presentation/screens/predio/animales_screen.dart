import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/predio_provider.dart';
import '../inventory/inventory_screen.dart';

/// Pantalla de animales del predio.
/// 
/// Muestra el inventario de animales del predio seleccionado.
class AnimalesScreen extends ConsumerWidget {
  final String? predioId;
  
  const AnimalesScreen({super.key, this.predioId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Obtener predioId del parámetro o del provider
    final currentPredioId = predioId ?? ref.watch(currentPredioIdProvider);
    
    // Si se pasa predioId como parámetro, actualizar el provider
    if (predioId != null && predioId != ref.read(currentPredioIdProvider)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(currentPredioIdProvider.notifier).state = predioId;
      });
    }
    
    return InventoryScreen(predioId: currentPredioId);
  }
}




