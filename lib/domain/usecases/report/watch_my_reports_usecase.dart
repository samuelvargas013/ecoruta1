import '../../entities/report_entity.dart';
import '../../repositories/report_repository.dart';

class WatchMyReportsUseCase {
  final ReportRepository repository;
  WatchMyReportsUseCase(this.repository);

  Stream<List<ReportEntity>> call(String authorId) =>
      repository.watchReportsByAuthor(authorId);
}
