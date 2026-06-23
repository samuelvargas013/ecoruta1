import 'package:equatable/equatable.dart';
import '../../core/constants/firestore_paths.dart';

/// Entidad de usuario (F-01). Dart puro, sin dependencias externas.
class UserEntity extends Equatable {
  final String uid;
  final String email;
  final String name;
  final UserRole role;
  final int points;
  final double kgRecycled;
  final List<String> badgeIds;
  final String? photoUrl;
  final bool recicladorValidado; // F-03: solo recicladores validados ven el mapa

  const UserEntity({
    required this.uid,
    required this.email,
    required this.name,
    this.role = UserRole.vecino,
    this.points = 0,
    this.kgRecycled = 0,
    this.badgeIds = const [],
    this.photoUrl,
    this.recicladorValidado = false,
  });

  String get level {
    if (points >= 500) return 'Eco Maestro';
    if (points >= 200) return 'Eco Activo';
    if (points >= 50) return 'Eco Iniciado';
    return 'Nuevo';
  }

  @override
  List<Object?> get props =>
      [uid, email, name, role, points, kgRecycled, badgeIds, photoUrl, recicladorValidado];
}
