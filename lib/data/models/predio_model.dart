import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/predio_entity.dart';

/// Modelo de datos que representa un predio.
/// 
/// Extiende PredioEntity y proporciona métodos de serialización
/// para interactuar con Firebase Firestore y Supabase (legacy).
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
    required super.clavePGN,
    required super.propietarioLegal,
    required super.tipoProduccion,
    super.claveCatastral,
    required super.fechaCreacion,
  });

  /// Crea una instancia de PredioModel desde un JSON.
  /// 
  /// Compatible con:
  /// - Mapas de Firestore (con Timestamps)
  /// - Mapas de Supabase (con Strings ISO 8601)
  /// 
  /// Mapea los nombres de campos:
  /// - id_predio -> id
  /// - id_usuario -> idUsuario
  /// - fecha_creacion -> fechaCreacion (convierte Timestamp/String a DateTime)
  /// - Otros campos según corresponda
  factory PredioModel.fromJson(Map<String, dynamic> json) {
    return PredioModel(
      id: json['id_predio'] as String? ?? json['id'] as String,
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
      clavePGN: json['clave_pgn'] as String,
      propietarioLegal: json['propietario_legal'] as String,
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
      'clave_pgn': clavePGN,
      'propietario_legal': propietarioLegal,
      'tipo_produccion': tipoProduccion,
      if (claveCatastral != null) 'clave_catastral': claveCatastral,
      'fecha_creacion': _formatFecha(fechaCreacion),
    };
  }

  /// Parsea una fecha desde diferentes formatos posibles.
  /// 
  /// Soporta:
  /// - Timestamp de Firestore (objeto Timestamp o Map serializado)
  /// - String ISO 8601 (ej: "2023-12-25T00:00:00Z")
  /// - String formato fecha (ej: "2023-12-25")
  /// - DateTime directamente
  /// - Timestamp de Supabase (legacy)
  /// 
  /// Si la fecha es null, retorna la fecha actual (para fecha_creacion).
  static DateTime _parseFecha(dynamic fecha) {
    if (fecha == null) {
      return DateTime.now();
    }

    // Primero verificar si es un Timestamp de Firestore (objeto Timestamp)
    if (fecha is Timestamp) {
      return fecha.toDate();
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
          // Si falla el parseo, retornar fecha actual como fallback
          return DateTime.now();
        }
      }
    }

    // Si es un Timestamp de Firestore serializado (Map con seconds y nanoseconds)
    // También puede ser un Timestamp de Supabase (legacy)
    if (fecha is Map && fecha.containsKey('seconds')) {
      final seconds = fecha['seconds'] as int;
      final nanoseconds = fecha['nanoseconds'] as int? ?? 0;
      return DateTime.fromMillisecondsSinceEpoch(
        seconds * 1000 + (nanoseconds ~/ 1000000),
      );
    }

    // Fallback: retornar fecha actual
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
      clavePGN: clavePGN,
      propietarioLegal: propietarioLegal,
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
      clavePGN: entity.clavePGN,
      propietarioLegal: entity.propietarioLegal,
      tipoProduccion: entity.tipoProduccion,
      claveCatastral: entity.claveCatastral,
      fechaCreacion: entity.fechaCreacion,
    );
  }

  /// Crea una instancia de PredioModel desde un DocumentSnapshot de Firestore.
  /// 
  /// Mapea los nombres de campos de Firestore:
  /// - El ID del documento se usa como id_predio
  /// - id_usuario -> idUsuario
  /// - fecha_creacion -> fechaCreacion (convierte Timestamp a DateTime)
  /// - Otros campos según corresponda
  /// 
  /// Cumple con los requisitos de la NOM-001-SAG/GAN-2015.
  factory PredioModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw FormatException('El documento de Firestore está vacío');
    }

    return PredioModel(
      id: doc.id, // Usar el ID del documento como id_predio
      idUsuario: data['id_usuario'] as String,
      nombre: data['nombre'] as String,
      estado: data['estado'] as String,
      municipio: data['municipio'] as String,
      localidad: data['localidad'] as String,
      codigoPostal: data['codigo_postal'] as String,
      direccion: data['direccion'] as String,
      superficieHectareas: (data['superficie_hectareas'] as num).toDouble(),
      tipoTenencia: data['tipo_tenencia'] as String,
      latitud: data['latitud'] != null ? (data['latitud'] as num).toDouble() : null,
      longitud: data['longitud'] != null ? (data['longitud'] as num).toDouble() : null,
      upp: data['upp'] as String,
      clavePGN: data['clave_pgn'] as String,
      propietarioLegal: data['propietario_legal'] as String,
      tipoProduccion: data['tipo_produccion'] as String,
      claveCatastral: data['clave_catastral'] as String?,
      fechaCreacion: _parseFechaFirestore(data['fecha_creacion']),
    );
  }

  /// Convierte el modelo a un Map para enviar a Firestore.
  /// 
  /// Los nombres de las llaves coinciden exactamente con los nombres
  /// de los campos en Firestore. Las fechas se convierten a Timestamp.
  /// 
  /// Cumple con los requisitos de la NOM-001-SAG/GAN-2015.
  Map<String, dynamic> toFirestore() {
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
      'clave_pgn': clavePGN,
      'propietario_legal': propietarioLegal,
      'tipo_produccion': tipoProduccion,
      if (claveCatastral != null) 'clave_catastral': claveCatastral,
      'fecha_creacion': Timestamp.fromDate(fechaCreacion),
    };
  }

  /// Parsea una fecha desde Firestore (Timestamp).
  /// 
  /// Soporta:
  /// - Timestamp de Firestore (objeto Timestamp o Map serializado)
  /// - DateTime directamente
  /// - String ISO 8601 (para compatibilidad)
  /// 
  /// Si la fecha es null, retorna la fecha actual (para fecha_creacion).
  static DateTime _parseFechaFirestore(dynamic fecha) {
    if (fecha == null) {
      return DateTime.now();
    }

    DateTime dateTime;

    if (fecha is Timestamp) {
      dateTime = fecha.toDate();
    } else if (fecha is DateTime) {
      dateTime = fecha;
    } else if (fecha is String) {
      // Intentar parsear como ISO 8601 (para compatibilidad)
      try {
        dateTime = DateTime.parse(fecha);
      } catch (e) {
        // Si falla el parseo, retornar fecha actual como fallback
        return DateTime.now();
      }
    } else if (fecha is Map) {
      // Timestamp de Firestore serializado
      if (fecha.containsKey('seconds')) {
        final seconds = fecha['seconds'] as int;
        final nanoseconds = fecha['nanoseconds'] as int? ?? 0;
        dateTime = DateTime.fromMillisecondsSinceEpoch(
          seconds * 1000 + (nanoseconds ~/ 1000000),
        );
      } else {
        // Fallback: retornar fecha actual
        return DateTime.now();
      }
    } else {
      // Fallback: retornar fecha actual
      return DateTime.now();
    }

    return dateTime;
  }
}

