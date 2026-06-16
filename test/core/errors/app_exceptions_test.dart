import 'package:flutter_test/flutter_test.dart';
import 'package:haber_merkezi/core/errors/app_exceptions.dart';

void main() {
  group('NetworkException', () {
    test('noInternet factory doğru userMessage döndürmeli', () {
      final exception = NetworkException.noInternet();

      expect(exception.code, 'NO_INTERNET');
      expect(exception.message, 'İnternet bağlantısı yok');
      expect(
        exception.userMessage,
        'İnternet bağlantınızı kontrol edin ve tekrar deneyin.',
      );
    });

    test('timeout factory doğru userMessage döndürmeli', () {
      final exception = NetworkException.timeout();

      expect(exception.code, 'TIMEOUT');
      expect(
        exception.userMessage,
        'Bağlantı zaman aşımına uğradı. Lütfen tekrar deneyin.',
      );
    });

    test('dnsError factory doğru userMessage döndürmeli', () {
      final exception = NetworkException.dnsError();

      expect(exception.code, 'DNS_ERROR');
      expect(
        exception.userMessage,
        'Sunucuya ulaşılamıyor. İnternet bağlantınızı kontrol edin.',
      );
    });

    test('bilinmeyen kod için varsayılan userMessage döndürmeli', () {
      const exception = NetworkException('Bilinmeyen hata');

      expect(
        exception.userMessage,
        'Bağlantı hatası oluştu. Lütfen tekrar deneyin.',
      );
    });

    test('toString() doğru format döndürmeli', () {
      final exception = NetworkException.noInternet();

      expect(exception.toString(), contains('NetworkException'));
      expect(exception.toString(), contains('NO_INTERNET'));
    });

    test('originalError saklanmalı', () {
      final original = Exception('orijinal hata');
      final exception = NetworkException.noInternet(originalError: original);

      expect(exception.originalError, original);
    });
  });

  group('CacheException', () {
    test('readError factory doğru değerler döndürmeli', () {
      final exception = CacheException.readError();

      expect(exception.code, 'CACHE_READ_ERROR');
      expect(exception.userMessage, 'Yerel depolama hatası oluştu.');
    });

    test('writeError factory doğru değerler döndürmeli', () {
      final exception = CacheException.writeError();

      expect(exception.code, 'CACHE_WRITE_ERROR');
      expect(exception.userMessage, 'Yerel depolama hatası oluştu.');
    });

    test('notFound factory doğru userMessage döndürmeli', () {
      final exception = CacheException.notFound();

      expect(exception.code, 'CACHE_NOT_FOUND');
      expect(exception.userMessage, 'Kayıtlı veri bulunamadı.');
    });

    test('expired factory doğru userMessage döndürmeli', () {
      final exception = CacheException.expired();

      expect(exception.code, 'CACHE_EXPIRED');
      expect(exception.userMessage, 'Veriler güncel değil. Yenileniyor...');
    });
  });

  group('ParseException', () {
    test('jsonError factory doğru değerler döndürmeli', () {
      final exception = ParseException.jsonError(sourceUrl: 'https://test.com');

      expect(exception.code, 'JSON_PARSE_ERROR');
      expect(exception.sourceUrl, 'https://test.com');
      expect(exception.userMessage, 'Veri işleme hatası oluştu.');
    });

    test('xmlError factory doğru değerler döndürmeli', () {
      final exception = ParseException.xmlError();

      expect(exception.code, 'XML_PARSE_ERROR');
    });

    test('rssError factory doğru userMessage döndürmeli', () {
      final exception = ParseException.rssError(
        sourceUrl: 'https://rss.com/feed',
      );

      expect(exception.code, 'RSS_PARSE_ERROR');
      expect(exception.sourceUrl, 'https://rss.com/feed');
      expect(
        exception.userMessage,
        'Haber kaynağı okunamadı. Kaynak geçici olarak kullanılamıyor olabilir.',
      );
    });

    test('invalidFormat factory doğru userMessage döndürmeli', () {
      final exception = ParseException.invalidFormat();

      expect(exception.code, 'INVALID_FORMAT');
      expect(exception.userMessage, 'Veri formatı tanınamadı.');
    });
  });

  group('AuthException', () {
    test('unauthorized factory doğru userMessage döndürmeli', () {
      final exception = AuthException.unauthorized();

      expect(exception.code, 'UNAUTHORIZED');
      expect(exception.userMessage, 'Bu işlem için yetkiniz yok.');
    });

    test('tokenExpired factory doğru userMessage döndürmeli', () {
      final exception = AuthException.tokenExpired();

      expect(exception.code, 'TOKEN_EXPIRED');
      expect(
        exception.userMessage,
        'Oturumunuz sona erdi. Lütfen tekrar giriş yapın.',
      );
    });

    test('invalidCredentials factory doğru userMessage döndürmeli', () {
      final exception = AuthException.invalidCredentials();

      expect(exception.code, 'INVALID_CREDENTIALS');
      expect(exception.userMessage, 'E-posta veya şifre hatalı.');
    });

    test('accountDisabled factory doğru userMessage döndürmeli', () {
      final exception = AuthException.accountDisabled();

      expect(exception.code, 'ACCOUNT_DISABLED');
      expect(exception.userMessage, 'Hesabınız devre dışı bırakılmış.');
    });

    test('bilinmeyen kod için varsayılan userMessage döndürmeli', () {
      const exception = AuthException('Bilinmeyen');

      expect(exception.userMessage, 'Kimlik doğrulama hatası oluştu.');
    });
  });

  group('RateLimitException', () {
    test('tooManyRequests retryAfter ile doğru mesaj döndürmeli', () {
      final exception = RateLimitException.tooManyRequests(
        retryAfter: const Duration(seconds: 30),
      );

      expect(exception.code, 'TOO_MANY_REQUESTS');
      expect(exception.retryAfter, const Duration(seconds: 30));
      expect(
        exception.userMessage,
        'Çok fazla istek gönderildi. 30 saniye sonra tekrar deneyin.',
      );
    });

    test('apiQuotaExceeded doğru userMessage döndürmeli', () {
      final exception = RateLimitException.apiQuotaExceeded();

      expect(exception.code, 'API_QUOTA_EXCEEDED');
      expect(
        exception.userMessage,
        'Günlük istek limiti aşıldı. Lütfen daha sonra tekrar deneyin.',
      );
    });

    test('retryAfter olmadan varsayılan mesaj döndürmeli', () {
      final exception = RateLimitException.tooManyRequests();

      expect(exception.retryAfter, isNull);
      expect(
        exception.userMessage,
        'Çok fazla istek gönderildi. Lütfen biraz bekleyin.',
      );
    });
  });

  group('ServerException', () {
    test('internalError factory doğru değerler döndürmeli', () {
      final exception = ServerException.internalError(statusCode: 500);

      expect(exception.code, 'SERVER_ERROR');
      expect(exception.statusCode, 500);
      expect(
        exception.userMessage,
        'Sunucu hatası oluştu. Lütfen daha sonra tekrar deneyin.',
      );
    });

    test('serviceUnavailable factory doğru değerler döndürmeli', () {
      final exception = ServerException.serviceUnavailable();

      expect(exception.code, 'SERVICE_UNAVAILABLE');
      expect(exception.statusCode, 503);
      expect(
        exception.userMessage,
        'Servis geçici olarak kullanılamıyor. Lütfen daha sonra tekrar deneyin.',
      );
    });

    test('varsayılan statusCode 500 olmalı', () {
      final exception = ServerException.internalError();

      expect(exception.statusCode, 500);
    });
  });

  group('AppException toString()', () {
    test('code varsa parantez içinde göstermeli', () {
      final exception = NetworkException.noInternet();

      expect(
        exception.toString(),
        'NetworkException: İnternet bağlantısı yok (NO_INTERNET)',
      );
    });

    test('code yoksa parantez olmamalı', () {
      const exception = NetworkException('Basit hata');

      expect(exception.toString(), 'NetworkException: Basit hata');
    });
  });
}
