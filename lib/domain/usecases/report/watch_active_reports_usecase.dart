import '../../entities/report_entity.dart';
import '../../repositories/report_repository.dart';

/// Stream de reportes activos para el mapa (F-03).
class WatchActiveReportsUseCase {
  final ReportRepository repository;
  WatchActiveReportsUseCase(this.repository);

  Stream<List<ReportEntity>> call() => repository.watchActiveReports();
}
