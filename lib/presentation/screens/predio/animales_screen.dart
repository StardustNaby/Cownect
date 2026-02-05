import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../inventory/inventory_screen.dart';

/// Pantalla de animales del predio.
/// 
/// Por ahora redirige al inventario existente.
class AnimalesScreen extends StatelessWidget {
  const AnimalesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const InventoryScreen();
  }
}




