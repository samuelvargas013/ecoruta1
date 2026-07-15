import 'package:flutter/material.dart' hide MaterialType;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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

/// Pantalla del mapa (F-03): muestra los reportes como marcadores de
/// Google Maps, con un color distinto por tipo de material.
///
/// Regla de visibilidad:
/// - Reciclador VALIDADO: ve todos los reportes pendientes de la zona.
/// - Vecino o reciclador sin validar: solo ve sus propios reportes.
class MapPage extends StatelessWidget {
  final UserEntity user;
  const MapPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    // Reciclador validado ve todos los reportes activos; el resto, los suyos.
    final seeAll =
        user.role == UserRole.reciclador && user.recicladorValidado;
    return BlocProvider(
      create: (_) {
        final bloc = MapBloc(
          watchActiveReports: sl<WatchActiveReportsUseCase>(),
          watchMyReports: sl<WatchMyReportsUseCase>(),
          markCollected: sl<MarkCollectedUseCase>(),
        );
        return seeAll
            ? (bloc..add(MapStarted()))
            : (bloc..add(MyReportsStarted(user.uid)));
      },
      child: _MapView(user: user),
    );
  }
}

class _MapView extends StatelessWidget {
  final UserEntity user;
  const _MapView({required this.user});

  static const _initialCamera = CameraPosition(
    target: LatLng(18.4861, -69.9312), // Santo Domingo (ajusta a tu ciudad)
    zoom: 13,
  );

  /// Color del marcador en el mapa según el tipo de material
  /// (coincide con la leyenda inferior).
  double _hue(MaterialType m) {
    switch (m) {
      case MaterialType.plastico:
        return BitmapDescriptor.hueGreen;
      case MaterialType.carton:
        return BitmapDescriptor.hueOrange;
      case MaterialType.vidrio:
        return BitmapDescriptor.hueBlue;
      case MaterialType.metal:
        return BitmapDescriptor.hueAzure;
      case MaterialType.papel:
        return BitmapDescriptor.hueCyan;
    }
  }

  /// Al tocar un marcador: abre un panel inferior con el detalle del
  /// reporte. Si el usuario es reciclador validado, muestra además el
  /// botón "Marcar como recogido" (F-04).
  void _openReport(BuildContext context, ReportEntity r) {
    final canCollect =
        user.role == UserRole.reciclador && user.recicladorValidado;
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(MaterialVisuals.icon(r.material),
                  color: MaterialVisuals.color(r.material)),
              const SizedBox(width: 8),
              Text(r.material.label,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(height: 8),
            Text('Por: ${r.authorName}'),
            Text(r.address,
                style: const TextStyle(color: AppColors.textHint)),
            if (r.descriptionText != null) ...[
              const SizedBox(height: 8),
              Text(r.descriptionText!),
            ],
            const SizedBox(height: 16),
            if (canCollect)
              ElevatedButton.icon(
                onPressed: () {
                  context
                      .read<MapBloc>()
                      .add(CollectReportRequested(r.id, user.uid));
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Marcar como recogido'),
              )
            else if (user.role == UserRole.reciclador)
              const Text(
                'Tu cuenta de reciclador aún no está validada.',
                style: TextStyle(color: AppColors.warning),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapBloc, MapState>(
      builder: (context, state) {
        final markers = state.reports
            .map((r) => Marker(
                  markerId: MarkerId(r.id),
                  position: LatLng(r.latitude, r.longitude),
                  icon: BitmapDescriptor.defaultMarkerWithHue(_hue(r.material)),
                  infoWindow: InfoWindow(title: r.material.label),
                  onTap: () => _openReport(context, r),
                ))
            .toSet();

        return Stack(children: [
          GoogleMap(
            initialCameraPosition: _initialCamera,
            markers: markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false,
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: _Legend(),
          ),
          if (state.status == MapStatus.loading)
            const Center(child: CircularProgressIndicator()),
        ]);
      },
    );
  }
}

/// Leyenda flotante: qué color corresponde a cada material.
class _Legend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))
        ],
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 4,
        children: MaterialType.values
            .map((m) => Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                        color: MaterialVisuals.color(m),
                        borderRadius: BorderRadius.circular(5)),
                  ),
                  const SizedBox(width: 4),
                  Text(m.label, style: const TextStyle(fontSize: 12)),
                ]))
            .toList(),
      ),
    );
  }
}
