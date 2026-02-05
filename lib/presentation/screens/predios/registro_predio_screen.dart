import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/estados_mexico.dart';
import '../../../domain/entities/predio_entity.dart';
import '../../../data/repositories/predio_repository_impl.dart';
import '../../../data/models/predio_model.dart';
import '../../providers/auth_provider.dart';
import '../../../core/providers/predio_provider.dart';

/// Pantalla para registrar un nuevo predio.
/// 
/// Cumple con los requisitos de la NOM-001-SAG/GAN-2015 y estándares ISO 25010.
/// Implementa validación en origen, protección contra errores y completitud funcional.
class RegistroPredioScreen extends ConsumerStatefulWidget {
  const RegistroPredioScreen({super.key});

  @override
  ConsumerState<RegistroPredioScreen> createState() => _RegistroPredioScreenState();
}

class _RegistroPredioScreenState extends ConsumerState<RegistroPredioScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _clavePGNController = TextEditingController();
  final _propietarioLegalController = TextEditingController();
  final _municipioController = TextEditingController();
  final _localidadController = TextEditingController();
  final _codigoPostalController = TextEditingController();
  final _direccionController = TextEditingController();
  final _superficieController = TextEditingController();
  final _latitudController = TextEditingController();
  final _longitudController = TextEditingController();
  final _uppController = TextEditingController();
  final _claveCatastralController = TextEditingController();

  String? _estadoSeleccionado;
  String? _tipoTenencia;
  String? _tipoProduccion;
  String? _errorMessage;
  bool _isLoading = false;
  bool _obteniendoUbicacion = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _clavePGNController.dispose();
    _propietarioLegalController.dispose();
    _municipioController.dispose();
    _localidadController.dispose();
    _codigoPostalController.dispose();
    _direccionController.dispose();
    _superficieController.dispose();
    _latitudController.dispose();
    _longitudController.dispose();
    _uppController.dispose();
    _claveCatastralController.dispose();
    super.dispose();
  }

  /// Obtiene la ubicación actual usando GPS.
  Future<void> _obtenerUbicacionActual() async {
    setState(() {
      _obteniendoUbicacion = true;
      _errorMessage = null;
    });

    try {
      // Verificar permisos
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _errorMessage = 'El servicio de ubicación está deshabilitado. Por favor, actívalo en la configuración.';
          _obteniendoUbicacion = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _errorMessage = 'Se necesitan permisos de ubicación para obtener las coordenadas.';
            _obteniendoUbicacion = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _errorMessage = 'Los permisos de ubicación están denegados permanentemente. Configúralos en la aplicación.';
          _obteniendoUbicacion = false;
        });
        return;
      }

      // Obtener ubicación
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _latitudController.text = position.latitude.toStringAsFixed(6);
        _longitudController.text = position.longitude.toStringAsFixed(6);
        _obteniendoUbicacion = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Ubicación obtenida correctamente'),
            backgroundColor: AppColors.emeraldGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al obtener la ubicación: ${e.toString()}';
        _obteniendoUbicacion = false;
      });
    }
  }

  /// Registra el nuevo predio.
  Future<void> _registrarPredio() async {
    if (!_formKey.currentState!.validate()) return;

    if (_estadoSeleccionado == null) {
      setState(() {
        _errorMessage = 'Debes seleccionar el estado.';
      });
      return;
    }

    if (_tipoTenencia == null) {
      setState(() {
        _errorMessage = 'Debes seleccionar el tipo de tenencia de la tierra.';
      });
      return;
    }

    if (_tipoProduccion == null) {
      setState(() {
        _errorMessage = 'Debes seleccionar el tipo de producción pecuaria.';
      });
      return;
    }

    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    try {
      // Validar datos
      final superficie = double.tryParse(_superficieController.text.trim());
      final latitud = _latitudController.text.trim().isNotEmpty
          ? double.tryParse(_latitudController.text.trim())
          : null;
      final longitud = _longitudController.text.trim().isNotEmpty
          ? double.tryParse(_longitudController.text.trim())
          : null;

      if (superficie == null || superficie <= 0) {
        setState(() {
          _errorMessage = 'La superficie debe ser un número mayor a 0.';
          _isLoading = false;
        });
        return;
      }

      if (latitud != null && (latitud < -90 || latitud > 90)) {
        setState(() {
          _errorMessage = 'La latitud debe estar entre -90 y 90.';
          _isLoading = false;
        });
        return;
      }

      if (longitud != null && (longitud < -180 || longitud > 180)) {
        setState(() {
          _errorMessage = 'La longitud debe estar entre -180 y 180.';
          _isLoading = false;
        });
        return;
      }

      // Validar que clavePGN tenga 12 dígitos
      final clavePGN = _clavePGNController.text.trim();
      if (clavePGN.length != 12 || !RegExp(r'^\d{12}$').hasMatch(clavePGN)) {
        setState(() {
          _errorMessage = 'La Clave PGN debe tener exactamente 12 dígitos numéricos.';
          _isLoading = false;
        });
        return;
      }

      // Obtener el usuario actual
      final authState = ref.read(authNotifierProvider);
      if (authState is! Authenticated) {
        setState(() {
          _errorMessage = 'No hay una sesión activa. Por favor, inicia sesión nuevamente.';
          _isLoading = false;
        });
        return;
      }

      final usuario = authState.user;

      // Crear la entidad del predio
      final nuevoPredio = PredioEntity(
        id: '', // Se generará en Supabase
        idUsuario: usuario.id,
        nombre: _nombreController.text.trim(),
        estado: _estadoSeleccionado!,
        municipio: _municipioController.text.trim(),
        localidad: _localidadController.text.trim(),
        codigoPostal: _codigoPostalController.text.trim(),
        direccion: _direccionController.text.trim(),
        superficieHectareas: superficie,
        tipoTenencia: _tipoTenencia!,
        latitud: latitud,
        longitud: longitud,
        upp: _uppController.text.trim(),
        clavePGN: clavePGN,
        propietarioLegal: _propietarioLegalController.text.trim(),
        tipoProduccion: _tipoProduccion!,
        claveCatastral: _claveCatastralController.text.trim().isNotEmpty
            ? _claveCatastralController.text.trim()
            : null,
        fechaCreacion: DateTime.now(),
      );

      // Guardar en Firebase usando el repositorio
      final repository = ref.read(predioRepositoryProvider);
      final predioCreado = await repository.createPredio(nuevoPredio);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Predio registrado correctamente'),
            backgroundColor: AppColors.emeraldGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
        
        // Establecer el predio actual en el provider y navegar directamente al predio
        ref.read(currentPredioIdProvider.notifier).state = predioCreado.id;
        context.go('/predio/home');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al registrar el predio. Intenta nuevamente.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Registrar Predio',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),

                // Icono
                Icon(
                  Icons.agriculture_outlined,
                  size: 80,
                  color: AppColors.emeraldGreen,
                ),
                const SizedBox(height: 24),

                // Título
                Text(
                  'Nuevo Predio',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Registro según NOM-001-SAG/GAN-2015',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Sección: Identificación Oficial
                _buildSectionTitle('Identificación Oficial'),
                const SizedBox(height: 16),

                // Campo Nombre
                TextFormField(
                  controller: _nombreController,
                  decoration: InputDecoration(
                    labelText: 'Nombre o Razón Social *',
                    labelStyle: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                    prefixIcon: const Icon(
                      Icons.agriculture_outlined,
                      color: Colors.black87,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  style: const TextStyle(color: Colors.black),
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El nombre del predio es obligatorio';
                    }
                    if (value.trim().length < 3) {
                      return 'El nombre debe tener al menos 3 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Campo Clave PGN (UPP)
                TextFormField(
                  controller: _clavePGNController,
                  decoration: InputDecoration(
                    labelText: 'Clave PGN (UPP) *',
                    labelStyle: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                    hintText: '12 dígitos',
                    prefixIcon: const Icon(
                      Icons.badge_outlined,
                      color: Colors.black87,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    helperText: 'Padrón Ganadero Nacional - 12 dígitos numéricos',
                    helperMaxLines: 2,
                  ),
                  style: const TextStyle(color: Colors.black),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(12),
                  ],
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'La Clave PGN es obligatoria';
                    }
                    if (value.length != 12) {
                      return 'La Clave PGN debe tener exactamente 12 dígitos';
                    }
                    if (!RegExp(r'^\d{12}$').hasMatch(value)) {
                      return 'La Clave PGN solo puede contener números';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Campo Propietario Legal
                TextFormField(
                  controller: _propietarioLegalController,
                  decoration: InputDecoration(
                    labelText: 'Propietario Legal *',
                    labelStyle: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                    hintText: 'Persona física o moral',
                    prefixIcon: const Icon(
                      Icons.person_outline,
                      color: Colors.black87,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  style: const TextStyle(color: Colors.black),
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El propietario legal es obligatorio';
                    }
                    if (value.trim().length < 3) {
                      return 'El nombre debe tener al menos 3 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Campo UPP
                TextFormField(
                  controller: _uppController,
                  decoration: InputDecoration(
                    labelText: 'Número de UPP *',
                    labelStyle: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                    hintText: 'Ingresa el número de UPP',
                    prefixIcon: const Icon(
                      Icons.badge_outlined,
                      color: Colors.black87,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  style: const TextStyle(color: Colors.black),
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.characters,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El UPP es obligatorio';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Sección: Ubicación Geográfica
                _buildSectionTitle('Ubicación Geográfica'),
                const SizedBox(height: 16),

                // Campo Estado (Dropdown)
                DropdownButtonFormField<String>(
                  value: _estadoSeleccionado,
                  decoration: InputDecoration(
                    labelText: 'Estado *',
                    labelStyle: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                    prefixIcon: const Icon(
                      Icons.map_outlined,
                      color: Colors.black87,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  style: const TextStyle(color: Colors.black),
                  items: EstadosMexico.nombres.map((estado) {
                    return DropdownMenuItem(
                      value: estado,
                      child: Text(estado),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _estadoSeleccionado = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Debes seleccionar el estado';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Campo Municipio
                TextFormField(
                  controller: _municipioController,
                  decoration: InputDecoration(
                    labelText: 'Municipio *',
                    labelStyle: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                    prefixIcon: const Icon(
                      Icons.location_city_outlined,
                      color: Colors.black87,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  style: const TextStyle(color: Colors.black),
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El municipio es obligatorio';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Campo Localidad
                TextFormField(
                  controller: _localidadController,
                  decoration: InputDecoration(
                    labelText: 'Localidad *',
                    labelStyle: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                    prefixIcon: const Icon(
                      Icons.place_outlined,
                      color: Colors.black87,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  style: const TextStyle(color: Colors.black),
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'La localidad es obligatoria';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Campo Código Postal
                TextFormField(
                  controller: _codigoPostalController,
                  decoration: InputDecoration(
                    labelText: 'Código Postal *',
                    labelStyle: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                    prefixIcon: const Icon(
                      Icons.markunread_mailbox_outlined,
                      color: Colors.black87,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  style: const TextStyle(color: Colors.black),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(5),
                  ],
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El código postal es obligatorio';
                    }
                    if (value.length != 5) {
                      return 'El código postal debe tener 5 dígitos';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Campo Dirección
                TextFormField(
                  controller: _direccionController,
                  decoration: InputDecoration(
                    labelText: 'Dirección Completa *',
                    labelStyle: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                    prefixIcon: const Icon(
                      Icons.home_outlined,
                      color: Colors.black87,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  style: const TextStyle(color: Colors.black),
                  textInputAction: TextInputAction.next,
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'La dirección es obligatoria';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Sección: Coordenadas GPS
                _buildSectionTitle('Coordenadas GPS (Trazabilidad)'),
                const SizedBox(height: 16),

                // Botón para obtener ubicación
                OutlinedButton.icon(
                  onPressed: _obteniendoUbicacion ? null : _obtenerUbicacionActual,
                  icon: _obteniendoUbicacion
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.my_location),
                  label: Text(
                    _obteniendoUbicacion ? 'Obteniendo ubicación...' : 'Obtener Ubicación Actual',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: AppColors.emeraldGreen,
                      width: 2,
                    ),
                    foregroundColor: AppColors.emeraldGreen,
                    minimumSize: const Size(double.infinity, 56),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Campos de coordenadas
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _latitudController,
                        decoration: InputDecoration(
                          labelText: 'Latitud',
                          labelStyle: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                          prefixIcon: const Icon(
                            Icons.navigation_outlined,
                            color: Colors.black87,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        style: const TextStyle(color: Colors.black),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value != null && value.trim().isNotEmpty) {
                            final lat = double.tryParse(value);
                            if (lat == null || lat < -90 || lat > 90) {
                              return 'Latitud inválida';
                            }
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _longitudController,
                        decoration: InputDecoration(
                          labelText: 'Longitud',
                          labelStyle: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                          prefixIcon: const Icon(
                            Icons.explore_outlined,
                            color: Colors.black87,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        style: const TextStyle(color: Colors.black),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value != null && value.trim().isNotEmpty) {
                            final lon = double.tryParse(value);
                            if (lon == null || lon < -180 || lon > 180) {
                              return 'Longitud inválida';
                            }
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Sección: Datos del Predio
                _buildSectionTitle('Datos del Predio'),
                const SizedBox(height: 16),

                // Campo Superficie
                TextFormField(
                  controller: _superficieController,
                  decoration: InputDecoration(
                    labelText: 'Superficie Total (Hectáreas) *',
                    labelStyle: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                    prefixIcon: const Icon(
                      Icons.square_foot_outlined,
                      color: Colors.black87,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    suffixText: 'ha',
                  ),
                  style: const TextStyle(color: Colors.black),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'La superficie es obligatoria';
                    }
                    final superficie = double.tryParse(value);
                    if (superficie == null || superficie <= 0) {
                      return 'La superficie debe ser un número mayor a 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Campo Tipo de Tenencia
                DropdownButtonFormField<String>(
                  value: _tipoTenencia,
                  decoration: InputDecoration(
                    labelText: 'Tipo de Tenencia *',
                    labelStyle: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                    prefixIcon: const Icon(
                      Icons.landscape_outlined,
                      color: Colors.black87,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  style: const TextStyle(color: Colors.black),
                  items: PredioEntity.tiposTenenciaValidos.map((tipo) {
                    return DropdownMenuItem(
                      value: tipo,
                      child: Text(_getTipoTenenciaLabel(tipo)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _tipoTenencia = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Debes seleccionar el tipo de tenencia';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Campo Tipo de Producción
                DropdownButtonFormField<String>(
                  value: _tipoProduccion,
                  decoration: InputDecoration(
                    labelText: 'Tipo de Producción Pecuaria *',
                    labelStyle: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                    prefixIcon: const Icon(
                      Icons.pets_outlined,
                      color: Colors.black87,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  style: const TextStyle(color: Colors.black),
                  items: PredioEntity.tiposProduccionValidos.map((tipo) {
                    return DropdownMenuItem(
                      value: tipo,
                      child: Text(_getTipoProduccionLabel(tipo)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _tipoProduccion = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Debes seleccionar el tipo de producción';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Campo Clave Catastral (Opcional)
                TextFormField(
                  controller: _claveCatastralController,
                  decoration: InputDecoration(
                    labelText: 'Clave Catastral (Opcional)',
                    labelStyle: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                    prefixIcon: const Icon(
                      Icons.map_outlined,
                      color: Colors.black87,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  style: const TextStyle(color: Colors.black),
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 32),

                // Mensaje de error
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.red.shade300,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.red.shade700,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Botón de registro
                ElevatedButton(
                  onPressed: _isLoading ? null : _registrarPredio,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.emeraldGreen,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 64),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Registrar Predio',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Construye un título de sección.
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  /// Obtiene la etiqueta legible para el tipo de tenencia.
  String _getTipoTenenciaLabel(String tipo) {
    switch (tipo) {
      case 'PROPIO':
        return 'Propio';
      case 'ARRENDADO':
        return 'Arrendado';
      case 'EJIDAL':
        return 'Ejidal';
      case 'COMUNAL':
        return 'Comunal';
      case 'OTRO':
        return 'Otro';
      default:
        return tipo;
    }
  }

  /// Obtiene la etiqueta legible para el tipo de producción.
  String _getTipoProduccionLabel(String tipo) {
    switch (tipo) {
      case 'BOVINOS':
        return 'Bovinos';
      case 'PORCINOS':
        return 'Porcinos';
      case 'AVES':
        return 'Aves';
      case 'OVINOS':
        return 'Ovinos';
      case 'CAPRINOS':
        return 'Caprinos';
      case 'EQUINOS':
        return 'Equinos';
      case 'OTRO':
        return 'Otro';
      default:
        return tipo;
    }
  }
}
