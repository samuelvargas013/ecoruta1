import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firestore_paths.dart';
import '../../domain/entities/user_entity.dart';

/// DTO de usuario: convierte entre Firestore y la entidad de dominio.
class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.email,
    required super.name,
    super.role,
    super.points,
    super.kgRecycled,
    super.badgeIds,
    super.photoUrl,
    super.recicladorValidado,
  });

  factory UserModel.fromMap(String uid, Map<String, dynamic> map) {
    return UserModel(
      uid: uid,
      email: map['email'] as String? ?? '',
      name: map['name'] as String? ?? '',
      role: UserRoleX.fromId(map['role'] as String? ?? 'vecino'),
      points: (map['points'] as num?)?.toInt() ?? 0,
      kgRecycled: (map['kgRecycled'] as num?)?.toDouble() ?? 0,
      badgeIds: List<String>.from(map['badgeIds'] as List? ?? const []),
      photoUrl: map['photoUrl'] as String?,
      recicladorValidado: map['recicladorValidado'] as bool? ?? false,
    );
  }

  factory UserModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) =>
      UserModel.fromMap(doc.id, doc.data() ?? const {});

  Map<String, dynamic> toMap() => {
        'email': email,
        'name': name,
        'role': role.id,
        'points': points,
        'kgRecycled': kgRecycled,
        'badgeIds': badgeIds,
        'photoUrl': photoUrl,
        'recicladorValidado': recicladorValidado,
        'createdAt': FieldValue.serverTimestamp(),
      };
}
