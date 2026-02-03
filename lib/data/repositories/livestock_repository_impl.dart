import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/livestock_repository.dart';
import '../../domain/entities/bovino_entity.dart';
import '../../data/models/bovino_model.dart';
import '../../core/providers/supabase_provider.dart';
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

/// Implementación del repositorio de ganado usando Supabase.
/// 
/// Esta clase implementa [LivestockRepository] y utiliza Supabase
/// para todas las operaciones relacionadas con bovinos.
class LivestockRepositoryImpl implements LivestockRepository {
  final SupabaseClient _supabaseClient;
  final String? _activeUppId;

  LivestockRepositoryImpl(
    this._supabaseClient, {
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

      var query = _supabaseClient
          .from('bovino')
          .select()
          .eq('id_upp', uppId);

      final response = await query;

      if (response is List && response.isEmpty) {
        return [];
      }

      final List<dynamic> data = response is List ? response : [response];
      return data
          .map((json) => BovinoModel.fromJson(
                Map<String, dynamic>.from(json),
              ).toEntity())
          .toList();
    } on SocketException catch (_) {
      throw NoInternetException();
    } on HttpException catch (e) {
      throw LivestockException('Error de conexión: ${e.message}');
    } on PostgrestException catch (e) {
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
      final response = await _supabaseClient
          .from('bovino')
          .select()
          .eq('id_bovino', id)
          .maybeSingle();

      if (response == null) {
        throw LivestockException('Bovino no encontrado con ID: $id');
      }

      final model = BovinoModel.fromJson(Map<String, dynamic>.from(response));
      return model.toEntity();
    } on SocketException catch (_) {
      throw NoInternetException();
    } on HttpException catch (e) {
      throw LivestockException('Error de conexión: ${e.message}');
    } on PostgrestException catch (e) {
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
      // Validar formato del arete SINIIGA antes de enviar a Supabase
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
      final json = model.toJson();

      // Remover el ID si existe (Supabase lo generará)
      json.remove('id_bovino');

      final response = await _supabaseClient
          .from('bovino')
          .insert(json)
          .select()
          .single();

      final createdModel = BovinoModel.fromJson(
        Map<String, dynamic>.from(response),
      );
      return createdModel.toEntity();
    } on SocketException catch (_) {
      throw NoInternetException();
    } on HttpException catch (e) {
      throw LivestockException('Error de conexión: ${e.message}');
    } on PostgrestException catch (e) {
      // Manejar errores específicos de Supabase
      if (e.code == '23505') {
        // Violación de constraint único (arete duplicado)
        throw LivestockException(
          'Ya existe un bovino con este arete. Verifica que el arete sea único.',
          'DUPLICATE_ARETE',
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
      final json = model.toJson();

      // Remover el ID del JSON de actualización
      final id = json.remove('id_bovino') as String;

      final response = await _supabaseClient
          .from('bovino')
          .update(json)
          .eq('id_bovino', id)
          .select()
          .single();

      final updatedModel = BovinoModel.fromJson(
        Map<String, dynamic>.from(response),
      );
      return updatedModel.toEntity();
    } on SocketException catch (_) {
      throw NoInternetException();
    } on HttpException catch (e) {
      throw LivestockException('Error de conexión: ${e.message}');
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        // No se encontró el registro
        throw LivestockException(
          'Bovino no encontrado. No se pudo actualizar.',
          'NOT_FOUND',
        );
      }
      if (e.code == '23505') {
        throw LivestockException(
          'Ya existe un bovino con este arete. Verifica que el arete sea único.',
          'DUPLICATE_ARETE',
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
      final response = await _supabaseClient
          .from('bovino')
          .delete()
          .eq('id_bovino', id);

      // Verificar si se eliminó algún registro
      if (response == null || (response is List && response.isEmpty)) {
        throw LivestockException(
          'Bovino no encontrado. No se pudo eliminar.',
          'NOT_FOUND',
        );
      }
    } on SocketException catch (_) {
      throw NoInternetException();
    } on HttpException catch (e) {
      throw LivestockException('Error de conexión: ${e.message}');
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        throw LivestockException(
          'Bovino no encontrado. No se pudo eliminar.',
          'NOT_FOUND',
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

      var query = _supabaseClient
          .from('bovino')
          .select()
          .eq('id_upp', uppId)
          .eq('estado_productivo', estadoProductivo);

      final response = await query;

      if (response is List && response.isEmpty) {
        return [];
      }

      final List<dynamic> data = response is List ? response : [response];
      return data
          .map((json) => BovinoModel.fromJson(
                Map<String, dynamic>.from(json),
              ).toEntity())
          .toList();
    } on SocketException catch (_) {
      throw NoInternetException();
    } on HttpException catch (e) {
      throw LivestockException('Error de conexión: ${e.message}');
    } on PostgrestException catch (e) {
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

      var query = _supabaseClient
          .from('bovino')
          .select()
          .eq('id_upp', uppId)
          .eq('estatus_sistema', estatusSistema);

      final response = await query;

      if (response is List && response.isEmpty) {
        return [];
      }

      final List<dynamic> data = response is List ? response : [response];
      return data
          .map((json) => BovinoModel.fromJson(
                Map<String, dynamic>.from(json),
              ).toEntity())
          .toList();
    } on SocketException catch (_) {
      throw NoInternetException();
    } on HttpException catch (e) {
      throw LivestockException('Error de conexión: ${e.message}');
    } on PostgrestException catch (e) {
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
/// Este provider utiliza el [supabaseClientProvider] para obtener el cliente
/// de Supabase y crear una instancia de [LivestockRepositoryImpl].
/// 
/// Nota: Requiere que se proporcione el ID de la UPP activa.
/// Por defecto, intentará obtenerlo del usuario actual si está disponible.
final livestockRepositoryProvider = Provider.family<LivestockRepository, String?>((ref, activeUppId) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return LivestockRepositoryImpl(supabaseClient, activeUppId: activeUppId);
});

