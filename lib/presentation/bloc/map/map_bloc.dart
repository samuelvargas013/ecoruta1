import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/report_entity.dart';
import '../../../domain/usecases/report/mark_collected_usecase.dart';
import '../../../domain/usecases/report/watch_active_reports_usecase.dart';
import '../../../domain/usecases/report/watch_my_reports_usecase.dart';

part 'map_event.dart';
part 'map_state.dart';

/// BLoC del mapa de reportes activos (F-03) y recolección (F-04).
/// También sirve la lista de reportes propios de un vecino (F-02).
class MapBloc extends Bloc<MapEvent, MapState> {
  final WatchActiveReportsUseCase watchActiveReports;
  final WatchMyReportsUseCase watchMyReports;
  final MarkCollectedUseCase markCollected;

  StreamSubscription<List<ReportEntity>>? _sub;

  MapBloc({
    required this.watchActiveReports,
    required this.watchMyReports,
    required this.markCollected,
  }) : super(const MapState()) {
    on<MapStarted>(_onStarted);
    on<MyReportsStarted>(_onMyReportsStarted);
    on<_ReportsUpdated>(_onUpdated);
    on<CollectReportRequested>(_onCollect);
  }

  void _onStarted(MapStarted event, Emitter<MapState> emit) {
    _listen(watchActiveReports());
  }

  void _onMyReportsStarted(MyReportsStarted event, Emitter<MapState> emit) {
    _listen(watchMyReports(event.authorId));
  }

  void _listen(Stream<List<ReportEntity>> stream) {
    _sub?.cancel();
    _sub = stream.listen(
      (reports) => add(_ReportsUpdated(reports)),
      onError: (_) => add(const _ReportsUpdated([])),
    );
  }

  void _onUpdated(_ReportsUpdated event, Emitter<MapState> emit) {
    emit(state.copyWith(status: MapStatus.loaded, reports: event.reports));
  }

  Future<void> _onCollect(
      CollectReportRequested event, Emitter<MapState> emit) async {
    final result = await markCollected(MarkCollectedParams(
      reportId: event.reportId,
      recyclerId: event.recyclerId,
    ));
    result.fold(
      (f) => emit(state.copyWith(errorMessage: f.message)),
      (_) {}, // El stream refresca la lista automáticamente.
    );
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
