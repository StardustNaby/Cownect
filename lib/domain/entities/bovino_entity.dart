/// Entidad de dominio que representa un bovino.
/// 
/// Esta entidad es inmutable y contiene toda la información
/// de un animal bovino registrado en el sistema.
class BovinoEntity {
  /// Identificador único del bovino (UUID).
  final String id;

  /// Identificador de la UPP a la que pertenece (FK a upp).
  final String idUpp;

  /// Identificador de la infraestructura/corral (FK opcional a corrales).
  final String? idInfraestructura;

  /// Arete SINIIGA (formato: MX + 2 dígitos estado + 8 dígitos consecutivo).
  /// Ejemplo: 'MX3100000123'
  final String? areteSiniiga;

  /// Arete de trabajo (número visual corto, ej: '504').
  final String areteTrabajo;

  /// Sexo del bovino (debe ser estrictamente 'M' o 'H').
  final String sexo;

  /// Fecha de nacimiento del bovino (no puede ser fecha futura).
  final DateTime fechaNacimiento;

  /// Raza predominante del bovino.
  final String razaPredominante;

  /// Estado productivo del bovino.
  /// Valores permitidos: CRIA, DESTETADO, VAQUILLA, TORO_ENGORDA,
  /// VACA_ORDENA, VACA_SECA
  final String estadoProductivo;

  /// Estatus del bovino en el sistema.
  /// Valores permitidos: ACTIVO, VENDIDO, MUERTO, ROBADO
  final String estatusSistema;

  /// Valores permitidos para el estado productivo.
  static const List<String> estadosProductivosValidos = [
    'CRIA',
    'DESTETADO',
    'VAQUILLA',
    'TORO_ENGORDA',
    'VACA_ORDENA',
    'VACA_SECA',
  ];

  /// Valores permitidos para el estatus del sistema.
  static const List<String> estatusSistemaValidos = [
    'ACTIVO',
    'VENDIDO',
    'MUERTO',
    'ROBADO',
  ];

  /// Constructor de la entidad Bovino.
  /// 
  /// Valida que:
  /// - El sexo sea 'M' o 'H'
  /// - La fecha de nacimiento no sea futura
  /// - El estado productivo sea uno de los valores permitidos
  /// - El estatus del sistema sea uno de los valores permitidos
  /// - El areteSiniiga tenga el formato correcto si está presente
  BovinoEntity({
    required this.id,
    required this.idUpp,
    this.idInfraestructura,
    this.areteSiniiga,
    required this.areteTrabajo,
    required this.sexo,
    required this.fechaNacimiento,
    required this.razaPredominante,
    required this.estadoProductivo,
    required this.estatusSistema,
  }) : assert(
          sexo == 'M' || sexo == 'H',
          'El sexo debe ser estrictamente "M" o "H"',
        ),
        assert(
          !_esFechaFutura(fechaNacimiento),
          'La fecha de nacimiento no puede ser una fecha futura',
        ),
        assert(
          estadosProductivosValidos.contains(estadoProductivo),
          'El estado productivo debe ser uno de: ${estadosProductivosValidos.join(", ")}',
        ),
        assert(
          estatusSistemaValidos.contains(estatusSistema),
          'El estatus del sistema debe ser uno de: ${estatusSistemaValidos.join(", ")}',
        ),
        assert(
          areteSiniiga == null || _esFormatoAreteSiniigaValido(areteSiniiga),
          'El areteSiniiga debe tener el formato: MX + 2 dígitos estado + 8 dígitos consecutivo',
        );

  /// Valida que la fecha no sea futura.
  static bool _esFechaFutura(DateTime fecha) {
    return fecha.isAfter(DateTime.now());
  }

  /// Valida el formato del arete SINIIGA.
  /// Formato esperado: MX + 2 dígitos estado + 8 dígitos consecutivo
  /// Ejemplo: 'MX3100000123'
  static bool _esFormatoAreteSiniigaValido(String arete) {
    final regex = RegExp(r'^MX\d{2}\d{8}$');
    return regex.hasMatch(arete);
  }

  /// Crea una copia de la entidad con los campos modificados.
  BovinoEntity copyWith({
    String? id,
    String? idUpp,
    String? idInfraestructura,
    String? areteSiniiga,
    String? areteTrabajo,
    String? sexo,
    DateTime? fechaNacimiento,
    String? razaPredominante,
    String? estadoProductivo,
    String? estatusSistema,
  }) {
    return BovinoEntity(
      id: id ?? this.id,
      idUpp: idUpp ?? this.idUpp,
      idInfraestructura: idInfraestructura ?? this.idInfraestructura,
      areteSiniiga: areteSiniiga ?? this.areteSiniiga,
      areteTrabajo: areteTrabajo ?? this.areteTrabajo,
      sexo: sexo ?? this.sexo,
      fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
      razaPredominante: razaPredominante ?? this.razaPredominante,
      estadoProductivo: estadoProductivo ?? this.estadoProductivo,
      estatusSistema: estatusSistema ?? this.estatusSistema,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BovinoEntity &&
        other.id == id &&
        other.idUpp == idUpp &&
        other.idInfraestructura == idInfraestructura &&
        other.areteSiniiga == areteSiniiga &&
        other.areteTrabajo == areteTrabajo &&
        other.sexo == sexo &&
        other.fechaNacimiento == fechaNacimiento &&
        other.razaPredominante == razaPredominante &&
        other.estadoProductivo == estadoProductivo &&
        other.estatusSistema == estatusSistema;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      idUpp,
      idInfraestructura,
      areteSiniiga,
      areteTrabajo,
      sexo,
      fechaNacimiento,
      razaPredominante,
      estadoProductivo,
      estatusSistema,
    );
  }

  @override
  String toString() {
    return 'BovinoEntity(id: $id, idUpp: $idUpp, '
        'idInfraestructura: $idInfraestructura, areteSiniiga: $areteSiniiga, '
        'areteTrabajo: $areteTrabajo, sexo: $sexo, '
        'fechaNacimiento: $fechaNacimiento, razaPredominante: $razaPredominante, '
        'estadoProductivo: $estadoProductivo, estatusSistema: $estatusSistema)';
  }
}

