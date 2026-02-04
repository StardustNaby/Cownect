import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

/// Pantalla de acceso para colaboradores.
/// 
/// Permite iniciar sesión con escáner QR o con UPP y código.
class ColaboradorScreen extends ConsumerStatefulWidget {
  const ColaboradorScreen({super.key});

  @override
  ConsumerState<ColaboradorScreen> createState() => _ColaboradorScreenState();
}

class _ColaboradorScreenState extends ConsumerState<ColaboradorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _uppController = TextEditingController();
  final _codigoController = TextEditingController();

  bool _obscureCodigo = true;
  String? _errorMessage;
  bool _isScanning = false;

  @override
  void dispose() {
    _uppController.dispose();
    _codigoController.dispose();
    super.dispose();
  }

  /// Inicia el escáner QR.
  Future<void> _startQRScanner() async {
    setState(() {
      _isScanning = true;
      _errorMessage = null;
    });

    // TODO: Implementar escáner QR real
    // Por ahora, simulamos el escáner
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isScanning = false;
      });

      // Mostrar mensaje de que el escáner está en desarrollo
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Escáner QR en desarrollo. Usa UPP y código por ahora.'),
          backgroundColor: AppColors.emeraldGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Inicia sesión con UPP y código.
  Future<void> _signInWithUPP() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _errorMessage = null;
    });

    // TODO: Implementar autenticación real con UPP y código
    final upp = _uppController.text.trim();
    final codigo = _codigoController.text.trim();

    try {
      // Simulación de autenticación
      await Future.delayed(const Duration(seconds: 1));

      // Por ahora, solo validamos que los campos no estén vacíos
      if (upp.isEmpty || codigo.isEmpty) {
        setState(() {
          _errorMessage = 'Por favor, completa todos los campos.';
        });
        return;
      }

      // TODO: Llamar al método de autenticación real
      // await ref.read(authNotifierProvider.notifier).signInAsColaborador(
      //   upp: upp,
      //   codigo: codigo,
      // );

      if (mounted) {
        // Por ahora, redirigir a predios
        // En producción, esto debería redirigir a una vista específica de colaborador
        context.go('/predios');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al iniciar sesión. Verifica tu UPP y código.';
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
          onPressed: () => context.go('/login'),
        ),
        title: Text(
          'Acceso Colaborador',
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

                // Icono de colaborador
                Icon(
                  Icons.badge_outlined,
                  size: 80,
                  color: AppColors.emeraldGreen,
                ),
                const SizedBox(height: 24),

                // Título
                Text(
                  'Acceso para Colaboradores',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Escanea tu código QR o ingresa tu UPP y código',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Botón de escáner QR
                ElevatedButton.icon(
                  onPressed: _isScanning ? null : _startQRScanner,
                  icon: _isScanning
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Icon(Icons.qr_code_scanner, size: 28),
                  label: Text(
                    _isScanning ? 'Escaneando...' : 'Escanear Código QR',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.emeraldGreen,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 64),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Divisor
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: Colors.grey.shade400,
                        thickness: 1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'O',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: Colors.grey.shade400,
                        thickness: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Campo UPP
                TextFormField(
                  controller: _uppController,
                  decoration: InputDecoration(
                    labelText: 'UPP *',
                    labelStyle: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                    hintText: 'Ingresa tu UPP',
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
                const SizedBox(height: 20),

                // Campo Código
                TextFormField(
                  controller: _codigoController,
                  decoration: InputDecoration(
                    labelText: 'Código *',
                    labelStyle: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                    hintText: 'Ingresa tu código',
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: Colors.black87,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureCodigo 
                            ? Icons.visibility_outlined 
                            : Icons.visibility_off_outlined,
                        color: Colors.black87,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureCodigo = !_obscureCodigo;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  style: const TextStyle(color: Colors.black),
                  obscureText: _obscureCodigo,
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El código es obligatorio';
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

                // Botón de inicio de sesión
                ElevatedButton(
                  onPressed: _signInWithUPP,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.emeraldGreen,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 64),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Iniciar Sesión',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Enlace de vuelta a login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '¿Eres usuario? ',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.black87,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: Text(
                        'Inicia sesión',
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

