/// Functional programming Result pattern implementasyonu
/// Error handling için Either benzeri yaklaşım
/// Success ve Failure durumlarını type-safe şekilde handle eder

abstract class Result<T> {
  const Result();
  
  /// Success durumunda true döner
  bool get isSuccess => this is Success<T>;
  
  /// Failure durumunda true döner  
  bool get isFailure => this is Failure<T>;
  
  /// Success durumunda data'yı döner, aksi halde null
  T? get dataOrNull => isSuccess ? (this as Success<T>).data : null;
  
  /// Failure durumunda error'ı döner, aksi halde null
  Exception? get errorOrNull => isFailure ? (this as Failure<T>).error : null;
  
  /// Success durumunda callback çalıştırır
  Result<U> map<U>(U Function(T data) mapper) {
    if (isSuccess) {
      try {
        return Success(mapper((this as Success<T>).data));
      } catch (e) {
        return Failure(e is Exception ? e : Exception(e.toString()));
      }
    }
    return Failure((this as Failure<T>).error);
  }
  
  /// Failure durumunda callback çalıştırır
  Result<T> mapError(Exception Function(Exception error) mapper) {
    if (isFailure) {
      return Failure(mapper((this as Failure<T>).error));
    }
    return this;
  }
  
  /// Success callback'i çalıştırır
  void onSuccess(void Function(T data) callback) {
    if (isSuccess) {
      callback((this as Success<T>).data);
    }
  }
  
  /// Failure callback'i çalıştırır
  void onFailure(void Function(Exception error) callback) {
    if (isFailure) {
      callback((this as Failure<T>).error);
    }
  }
  
  /// Pattern matching benzeri when method
  U when<U>({
    required U Function(T data) success,
    required U Function(Exception error) failure,
  }) {
    if (isSuccess) {
      return success((this as Success<T>).data);
    } else {
      return failure((this as Failure<T>).error);
    }
  }
}

/// Başarılı sonuç
class Success<T> extends Result<T> {
  final T data;
  
  const Success(this.data);
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Success<T> && other.data == data;
  }
  
  @override
  int get hashCode => data.hashCode;
  
  @override
  String toString() => 'Success($data)';
}

/// Hatalı sonuç
class Failure<T> extends Result<T> {
  final Exception error;
  
  const Failure(this.error);
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Failure<T> && other.error == error;
  }
  
  @override
  int get hashCode => error.hashCode;
  
  @override
  String toString() => 'Failure($error)';
}

/// Result utility extension methods
extension ResultExtensions<T> on Result<T> {
  /// Success durumunda data'yı döner, Failure durumunda exception fırlatır
  T get data {
    return when(
      success: (data) => data,
      failure: (error) => throw error,
    );
  }
  
  /// Success durumunda data'yı, Failure durumunda defaultValue'yu döner
  T getOrElse(T defaultValue) {
    return when(
      success: (data) => data,
      failure: (_) => defaultValue,
    );
  }
  
  /// Success durumunda data'yı, Failure durumunda callback sonucunu döner
  T getOrDefault(T Function() defaultValueProvider) {
    return when(
      success: (data) => data,
      failure: (_) => defaultValueProvider(),
    );
  }
}

/// Result helper methods
class ResultHelper {
  ResultHelper._();
  
  /// Try-catch wrapper
  static Result<T> tryCatch<T>(T Function() operation) {
    try {
      return Success(operation());
    } catch (e) {
      return Failure(e is Exception ? e : Exception(e.toString()));
    }
  }
  
  /// Async try-catch wrapper
  static Future<Result<T>> tryCatchAsync<T>(Future<T> Function() operation) async {
    try {
      final result = await operation();
      return Success(result);
    } catch (e) {
      return Failure(e is Exception ? e : Exception(e.toString()));
    }
  }
  
  /// List of Results'i Result of List'e çevirir
  static Result<List<T>> combine<T>(List<Result<T>> results) {
    final List<T> successResults = [];
    
    for (final result in results) {
      if (result.isFailure) {
        return Failure((result as Failure<T>).error);
      }
      successResults.add((result as Success<T>).data);
    }
    
    return Success(successResults);
  }
}