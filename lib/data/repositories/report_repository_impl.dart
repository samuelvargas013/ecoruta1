import 'dart:typed_data';
import 'package:dartz/dartz.dart';

import '../../core/constants/firestore_paths.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/report_entity.dart';
import '../../domain/repositories/report_repository.dart';
import '../datasources/report_remote_datasource.dart';

/// Implementa ReportRepository: delega en el datasource y
/// convierte excepciones (Storage/Server) en Failures para la UI.
class ReportRepositoryImpl implements ReportRepository {
  final ReportRemoteDataSource remote;
  ReportRepositoryImpl(this.remote);

  @override
  Future<Either<Failure, ReportEntity>> createReport({
    required String authorId,
    required String authorName,
    required MaterialType material,
    required double latitude,
    required double longitude,
    required String address,
    required List<Uint8List> photos,
    String? descriptionText,
  }) async {
    try {
      final report = await remote.createReport(
        authorId: authorId,
        authorName: authorName,
        material: material,
        latitude: latitude,
        longitude: longitude,
        address: address,
        photos: photos,
        descriptionText: descriptionText,
      );
      return Right(report);
    } on StorageException catch (e) {
      return Left(StorageFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Stream<List<ReportEntity>> watchActiveReports() =>
      remote.watchActiveReports();

  @override
  Stream<List<ReportEntity>> watchReportsByAuthor(String authorId) =>
      remote.watchReportsByAuthor(authorId);

  @override
  Future<Either<Failure, Unit>> markAsCollected({
    required String reportId,
    required String recyclerId,
  }) async {
    try {
      await remote.markAsCollected(reportId, recyclerId);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }
}
