import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/predio_repository.dart';
import '../../domain/entities/predio_entity.dart';
import '../../data/models/predio_model.dart';
import '../../core/providers/firebase_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Excepción personalizada para errores del repositorio de predios.
class PredioException implements Exception {
  final String message;
  final String? code;

  PredioException(this.message, [this.code]);

  @override
  String toString() => message;
}

/// Excepción para errores de conexión (modo offline).
class NoInternetException extends PredioException {
  NoInternetException([String? message])
      : super(
          message ?? 'No hay conexión a internet. Verifica tu conexión e intenta nuevamente.',
          'NO_INTERNET',
        );
}

/// Implementación del repositorio de predios usando Firebase Firestore.
/// 
/// Esta clase implementa [PredioRepository] y utiliza Firestore
/// para todas las operaciones relacionadas con predios.
/// Cumple con los requisitos de la NOM-001-SAG/GAN-2015.
class PredioRepositoryImpl implements PredioRepository {
  final FirebaseFirestore _firestore;

  PredioRepositoryImpl(this._firestore);

  @override
  Future<List<PredioEntity>> getPrediosByUsuario(String idUsuario) async {
    try {
      final querySnapshot = await _firestore
          .collection('predio')
          .where('id_usuario', isEqualTo: idUsuario)
          .orderBy('fecha_creacion', descending: true)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return [];
      }

      return querySnapshot.docs
          .map((doc) => PredioModel.fromFirestore(doc).toEntity())
          .toList();
    } on SocketException catch (_) {
      throw NoInternetException();
    } on FirebaseException catch (e) {
      throw PredioException(
        'Error al obtener predios: ${e.message}',
        e.code,
      );
    } catch (e) {
      if (e is PredioException) rethrow;
      throw PredioException('Error inesperado al obtener predios: ${e.toString()}');
    }
  }

  @override
  Future<PredioEntity?> getPredioById(String idPredio) async {
    try {
      final doc = await _firestore
          .collection('predio')
          .doc(idPredio)
          .get();

      if (!doc.exists) {
        return null;
      }

      final model = PredioModel.fromFirestore(doc);
      return model.toEntity();
    } on SocketException catch (_) {
      throw NoInternetException();
    } on FirebaseException catch (e) {
      throw PredioException(
        'Error al obtener predio: ${e.message}',
        e.code,
      );
    } catch (e) {
      if (e is PredioException) rethrow;
      throw PredioException('Error inesperado al obtener predio: ${e.toString()}');
    }
  }

  @override
  Future<PredioEntity> createPredio(PredioEntity predio) async {
    try {
      // Convertir entidad a modelo para serialización
      final model = PredioModel.fromEntity(predio);
      final json = model.toFirestore();

      // Generar un ID único si no existe
      final docRef = _firestore.collection('predio').doc();
      final id = predio.id.isNotEmpty ? predio.id : docRef.id;

      // Remover el ID del JSON (Firestore lo maneja como document ID)
      json.remove('id_predio');
      
      // Establecer fecha de creación si no existe
      if (!json.containsKey('fecha_creacion') || json['fecha_creacion'] == null) {
        json['fecha_creacion'] = Timestamp.fromDate(DateTime.now());
      }

      // Guardar en Firestore usando el ID como document ID
      await _firestore
          .collection('predio')
          .doc(id)
          .set(json);

      // Obtener el documento creado
      final createdDoc = await _firestore
          .collection('predio')
          .doc(id)
          .get();

      final createdModel = PredioModel.fromFirestore(createdDoc);
      return createdModel.toEntity();
    } on SocketException catch (_) {
      throw NoInternetException();
    } on FirebaseException catch (e) {
      // Manejar errores específicos de Firestore
      if (e.code == 'permission-denied') {
        throw PredioException(
          'No tienes permisos para crear predios.',
          'PERMISSION_DENIED',
        );
      }
      if (e.code == 'already-exists') {
        throw PredioException(
          'Ya existe un predio con esta Clave PGN. Verifica que la clave sea única.',
          'DUPLICATE_CLAVE_PGN',
        );
      }
      throw PredioException(
        'Error al crear predio: ${e.message}',
        e.code,
      );
    } catch (e) {
      if (e is PredioException) rethrow;
      throw PredioException('Error inesperado al crear predio: ${e.toString()}');
    }
  }

  @override
  Future<PredioEntity> updatePredio(PredioEntity predio) async {
    try {
      // Convertir entidad a modelo para serialización
      final model = PredioModel.fromEntity(predio);
      final json = model.toFirestore();

      // Remover el ID del JSON de actualización
      final id = predio.id;
      json.remove('id_predio');

      // Verificar que el documento existe
      final docRef = _firestore.collection('predio').doc(id);
      final doc = await docRef.get();

      if (!doc.exists) {
        throw PredioException(
          'Predio no encontrado. No se pudo actualizar.',
          'NOT_FOUND',
        );
      }

      // Actualizar en Firestore
      await docRef.update(json);

      // Obtener el documento actualizado
      final updatedDoc = await docRef.get();
      final updatedModel = PredioModel.fromFirestore(updatedDoc);
      return updatedModel.toEntity();
    } on SocketException catch (_) {
      throw NoInternetException();
    } on FirebaseException catch (e) {
      if (e.code == 'not-found') {
        throw PredioException(
          'Predio no encontrado. No se pudo actualizar.',
          'NOT_FOUND',
        );
      }
      if (e.code == 'permission-denied') {
        throw PredioException(
          'No tienes permisos para actualizar predios.',
          'PERMISSION_DENIED',
        );
      }
      if (e.code == 'already-exists') {
        throw PredioException(
          'Ya existe un predio con esta Clave PGN. Verifica que la clave sea única.',
          'DUPLICATE_CLAVE_PGN',
        );
      }
      throw PredioException(
        'Error al actualizar predio: ${e.message}',
        e.code,
      );
    } catch (e) {
      if (e is PredioException) rethrow;
      throw PredioException('Error inesperado al actualizar predio: ${e.toString()}');
    }
  }

  @override
  Future<void> deletePredio(String idPredio) async {
    try {
      final docRef = _firestore.collection('predio').doc(idPredio);
      
      // Verificar que el documento existe
      final doc = await docRef.get();
      
      if (!doc.exists) {
        throw PredioException(
          'Predio no encontrado. No se pudo eliminar.',
          'NOT_FOUND',
        );
      }

      // Eliminar el documento
      await docRef.delete();
    } on SocketException catch (_) {
      throw NoInternetException();
    } on FirebaseException catch (e) {
      if (e.code == 'not-found') {
        throw PredioException(
          'Predio no encontrado. No se pudo eliminar.',
          'NOT_FOUND',
        );
      }
      if (e.code == 'permission-denied') {
        throw PredioException(
          'No tienes permisos para eliminar predios.',
          'PERMISSION_DENIED',
        );
      }
      throw PredioException(
        'Error al eliminar predio: ${e.message}',
        e.code,
      );
    } catch (e) {
      if (e is PredioException) rethrow;
      throw PredioException('Error inesperado al eliminar predio: ${e.toString()}');
    }
  }
}

/// Provider que expone la implementación del repositorio de predios.
/// 
/// Este provider utiliza el [firebaseFirestoreProvider] para obtener la instancia
/// de Firestore y crear una instancia de [PredioRepositoryImpl].
final predioRepositoryProvider = Provider<PredioRepository>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return PredioRepositoryImpl(firestore);
});
