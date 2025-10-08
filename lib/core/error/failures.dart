// lib/core/error/failures.dart
// Purpose: Define application-level Failure/Exception types used across the domain layer.
// How to use: Throw or return these Failure objects from usecases/repositories to represent errors.

abstract class Failure {
  final String message;
  Failure(this.message);
}

class ServerFailure extends Failure {
  ServerFailure(String message) : super(message);
}

class CacheFailure extends Failure {
  CacheFailure(String message) : super(message);
}
