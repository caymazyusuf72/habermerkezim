// Clean Architecture'da use case'ler tarafından return edilen failure sınıfları
// Exception'lar presentation layer'a kadar çıkmaz, failure'lara dönüştürülür

abstract class Failure {
  final String message;
  final String? code;
  
  const Failure(this.message, {this.code});
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Failure && 
           other.message == message && 
           other.code == code;
  }
  
  @override
  int get hashCode => message.hashCode ^ (code?.hashCode ?? 0);
  
  @override
  String toString() => 'Failure: $message${code != null ? ' ($code)' : ''}';
}

/// Network ile ilgili failure'lar
class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.code});
  
  factory NetworkFailure.noInternet() {
    return const NetworkFailure(
      'İnternet bağlantısı yok. Lütfen bağlantınızı kontrol edin.',
      code: 'NO_INTERNET',
    );
  }
  
  factory NetworkFailure.timeout() {
    return const NetworkFailure(
      'Bağlantı zaman aşımına uğradı. Lütfen tekrar deneyin.',
      code: 'TIMEOUT',
    );
  }
  
  factory NetworkFailure.serverError(int? statusCode) {
    return NetworkFailure(
      'Sunucu hatası${statusCode != null ? ' ($statusCode)' : ''}',
      code: 'SERVER_ERROR',
    );
  }
}

/// Cache/Local storage failure'ları
class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.code});
  
  factory CacheFailure.notFound() {
    return const CacheFailure(
      'Önbelleğe alınmış veri bulunamadı',
      code: 'CACHE_NOT_FOUND',
    );
  }
  
  factory CacheFailure.writeError() {
    return const CacheFailure(
      'Veri önbelleğe kaydedilemedi',
      code: 'CACHE_WRITE_ERROR',
    );
  }
  
  factory CacheFailure.readError() {
    return const CacheFailure(
      'Önbellekten veri okunamadı',
      code: 'CACHE_READ_ERROR',
    );
  }
}

/// RSS feed parse failure'ları
class RssParseFailure extends Failure {
  final String? feedUrl;
  
  const RssParseFailure(super.message, {super.code, this.feedUrl});
  
  factory RssParseFailure.invalidFormat(String feedUrl) {
    return RssParseFailure(
      'RSS feed formatı geçersiz',
      code: 'INVALID_RSS_FORMAT',
      feedUrl: feedUrl,
    );
  }
  
  factory RssParseFailure.emptyFeed(String feedUrl) {
    return RssParseFailure(
      'RSS feed boş veya haber bulunmuyor',
      code: 'EMPTY_RSS_FEED',
      feedUrl: feedUrl,
    );
  }
  
  factory RssParseFailure.xmlParseError(String feedUrl) {
    return RssParseFailure(
      'XML parse hatası',
      code: 'XML_PARSE_ERROR',
      feedUrl: feedUrl,
    );
  }
}

/// Genel uygulama failure'ları
class GeneralFailure extends Failure {
  const GeneralFailure(super.message, {super.code});
  
  factory GeneralFailure.unexpected() {
    return const GeneralFailure(
      'Beklenmeyen bir hata oluştu',
      code: 'UNEXPECTED_ERROR',
    );
  }
  
  factory GeneralFailure.invalidInput(String details) {
    return GeneralFailure(
      'Geçersiz giriş: $details',
      code: 'INVALID_INPUT',
    );
  }
}

/// Validation failure'ları
class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.code});
  
  factory ValidationFailure.emptyField(String fieldName) {
    return ValidationFailure(
      '$fieldName boş olamaz',
      code: 'EMPTY_FIELD',
    );
  }
  
  factory ValidationFailure.invalidUrl(String url) {
    return ValidationFailure(
      'Geçersiz URL formatı: $url',
      code: 'INVALID_URL',
    );
  }
}