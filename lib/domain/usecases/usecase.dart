/// Base UseCase sınıfları - Clean Architecture Use Case Pattern
/// Tüm use case'ler bu soyut sınıflardan türetilir

/// Parametresiz use case
abstract class UseCase<Type> {
  Future<Type> call();
}

/// Parametreli use case
abstract class UseCaseWithParams<Type, Params> {
  Future<Type> call(Params params);
}

/// Stream dönen use case (reactive)
abstract class StreamUseCase<Type> {
  Stream<Type> call();
}

/// Stream dönen parametreli use case
abstract class StreamUseCaseWithParams<Type, Params> {
  Stream<Type> call(Params params);
}

/// Void dönen parametreli use case
abstract class VoidUseCaseWithParams<Params> {
  Future<void> call(Params params);
}

/// Void dönen parametresiz use case
abstract class VoidUseCase {
  Future<void> call();
}