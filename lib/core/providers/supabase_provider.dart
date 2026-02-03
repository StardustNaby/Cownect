import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider que expone la instancia del cliente de Supabase.
/// 
/// Este provider inicializa y proporciona acceso al cliente de Supabase
/// en toda la aplicación usando Riverpod.
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  // Obtener la instancia de Supabase
  // Nota: Supabase debe ser inicializado en main() antes de usar este provider
  return Supabase.instance.client;
});

/// Provider que expone el cliente de autenticación de Supabase.
/// 
/// Facilita el acceso a las funcionalidades de autenticación.
final supabaseAuthProvider = Provider<GoTrueClient>((ref) {
  return ref.watch(supabaseClientProvider).auth;
});

/// Provider helper para acceder a tablas específicas de Supabase.
/// 
/// Ejemplo de uso:
/// ```dart
/// final table = ref.watch(supabaseClientProvider).from('nombre_tabla');
/// ```
/// 
/// Nota: Este provider expone el cliente completo para mayor flexibilidad.

