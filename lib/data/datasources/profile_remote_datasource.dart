import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/firestore_paths.dart';
import '../../core/errors/exceptions.dart';
import '../models/user_model.dart';
import '../../domain/entities/badge_entity.dart';

abstract class ProfileRemoteDataSource {
  Stream<UserModel?> watchProfile(String uid);
  Future<List<BadgeEntity>> getBadges(String uid);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final FirebaseFirestore _firestore;
  ProfileRemoteDataSourceImpl({required this._firestore});

  /// Catálogo base de insignias del MVP (F-05).
  static const _catalog = [
    {'id': 'primer_reporte', 'name': 'Primer Reporte', 'icon': 'leaf'},
    {'id': 'reciclador_activo', 'name': 'Reciclador Activo', 'icon': 'recycle'},
    {'id': 'eco_estrella', 'name': 'Eco Estrella', 'icon': 'star'},
    {'id': 'eco_maestro', 'name': 'Eco Maestro', 'icon': 'medal'},
  ];

  @override
  Stream<UserModel?> watchProfile(String uid) {
    return _firestore
        .collection(FirestorePaths.users)
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromDoc(doc) : null);
  }

  @override
  Future<List<BadgeEntity>> getBadges(String uid) async {
    try {
      final doc = await _firestore
          .collection(FirestorePaths.users)
          .doc(uid)
          .get();
      final unlockedIds =
          List<String>.from(doc.data()?['badgeIds'] as List? ?? const []);
      return _catalog
          .map((b) => BadgeEntity(
                id: b['id']!,
                name: b['name']!,
                iconName: b['icon']!,
                unlocked: unlockedIds.contains(b['id']),
              ))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'No se pudieron cargar las insignias.');
    }
  }
}
