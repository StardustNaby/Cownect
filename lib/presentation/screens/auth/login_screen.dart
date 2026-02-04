import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/auth_repository_impl.dart';

/// Pantalla de inicio de sesión.
/// 
/// Diseño minimalista con fondo gris claro y botones grandes.
/// Soporta login con email/contraseña o teléfono/OTP.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailPhoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otpController = TextEditingController();

  bool _isEmail = false;
  bool _isOtpSent = false;
  bool _rememberMe = false;
  bool _obscurePassword = true;
  String? _errorMessage;
  bool _methodManuallySelected = false; // Rastrea si el usuario seleccionó manualmente

  @override
  void dispose() {
    _emailPhoneController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  /// Detecta si el texto ingresado es un email o un teléfono.
  bool _detectInputType(String input) {
    // Eliminar espacios y caracteres especiales para validar
    final cleanInput = input.trim().replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    // Si contiene @, es email
    if (input.contains('@')) {
      return true;
    }
    
    // Si son solo dígitos (mínimo 10), es teléfono
    if (RegExp(r'^\d{10,}$').hasMatch(cleanInput)) {
      return false;
    }
    
    // Por defecto, asumir email si tiene formato de email
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+').hasMatch(input);
  }

  /// Maneja el cambio en el campo de email/teléfono.
  void _onEmailPhoneChanged(String value) {
    setState(() {
      // Solo detectar automáticamente si el usuario no ha seleccionado manualmente un método
      if (!_methodManuallySelected) {
        _isEmail = _detectInputType(value);
      }
      _errorMessage = null;
      // Si cambia el tipo, limpiar campos relacionados
      if (_isEmail) {
        _otpController.clear();
        _isOtpSent = false;
      } else {
        _passwordController.clear();
      }
    });
  }

  /// Envía el código OTP al teléfono.
  Future<void> _sendOTP() async {
    if (!_formKey.currentState!.validate()) return;

    final phone = _emailPhoneController.text.trim();
    setState(() {
      _errorMessage = null;
    });

    try {
      await ref.read(authNotifierProvider.notifier).sendOTP(phone: phone);
      setState(() {
        _isOtpSent = true;
        _errorMessage = null;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Código OTP enviado a tu teléfono'),
            backgroundColor: AppColors.emeraldGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() {
        // Traducir errores técnicos a mensajes comprensibles
        String errorMsg = 'Error al enviar código. Verifica tu número de teléfono.';
        if (e is AuthException) {
          errorMsg = e.message;
        } else {
          final errorString = e.toString().toLowerCase();
          if (errorString.contains('phone_provider_disabled') ||
              (errorString.contains('sms provider') && errorString.contains('disabled'))) {
            errorMsg = 'Servicio de SMS temporalmente fuera de servicio. Por favor, usa correo electrónico para iniciar sesión.';
          } else if (errorString.contains('statuscode: 400') ||
                     errorString.contains('400')) {
            errorMsg = 'Error con el servicio de SMS. Intenta usar correo electrónico o contacta al soporte.';
          }
        }
        _errorMessage = errorMsg;
      });
    }
  }

  /// Inicia sesión con email y contraseña.
  Future<void> _signInWithEmail() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailPhoneController.text.trim();
    final password = _passwordController.text;

    setState(() {
      _errorMessage = null;
    });

    try {
      await ref.read(authNotifierProvider.notifier).signInWithEmail(
            email: email,
            password: password,
            rememberMe: _rememberMe,
          );

      if (mounted) {
        context.go('/predios');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e is AuthException 
            ? e.message 
            : 'Error al iniciar sesión. Verifica tus credenciales.';
      });
    }
  }

  /// Inicia sesión con código OTP.
  Future<void> _signInWithOTP() async {
    if (!_formKey.currentState!.validate()) return;

    final phone = _emailPhoneController.text.trim();
    final otp = _otpController.text.trim();

    setState(() {
      _errorMessage = null;
    });

    try {
      await ref.read(authNotifierProvider.notifier).signInWithOTP(
            phone: phone,
            otp: otp,
            rememberMe: _rememberMe,
          );

      if (mounted) {
        context.go('/predios');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e is AuthException 
            ? e.message 
            : 'Código inválido. Verifica el código recibido.';
      });
    }
  }

  /// Maneja el botón de acceso principal.
  Future<void> _handleSignIn() async {
    if (_isEmail) {
      await _signInWithEmail();
    } else {
      if (_isOtpSent) {
        await _signInWithOTP();
      } else {
        await _sendOTP();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState is Loading;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo/Icono
                  const Icon(
                    Icons.lock_outline,
                    size: 80,
                    color: AppColors.emeraldGreen,
                  ),
                  const SizedBox(height: 32),

                  // Título
                  Text(
                    'Cownect',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sistema de Gestión Ganadera',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // Selector de método de autenticación
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.shade400,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _isEmail = true;
                                _methodManuallySelected = true;
                                _emailPhoneController.clear();
                                _passwordController.clear();
                                _otpController.clear();
                                _isOtpSent = false;
                                _errorMessage = null;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: _isEmail 
                                    ? AppColors.emeraldGreen.withOpacity(0.1)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                border: _isEmail
                                    ? Border.all(
                                        color: AppColors.emeraldGreen,
                                        width: 2,
                                      )
                                    : null,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.email_outlined,
                                    color: _isEmail
                                        ? AppColors.emeraldGreen
                                        : Colors.black54,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Correo',
                                    style: TextStyle(
                                      color: _isEmail
                                          ? AppColors.emeraldGreen
                                          : Colors.black87,
                                      fontWeight: _isEmail
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _isEmail = false;
                                _methodManuallySelected = true;
                                _emailPhoneController.clear();
                                _passwordController.clear();
                                _otpController.clear();
                                _isOtpSent = false;
                                _errorMessage = null;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: !_isEmail 
                                    ? AppColors.emeraldGreen.withOpacity(0.1)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                border: !_isEmail
                                    ? Border.all(
                                        color: AppColors.emeraldGreen,
                                        width: 2,
                                      )
                                    : null,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.phone_outlined,
                                    color: !_isEmail
                                        ? AppColors.emeraldGreen
                                        : Colors.black54,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Teléfono',
                                    style: TextStyle(
                                      color: !_isEmail
                                          ? AppColors.emeraldGreen
                                          : Colors.black87,
                                      fontWeight: !_isEmail
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Campo Email/Teléfono
                  TextFormField(
                    controller: _emailPhoneController,
                    decoration: InputDecoration(
                      labelText: _isEmail ? 'Correo electrónico' : 'Teléfono',
                      labelStyle: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                      hintText: _isEmail 
                          ? 'ejemplo@correo.com' 
                          : '10 dígitos',
                      prefixIcon: Icon(
                        _isEmail ? Icons.email_outlined : Icons.phone_outlined,
                        color: Colors.black87,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    style: const TextStyle(color: Colors.black),
                    keyboardType: _isEmail 
                        ? TextInputType.emailAddress 
                        : TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    inputFormatters: _isEmail 
                        ? null 
                        : [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                    onChanged: (value) {
                      _onEmailPhoneChanged(value);
                      // Validación en tiempo real para teléfono
                      if (!_isEmail && _formKey.currentState != null) {
                        final cleanPhone = value.trim()
                            .replaceAll(RegExp(r'[\s\-\(\)]'), '');
                        if (cleanPhone.length == 10) {
                          // Validar automáticamente cuando tenga 10 dígitos
                          _formKey.currentState!.validate();
                        }
                      }
                    },
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Este campo es obligatorio';
                      }
                      if (_isEmail) {
                        if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+')
                            .hasMatch(value.trim())) {
                          return 'Ingresa un correo electrónico válido';
                        }
                      } else {
                        final cleanPhone = value.trim()
                            .replaceAll(RegExp(r'[\s\-\(\)]'), '');
                        if (cleanPhone.length != 10) {
                          return 'El teléfono debe tener exactamente 10 dígitos';
                        }
                        if (!RegExp(r'^\d{10}$').hasMatch(cleanPhone)) {
                          return 'Solo se permiten números';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Campo Contraseña (solo si es email)
                  if (_isEmail) ...[
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        labelStyle: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: Colors.black87,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword 
                                ? Icons.visibility_outlined 
                                : Icons.visibility_off_outlined,
                            color: Colors.black87,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      style: const TextStyle(color: Colors.black),
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'La contraseña es obligatoria';
                        }
                        if (value.length < 6) {
                          return 'La contraseña debe tener al menos 6 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Campo OTP (solo si es teléfono y se envió el código)
                  if (!_isEmail && _isOtpSent) ...[
                    TextFormField(
                      controller: _otpController,
                      decoration: InputDecoration(
                        labelText: 'Código OTP',
                        labelStyle: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                        hintText: 'Ingresa el código de 6 dígitos',
                        prefixIcon: const Icon(
                          Icons.sms_outlined,
                          color: Colors.black87,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      style: const TextStyle(color: Colors.black),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      maxLength: 6,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ingresa el código OTP';
                        }
                        if (value.trim().length != 6) {
                          return 'El código debe tener 6 dígitos';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Checkbox "Mantener sesión"
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: (value) {
                          setState(() {
                            _rememberMe = value ?? false;
                          });
                        },
                        activeColor: AppColors.emeraldGreen,
                      ),
                      Expanded(
                        child: Text(
                          'Mantener sesión iniciada',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Mensaje de error
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.red.shade300,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red.shade700,
                            size: 20,
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
                    const SizedBox(height: 16),
                  ],

                  // Botón de acceso
                  ElevatedButton(
                    onPressed: isLoading ? null : _handleSignIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.emeraldGreen,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 64),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
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
                        : Text(
                            _isEmail
                                ? 'Iniciar Sesión'
                                : _isOtpSent
                                    ? 'Verificar Código'
                                    : 'Enviar Código',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),

                  // Botón para reenviar código (si es OTP)
                  if (!_isEmail && _isOtpSent) ...[
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: isLoading ? null : _sendOTP,
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
                      child: Text(
                        'Reenviar código',
                        style: TextStyle(
                          color: AppColors.emeraldGreen,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Enlace a registro
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '¿Tienes cuenta? ',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.black87,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.go('/register'),
                        child: Text(
                          'Regístrate ahora',
                          style: TextStyle(
                            color: AppColors.emeraldGreen,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Opción de colaborador
                  OutlinedButton(
                    onPressed: () => context.go('/colaborador'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 64),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      side: BorderSide(
                        color: AppColors.emeraldGreen,
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.badge_outlined,
                          color: AppColors.emeraldGreen,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Entrar como Colaborador',
                          style: TextStyle(
                            color: AppColors.emeraldGreen,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

