import '../../entities/report_entity.dart';
import '../../repositories/report_repository.dart';

/// Caso de uso: observar en tiempo real los reportes creados por
/// el usuario actual, para la pestaña "Mis reportes" (F-02/F-04).
class WatchMyReportsUseCase {
  final ReportRepository repository;
  WatchMyReportsUseCase(this.repository);

  Stream<List<ReportEntity>> call(String authorId) =>
      repository.watchReportsByAuthor(authorId);
}
