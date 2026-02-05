import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/bovino_entity.dart';

/// Modelo de datos que representa un bovino.
/// 
/// Extiende BovinoEntity y proporciona métodos de serialización
/// para interactuar con Firebase Firestore y Supabase (legacy).
class BovinoModel extends BovinoEntity {
  /// Nombre del bovino (campo adicional del modelo).
  final String? nombre;

  /// Constructor del modelo que llama al constructor de la entidad.
  BovinoModel({
    required super.id,
    required super.idUpp,
    super.idInfraestructura,
    super.areteSiniiga,
    required super.areteTrabajo,
    required super.sexo,
    required super.fechaNacimiento,
    required super.razaPredominante,
    required super.estadoProductivo,
    required super.estatusSistema,
    this.nombre,
  });

  /// Crea una instancia de BovinoModel desde un JSON de Supabase.
  /// 
  /// Mapea los nombres de columnas de la base de datos:
  /// - id_bovino -> id
  /// - id_upp -> idUpp
  /// - id_infraestructura -> idInfraestructura
  /// - arete_siniiga -> areteSiniiga
  /// - arete_trabajo -> areteTrabajo
  /// - nombre -> nombre
  /// - fecha_nacimiento -> fechaNacimiento (convierte String a DateTime)
  /// - sexo -> sexo
  /// - raza_predominante -> razaPredominante
  /// - estado_productivo -> estadoProductivo
  /// - estatus_sistema -> estatusSistema
  factory BovinoModel.fromJson(Map<String, dynamic> json) {
    return BovinoModel(
      id: json['id_bovino'] as String,
      idUpp: json['id_upp'] as String,
      idInfraestructura: json['id_infraestructura'] as String?,
      areteSiniiga: json['arete_siniiga'] as String?,
      areteTrabajo: json['arete_trabajo'] as String,
      nombre: json['nombre'] as String?,
      fechaNacimiento: _parseFecha(json['fecha_nacimiento']),
      sexo: json['sexo'] as String,
      razaPredominante: json['raza_predominante'] as String,
      estadoProductivo: json['estado_productivo'] as String,
      estatusSistema: json['estatus_sistema'] as String,
    );
  }

  /// Convierte el modelo a un Map para enviar a Supabase.
  /// 
  /// Los nombres de las llaves coinciden exactamente con los nombres
  /// de las columnas en la base de datos.
  Map<String, dynamic> toJson() {
    return {
      'id_bovino': id,
      'id_upp': idUpp,
      if (idInfraestructura != null) 'id_infraestructura': idInfraestructura,
      if (areteSiniiga != null) 'arete_siniiga': areteSiniiga,
      'arete_trabajo': areteTrabajo,
      if (nombre != null) 'nombre': nombre,
      'fecha_nacimiento': _formatFecha(fechaNacimiento),
      'sexo': sexo,
      'raza_predominante': razaPredominante,
      'estado_productivo': estadoProductivo,
      'estatus_sistema': estatusSistema,
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
  /// Valida que la fecha no sea futura (requisito de NOM-001 para fecha de nacimiento).
  static DateTime _parseFecha(dynamic fecha) {
    if (fecha == null) {
      throw FormatException('La fecha no puede ser nula');
    }

    // Primero verificar si es un Timestamp de Firestore (objeto Timestamp)
    if (fecha is Timestamp) {
      final dateTime = fecha.toDate();
      _validarFechaNoFutura(dateTime);
      return dateTime;
    }

    if (fecha is DateTime) {
      _validarFechaNoFutura(fecha);
      return fecha;
    }

    if (fecha is String) {
      // Intentar parsear como ISO 8601
      try {
        final dateTime = DateTime.parse(fecha);
        _validarFechaNoFutura(dateTime);
        return dateTime;
      } catch (e) {
        // Intentar parsear como fecha simple (YYYY-MM-DD)
        try {
          final dateTime = DateTime.parse('$fecha 00:00:00Z');
          _validarFechaNoFutura(dateTime);
          return dateTime;
        } catch (e2) {
          throw FormatException(
            'Formato de fecha no válido: $fecha',
          );
        }
      }
    }

    // Si es un Timestamp de Firestore serializado (Map con seconds y nanoseconds)
    // También puede ser un Timestamp de Supabase (legacy)
    if (fecha is Map) {
      if (fecha.containsKey('seconds')) {
        final seconds = fecha['seconds'] as int;
        final nanoseconds = fecha['nanoseconds'] as int? ?? 0;
        final dateTime = DateTime.fromMillisecondsSinceEpoch(
          seconds * 1000 + (nanoseconds ~/ 1000000),
        );
        _validarFechaNoFutura(dateTime);
        return dateTime;
      }
    }

    throw FormatException('Tipo de fecha no soportado: ${fecha.runtimeType}');
  }

  /// Valida que la fecha no sea futura (requisito de NOM-001).
  /// 
  /// La fecha de nacimiento de un bovino no puede ser una fecha futura.
  static void _validarFechaNoFutura(DateTime fecha) {
    if (fecha.isAfter(DateTime.now())) {
      throw FormatException(
        'La fecha de nacimiento no puede ser una fecha futura (NOM-001-SAG/GAN-2015)',
      );
    }
  }

  /// Formatea una fecha a String ISO 8601 para Supabase.
  static String _formatFecha(DateTime fecha) {
    return fecha.toIso8601String();
  }

  /// Convierte el modelo a una entidad de dominio.
  BovinoEntity toEntity() {
    return BovinoEntity(
      id: id,
      idUpp: idUpp,
      idInfraestructura: idInfraestructura,
      areteSiniiga: areteSiniiga,
      areteTrabajo: areteTrabajo,
      sexo: sexo,
      fechaNacimiento: fechaNacimiento,
      razaPredominante: razaPredominante,
      estadoProductivo: estadoProductivo,
      estatusSistema: estatusSistema,
    );
  }

  /// Crea un modelo desde una entidad de dominio.
  factory BovinoModel.fromEntity(BovinoEntity entity, {String? nombre}) {
    return BovinoModel(
      id: entity.id,
      idUpp: entity.idUpp,
      idInfraestructura: entity.idInfraestructura,
      areteSiniiga: entity.areteSiniiga,
      areteTrabajo: entity.areteTrabajo,
      sexo: entity.sexo,
      fechaNacimiento: entity.fechaNacimiento,
      razaPredominante: entity.razaPredominante,
      estadoProductivo: entity.estadoProductivo,
      estatusSistema: entity.estatusSistema,
      nombre: nombre,
    );
  }

  /// Crea una instancia de BovinoModel desde un DocumentSnapshot de Firestore.
  /// 
  /// Mapea los nombres de campos de Firestore:
  /// - El ID del documento se usa como id_bovino
  /// - id_upp -> idUpp
  /// - id_infraestructura -> idInfraestructura
  /// - arete_siniiga -> areteSiniiga
  /// - arete_trabajo -> areteTrabajo
  /// - nombre -> nombre
  /// - fecha_nacimiento -> fechaNacimiento (convierte Timestamp a DateTime)
  /// - sexo -> sexo
  /// - raza_predominante -> razaPredominante
  /// - estado_productivo -> estadoProductivo
  /// - estatus_sistema -> estatusSistema
  factory BovinoModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw FormatException('El documento de Firestore está vacío');
    }

    return BovinoModel(
      id: doc.id, // Usar el ID del documento como id_bovino
      idUpp: data['id_upp'] as String,
      idInfraestructura: data['id_infraestructura'] as String?,
      areteSiniiga: data['arete_siniiga'] as String?,
      areteTrabajo: data['arete_trabajo'] as String,
      nombre: data['nombre'] as String?,
      fechaNacimiento: _parseFechaFirestore(data['fecha_nacimiento']),
      sexo: data['sexo'] as String,
      razaPredominante: data['raza_predominante'] as String,
      estadoProductivo: data['estado_productivo'] as String,
      estatusSistema: data['estatus_sistema'] as String,
    );
  }

  /// Convierte el modelo a un Map para enviar a Firestore.
  /// 
  /// Los nombres de las llaves coinciden exactamente con los nombres
  /// de los campos en Firestore. Las fechas se convierten a Timestamp.
  Map<String, dynamic> toFirestore() {
    return {
      'id_bovino': id,
      'id_upp': idUpp,
      if (idInfraestructura != null) 'id_infraestructura': idInfraestructura,
      if (areteSiniiga != null) 'arete_siniiga': areteSiniiga,
      'arete_trabajo': areteTrabajo,
      if (nombre != null) 'nombre': nombre,
      'fecha_nacimiento': Timestamp.fromDate(fechaNacimiento),
      'sexo': sexo,
      'raza_predominante': razaPredominante,
      'estado_productivo': estadoProductivo,
      'estatus_sistema': estatusSistema,
    };
  }

  /// Parsea una fecha desde Firestore (Timestamp).
  /// 
  /// Soporta:
  /// - Timestamp de Firestore (objeto Timestamp o Map serializado)
  /// - DateTime directamente
  /// - String ISO 8601 (para compatibilidad)
  /// 
  /// Valida que la fecha no sea futura (requisito de NOM-001 para fecha de nacimiento).
  static DateTime _parseFechaFirestore(dynamic fecha) {
    if (fecha == null) {
      throw FormatException('La fecha no puede ser nula');
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
        throw FormatException(
          'Formato de fecha no válido: $fecha',
        );
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
        throw FormatException('Formato de Timestamp no válido: $fecha');
      }
    } else {
      throw FormatException('Tipo de fecha no soportado: ${fecha.runtimeType}');
    }

    // Validar que la fecha no sea futura (NOM-001)
    _validarFechaNoFutura(dateTime);
    return dateTime;
  }
}

