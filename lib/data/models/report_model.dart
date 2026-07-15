import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firestore_paths.dart';
import '../../domain/entities/report_entity.dart';

/// DTO de reporte: mapea entre Firestore y la entidad de dominio.
class ReportModel extends ReportEntity {
  const ReportModel({
    required super.id,
    required super.authorId,
    required super.authorName,
    required super.material,
    required super.latitude,
    required super.longitude,
    required super.address,
    required super.photoUrls,
    super.descriptionText,
    super.status,
    required super.createdAt,
    super.collectedBy,
  });

  /// Construye el modelo desde un documento de Firestore.
  /// Usa valores por defecto para tolerar campos faltantes o antiguos.
  factory ReportModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final map = doc.data() ?? const {};
    final geo = map['location'] as GeoPoint?;
    final ts = map['createdAt'];
    return ReportModel(
      id: doc.id,
      authorId: map['authorId'] as String? ?? '',
      authorName: map['authorName'] as String? ?? '',
      material: MaterialTypeX.fromId(map['material'] as String? ?? 'plastico'),
      latitude: geo?.latitude ?? (map['latitude'] as num?)?.toDouble() ?? 0,
      longitude: geo?.longitude ?? (map['longitude'] as num?)?.toDouble() ?? 0,
      address: map['address'] as String? ?? '',
      photoUrls: List<String>.from(map['photoUrls'] as List? ?? const []),
      descriptionText: map['descriptionText'] as String?,
      status: ReportStatusX.fromId(map['status'] as String? ?? 'pendiente'),
      createdAt: ts is Timestamp ? ts.toDate() : DateTime.now(),
      collectedBy: map['collectedBy'] as String?,
    );
  }

  /// Convierte los datos a un mapa listo para guardarse en Firestore.
  /// La fecha la pone el servidor (serverTimestamp) para evitar
  /// relojes desajustados en los teléfonos.
  static Map<String, dynamic> toCreateMap({
    required String authorId,
    required String authorName,
    required MaterialType material,
    required double latitude,
    required double longitude,
    required String address,
    required List<String> photoUrls,
    String? descriptionText,
  }) =>
      {
        'authorId': authorId,
        'authorName': authorName,
        'material': material.id,
        'location': GeoPoint(latitude, longitude),
        'address': address,
        'photoUrls': photoUrls,
        'descriptionText': descriptionText,
        'status': ReportStatus.pendiente.id,
        'collectedBy': null,
        'createdAt': FieldValue.serverTimestamp(),
      };
}
