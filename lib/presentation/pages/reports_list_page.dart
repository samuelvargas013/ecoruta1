import 'package:flutter/material.dart' hide MaterialType;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/firestore_paths.dart';
import '../../core/di/injection.dart';
import '../../domain/entities/report_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/report/mark_collected_usecase.dart';
import '../../domain/usecases/report/watch_active_reports_usecase.dart';
import '../../domain/usecases/report/watch_my_reports_usecase.dart';
import '../bloc/map/map_bloc.dart';
import '../widgets/material_visuals.dart';

/// Pestaña "Reportes". Según el rol:
///  - Reciclador validado: ve todos los reportes activos.
///  - Vecino (u otros): ve únicamente los reportes que él mismo creó.
class ReportsListPage extends StatelessWidget {
  final UserEntity user;
  const ReportsListPage({super.key, required this.user});

  bool get _seeAll =>
      user.role == UserRole.reciclador && user.recicladorValidado;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final bloc = MapBloc(
          watchActiveReports: sl<WatchActiveReportsUseCase>(),
          watchMyReports: sl<WatchMyReportsUseCase>(),
          markCollected: sl<MarkCollectedUseCase>(),
        );
        // Vecino → sus reportes; reciclador validado → todos los activos.
        return _seeAll
            ? (bloc..add(MapStarted()))
            : (bloc..add(MyReportsStarted(user.uid)));
      },
      child: BlocBuilder<MapBloc, MapState>(
        builder: (context, state) {
          if (state.status == MapStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.reports.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  _seeAll
                      ? 'No hay reportes activos por ahora.'
                      : 'Aún no has creado reportes.\nPulsa el botón + en el mapa para crear el primero.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textHint),
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: state.reports.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (_, i) =>
                _ReportTile(report: state.reports[i], showAuthor: _seeAll),
          );
        },
      ),
    );
  }
}

class _ReportTile extends StatelessWidget {
  final ReportEntity report;
  final bool showAuthor;
  const _ReportTile({required this.report, this.showAuthor = true});

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('dd/MM HH:mm').format(report.createdAt);
    final subtitle =
        showAuthor ? '${report.authorName} · $date\n${report.address}'
                   : '$date\n${report.address}';
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              MaterialVisuals.color(report.material).withValues(alpha: 0.15),
          child: Icon(MaterialVisuals.icon(report.material),
              color: MaterialVisuals.color(report.material)),
        ),
        title: Row(children: [
          Expanded(
            child: Text(report.material.label,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          _StatusChip(status: report.status),
        ]),
        subtitle: Text(subtitle),
        isThreeLine: true,
        trailing: report.photoUrls.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(report.photoUrls.first,
                    width: 48, height: 48, fit: BoxFit.cover),
              )
            : null,
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final ReportStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final recogido = status == ReportStatus.recogido;
    final color = recogido ? AppColors.primary : AppColors.warning;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(status.label,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }
}
