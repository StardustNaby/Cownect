import '../../domain/entities/usuario_entity.dart';

/// Contrato (interfaz) para el repositorio de autenticación.
/// 
/// Define los métodos necesarios para la autenticación de usuarios.
/// Las implementaciones concretas estarán en la capa de datos.
abstract class AuthRepository {
  /// Inicia sesión con correo electrónico y contraseña.
  /// 
  /// [email] - Correo electrónico del usuario
  /// [password] - Contraseña del usuario
  /// 
  /// Retorna la entidad [UsuarioEntity] del usuario autenticado.
  /// Lanza una excepción si las credenciales son inválidas.
  Future<UsuarioEntity> signInWithEmail({
    required String email,
    required String password,
  });

  /// Inicia sesión con OTP (One-Time Password) enviado por SMS.
  /// 
  /// [phone] - Número de teléfono del usuario
  /// [otp] - Código OTP recibido por SMS
  /// 
  /// Retorna la entidad [UsuarioEntity] del usuario autenticado.
  /// Lanza una excepción si el OTP es inválido o ha expirado.
  Future<UsuarioEntity> signInWithOTP({
    required String phone,
    required String otp,
  });

  /// Registra un nuevo usuario en el sistema.
  /// 
  /// [email] - Correo electrónico del nuevo usuario (opcional)
  /// [phone] - Teléfono del nuevo usuario (opcional)
  /// [password] - Contraseña del nuevo usuario
  /// [nombreCompleto] - Nombre completo del usuario
  /// [fechaNacimiento] - Fecha de nacimiento del usuario
  /// 
  /// Retorna la entidad [UsuarioEntity] del usuario recién registrado.
  /// Lanza una excepción si el registro falla (email/phone ya existe, etc.).
  /// 
  /// Nota: Debe proporcionarse al menos email o phone.
  Future<UsuarioEntity> signUp({
    String? email,
    String? phone,
    required String password,
    required String nombreCompleto,
    required DateTime fechaNacimiento,
  });

  /// Cierra la sesión del usuario actual.
  /// 
  /// No retorna nada. Lanza una excepción si hay un error al cerrar sesión.
  Future<void> signOut();

  /// Obtiene el usuario actualmente autenticado.
  /// 
  /// Retorna la entidad [UsuarioEntity] del usuario autenticado.
  /// Retorna null si no hay usuario autenticado.
  Future<UsuarioEntity?> getCurrentUser();

  /// Envía un código OTP por SMS al número de teléfono proporcionado.
  /// 
  /// [phone] - Número de teléfono al que se enviará el OTP
  /// 
  /// No retorna nada. Lanza una excepción si el número es inválido.
  Future<void> sendOTP({required String phone});
}

