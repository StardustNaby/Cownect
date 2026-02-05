import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/auth_repository_impl.dart';

/// Pantalla de registro de usuario.
/// 
/// Diseño con alto contraste, texto negro, fácil lectura bajo sol.
/// Registro disyuntivo: Correo O Celular (no ambos).
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fechaNacimientoController = TextEditingController();
  final _otpController = TextEditingController();

  bool _registroPorEmail = true; // true = Email, false = Celular
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  DateTime? _fechaNacimiento;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Iniciar temporizador si es necesario
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fechaNacimientoController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  /// Selecciona la fecha de nacimiento.
  Future<void> _selectFechaNacimiento() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.emeraldGreen,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _fechaNacimiento = picked;
        _fechaNacimientoController.text = 
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }


  /// Registra un nuevo usuario.
  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (_fechaNacimiento == null) {
      setState(() {
        _errorMessage = 'Debes seleccionar tu fecha de nacimiento.';
      });
      return;
    }

    // Validar contraseñas (tanto para email como celular)
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Las contraseñas no coinciden.';
      });
      return;
    }

    setState(() {
      _errorMessage = null;
    });

    try {
      if (_registroPorEmail) {
        // Registro por email
        await ref.read(authNotifierProvider.notifier).signUp(
              email: _emailController.text.trim(),
              phone: null,
              password: _passwordController.text,
              nombreCompleto: _nombreController.text.trim(),
              fechaNacimiento: _fechaNacimiento!,
              rememberMe: false,
            );
      } else {
        // Registro por celular - también requiere email y contraseña
        await ref.read(authNotifierProvider.notifier).signUp(
              email: _emailController.text.trim(),
              phone: _telefonoController.text.trim(),
              password: _passwordController.text,
              nombreCompleto: _nombreController.text.trim(),
              fechaNacimiento: _fechaNacimiento!,
              rememberMe: false,
            );
      }

      if (mounted) {
        context.go('/predios');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e is AuthException 
            ? e.message 
            : 'Error al registrar. Intenta nuevamente.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState is Loading;

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
          'Registro',
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
                const SizedBox(height: 40),

                // Selector de método de registro (ToggleButtons)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey.shade400,
                      width: 2,
                    ),
                  ),
                  child: ToggleButtons(
                    isSelected: [_registroPorEmail, !_registroPorEmail],
                    onPressed: (index) {
                      setState(() {
                        _registroPorEmail = index == 0;
                        _errorMessage = null;
                        // Limpiar campos al cambiar
                        if (_registroPorEmail) {
                          _telefonoController.clear();
                        } else {
                          // No limpiar email/contraseña porque también se necesitan
                        }
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    selectedColor: Colors.white,
                    fillColor: AppColors.emeraldGreen,
                    color: Colors.black87,
                    constraints: const BoxConstraints(
                      minHeight: 56,
                      minWidth: double.infinity,
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.email_outlined,
                              size: 24,
                              color: _registroPorEmail ? Colors.white : Colors.black87,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Registro por Correo',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _registroPorEmail ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.phone_outlined,
                              size: 24,
                              color: !_registroPorEmail ? Colors.white : Colors.black87,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Registro por Celular',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: !_registroPorEmail ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Nombre Completo
                TextFormField(
                  controller: _nombreController,
                  decoration: InputDecoration(
                    labelText: 'Nombre Completo *',
                    labelStyle: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
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
                      return 'El nombre completo es obligatorio';
                    }
                    if (value.trim().length < 3) {
                      return 'El nombre debe tener al menos 3 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Campos según el método de registro seleccionado
                if (_registroPorEmail) ...[
                  // Registro por Email
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email *',
                      labelStyle: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                      prefixIcon: const Icon(
                        Icons.email_outlined,
                        color: Colors.black87,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    style: const TextStyle(color: Colors.black),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El email es obligatorio';
                      }
                      if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+')
                          .hasMatch(value.trim())) {
                        return 'Ingresa un correo electrónico válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Contraseña *',
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
                    textInputAction: TextInputAction.next,
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
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Confirmar Contraseña *',
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
                          _obscureConfirmPassword 
                              ? Icons.visibility_outlined 
                              : Icons.visibility_off_outlined,
                          color: Colors.black87,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    style: const TextStyle(color: Colors.black),
                    obscureText: _obscureConfirmPassword,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Confirma tu contraseña';
                      }
                      if (value != _passwordController.text) {
                        return 'Las contraseñas no coinciden';
                      }
                      return null;
                    },
                  ),
                ] else ...[
                  // Registro por Celular - también requiere email y contraseña
                  TextFormField(
                    controller: _telefonoController,
                    decoration: InputDecoration(
                      labelText: 'Teléfono *',
                      labelStyle: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                      hintText: '10 dígitos',
                      prefixIcon: const Icon(
                        Icons.phone_outlined,
                        color: Colors.black87,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    style: const TextStyle(color: Colors.black),
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El teléfono es obligatorio';
                      }
                      final cleanPhone = value.trim()
                          .replaceAll(RegExp(r'[\s\-\(\)]'), '');
                      if (cleanPhone.length != 10) {
                        return 'El teléfono debe tener exactamente 10 dígitos';
                      }
                      if (!RegExp(r'^\d{10}$').hasMatch(cleanPhone)) {
                        return 'Solo se permiten números';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  // Email también requerido para registro con teléfono
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email *',
                      labelStyle: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                      prefixIcon: const Icon(
                        Icons.email_outlined,
                        color: Colors.black87,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      helperText: 'Necesario para iniciar sesión con contraseña',
                    ),
                    style: const TextStyle(color: Colors.black),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El email es obligatorio';
                      }
                      if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+')
                          .hasMatch(value.trim())) {
                        return 'Ingresa un correo electrónico válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Contraseña *',
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
                    textInputAction: TextInputAction.next,
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
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Confirmar Contraseña *',
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
                          _obscureConfirmPassword 
                              ? Icons.visibility_outlined 
                              : Icons.visibility_off_outlined,
                          color: Colors.black87,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    style: const TextStyle(color: Colors.black),
                    obscureText: _obscureConfirmPassword,
                    textInputAction: TextInputAction.done,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Confirma tu contraseña';
                      }
                      if (value != _passwordController.text) {
                        return 'Las contraseñas no coinciden';
                      }
                      return null;
                    },
                  ),
                ],
                const SizedBox(height: 20),

                // Fecha de Nacimiento
                TextFormField(
                  controller: _fechaNacimientoController,
                  decoration: InputDecoration(
                    labelText: 'Fecha de Nacimiento *',
                    labelStyle: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                    prefixIcon: const Icon(
                      Icons.calendar_today_outlined,
                      color: Colors.black87,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  style: const TextStyle(color: Colors.black),
                  readOnly: true,
                  onTap: _selectFechaNacimiento,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'La fecha de nacimiento es obligatoria';
                    }
                    return null;
                  },
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
                  onPressed: isLoading ? null : _register,
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
                      : const Text(
                          'Crear Cuenta',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(height: 24),

                // Enlace a login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '¿Ya tienes cuenta? ',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.black87,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: Text(
                        'Iniciar sesión',
                        style: TextStyle(
                          color: AppColors.emeraldGreen,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
