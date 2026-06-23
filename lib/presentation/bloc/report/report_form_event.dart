part of 'report_form_bloc.dart';

abstract class ReportFormEvent extends Equatable {
  const ReportFormEvent();
  @override
  List<Object?> get props => [];
}

class MaterialSelected extends ReportFormEvent {
  final MaterialType material;
  const MaterialSelected(this.material);
  @override
  List<Object?> get props => [material];
}

class PhotoAdded extends ReportFormEvent {
  final XFile photo;
  const PhotoAdded(this.photo);
  @override
  List<Object?> get props => [photo];
}

class PhotoRemoved extends ReportFormEvent {
  final int index;
  const PhotoRemoved(this.index);
  @override
  List<Object?> get props => [index];
}

class DescriptionChanged extends ReportFormEvent {
  final String value;
  const DescriptionChanged(this.value);
  @override
  List<Object?> get props => [value];
}

class LocationRequested extends ReportFormEvent {}

class ReportSubmitted extends ReportFormEvent {
  final String authorId;
  final String authorName;
  const ReportSubmitted({required this.authorId, required this.authorName});
  @override
  List<Object?> get props => [authorId, authorName];
}
