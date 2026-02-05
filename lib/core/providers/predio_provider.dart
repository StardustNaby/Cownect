import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider que almacena el ID del predio actualmente seleccionado.
/// 
/// Este provider permite que todas las pantallas del predio accedan
/// al ID del predio sin necesidad de pasarlo como parámetro en cada navegación.
final currentPredioIdProvider = StateProvider<String?>((ref) => null);

/// Provider que expone si hay un predio seleccionado.
final hasPredioSelectedProvider = Provider<bool>((ref) {
  final predioId = ref.watch(currentPredioIdProvider);
  return predioId != null && predioId.isNotEmpty;
});

