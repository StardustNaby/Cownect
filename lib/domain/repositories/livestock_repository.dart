import '../../domain/entities/bovino_entity.dart';

/// Contrato (interfaz) para el repositorio de ganado.
/// 
/// Define los métodos necesarios para la gestión de bovinos.
/// Las implementaciones concretas estarán en la capa de datos.
abstract class LivestockRepository {
  /// Obtiene la lista de todos los bovinos.
  /// 
  /// [idUpp] - ID de la UPP para filtrar bovinos (opcional).
  ///            Si se proporciona, retorna solo los bovinos de esa UPP.
  /// 
  /// Retorna una lista de entidades [BovinoEntity].
  /// Retorna una lista vacía si no hay bovinos.
  Future<List<BovinoEntity>> getBovinos({String? idUpp});

  /// Obtiene un bovino específico por su ID.
  /// 
  /// [id] - ID único del bovino (UUID)
  /// 
  /// Retorna la entidad [BovinoEntity] del bovino encontrado.
  /// Lanza una excepción si el bovino no existe.
  Future<BovinoEntity> getBovinoById({required String id});

  /// Crea un nuevo bovino en el sistema.
  /// 
  /// [bovino] - Entidad [BovinoEntity] con los datos del nuevo bovino.
  ///            El campo [id] puede ser generado automáticamente.
  /// 
  /// Retorna la entidad [BovinoEntity] del bovino creado con su ID asignado.
  /// Lanza una excepción si la creación falla (validaciones, etc.).
  Future<BovinoEntity> createBovino({required BovinoEntity bovino});

  /// Actualiza un bovino existente en el sistema.
  /// 
  /// [bovino] - Entidad [BovinoEntity] con los datos actualizados.
  ///            Debe incluir el [id] del bovino a actualizar.
  /// 
  /// Retorna la entidad [BovinoEntity] actualizada.
  /// Lanza una excepción si el bovino no existe o si la actualización falla.
  Future<BovinoEntity> updateBovino({required BovinoEntity bovino});

  /// Elimina un bovino del sistema.
  /// 
  /// [id] - ID único del bovino a eliminar (UUID)
  /// 
  /// No retorna nada. Lanza una excepción si el bovino no existe o si la eliminación falla.
  Future<void> deleteBovino({required String id});

  /// Obtiene bovinos filtrados por estado productivo.
  /// 
  /// [estadoProductivo] - Estado productivo a filtrar
  ///                      (CRIA, DESTETADO, VAQUILLA, TORO_ENGORDA, VACA_ORDENA, VACA_SECA)
  /// [idUpp] - ID de la UPP para filtrar (opcional)
  /// 
  /// Retorna una lista de entidades [BovinoEntity] que coinciden con el filtro.
  Future<List<BovinoEntity>> getBovinosByEstadoProductivo({
    required String estadoProductivo,
    String? idUpp,
  });

  /// Obtiene bovinos filtrados por estatus del sistema.
  /// 
  /// [estatusSistema] - Estatus del sistema a filtrar
  ///                    (ACTIVO, VENDIDO, MUERTO, ROBADO)
  /// [idUpp] - ID de la UPP para filtrar (opcional)
  /// 
  /// Retorna una lista de entidades [BovinoEntity] que coinciden con el filtro.
  Future<List<BovinoEntity>> getBovinosByEstatusSistema({
    required String estatusSistema,
    String? idUpp,
  });
}

