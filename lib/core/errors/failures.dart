import 'package:equatable/equatable.dart';

/// Representa un error en la capa de dominio/presentación.
/// Las capas internas NO conocen excepciones de Firebase; trabajan con Failures.
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Ocurrió un error en el servidor.']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Error de autenticación.']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Sin conexión a internet.']);
}

class StorageFailure extends Failure {
  const StorageFailure([super.message = 'No se pudo subir el archivo.']);
}

class LocationFailure extends Failure {
  const LocationFailure([super.message = 'No se pudo obtener la ubicación.']);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}
