import 'dart:typed_data';
import 'package:flutter/material.dart' hide MaterialType;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/firestore_paths.dart';
import '../../core/di/injection.dart';
import '../../core/utils/location_service.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/report/create_report_usecase.dart';
import '../bloc/report/report_form_bloc.dart';
import '../widgets/material_visuals.dart';
import '../widgets/primary_button.dart';

/// Formulario de nuevo reporte (F-02).
///
/// Flujo del vecino: elegir material -> capturar ubicación GPS ->
/// agregar fotos (mínimo 1, desde cámara o galería) -> descripción
/// opcional -> enviar. Al enviar, las fotos suben a Firebase Storage
/// y el reporte se guarda en Firestore (+10 puntos para el autor).
class ReportFormPage extends StatelessWidget {
  final UserEntity user;
  const ReportFormPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ReportFormBloc(
        createReport: sl<CreateReportUseCase>(),
        locationService: sl<LocationService>(),
      ),
      child: _ReportFormView(user: user),
    );
  }
}

class _ReportFormView extends StatelessWidget {
  final UserEntity user;
  const _ReportFormView({required this.user});

  /// Abre cámara o galería. La imagen se comprime (calidad 70,
  /// máx. 1280px) para ahorrar datos y almacenamiento.
  Future<void> _pickPhoto(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final picked =
        await picker.pickImage(source: source, imageQuality: 70, maxWidth: 1280);
    if (picked != null && context.mounted) {
      context.read<ReportFormBloc>().add(PhotoAdded(picked));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.newReport)),
      body: BlocConsumer<ReportFormBloc, ReportFormState>(
        listener: (context, state) {
          if (state.status == FormSubmitStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('¡Reporte enviado! +10 puntos 🌱'),
                backgroundColor: AppColors.primary));
            Navigator.of(context).pop();
          } else if (state.errorMessage != null &&
              state.status == FormSubmitStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.error));
          }
        },
        builder: (context, state) {
          final bloc = context.read<ReportFormBloc>();
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label(AppStrings.materialType),
                DropdownButtonFormField<MaterialType>(
                  initialValue: state.material,
                  decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.recycling)),
                  items: MaterialType.values
                      .map((m) => DropdownMenuItem(
                            value: m,
                            child: Row(children: [
                              Icon(MaterialVisuals.icon(m),
                                  size: 18, color: MaterialVisuals.color(m)),
                              const SizedBox(width: 8),
                              Text(m.label),
                            ]),
                          ))
                      .toList(),
                  onChanged: (m) =>
                      m == null ? null : bloc.add(MaterialSelected(m)),
                ),
                const SizedBox(height: 16),
                _label(AppStrings.location),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(children: [
                    const Icon(Icons.location_on_outlined,
                        color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        state.hasLocation
                            ? state.address
                            : 'Aún sin ubicación',
                        style: TextStyle(
                            color: state.hasLocation
                                ? AppColors.textPrimary
                                : AppColors.textHint),
                      ),
                    ),
                    if (state.loadingLocation)
                      const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2)),
                  ]),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () => bloc.add(LocationRequested()),
                  icon: const Icon(Icons.my_location, size: 18),
                  label: const Text(AppStrings.useMyLocation),
                ),
                const SizedBox(height: 8),
                Row(children: [
                  _label('${AppStrings.photos} '),
                  const Text('*', style: TextStyle(color: AppColors.error)),
                ]),
                _PhotoGrid(
                  photos: state.photos,
                  onRemove: (i) => bloc.add(PhotoRemoved(i)),
                  onCamera: () => _pickPhoto(context, ImageSource.camera),
                  onGallery: () => _pickPhoto(context, ImageSource.gallery),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text(AppStrings.minOnePhoto,
                      style:
                          TextStyle(fontSize: 12, color: AppColors.textHint)),
                ),
                const SizedBox(height: 16),
                _label(AppStrings.description),
                TextField(
                  maxLines: 3,
                  onChanged: (v) => bloc.add(DescriptionChanged(v)),
                  decoration: const InputDecoration(
                    hintText: 'Ej: Botellas plásticas limpias...',
                  ),
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: AppStrings.sendReport,
                  loading: state.status == FormSubmitStatus.submitting,
                  onPressed: state.canSubmit
                      ? () => bloc.add(ReportSubmitted(
                            authorId: user.uid,
                            authorName: user.name,
                          ))
                      : null,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text,
            style: const TextStyle(
                fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
      );
}

class _PhotoGrid extends StatelessWidget {
  final List<XFile> photos;
  final void Function(int) onRemove;
  final VoidCallback onCamera;
  final VoidCallback onGallery;

  const _PhotoGrid({
    required this.photos,
    required this.onRemove,
    required this.onCamera,
    required this.onGallery,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ...photos.asMap().entries.map((e) => Stack(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _Thumb(file: e.value),
              ),
              Positioned(
                top: -6,
                right: -6,
                child: IconButton(
                  icon: const CircleAvatar(
                    radius: 11,
                    backgroundColor: AppColors.error,
                    child: Icon(Icons.close, size: 14, color: Colors.white),
                  ),
                  onPressed: () => onRemove(e.key),
                ),
              ),
            ])),
        _AddTile(icon: Icons.camera_alt_outlined, onTap: onCamera),
        _AddTile(icon: Icons.photo_library_outlined, onTap: onGallery),
      ],
    );
  }
}

/// Miniatura multiplataforma: lee bytes y usa Image.memory (web/Android/iOS).
class _Thumb extends StatelessWidget {
  final XFile file;
  const _Thumb({required this.file});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: file.readAsBytes(),
      builder: (context, snap) {
        if (snap.hasData) {
          return Image.memory(snap.data!,
              width: 80, height: 80, fit: BoxFit.cover);
        }
        return Container(
          width: 80,
          height: 80,
          color: AppColors.border,
          child: const Center(
              child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2))),
        );
      },
    );
  }
}

class _AddTile extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _AddTile({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F8E9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.primaryLight),
        ),
        child: Icon(icon, color: AppColors.secondary),
      ),
    );
  }
}
