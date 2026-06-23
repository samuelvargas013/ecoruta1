import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../core/constants/firestore_paths.dart';
import '../entities/report_entity.dart';

/// Contrato del módulo de reportes (F-02, F-03, F-04).
abstract class ReportRepository {
  /// Crea un reporte: sube fotos (bytes) a Storage y guarda el doc en Firestore.
  Future<Either<Failure, ReportEntity>> createReport({
    required String authorId,
    required String authorName,
    required MaterialType material,
    required double latitude,
    required double longitude,
    required String address,
    required List<Uint8List> photos,
    String? descriptionText,
  });

  Stream<List<ReportEntity>> watchActiveReports();
  Stream<List<ReportEntity>> watchReportsByAuthor(String authorId);

  Future<Either<Failure, Unit>> markAsCollected({
    required String reportId,
    required String recyclerId,
  });
}
