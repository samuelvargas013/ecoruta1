import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../../core/constants/firestore_paths.dart';
import '../../entities/report_entity.dart';
import '../../repositories/report_repository.dart';
import '../usecase.dart';

/// Caso de uso: crear un reporte de material reciclable (F-02).
///
/// Aquí vive la REGLA DE NEGOCIO (no en la pantalla ni en Firebase):
/// un reporte debe tener al menos una foto. Si no la tiene, se rechaza
/// antes de tocar la red.
class CreateReportUseCase implements UseCase<ReportEntity, CreateReportParams> {
  final ReportRepository repository;
  CreateReportUseCase(this.repository);

  @override
  Future<Either<Failure, ReportEntity>> call(CreateReportParams params) {
    // Regla de negocio F-02: al menos una foto es obligatoria.
    if (params.photos.isEmpty) {
      return Future.value(
          const Left(ValidationFailure('Debes agregar al menos una foto.')));
    }
    return repository.createReport(
      authorId: params.authorId,
      authorName: params.authorName,
      material: params.material,
      latitude: params.latitude,
      longitude: params.longitude,
      address: params.address,
      photos: params.photos,
      descriptionText: params.descriptionText,
    );
  }
}

/// Todos los datos necesarios para crear un reporte:
/// autor, tipo de material, coordenadas GPS, dirección, fotos y descripción.
class CreateReportParams extends Equatable {
  final String authorId;
  final String authorName;
  final MaterialType material;
  final double latitude;
  final double longitude;
  final String address;
  final List<Uint8List> photos; // bytes: multiplataforma (web/Android/iOS)
  final String? descriptionText;

  const CreateReportParams({
    required this.authorId,
    required this.authorName,
    required this.material,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.photos,
    this.descriptionText,
  });

  @override
  List<Object?> get props => [
        authorId,
        authorName,
        material,
        latitude,
        longitude,
        address,
        photos,
        descriptionText,
      ];
}
