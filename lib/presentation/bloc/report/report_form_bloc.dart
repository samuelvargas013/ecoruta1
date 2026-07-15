import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/firestore_paths.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/utils/location_service.dart';
import '../../../domain/usecases/report/create_report_usecase.dart';

part 'report_form_event.dart';
part 'report_form_state.dart';

/// BLoC del formulario de nuevo reporte (F-02). Un BLoC por funcionalidad,
/// siguiendo la recomendación del experto en la clínica técnica.
class ReportFormBloc extends Bloc<ReportFormEvent, ReportFormState> {
  final CreateReportUseCase createReport;
  final LocationService locationService;

  ReportFormBloc({
    required this.createReport,
    required this.locationService,
  }) : super(const ReportFormState()) {
    on<MaterialSelected>((e, emit) =>
        emit(state.copyWith(material: e.material)));
    on<PhotoAdded>((e, emit) =>
        emit(state.copyWith(photos: [...state.photos, e.photo])));
    on<PhotoRemoved>((e, emit) {
      final list = [...state.photos]..removeAt(e.index);
      emit(state.copyWith(photos: list));
    });
    on<DescriptionChanged>((e, emit) =>
        emit(state.copyWith(description: e.value)));
    on<LocationRequested>(_onLocation);
    on<ReportSubmitted>(_onSubmit);
  }

  /// "Usar mi ubicación": pide el GPS al teléfono y guarda las
  /// coordenadas en el estado del formulario.
  Future<void> _onLocation(
      LocationRequested event, Emitter<ReportFormState> emit) async {
    emit(state.copyWith(loadingLocation: true, clearError: true));
    try {
      final pos = await locationService.getCurrentPosition();
      emit(state.copyWith(
        latitude: pos.latitude,
        longitude: pos.longitude,
        address:
            'Lat: ${pos.latitude.toStringAsFixed(5)}, Lng: ${pos.longitude.toStringAsFixed(5)}',
        loadingLocation: false,
      ));
    } on LocationException catch (e) {
      emit(state.copyWith(loadingLocation: false, errorMessage: e.message));
    } catch (_) {
      emit(state.copyWith(
          loadingLocation: false,
          errorMessage: 'No se pudo obtener la ubicación.'));
    }
  }

  /// Envío del reporte: valida (foto + ubicación), convierte las fotos
  /// a bytes y llama al caso de uso. Emite success o failure para que
  /// la pantalla muestre el resultado.
  Future<void> _onSubmit(
      ReportSubmitted event, Emitter<ReportFormState> emit) async {
    if (!state.canSubmit) {
      emit(state.copyWith(
          errorMessage:
              'Agrega al menos una foto y tu ubicación antes de enviar.'));
      return;
    }
    emit(state.copyWith(status: FormSubmitStatus.submitting, clearError: true));

    // Leer bytes de cada foto (funciona en web, Android e iOS).
    final List<Uint8List> bytes = [
      for (final x in state.photos) await x.readAsBytes(),
    ];

    final result = await createReport(CreateReportParams(
      authorId: event.authorId,
      authorName: event.authorName,
      material: state.material,
      latitude: state.latitude!,
      longitude: state.longitude!,
      address: state.address,
      photos: bytes,
      descriptionText: state.description.isEmpty ? null : state.description,
    ));

    result.fold(
      (f) => emit(state.copyWith(
          status: FormSubmitStatus.failure, errorMessage: f.message)),
      (_) => emit(state.copyWith(status: FormSubmitStatus.success)),
    );
  }
}
