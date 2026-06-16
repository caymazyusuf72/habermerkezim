// Uygulama genelindeki exception sınıfları
// Data layer'da fırlatılır, presentation layer'da yakalanır

/// Genel uygulama exception'ı
abstract class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, {this.code});

  @override
  String toString() => message;
}

/// Sunucu ve network ile ilgili exception'lar
class ServerException extends AppException {
  final int? statusCode;

  const ServerException(super.message, {super.code, this.statusCode});
}

/// Cache/Local storage exception'ları
class CacheException extends AppException {
  const CacheException(super.message, {super.code});
}

/// RSS feed parse exception'ları
class RssParseException extends AppException {
  final String? feedUrl;

  const RssParseException(super.message, {super.code, this.feedUrl});
}

/// Network bağlantısı exception'ları
class NetworkException extends AppException {
  const NetworkException(super.message, {super.code});
}

/// Spesifik network exception'ları
class NoInternetException extends NetworkException {
  const NoInternetException()
    : super('İnternet bağlantısı yok', code: 'NO_INTERNET');
}

class TimeoutException extends NetworkException {
  const TimeoutException()
    : super('Bağlantı zaman aşımına uğradı', code: 'TIMEOUT');
}

class BadRequestException extends ServerException {
  const BadRequestException([super.message = 'Geçersiz istek'])
    : super(statusCode: 400, code: 'BAD_REQUEST');
}

class UnauthorizedException extends ServerException {
  const UnauthorizedException([super.message = 'Yetkisiz erişim'])
    : super(statusCode: 401, code: 'UNAUTHORIZED');
}

class NotFoundException extends ServerException {
  const NotFoundException([super.message = 'Kaynak bulunamadı'])
    : super(statusCode: 404, code: 'NOT_FOUND');
}

class InternalServerException extends ServerException {
  const InternalServerException([super.message = 'Sunucu hatası'])
    : super(statusCode: 500, code: 'INTERNAL_SERVER_ERROR');
}

/// RSS feed spesifik exception'ları
class InvalidRssFeedException extends RssParseException {
  const InvalidRssFeedException(String feedUrl)
    : super('Geçersiz RSS feed formatı', feedUrl: feedUrl, code: 'INVALID_RSS');
}

class EmptyRssFeedException extends RssParseException {
  const EmptyRssFeedException(String feedUrl)
    : super('RSS feed boş', feedUrl: feedUrl, code: 'EMPTY_RSS');
}

/// Local storage exception'ları
class DatabaseException extends CacheException {
  const DatabaseException(super.message) : super(code: 'DATABASE_ERROR');
}

class DataNotFoundException extends CacheException {
  const DataNotFoundException([super.message = 'Veri bulunamadı'])
    : super(code: 'DATA_NOT_FOUND');
}
