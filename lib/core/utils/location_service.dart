import 'package:geolocator/geolocator.dart';
import '../errors/exceptions.dart';

/// Servicio de geolocalización (RNF-07: flujo de creación de reporte con GPS).
class LocationService {
  Future<Position> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationException('Activa el GPS para continuar.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw LocationException('Permiso de ubicación denegado.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw LocationException(
          'Permiso de ubicación denegado permanentemente. Habilítalo en ajustes.');
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }
}
