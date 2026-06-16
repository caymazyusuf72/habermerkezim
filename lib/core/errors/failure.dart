import 'app_exceptions.dart';

/// Genişletilmiş Failure Sınıfları
/// 
/// Mevcut [core/error/failures.dart] ile geriye uyumludur.
/// Exception'ları Failure'lara dönüştüren factory metotları içerir.
/// Use case katmanında hata yönetimi için kullanılır.

/// Tüm failure'ların base class'ı
abstract class AppFailure {
  final String message;
  final String? code;
  final Object? originalError;

  const AppFailure(this.message, {this.code, this.originalError});

  /// Kullanıcı dostu hata mesajı
  String get userMessage;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppFailure && other.message == message && other.code == code;
  }

  @override
  int get hashCode => message.hashCode ^ (code?.hashCode ?? 0);

  @override
  String toString() => '${runtimeType.toString()}: $message${code != null ? ' ($code)' : ''}';

  /// Exception'ı uygun Failure'a dönüştür
  static AppFailure fromException(Object error) {
    if (error is NetworkException) {
      return NetworkFailure.fromException(error);
    } else if (error is CacheException) {
      return CacheFailure.fromException(error);
    } else if (error is ParseException) {
      return ParseFailure.fromException(error);
    } else if (error is ServerException) {
      return ServerFailure.fromException(error);
    } else if (error is AuthException) {
      return ServerFailure(
        error.message,
        code: error.code,
        originalError: error,
      );
    } else if (error is RateLimitException) {
      return ServerFailure(
        error.message,
        code: error.code,
        originalError: error,
      );
    } else {
      return UnexpectedFailure(
        error.toString(),
        originalError: error,
      );
    }
  }
}

/// Network failure'ları
class NetworkFailure extends AppFailure {
  const NetworkFailure(
    super.message, {
    super.code,
    super.originalError,
  });

  factory NetworkFailure.noInternet() {
    return const NetworkFailure(
      'İnternet bağlantısı yok',
      code: 'NO_INTERNET',
    );
  }

  factory NetworkFailure.timeout() {
    return const NetworkFailure(
      'Bağlantı zaman aşımına uğradı',
      code: 'TIMEOUT',
    );
  }

  factory NetworkFailure.fromException(NetworkException exception) {
    return NetworkFailure(
      exception.message,
      code: exception.code,
      originalError: exception,
    );
  }

  @override
  String get userMessage {
    switch (code) {
      case 'NO_INTERNET':
        return 'İnternet bağlantınızı kontrol edin ve tekrar deneyin.';
      case 'TIMEOUT':
        return 'Bağlantı zaman aşımına uğradı. Lütfen tekrar deneyin.';
      default:
        return 'Bağlantı hatası oluştu. Lütfen tekrar deneyin.';
    }
  }
}

/// Cache failure'ları
class CacheFailure extends AppFailure {
  const CacheFailure(
    super.message, {
    super.code,
    super.originalError,
  });

  factory CacheFailure.notFound() {
    return const CacheFailure(
      'Önbellekte veri bulunamadı',
      code: 'CACHE_NOT_FOUND',
    );
  }

  factory CacheFailure.readError() {
    return const CacheFailure(
      'Önbellekten veri okunamadı',
      code: 'CACHE_READ_ERROR',
    );
  }

  factory CacheFailure.writeError() {
    return const CacheFailure(
      'Veri önbelleğe kaydedilemedi',
      code: 'CACHE_WRITE_ERROR',
    );
  }

  factory CacheFailure.fromException(CacheException exception) {
    return CacheFailure(
      exception.message,
      code: exception.code,
      originalError: exception,
    );
  }

  @override
  String get userMessage {
    switch (code) {
      case 'CACHE_NOT_FOUND':
        return 'Kayıtlı veri bulunamadı.';
      case 'CACHE_READ_ERROR':
        return 'Veriler yüklenemedi. Lütfen tekrar deneyin.';
      case 'CACHE_WRITE_ERROR':
        return 'Veriler kaydedilemedi.';
      default:
        return 'Yerel depolama hatası oluştu.';
    }
  }
}

/// Parse/Format failure'ları
class ParseFailure extends AppFailure {
  final String? sourceUrl;

  const ParseFailure(
    super.message, {
    super.code,
    super.originalError,
    this.sourceUrl,
  });

  factory ParseFailure.rssError({String? sourceUrl}) {
    return ParseFailure(
      'RSS feed ayrıştırılamadı',
      code: 'RSS_PARSE_ERROR',
      sourceUrl: sourceUrl,
    );
  }

  factory ParseFailure.jsonError() {
    return const ParseFailure(
      'JSON veri ayrıştırılamadı',
      code: 'JSON_PARSE_ERROR',
    );
  }

  factory ParseFailure.fromException(ParseException exception) {
    return ParseFailure(
      exception.message,
      code: exception.code,
      originalError: exception,
      sourceUrl: exception.sourceUrl,
    );
  }

  @override
  String get userMessage {
    switch (code) {
      case 'RSS_PARSE_ERROR':
        return 'Haber kaynağı okunamadı. Kaynak geçici olarak kullanılamıyor olabilir.';
      case 'JSON_PARSE_ERROR':
        return 'Veri formatı okunamadı.';
      default:
        return 'Veri işleme hatası oluştu.';
    }
  }
}

/// Sunucu failure'ları
class ServerFailure extends AppFailure {
  final int? statusCode;

  const ServerFailure(
    super.message, {
    super.code,
    super.originalError,
    this.statusCode,
  });

  factory ServerFailure.internalError({int? statusCode}) {
    return ServerFailure(
      'Sunucu hatası',
      code: 'SERVER_ERROR',
      statusCode: statusCode ?? 500,
    );
  }

  factory ServerFailure.serviceUnavailable() {
    return const ServerFailure(
      'Servis kullanılamıyor',
      code: 'SERVICE_UNAVAILABLE',
      statusCode: 503,
    );
  }

  factory ServerFailure.fromException(ServerException exception) {
    return ServerFailure(
      exception.message,
      code: exception.code,
      originalError: exception,
      statusCode: exception.statusCode,
    );
  }

  @override
  String get userMessage {
    switch (code) {
      case 'SERVICE_UNAVAILABLE':
        return 'Servis geçici olarak kullanılamıyor. Lütfen daha sonra tekrar deneyin.';
      default:
        return 'Sunucu hatası oluştu. Lütfen daha sonra tekrar deneyin.';
    }
  }
}

/// Beklenmeyen hatalar
class UnexpectedFailure extends AppFailure {
  const UnexpectedFailure(
    super.message, {
    super.code,
    super.originalError,
  });

  factory UnexpectedFailure.unknown({Object? originalError}) {
    return UnexpectedFailure(
      'Beklenmeyen bir hata oluştu',
      code: 'UNEXPECTED_ERROR',
      originalError: originalError,
    );
  }

  @override
  String get userMessage => 'Beklenmeyen bir hata oluştu. Lütfen tekrar deneyin.';
}