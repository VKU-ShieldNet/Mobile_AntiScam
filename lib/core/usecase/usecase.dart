// lib/core/usecase/usecase.dart
// Purpose: Base UseCase type for domain layer. Use to execute business logic.
// How to use: Extend UseCase<ReturnType, Params> and implement `call`.

abstract class UseCase<Type, Params> {
  Future<Type> call(Params params);
}

class NoParams {}
