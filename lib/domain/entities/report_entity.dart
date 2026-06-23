import 'package:equatable/equatable.dart';
import '../../core/constants/firestore_paths.dart';

/// Entidad de reporte de residuos (F-02, F-03, F-04).
class ReportEntity extends Equatable {
  final String id;
  final String authorId;
  final String authorName;
  final MaterialType material;
  final double latitude;
  final double longitude;
  final String address;
  final List<String> photoUrls;
  final String? descriptionText;
  final ReportStatus status;
  final DateTime createdAt;
  final String? collectedBy; // uid del reciclador que recogió (F-04)

  const ReportEntity({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.material,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.photoUrls,
    this.descriptionText,
    this.status = ReportStatus.pendiente,
    required this.createdAt,
    this.collectedBy,
  });

  @override
  List<Object?> get props => [
        id,
        authorId,
        authorName,
        material,
        latitude,
        longitude,
        address,
        photoUrls,
        descriptionText,
        status,
        createdAt,
        collectedBy,
      ];
}
