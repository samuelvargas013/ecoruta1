/// Rutas y nombres de colecciones/campos en Firestore.
/// Centralizadas para evitar "magic strings" (recomendación del experto:
/// diseñar el modelo de datos antes de codificar).
class FirestorePaths {
  FirestorePaths._();

  static const String users = 'users';
  static const String reports = 'reports';
  static const String badges = 'badges';

  // Subcolección de insignias del usuario
  static String userBadges(String uid) => '$users/$uid/$badges';
}

/// Tipos de material reciclable soportados en el MVP.
enum MaterialType { plastico, carton, vidrio, metal, papel }

extension MaterialTypeX on MaterialType {
  String get label {
    switch (this) {
      case MaterialType.plastico:
        return 'Plástico';
      case MaterialType.carton:
        return 'Cartón';
      case MaterialType.vidrio:
        return 'Vidrio';
      case MaterialType.metal:
        return 'Metal';
      case MaterialType.papel:
        return 'Papel';
    }
  }

  String get id => name;

  static MaterialType fromId(String id) =>
      MaterialType.values.firstWhere((e) => e.name == id,
          orElse: () => MaterialType.plastico);
}

/// Estado de recolección de un reporte (F-04).
enum ReportStatus { pendiente, recogido }

extension ReportStatusX on ReportStatus {
  String get label => this == ReportStatus.pendiente ? 'Pendiente' : 'Recogido';
  String get id => name;

  static ReportStatus fromId(String id) =>
      ReportStatus.values.firstWhere((e) => e.name == id,
          orElse: () => ReportStatus.pendiente);
}

/// Roles de usuario (F-01).
enum UserRole { vecino, reciclador }

extension UserRoleX on UserRole {
  String get label => this == UserRole.vecino ? 'Vecino' : 'Reciclador';
  String get id => name;

  static UserRole fromId(String id) =>
      UserRole.values.firstWhere((e) => e.name == id,
          orElse: () => UserRole.vecino);
}
