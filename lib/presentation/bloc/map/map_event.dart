part of 'map_bloc.dart';

abstract class MapEvent extends Equatable {
  const MapEvent();
  @override
  List<Object?> get props => [];
}

/// Observa todos los reportes activos (mapa / reciclador validado).
class MapStarted extends MapEvent {}

/// Observa solo los reportes creados por un autor (vecino ve los suyos).
class MyReportsStarted extends MapEvent {
  final String authorId;
  const MyReportsStarted(this.authorId);
  @override
  List<Object?> get props => [authorId];
}

class _ReportsUpdated extends MapEvent {
  final List<ReportEntity> reports;
  const _ReportsUpdated(this.reports);
  @override
  List<Object?> get props => [reports];
}

class CollectReportRequested extends MapEvent {
  final String reportId;
  final String recyclerId;
  const CollectReportRequested(this.reportId, this.recyclerId);
  @override
  List<Object?> get props => [reportId, recyclerId];
}
