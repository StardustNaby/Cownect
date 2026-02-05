import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/usuario_entity.dart';
import '../../core/providers/firebase_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Excepción personalizada para errores de autenticación.
class AuthException implements Exception {
  final String message;
  final String? code;

  AuthException(this.message, [this.code]);

  @override
  String toString() => message;
}

/// Implementación del repositorio de autenticación usando Firebase.
/// 
/// Esta clase implementa [AuthRepository] y utiliza Firebase Auth
/// para todas las operaciones de autenticación.
class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRepositoryImpl(this._firebaseAuth, this._firestore);

  @override
  Future<UsuarioEntity> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw AuthException('No se pudo iniciar sesión. Intenta nuevamente.');
      }

      // Obtener datos adicionales del usuario desde Firestore
      final usuarioData = await _getUsuarioData(userCredential.user!.uid);

      return _mapUserToEntity(userCredential.user!, usuarioData);
    } on AuthException {
      rethrow;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_translateFirebaseError(e));
    } catch (e) {
      throw AuthException('Error inesperado: ${e.toString()}');
    }
  }

  @override
  Future<UsuarioEntity> signInWithOTP({
    required String phone,
    required String otp,
  }) async {
    try {
      // Firebase requiere que primero se envíe el código OTP con signInWithPhoneNumber
      // y luego se verifique con el código. Para este método, asumimos que el código
      // ya fue enviado y ahora se está verificando.
      
      // Obtener el verificationId del usuario (normalmente se guarda después de enviar el OTP)
      // Por ahora, lanzamos un error indicando que se debe usar sendOTP primero
      throw AuthException(
        'Para iniciar sesión con OTP, primero debes enviar el código usando sendOTP().',
      );
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException('Error al verificar código OTP: ${e.toString()}');
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

      UserCredential userCredential;

      if (email != null) {
        // Registrar con email y contraseña
        userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        // Solo teléfono - usar OTP (no recomendado para registro inicial)
        throw AuthException(
          'El registro solo con teléfono requiere verificación OTP. '
          'Por favor, usa sendOTP() primero.',
        );
      }

      if (userCredential.user == null) {
        throw AuthException('No se pudo registrar el usuario. Intenta nuevamente.');
      }

      // Crear registro en Firestore en la colección usuario_propietario
      final usuarioData = <String, dynamic>{
        'nombre_completo': nombreCompleto,
        'fecha_nacimiento': Timestamp.fromDate(fechaNacimiento),
      };
      
      if (email != null) {
        usuarioData['email'] = email;
      }
      if (phone != null) {
        usuarioData['telefono'] = phone;
      }

      await _firestore
          .collection('usuario_propietario')
          .doc(userCredential.user!.uid)
          .set(usuarioData);

      // Obtener los datos completos del usuario
      final usuarioCompleto = await _getUsuarioData(userCredential.user!.uid);

      return _mapUserToEntity(userCredential.user!, usuarioCompleto);
    } on AuthException {
      rethrow;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_translateFirebaseError(e));
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Error inesperado al registrar usuario: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw AuthException('Error al cerrar sesión: ${e.toString()}');
    }
  }

  @override
  Future<UsuarioEntity?> getCurrentUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return null;

      // Obtener datos adicionales del usuario desde Firestore
      final usuarioData = await _getUsuarioData(user.uid);

      return _mapUserToEntity(user, usuarioData);
    } catch (e) {
      throw AuthException('Error al obtener usuario actual: ${e.toString()}');
    }
  }

  @override
  Future<void> sendOTP({required String phone}) async {
    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phone,
        verificationCompleted: (PhoneAuthCredential credential) {
          // Auto-verificación (Android)
          // No necesitamos hacer nada aquí, Firebase lo maneja automáticamente
        },
        verificationFailed: (FirebaseAuthException e) {
          throw AuthException(_translateFirebaseError(e));
        },
        codeSent: (String verificationId, int? resendToken) {
          // El código se envió exitosamente
          // El verificationId debe guardarse para usarlo en signInWithOTP
          // Por ahora, solo verificamos que no haya error
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Timeout para auto-verificación
        },
        timeout: const Duration(seconds: 60),
      );
    } on AuthException {
      rethrow;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_translateFirebaseError(e));
    } catch (e) {
      throw AuthException('Error al enviar código OTP: ${e.toString()}');
    }
  }

  /// Obtiene los datos adicionales del usuario desde Firestore.
  Future<Map<String, dynamic>?> _getUsuarioData(String userId) async {
    try {
      final doc = await _firestore
          .collection('usuario_propietario')
          .doc(userId)
          .get();

      if (!doc.exists) return null;
      return doc.data();
    } catch (e) {
      // Si no existe el registro, retornar null
      return null;
    }
  }

  /// Mapea los datos de Firebase User y Firestore a UsuarioEntity.
  UsuarioEntity _mapUserToEntity(
    User user,
    Map<String, dynamic>? usuarioData,
  ) {
    // Si hay datos en Firestore, usarlos; si no, usar datos de auth
    final nombreCompleto = usuarioData?['nombre_completo'] as String? ??
        user.displayName ??
        'Usuario';

    final fechaNacimientoTimestamp = usuarioData?['fecha_nacimiento'] as Timestamp?;
    final fechaNacimiento = fechaNacimientoTimestamp != null
        ? fechaNacimientoTimestamp.toDate()
        : DateTime.now().subtract(const Duration(days: 365 * 20)); // Default: 20 años

    final email = usuarioData?['email'] as String? ?? user.email ?? '';
    final telefono = usuarioData?['telefono'] as String? ?? user.phoneNumber;

    return UsuarioEntity(
      id: user.uid,
      nombreCompleto: nombreCompleto,
      fechaNacimiento: fechaNacimiento,
      email: email.isNotEmpty ? email : null,
      telefono: telefono,
    );
  }

  /// Traduce los errores de Firebase a mensajes claros para el usuario.
  String _translateFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Correo electrónico inválido. Verifica el formato.';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada. Contacta al soporte.';
      case 'user-not-found':
        return 'No existe una cuenta con este correo electrónico.';
      case 'wrong-password':
        return 'Contraseña incorrecta.';
      case 'invalid-credential':
        return 'Credenciales inválidas. Verifica tu correo y contraseña.';
      case 'email-already-in-use':
        return 'El correo electrónico ya está en uso.';
      case 'weak-password':
        return 'La contraseña es muy débil. Usa al menos 6 caracteres.';
      case 'invalid-phone-number':
        return 'Número de teléfono inválido. Verifica el formato.';
      case 'phone-number-already-exists':
        return 'El número de teléfono ya está en uso.';
      case 'invalid-verification-code':
        return 'Código SMS inválido. Verifica el código e intenta nuevamente.';
      case 'invalid-verification-id':
        return 'Código SMS expirado. Solicita un nuevo código.';
      case 'session-expired':
        return 'La sesión ha expirado. Solicita un nuevo código.';
      case 'too-many-requests':
        return 'Demasiados intentos. Espera unos minutos antes de intentar nuevamente.';
      case 'operation-not-allowed':
        return 'Esta operación no está permitida. Contacta al soporte.';
      case 'network-request-failed':
        return 'Error de conexión. Verifica tu internet e intenta nuevamente.';
      default:
        return e.message ?? 'Error de autenticación. Intenta nuevamente.';
    }
  }
}

/// Provider que expone la implementación del repositorio de autenticación.
/// 
/// Este provider utiliza los providers de Firebase para obtener las instancias
/// de FirebaseAuth y FirebaseFirestore y crear una instancia de [AuthRepositoryImpl].
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  final firestore = ref.watch(firebaseFirestoreProvider);
  return AuthRepositoryImpl(firebaseAuth, firestore);
});
