import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/report_repository.dart';
import '../usecase.dart';

class MarkCollectedUseCase implements UseCase<Unit, MarkCollectedParams> {
  final ReportRepository repository;
  MarkCollectedUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(MarkCollectedParams params) {
    return repository.markAsCollected(
      reportId: params.reportId,
      recyclerId: params.recyclerId,
    );
  }
}

class MarkCollectedParams extends Equatable {
  final String reportId;
  final String recyclerId;
  const MarkCollectedParams(
      {required this.reportId, required this.recyclerId});
  @override
  List<Object?> get props => [reportId, recyclerId];
}
