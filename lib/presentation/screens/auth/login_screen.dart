import 'package:flutter/material.dart';
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
      _isEmail = _detectInputType(value);
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
        _errorMessage = e is AuthException 
            ? e.message 
            : 'Error al enviar código. Verifica tu número de teléfono.';
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
        context.go('/inventario');
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
        context.go('/inventario');
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
                    'Bienvenido a Cownect',
                    style: Theme.of(context).textTheme.displaySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sistema de Gestión Ganadera',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // Campo Email/Teléfono
                  TextFormField(
                    controller: _emailPhoneController,
                    decoration: InputDecoration(
                      labelText: _isEmail ? 'Correo electrónico' : 'Teléfono',
                      hintText: _isEmail 
                          ? 'ejemplo@correo.com' 
                          : '10 dígitos',
                      prefixIcon: Icon(
                        _isEmail ? Icons.email_outlined : Icons.phone_outlined,
                      ),
                    ),
                    keyboardType: _isEmail 
                        ? TextInputType.emailAddress 
                        : TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    onChanged: _onEmailPhoneChanged,
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
                        if (cleanPhone.length < 10) {
                          return 'Ingresa un número de teléfono válido (10 dígitos)';
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
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword 
                                ? Icons.visibility_outlined 
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
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
                      decoration: const InputDecoration(
                        labelText: 'Código OTP',
                        hintText: 'Ingresa el código de 6 dígitos',
                        prefixIcon: Icon(Icons.sms_outlined),
                      ),
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
                          style: Theme.of(context).textTheme.bodyMedium,
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
                                fontSize: 14,
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
                    child: isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.emeraldGreen,
                              ),
                            ),
                          )
                        : Text(
                            _isEmail
                                ? 'Iniciar Sesión'
                                : _isOtpSent
                                    ? 'Verificar Código'
                                    : 'Enviar Código',
                          ),
                  ),

                  // Botón para reenviar código (si es OTP)
                  if (!_isEmail && _isOtpSent) ...[
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: isLoading ? null : _sendOTP,
                      child: const Text('Reenviar código'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

