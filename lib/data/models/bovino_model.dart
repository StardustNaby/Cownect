import '../../domain/entities/bovino_entity.dart';

/// Modelo de datos que representa un bovino.
/// 
/// Extiende BovinoEntity y proporciona métodos de serialización
/// para interactuar con Supabase.
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
  /// - String ISO 8601 (ej: "2023-12-25T00:00:00Z")
  /// - String formato fecha (ej: "2023-12-25")
  /// - DateTime directamente
  /// - Timestamp de Supabase
  static DateTime _parseFecha(dynamic fecha) {
    if (fecha == null) {
      throw FormatException('La fecha no puede ser nula');
    }

    if (fecha is DateTime) {
      return fecha;
    }

    if (fecha is String) {
      // Intentar parsear como ISO 8601
      try {
        return DateTime.parse(fecha);
      } catch (e) {
        // Intentar parsear como fecha simple (YYYY-MM-DD)
        try {
          return DateTime.parse('$fecha 00:00:00Z');
        } catch (e2) {
          throw FormatException(
            'Formato de fecha no válido: $fecha',
          );
        }
      }
    }

    // Si es un Timestamp de Supabase (objeto con seconds y nanoseconds)
    if (fecha is Map) {
      if (fecha.containsKey('seconds')) {
        final seconds = fecha['seconds'] as int;
        return DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
      }
    }

    throw FormatException('Tipo de fecha no soportado: ${fecha.runtimeType}');
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
}

