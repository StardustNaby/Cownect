/// Entidad de dominio que representa un predio.
/// 
/// Un predio es una unidad de producción pecuaria (UPP) que pertenece a un usuario.
/// Cumple con los requisitos de la NOM-001-SAG/GAN-2015.
class PredioEntity {
  /// Identificador único del predio (UUID).
  final String id;

  /// Identificador del usuario propietario (FK a usuario_propietario).
  final String idUsuario;

  /// Nombre o razón social del predio (NOM-001-SAG/GAN-2015).
  final String nombre;

  /// Estado donde se ubica el predio (NOM-001-SAG/GAN-2015).
  final String estado;

  /// Municipio donde se ubica el predio (NOM-001-SAG/GAN-2015).
  final String municipio;

  /// Localidad donde se ubica el predio (NOM-001-SAG/GAN-2015).
  final String localidad;

  /// Código postal del predio (NOM-001-SAG/GAN-2015).
  final String codigoPostal;

  /// Dirección completa del predio (NOM-001-SAG/GAN-2015).
  final String direccion;

  /// Superficie total del predio en hectáreas (NOM-001-SAG/GAN-2015).
  final double superficieHectareas;

  /// Tipo de tenencia de la tierra (NOM-001-SAG/GAN-2015).
  /// Valores: PROPIO, ARRENDADO, EJIDAL, COMUNAL, OTRO
  final String tipoTenencia;

  /// Latitud geográfica del predio (NOM-001-SAG/GAN-2015).
  final double? latitud;

  /// Longitud geográfica del predio (NOM-001-SAG/GAN-2015).
  final double? longitud;

  /// UPP (Unidad de Producción Pecuaria) - identificador único del predio (NOM-001-SAG/GAN-2015).
  final String upp;

  /// Clave PGN (Padrón Ganadero Nacional) - 12 dígitos (NOM-001-SAG/GAN-2015).
  final String clavePGN;

  /// Propietario Legal - Nombre de la persona física o moral (NOM-001-SAG/GAN-2015).
  final String propietarioLegal;

  /// Tipo de producción pecuaria (NOM-001-SAG/GAN-2015).
  /// Valores: BOVINOS, PORCINOS, AVES, OVINOS, CAPRINOS, EQUINOS, OTRO
  final String tipoProduccion;

  /// Clave catastral del predio (opcional).
  final String? claveCatastral;

  /// Fecha de creación del predio.
  final DateTime fechaCreacion;

  /// Valores permitidos para tipo de tenencia.
  static const List<String> tiposTenenciaValidos = [
    'PROPIO',
    'ARRENDADO',
    'EJIDAL',
    'COMUNAL',
    'OTRO',
  ];

  /// Valores permitidos para tipo de producción.
  static const List<String> tiposProduccionValidos = [
    'BOVINOS',
    'PORCINOS',
    'AVES',
    'OVINOS',
    'CAPRINOS',
    'EQUINOS',
    'OTRO',
  ];

  /// Constructor de la entidad Predio.
  PredioEntity({
    required this.id,
    required this.idUsuario,
    required this.nombre,
    required this.estado,
    required this.municipio,
    required this.localidad,
    required this.codigoPostal,
    required this.direccion,
    required this.superficieHectareas,
    required this.tipoTenencia,
    this.latitud,
    this.longitud,
    required this.upp,
    required this.clavePGN,
    required this.propietarioLegal,
    required this.tipoProduccion,
    this.claveCatastral,
    required this.fechaCreacion,
  }) : assert(
          superficieHectareas > 0,
          'La superficie debe ser mayor a 0',
        ),
        assert(
          tiposTenenciaValidos.contains(tipoTenencia),
          'El tipo de tenencia debe ser uno de: ${tiposTenenciaValidos.join(", ")}',
        ),
        assert(
          tiposProduccionValidos.contains(tipoProduccion),
          'El tipo de producción debe ser uno de: ${tiposProduccionValidos.join(", ")}',
        ),
        assert(
          codigoPostal.length == 5,
          'El código postal debe tener 5 dígitos',
        ),
        assert(
          latitud == null || (latitud >= -90 && latitud <= 90),
          'La latitud debe estar entre -90 y 90',
        ),
        assert(
          longitud == null || (longitud >= -180 && longitud <= 180),
          'La longitud debe estar entre -180 y 180',
        ),
        assert(
          clavePGN.length == 12 && RegExp(r'^\d{12}$').hasMatch(clavePGN),
          'La Clave PGN debe tener exactamente 12 dígitos numéricos',
        );

  /// Crea una copia de la entidad con los campos modificados.
  PredioEntity copyWith({
    String? id,
    String? idUsuario,
    String? nombre,
    String? estado,
    String? municipio,
    String? localidad,
    String? codigoPostal,
    String? direccion,
    double? superficieHectareas,
    String? tipoTenencia,
    double? latitud,
    double? longitud,
    String? upp,
    String? clavePGN,
    String? propietarioLegal,
    String? tipoProduccion,
    String? claveCatastral,
    DateTime? fechaCreacion,
  }) {
    return PredioEntity(
      id: id ?? this.id,
      idUsuario: idUsuario ?? this.idUsuario,
      nombre: nombre ?? this.nombre,
      estado: estado ?? this.estado,
      municipio: municipio ?? this.municipio,
      localidad: localidad ?? this.localidad,
      codigoPostal: codigoPostal ?? this.codigoPostal,
      direccion: direccion ?? this.direccion,
      superficieHectareas: superficieHectareas ?? this.superficieHectareas,
      tipoTenencia: tipoTenencia ?? this.tipoTenencia,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      upp: upp ?? this.upp,
      clavePGN: clavePGN ?? this.clavePGN,
      propietarioLegal: propietarioLegal ?? this.propietarioLegal,
      tipoProduccion: tipoProduccion ?? this.tipoProduccion,
      claveCatastral: claveCatastral ?? this.claveCatastral,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
    );
  }
}

