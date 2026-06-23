part of 'map_bloc.dart';

enum MapStatus { loading, loaded, error }

class MapState extends Equatable {
  final MapStatus status;
  final List<ReportEntity> reports;
  final String? errorMessage;

  const MapState({
    this.status = MapStatus.loading,
    this.reports = const [],
    this.errorMessage,
  });

  MapState copyWith({
    MapStatus? status,
    List<ReportEntity>? reports,
    String? errorMessage,
  }) =>
      MapState(
        status: status ?? this.status,
        reports: reports ?? this.reports,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props => [status, reports, errorMessage];
}
