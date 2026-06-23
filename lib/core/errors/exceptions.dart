/// Excepciones de la capa de datos. Se traducen a Failures en los repositorios.
class ServerException implements Exception {
  final String message;
  ServerException([this.message = 'Error del servidor']);
}

class AuthException implements Exception {
  final String message;
  AuthException([this.message = 'Error de autenticación']);
}

class StorageException implements Exception {
  final String message;
  StorageException([this.message = 'Error al subir archivo']);
}

class LocationException implements Exception {
  final String message;
  LocationException([this.message = 'Error de ubicación']);
}
