import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/usuario_entity.dart';
import '../../core/providers/supabase_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Excepción personalizada para errores de autenticación.
class AuthException implements Exception {
  final String message;
  final String? code;

  AuthException(this.message, [this.code]);

  @override
  String toString() => message;
}

/// Implementación del repositorio de autenticación usando Supabase.
/// 
/// Esta clase implementa [AuthRepository] y utiliza Supabase
/// para todas las operaciones de autenticación.
class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _supabaseClient;

  AuthRepositoryImpl(this._supabaseClient);

  @override
  Future<UsuarioEntity> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw AuthException('No se pudo iniciar sesión. Intenta nuevamente.');
      }

      // Obtener datos adicionales del usuario desde la tabla usuario_propietario
      final usuarioData = await _getUsuarioData(response.user!.id);

      return _mapUserToEntity(response.user!, usuarioData);
    } on AuthException {
      rethrow;
    } catch (e) {
      final errorMessage = _extractErrorMessage(e);
      throw AuthException(_translateSupabaseError(errorMessage, null));
    }
  }

  @override
  Future<UsuarioEntity> signInWithOTP({
    required String phone,
    required String otp,
  }) async {
    try {
      final response = await _supabaseClient.auth.verifyOTP(
        type: OtpType.sms,
        phone: phone,
        token: otp,
      );

      if (response.user == null) {
        throw AuthException('Código SMS inválido o expirado.');
      }

      // Obtener datos adicionales del usuario desde la tabla usuario_propietario
      final usuarioData = await _getUsuarioData(response.user!.id);

      return _mapUserToEntity(response.user!, usuarioData);
    } on AuthException {
      rethrow;
    } catch (e) {
      final errorMessage = _extractErrorMessage(e);
      throw AuthException(_translateSupabaseError(errorMessage, null));
    }
  }

  @override
  Future<UsuarioEntity> signUp({
    String? email,
    String? phone,
    required String password,
    required String nombreCompleto,
    required DateTime fechaNacimiento,
  }) async {
    try {
      // Validar que haya al menos email o phone
      if (email == null && phone == null) {
        throw AuthException('Debe proporcionar al menos un correo electrónico o teléfono.');
      }

      // Registrar usuario en Supabase Auth
      AuthResponse response;
      if (email != null) {
        response = await _supabaseClient.auth.signUp(
          email: email,
          password: password,
        );
      } else {
        // Para registro con teléfono, primero enviamos OTP
        await _supabaseClient.auth.signInWithOtp(phone: phone!);
        throw AuthException(
          'Se ha enviado un código de verificación a tu teléfono. '
          'Por favor, verifica tu número para completar el registro.',
        );
      }

      if (response.user == null) {
        throw AuthException('No se pudo registrar el usuario. Intenta nuevamente.');
      }

      // Crear registro en la tabla usuario_propietario
      final usuarioData = <String, dynamic>{
        'id_usuario': response.user!.id,
        'nombre_completo': nombreCompleto,
        'fecha_nacimiento': fechaNacimiento.toIso8601String(),
      };
      
      if (email != null) {
        usuarioData['email'] = email;
      }
      if (phone != null) {
        usuarioData['telefono'] = phone;
      }

      await _supabaseClient
          .from('usuario_propietario')
          .insert(usuarioData);

      // Obtener los datos completos del usuario
      final usuarioCompleto = await _getUsuarioData(response.user!.id);

      return _mapUserToEntity(response.user!, usuarioCompleto);
    } on AuthException {
      rethrow;
    } catch (e) {
      if (e is AuthException) rethrow;
      final errorMessage = _extractErrorMessage(e);
      throw AuthException(_translateSupabaseError(errorMessage, null));
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _supabaseClient.auth.signOut();
    } catch (e) {
      throw AuthException('Error al cerrar sesión: ${e.toString()}');
    }
  }

  @override
  Future<UsuarioEntity?> getCurrentUser() async {
    try {
      final user = _supabaseClient.auth.currentUser;
      if (user == null) return null;

      // Obtener datos adicionales del usuario desde la tabla usuario_propietario
      final usuarioData = await _getUsuarioData(user.id);

      return _mapUserToEntity(user, usuarioData);
    } catch (e) {
      throw AuthException('Error al obtener usuario actual: ${e.toString()}');
    }
  }

  @override
  Future<void> sendOTP({required String phone}) async {
    try {
      await _supabaseClient.auth.signInWithOtp(
        phone: phone,
      );
    } catch (e) {
      final errorMessage = _extractErrorMessage(e);
      throw AuthException(_translateSupabaseError(errorMessage, null));
    }
  }

  /// Obtiene los datos adicionales del usuario desde la tabla usuario_propietario.
  Future<Map<String, dynamic>?> _getUsuarioData(String userId) async {
    try {
      final response = await _supabaseClient
          .from('usuario_propietario')
          .select()
          .eq('id_usuario', userId)
          .maybeSingle();

      if (response == null) return null;
      return Map<String, dynamic>.from(response);
    } catch (e) {
      // Si no existe el registro, retornar null
      return null;
    }
  }

  /// Mapea los datos de Supabase User y la tabla usuario_propietario a UsuarioEntity.
  UsuarioEntity _mapUserToEntity(
    User user,
    Map<String, dynamic>? usuarioData,
  ) {
    // Si hay datos en la tabla, usarlos; si no, usar datos de auth
    final nombreCompleto = usuarioData?['nombre_completo'] as String? ??
        user.userMetadata?['nombre_completo'] as String? ??
        'Usuario';

    final fechaNacimientoStr = usuarioData?['fecha_nacimiento'] as String?;
    final fechaNacimiento = fechaNacimientoStr != null
        ? DateTime.parse(fechaNacimientoStr)
        : DateTime.now().subtract(const Duration(days: 365 * 20)); // Default: 20 años

    final email = usuarioData?['email'] as String? ?? user.email ?? '';
    final telefono = usuarioData?['telefono'] as String? ?? user.phone;

    return UsuarioEntity(
      id: user.id,
      nombreCompleto: nombreCompleto,
      fechaNacimiento: fechaNacimiento,
      email: email,
      telefono: telefono,
    );
  }

  /// Extrae el mensaje de error de una excepción.
  String _extractErrorMessage(dynamic error) {
    if (error == null) return 'Error desconocido';
    
    final errorString = error.toString();
    
    // Simplificar: retornar el string completo del error
    // La traducción se hará en _translateSupabaseError
    return errorString;
  }

  /// Traduce los errores de Supabase a mensajes claros para el usuario.
  String _translateSupabaseError(String? message, int? statusCode) {
    if (message == null) {
      return 'Error desconocido. Intenta nuevamente.';
    }

    final lowerMessage = message.toLowerCase();

    // Errores comunes de autenticación
    if (lowerMessage.contains('invalid login credentials') ||
        lowerMessage.contains('invalid credentials')) {
      return 'Correo electrónico o contraseña incorrectos.';
    }

    if (lowerMessage.contains('email already registered') ||
        lowerMessage.contains('user already registered')) {
      return 'El correo electrónico ya está en uso.';
    }

    if (lowerMessage.contains('phone already registered')) {
      return 'El número de teléfono ya está en uso.';
    }

    if (lowerMessage.contains('invalid otp') ||
        lowerMessage.contains('otp expired') ||
        lowerMessage.contains('token has expired')) {
      return 'Código SMS inválido o expirado. Solicita un nuevo código.';
    }

    if (lowerMessage.contains('invalid phone number') ||
        lowerMessage.contains('phone number format')) {
      return 'Número de teléfono inválido. Verifica el formato.';
    }

    // Error específico de proveedor de teléfono deshabilitado
    if (lowerMessage.contains('phone_provider_disabled') ||
        lowerMessage.contains('phone provider disabled') ||
        lowerMessage.contains('sms provider') && lowerMessage.contains('disabled')) {
      return 'Servicio de SMS temporalmente fuera de servicio. Por favor, usa correo electrónico para iniciar sesión.';
    }

    if (lowerMessage.contains('password') && lowerMessage.contains('weak')) {
      return 'La contraseña es muy débil. Usa al menos 8 caracteres.';
    }

    if (lowerMessage.contains('too many requests') ||
        lowerMessage.contains('rate limit')) {
      return 'Demasiados intentos. Espera unos minutos antes de intentar nuevamente.';
    }

    if (statusCode == 400) {
      // Mensaje más específico para errores 400
      if (lowerMessage.contains('phone') || lowerMessage.contains('sms')) {
        return 'Error con el servicio de SMS. Intenta usar correo electrónico o contacta al soporte.';
      }
      return 'Datos inválidos. Verifica la información proporcionada.';
    }

    if (statusCode == 401) {
      return 'No autorizado. Verifica tus credenciales.';
    }

    if (statusCode == 403) {
      return 'Acceso denegado. No tienes permisos para realizar esta acción.';
    }

    if (statusCode == 404) {
      return 'Recurso no encontrado.';
    }

    if (statusCode == 500) {
      return 'Error del servidor. Intenta nuevamente más tarde.';
    }

    // Si no se puede traducir, retornar el mensaje original
    return message;
  }
}

/// Provider que expone la implementación del repositorio de autenticación.
/// 
/// Este provider utiliza el [supabaseClientProvider] para obtener el cliente
/// de Supabase y crear una instancia de [AuthRepositoryImpl].
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return AuthRepositoryImpl(supabaseClient);
});

