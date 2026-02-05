import '../../domain/entities/predio_entity.dart';

/// Contrato (interfaz) para el repositorio de predios.
/// 
/// Define los métodos necesarios para la gestión de predios (UPPs).
/// Las implementaciones concretas estarán en la capa de datos.
abstract class PredioRepository {
  /// Obtiene todos los predios de un usuario.
  /// 
  /// [idUsuario] - ID del usuario propietario
  /// 
  /// Retorna una lista de [PredioEntity].
  Future<List<PredioEntity>> getPrediosByUsuario(String idUsuario);

  /// Obtiene un predio por su ID.
  /// 
  /// [idPredio] - ID del predio
  /// 
  /// Retorna la entidad [PredioEntity] o null si no existe.
  Future<PredioEntity?> getPredioById(String idPredio);

  /// Crea un nuevo predio.
  /// 
  /// [predio] - Entidad del predio a crear
  /// 
  /// Retorna la entidad [PredioEntity] creada con su ID asignado.
  Future<PredioEntity> createPredio(PredioEntity predio);

  /// Actualiza un predio existente.
  /// 
  /// [predio] - Entidad del predio con los datos actualizados
  /// 
  /// Retorna la entidad [PredioEntity] actualizada.
  Future<PredioEntity> updatePredio(PredioEntity predio);

  /// Elimina un predio.
  /// 
  /// [idPredio] - ID del predio a eliminar
  Future<void> deletePredio(String idPredio);
}




