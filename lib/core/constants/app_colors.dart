import 'package:flutter/material.dart';

/// Paleta de colores de EcoRuta (Material Design 3, identidad verde).
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF2E7D32); // Verde principal
  static const Color primaryDark = Color(0xFF1B5E20);
  static const Color primaryLight = Color(0xFFA5D6A7);
  static const Color secondary = Color(0xFF66BB6A);

  static const Color background = Color(0xFFF2F2F7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE0E0E0);

  static const Color textPrimary = Color(0xFF1B5E20);
  static const Color textSecondary = Color(0xFF555555);
  static const Color textHint = Color(0xFF9E9E9E);

  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFF9A825);
  static const Color error = Color(0xFFC62828);

  /// Colores por tipo de material reciclable.
  static const Color plastico = Color(0xFF2E7D32);
  static const Color carton = Color(0xFFE65100);
  static const Color vidrio = Color(0xFF1565C0);
  static const Color metal = Color(0xFF546E7A);
  static const Color papel = Color(0xFF00695C);
}
