import 'package:flutter/material.dart' hide MaterialType;
import '../../core/constants/app_colors.dart';
import '../../core/constants/firestore_paths.dart';

/// Mapea cada tipo de material a su color e ícono (consistencia con el mapa).
class MaterialVisuals {
  MaterialVisuals._();

  static Color color(MaterialType m) {
    switch (m) {
      case MaterialType.plastico:
        return AppColors.plastico;
      case MaterialType.carton:
        return AppColors.carton;
      case MaterialType.vidrio:
        return AppColors.vidrio;
      case MaterialType.metal:
        return AppColors.metal;
      case MaterialType.papel:
        return AppColors.papel;
    }
  }

  static IconData icon(MaterialType m) {
    switch (m) {
      case MaterialType.plastico:
        return Icons.local_drink_outlined;
      case MaterialType.carton:
        return Icons.inventory_2_outlined;
      case MaterialType.vidrio:
        return Icons.wine_bar_outlined;
      case MaterialType.metal:
        return Icons.hardware_outlined;
      case MaterialType.papel:
        return Icons.description_outlined;
    }
  }
}
