import '../../domain/entities/predio_entity.dart';

/// Modelo de datos que representa un predio.
/// 
/// Extiende PredioEntity y proporciona métodos de serialización
/// para interactuar con Supabase.
/// Cumple con los requisitos de la NOM-001-SAG/GAN-2015.
class PredioModel extends PredioEntity {
  /// Constructor del modelo que llama al constructor de la entidad.
  PredioModel({
    required super.id,
    required super.idUsuario,
    required super.nombre,
    required super.estado,
    required super.municipio,
    required super.localidad,
    required super.codigoPostal,
    required super.direccion,
    required super.superficieHectareas,
    required super.tipoTenencia,
    super.latitud,
    super.longitud,
    required super.upp,
    required super.tipoProduccion,
    super.claveCatastral,
    required super.fechaCreacion,
  });

  /// Crea una instancia de PredioModel desde un JSON de Supabase.
  factory PredioModel.fromJson(Map<String, dynamic> json) {
    return PredioModel(
      id: json['id_predio'] as String,
      idUsuario: json['id_usuario'] as String,
      nombre: json['nombre'] as String,
      estado: json['estado'] as String,
      municipio: json['municipio'] as String,
      localidad: json['localidad'] as String,
      codigoPostal: json['codigo_postal'] as String,
      direccion: json['direccion'] as String,
      superficieHectareas: (json['superficie_hectareas'] as num).toDouble(),
      tipoTenencia: json['tipo_tenencia'] as String,
      latitud: json['latitud'] != null ? (json['latitud'] as num).toDouble() : null,
      longitud: json['longitud'] != null ? (json['longitud'] as num).toDouble() : null,
      upp: json['upp'] as String,
      tipoProduccion: json['tipo_produccion'] as String,
      claveCatastral: json['clave_catastral'] as String?,
      fechaCreacion: _parseFecha(json['fecha_creacion']),
    );
  }

  /// Convierte el modelo a un Map para enviar a Supabase.
  Map<String, dynamic> toJson() {
    return {
      'id_predio': id,
      'id_usuario': idUsuario,
      'nombre': nombre,
      'estado': estado,
      'municipio': municipio,
      'localidad': localidad,
      'codigo_postal': codigoPostal,
      'direccion': direccion,
      'superficie_hectareas': superficieHectareas,
      'tipo_tenencia': tipoTenencia,
      if (latitud != null) 'latitud': latitud,
      if (longitud != null) 'longitud': longitud,
      'upp': upp,
      'tipo_produccion': tipoProduccion,
      if (claveCatastral != null) 'clave_catastral': claveCatastral,
      'fecha_creacion': _formatFecha(fechaCreacion),
    };
  }

  /// Parsea una fecha desde diferentes formatos posibles.
  static DateTime _parseFecha(dynamic fecha) {
    if (fecha == null) {
      return DateTime.now();
    }

    if (fecha is DateTime) {
      return fecha;
    }

    if (fecha is String) {
      try {
        return DateTime.parse(fecha);
      } catch (e) {
        try {
          return DateTime.parse('$fecha 00:00:00Z');
        } catch (e2) {
          return DateTime.now();
        }
      }
    }

    if (fecha is Map && fecha.containsKey('seconds')) {
      final seconds = fecha['seconds'] as int;
      return DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
    }

    return DateTime.now();
  }

  /// Formatea una fecha a String ISO 8601 para Supabase.
  static String _formatFecha(DateTime fecha) {
    return fecha.toIso8601String();
  }

  /// Convierte el modelo a una entidad de dominio.
  PredioEntity toEntity() {
    return PredioEntity(
      id: id,
      idUsuario: idUsuario,
      nombre: nombre,
      estado: estado,
      municipio: municipio,
      localidad: localidad,
      codigoPostal: codigoPostal,
      direccion: direccion,
      superficieHectareas: superficieHectareas,
      tipoTenencia: tipoTenencia,
      latitud: latitud,
      longitud: longitud,
      upp: upp,
      tipoProduccion: tipoProduccion,
      claveCatastral: claveCatastral,
      fechaCreacion: fechaCreacion,
    );
  }

  /// Crea un modelo desde una entidad de dominio.
  factory PredioModel.fromEntity(PredioEntity entity) {
    return PredioModel(
      id: entity.id,
      idUsuario: entity.idUsuario,
      nombre: entity.nombre,
      estado: entity.estado,
      municipio: entity.municipio,
      localidad: entity.localidad,
      codigoPostal: entity.codigoPostal,
      direccion: entity.direccion,
      superficieHectareas: entity.superficieHectareas,
      tipoTenencia: entity.tipoTenencia,
      latitud: entity.latitud,
      longitud: entity.longitud,
      upp: entity.upp,
      tipoProduccion: entity.tipoProduccion,
      claveCatastral: entity.claveCatastral,
      fechaCreacion: entity.fechaCreacion,
    );
  }
}

