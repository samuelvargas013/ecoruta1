part of 'report_form_bloc.dart';

enum FormSubmitStatus { editing, submitting, success, failure }

/// Estado del formulario: material elegido, fotos, descripción,
/// coordenadas GPS y estado del envío. La pantalla es un reflejo
/// directo de este objeto.
class ReportFormState extends Equatable {
  final MaterialType material;
  final List<XFile> photos;
  final String description;
  final double? latitude;
  final double? longitude;
  final String address;
  final bool loadingLocation;
  final FormSubmitStatus status;
  final String? errorMessage;

  const ReportFormState({
    this.material = MaterialType.plastico,
    this.photos = const [],
    this.description = '',
    this.latitude,
    this.longitude,
    this.address = '',
    this.loadingLocation = false,
    this.status = FormSubmitStatus.editing,
    this.errorMessage,
  });

  bool get hasLocation => latitude != null && longitude != null;
  bool get canSubmit => photos.isNotEmpty && hasLocation;

  ReportFormState copyWith({
    MaterialType? material,
    List<XFile>? photos,
    String? description,
    double? latitude,
    double? longitude,
    String? address,
    bool? loadingLocation,
    FormSubmitStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ReportFormState(
      material: material ?? this.material,
      photos: photos ?? this.photos,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      loadingLocation: loadingLocation ?? this.loadingLocation,
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        material,
        photos,
        description,
        latitude,
        longitude,
        address,
        loadingLocation,
        status,
        errorMessage,
      ];
}
