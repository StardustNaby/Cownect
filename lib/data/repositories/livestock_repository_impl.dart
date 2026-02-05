import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/livestock_repository.dart';
import '../../domain/entities/bovino_entity.dart';
import '../../data/models/bovino_model.dart';
import '../../core/providers/firebase_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Excepción personalizada para errores del repositorio de ganado.
class LivestockException implements Exception {
  final String message;
  final String? code;

  LivestockException(this.message, [this.code]);

  @override
  String toString() => message;
}

/// Excepción para errores de conexión (modo offline).
class NoInternetException extends LivestockException {
  NoInternetException([String? message])
      : super(
          message ?? 'No hay conexión a internet. Verifica tu conexión e intenta nuevamente.',
          'NO_INTERNET',
        );
}

/// Implementación del repositorio de ganado usando Firebase Firestore.
/// 
/// Esta clase implementa [LivestockRepository] y utiliza Firestore
/// para todas las operaciones relacionadas con bovinos.
class LivestockRepositoryImpl implements LivestockRepository {
  final FirebaseFirestore _firestore;
  final String? _activeUppId;

  LivestockRepositoryImpl(
    this._firestore, {
    String? activeUppId,
  }) : _activeUppId = activeUppId;

  @override
  Future<List<BovinoEntity>> getBovinos({String? idUpp}) async {
    try {
      // Usar la UPP activa si no se proporciona una específica
      final uppId = idUpp ?? _activeUppId;
      
      if (uppId == null) {
        throw LivestockException(
          'No se ha especificado una UPP. Debe seleccionar una UPP activa.',
        );
      }

      final querySnapshot = await _firestore
          .collection('bovino')
          .where('id_upp', isEqualTo: uppId)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return [];
      }

      return querySnapshot.docs
          .map((doc) => BovinoModel.fromFirestore(doc).toEntity())
          .toList();
    } on SocketException catch (_) {
      throw NoInternetException();
    } on FirebaseException catch (e) {
      throw LivestockException(
        'Error al obtener bovinos: ${e.message}',
        e.code,
      );
    } catch (e) {
      if (e is LivestockException) rethrow;
      throw LivestockException('Error inesperado al obtener bovinos: ${e.toString()}');
    }
  }

  @override
  Future<BovinoEntity> getBovinoById({required String id}) async {
    try {
      final doc = await _firestore
          .collection('bovino')
          .doc(id)
          .get();

      if (!doc.exists) {
        throw LivestockException('Bovino no encontrado con ID: $id');
      }

      final model = BovinoModel.fromFirestore(doc);
      return model.toEntity();
    } on SocketException catch (_) {
      throw NoInternetException();
    } on FirebaseException catch (e) {
      throw LivestockException(
        'Error al obtener bovino: ${e.message}',
        e.code,
      );
    } catch (e) {
      if (e is LivestockException) rethrow;
      throw LivestockException('Error inesperado al obtener bovino: ${e.toString()}');
    }
  }

  @override
  Future<BovinoEntity> createBovino({required BovinoEntity bovino}) async {
    try {
      // Validar formato del arete SINIIGA antes de enviar a Firestore
      if (bovino.areteSiniiga != null) {
        if (!_validarFormatoAreteSiniiga(bovino.areteSiniiga!)) {
          throw LivestockException(
            'El arete SINIIGA debe tener el formato: MX seguido de 10 dígitos (ej: MX3100000123)',
            'INVALID_ARETE_FORMAT',
          );
        }
      }

      // Convertir entidad a modelo para serialización
      final model = BovinoModel.fromEntity(bovino);
      final json = model.toFirestore();

      // Generar un ID único si no existe
      final docRef = _firestore.collection('bovino').doc();
      final id = bovino.id.isNotEmpty ? bovino.id : docRef.id;

      // Remover el ID del JSON (Firestore lo maneja como document ID)
      json.remove('id_bovino');

      // Guardar en Firestore usando el ID como document ID
      await _firestore
          .collection('bovino')
          .doc(id)
          .set(json);

      // Obtener el documento creado
      final createdDoc = await _firestore
          .collection('bovino')
          .doc(id)
          .get();

      final createdModel = BovinoModel.fromFirestore(createdDoc);
      return createdModel.toEntity();
    } on SocketException catch (_) {
      throw NoInternetException();
    } on FirebaseException catch (e) {
      // Manejar errores específicos de Firestore
      if (e.code == 'permission-denied') {
        throw LivestockException(
          'No tienes permisos para crear bovinos.',
          'PERMISSION_DENIED',
        );
      }
      throw LivestockException(
        'Error al crear bovino: ${e.message}',
        e.code,
      );
    } catch (e) {
      if (e is LivestockException) rethrow;
      throw LivestockException('Error inesperado al crear bovino: ${e.toString()}');
    }
  }

  @override
  Future<BovinoEntity> updateBovino({required BovinoEntity bovino}) async {
    try {
      // Validar formato del arete SINIIGA si se actualiza
      if (bovino.areteSiniiga != null) {
        if (!_validarFormatoAreteSiniiga(bovino.areteSiniiga!)) {
          throw LivestockException(
            'El arete SINIIGA debe tener el formato: MX seguido de 10 dígitos (ej: MX3100000123)',
            'INVALID_ARETE_FORMAT',
          );
        }
      }

      // Convertir entidad a modelo para serialización
      final model = BovinoModel.fromEntity(bovino);
      final json = model.toFirestore();

      // Remover el ID del JSON de actualización
      final id = bovino.id;
      json.remove('id_bovino');

      // Verificar que el documento existe
      final docRef = _firestore.collection('bovino').doc(id);
      final doc = await docRef.get();

      if (!doc.exists) {
        throw LivestockException(
          'Bovino no encontrado. No se pudo actualizar.',
          'NOT_FOUND',
        );
      }

      // Actualizar en Firestore
      await docRef.update(json);

      // Obtener el documento actualizado
      final updatedDoc = await docRef.get();
      final updatedModel = BovinoModel.fromFirestore(updatedDoc);
      return updatedModel.toEntity();
    } on SocketException catch (_) {
      throw NoInternetException();
    } on FirebaseException catch (e) {
      if (e.code == 'not-found') {
        throw LivestockException(
          'Bovino no encontrado. No se pudo actualizar.',
          'NOT_FOUND',
        );
      }
      if (e.code == 'permission-denied') {
        throw LivestockException(
          'No tienes permisos para actualizar bovinos.',
          'PERMISSION_DENIED',
        );
      }
      throw LivestockException(
        'Error al actualizar bovino: ${e.message}',
        e.code,
      );
    } catch (e) {
      if (e is LivestockException) rethrow;
      throw LivestockException('Error inesperado al actualizar bovino: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteBovino({required String id}) async {
    try {
      final docRef = _firestore.collection('bovino').doc(id);
      
      // Verificar que el documento existe
      final doc = await docRef.get();
      
      if (!doc.exists) {
        throw LivestockException(
          'Bovino no encontrado. No se pudo eliminar.',
          'NOT_FOUND',
        );
      }

      // Eliminar el documento
      await docRef.delete();
    } on SocketException catch (_) {
      throw NoInternetException();
    } on FirebaseException catch (e) {
      if (e.code == 'not-found') {
        throw LivestockException(
          'Bovino no encontrado. No se pudo eliminar.',
          'NOT_FOUND',
        );
      }
      if (e.code == 'permission-denied') {
        throw LivestockException(
          'No tienes permisos para eliminar bovinos.',
          'PERMISSION_DENIED',
        );
      }
      throw LivestockException(
        'Error al eliminar bovino: ${e.message}',
        e.code,
      );
    } catch (e) {
      if (e is LivestockException) rethrow;
      throw LivestockException('Error inesperado al eliminar bovino: ${e.toString()}');
    }
  }

  @override
  Future<List<BovinoEntity>> getBovinosByEstadoProductivo({
    required String estadoProductivo,
    String? idUpp,
  }) async {
    try {
      // Usar la UPP activa si no se proporciona una específica
      final uppId = idUpp ?? _activeUppId;
      
      if (uppId == null) {
        throw LivestockException(
          'No se ha especificado una UPP. Debe seleccionar una UPP activa.',
        );
      }

      final querySnapshot = await _firestore
          .collection('bovino')
          .where('id_upp', isEqualTo: uppId)
          .where('estado_productivo', isEqualTo: estadoProductivo)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return [];
      }

      return querySnapshot.docs
          .map((doc) => BovinoModel.fromFirestore(doc).toEntity())
          .toList();
    } on SocketException catch (_) {
      throw NoInternetException();
    } on FirebaseException catch (e) {
      throw LivestockException(
        'Error al obtener bovinos por estado productivo: ${e.message}',
        e.code,
      );
    } catch (e) {
      if (e is LivestockException) rethrow;
      throw LivestockException(
        'Error inesperado al obtener bovinos: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<BovinoEntity>> getBovinosByEstatusSistema({
    required String estatusSistema,
    String? idUpp,
  }) async {
    try {
      // Usar la UPP activa si no se proporciona una específica
      final uppId = idUpp ?? _activeUppId;
      
      if (uppId == null) {
        throw LivestockException(
          'No se ha especificado una UPP. Debe seleccionar una UPP activa.',
        );
      }

      final querySnapshot = await _firestore
          .collection('bovino')
          .where('id_upp', isEqualTo: uppId)
          .where('estatus_sistema', isEqualTo: estatusSistema)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return [];
      }

      return querySnapshot.docs
          .map((doc) => BovinoModel.fromFirestore(doc).toEntity())
          .toList();
    } on SocketException catch (_) {
      throw NoInternetException();
    } on FirebaseException catch (e) {
      throw LivestockException(
        'Error al obtener bovinos por estatus: ${e.message}',
        e.code,
      );
    } catch (e) {
      if (e is LivestockException) rethrow;
      throw LivestockException(
        'Error inesperado al obtener bovinos: ${e.toString()}',
      );
    }
  }

  /// Valida el formato del arete SINIIGA.
  /// 
  /// Formato esperado: MX seguido de 10 dígitos
  /// Ejemplo: MX3100000123 (MX + 2 dígitos estado + 8 dígitos consecutivo)
  bool _validarFormatoAreteSiniiga(String arete) {
    // Formato: MX + 10 dígitos
    final regex = RegExp(r'^MX\d{10}$');
    return regex.hasMatch(arete);
  }
}

/// Provider que expone la implementación del repositorio de ganado.
/// 
/// Este provider utiliza el [firebaseFirestoreProvider] para obtener la instancia
/// de Firestore y crear una instancia de [LivestockRepositoryImpl].
/// 
/// Nota: Requiere que se proporcione el ID de la UPP activa.
/// Por defecto, intentará obtenerlo del usuario actual si está disponible.
final livestockRepositoryProvider = Provider.family<LivestockRepository, String?>((ref, activeUppId) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return LivestockRepositoryImpl(firestore, activeUppId: activeUppId);
});
