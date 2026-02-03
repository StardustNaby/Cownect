/// Entidad de dominio que representa un usuario propietario.
/// 
/// Esta entidad es inmutable y contiene la información básica
/// de un usuario propietario del sistema.
class UsuarioEntity {
  /// Identificador único del usuario (UUID).
  final String id;

  /// Nombre completo del usuario (no nulo).
  final String nombreCompleto;

  /// Fecha de nacimiento del usuario.
  /// El sistema debe validar que el usuario tenga +18 años.
  final DateTime fechaNacimiento;

  /// Correo electrónico del usuario (opcional).
  /// Debe haber email o teléfono (al menos uno).
  final String? email;

  /// Teléfono del usuario (opcional).
  /// Debe haber email o teléfono (al menos uno).
  final String? telefono;

  /// Constructor de la entidad Usuario.
  /// 
  /// Valida que:
  /// - El usuario tenga al menos 18 años
  /// - Haya al menos un email o teléfono
  UsuarioEntity({
    required this.id,
    required this.nombreCompleto,
    required this.fechaNacimiento,
    this.email,
    this.telefono,
  }) : assert(
          email != null || telefono != null,
          'Debe proporcionar al menos un email o teléfono',
        ),
        assert(
          _esMayorDeEdad(fechaNacimiento),
          'El usuario debe tener al menos 18 años',
        );

  /// Valida que el usuario tenga al menos 18 años.
  static bool _esMayorDeEdad(DateTime fechaNacimiento) {
    final ahora = DateTime.now();
    final edad = ahora.year - fechaNacimiento.year;
    
    if (edad > 18) return true;
    if (edad < 18) return false;
    
    // Si tiene exactamente 18 años, verificar mes y día
    if (ahora.month > fechaNacimiento.month) return true;
    if (ahora.month < fechaNacimiento.month) return false;
    
    return ahora.day >= fechaNacimiento.day;
  }

  /// Crea una copia de la entidad con los campos modificados.
  UsuarioEntity copyWith({
    String? id,
    String? nombreCompleto,
    DateTime? fechaNacimiento,
    String? email,
    String? telefono,
  }) {
    return UsuarioEntity(
      id: id ?? this.id,
      nombreCompleto: nombreCompleto ?? this.nombreCompleto,
      fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
      email: email ?? this.email,
      telefono: telefono ?? this.telefono,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UsuarioEntity &&
        other.id == id &&
        other.nombreCompleto == nombreCompleto &&
        other.fechaNacimiento == fechaNacimiento &&
        other.email == email &&
        other.telefono == telefono;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      nombreCompleto,
      fechaNacimiento,
      email,
      telefono,
    );
  }

  @override
  String toString() {
    return 'UsuarioEntity(id: $id, nombreCompleto: $nombreCompleto, '
        'fechaNacimiento: $fechaNacimiento, email: $email, telefono: $telefono)';
  }
}

