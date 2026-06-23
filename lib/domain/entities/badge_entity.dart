import 'package:equatable/equatable.dart';

/// Entidad de insignia de gamificación (F-05).
class BadgeEntity extends Equatable {
  final String id;
  final String name;
  final String iconName;
  final bool unlocked;

  const BadgeEntity({
    required this.id,
    required this.name,
    required this.iconName,
    this.unlocked = false,
  });

  @override
  List<Object?> get props => [id, name, iconName, unlocked];
}
