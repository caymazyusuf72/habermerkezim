import 'package:flutter_test/flutter_test.dart';
import 'package:haber_merkezi/core/errors/app_exceptions.dart';
import 'package:haber_merkezi/core/errors/failure.dart';

void main() {
  group('NetworkFailure', () {
    test('noInternet factory doğru değerler döndürmeli', () {
      final failure = NetworkFailure.noInternet();

      expect(failure.message, 'İnternet bağlantısı yok');
      expect(failure.code, 'NO_INTERNET');
      expect(failure.userMessage, 'İnternet bağlantınızı kontrol edin ve tekrar deneyin.');
    });

    test('timeout factory doğru değerler döndürmeli', () {
      final failure = NetworkFailure.timeout();

      expect(failure.code, 'TIMEOUT');
      expect(failure.userMessage, 'Bağlantı zaman aşımına uğradı. Lütfen tekrar deneyin.');
    });

    test('fromException ile exception dönüşümü doğru olmalı', () {
      final exception = NetworkException.noInternet();
      final failure = NetworkFailure.fromException(exception);

      expect(failure.message, exception.message);
      expect(failure.code, exception.code);
      expect(failure.originalError, exception);
    });

    test('bilinmeyen kod için varsayılan userMessage döndürmeli', () {
      const failure = NetworkFailure('Bilinmeyen');

      expect(failure.userMessage, 'Bağlantı hatası oluştu. Lütfen tekrar deneyin.');
    });
  });

  group('CacheFailure', () {
    test('notFound factory doğru değerler döndürmeli', () {
      final failure = CacheFailure.notFound();

      expect(failure.code, 'CACHE_NOT_FOUND');
      expect(failure.userMessage, 'Kayıtlı veri bulunamadı.');
    });

    test('readError factory doğru değerler döndürmeli', () {
      final failure = CacheFailure.readError();

      expect(failure.code, 'CACHE_READ_ERROR');
      expect(failure.userMessage, 'Veriler yüklenemedi. Lütfen tekrar deneyin.');
    });

    test('writeError factory doğru değerler döndürmeli', () {
      final failure = CacheFailure.writeError();

      expect(failure.code, 'CACHE_WRITE_ERROR');
      expect(failure.userMessage, 'Veriler kaydedilemedi.');
    });

    test('fromException ile exception dönüşümü doğru olmalı', () {
      final exception = CacheException.notFound();
      final failure = CacheFailure.fromException(exception);

      expect(failure.message, exception.message);
      expect(failure.code, exception.code);
    });
  });

  group('ParseFailure', () {
    test('rssError factory doğru değerler döndürmeli', () {
      final failure = ParseFailure.rssError(sourceUrl: 'https://rss.com/feed');

      expect(failure.code, 'RSS_PARSE_ERROR');
      expect(failure.sourceUrl, 'https://rss.com/feed');
      expect(failure.userMessage,
          'Haber kaynağı okunamadı. Kaynak geçici olarak kullanılamıyor olabilir.');
    });

    test('jsonError factory doğru değerler döndürmeli', () {
      final failure = ParseFailure.jsonError();

      expect(failure.code, 'JSON_PARSE_ERROR');
      expect(failure.userMessage, 'Veri formatı okunamadı.');
    });

    test('fromException ile exception dönüşümü doğru olmalı', () {
      final exception = ParseException.rssError(sourceUrl: 'https://test.com');
      final failure = ParseFailure.fromException(exception);

      expect(failure.message, exception.message);
      expect(failure.code, exception.code);
      expect(failure.sourceUrl, 'https://test.com');
    });
  });

  group('ServerFailure', () {
    test('internalError factory doğru değerler döndürmeli', () {
      final failure = ServerFailure.internalError(statusCode: 500);

      expect(failure.code, 'SERVER_ERROR');
      expect(failure.statusCode, 500);
      expect(failure.userMessage,
          'Sunucu hatası oluştu. Lütfen daha sonra tekrar deneyin.');
    });

    test('serviceUnavailable factory doğru değerler döndürmeli', () {
      final failure = ServerFailure.serviceUnavailable();

      expect(failure.code, 'SERVICE_UNAVAILABLE');
      expect(failure.statusCode, 503);
      expect(failure.userMessage,
          'Servis geçici olarak kullanılamıyor. Lütfen daha sonra tekrar deneyin.');
    });

    test('fromException ile exception dönüşümü doğru olmalı', () {
      final exception = ServerException.internalError(statusCode: 502);
      final failure = ServerFailure.fromException(exception);

      expect(failure.message, exception.message);
      expect(failure.code, exception.code);
      expect(failure.statusCode, 502);
    });
  });

  group('UnexpectedFailure', () {
    test('unknown factory doğru değerler döndürmeli', () {
      final failure = UnexpectedFailure.unknown();

      expect(failure.code, 'UNEXPECTED_ERROR');
      expect(failure.userMessage,
          'Beklenmeyen bir hata oluştu. Lütfen tekrar deneyin.');
    });

    test('originalError saklanmalı', () {
      final error = Exception('beklenmeyen');
      final failure = UnexpectedFailure.unknown(originalError: error);

      expect(failure.originalError, error);
    });
  });

  group('AppFailure.fromException()', () {
    test('NetworkException → NetworkFailure dönüşümü doğru olmalı', () {
      final exception = NetworkException.noInternet();
      final failure = AppFailure.fromException(exception);

      expect(failure, isA<NetworkFailure>());
      expect(failure.code, 'NO_INTERNET');
    });

    test('CacheException → CacheFailure dönüşümü doğru olmalı', () {
      final exception = CacheException.readError();
      final failure = AppFailure.fromException(exception);

      expect(failure, isA<CacheFailure>());
      expect(failure.code, 'CACHE_READ_ERROR');
    });

    test('ParseException → ParseFailure dönüşümü doğru olmalı', () {
      final exception = ParseException.rssError();
      final failure = AppFailure.fromException(exception);

      expect(failure, isA<ParseFailure>());
      expect(failure.code, 'RSS_PARSE_ERROR');
    });

    test('ServerException → ServerFailure dönüşümü doğru olmalı', () {
      final exception = ServerException.internalError();
      final failure = AppFailure.fromException(exception);

      expect(failure, isA<ServerFailure>());
    });

    test('AuthException → ServerFailure dönüşümü doğru olmalı', () {
      final exception = AuthException.unauthorized();
      final failure = AppFailure.fromException(exception);

      expect(failure, isA<ServerFailure>());
      expect(failure.code, 'UNAUTHORIZED');
    });

    test('RateLimitException → ServerFailure dönüşümü doğru olmalı', () {
      final exception = RateLimitException.tooManyRequests();
      final failure = AppFailure.fromException(exception);

      expect(failure, isA<ServerFailure>());
      expect(failure.code, 'TOO_MANY_REQUESTS');
    });

    test('bilinmeyen exception → UnexpectedFailure dönüşümü doğru olmalı', () {
      final exception = Exception('bilinmeyen hata');
      final failure = AppFailure.fromException(exception);

      expect(failure, isA<UnexpectedFailure>());
    });

    test('String hata → UnexpectedFailure dönüşümü doğru olmalı', () {
      final failure = AppFailure.fromException('string hata');

      expect(failure, isA<UnexpectedFailure>());
    });
  });

  group('AppFailure equality', () {
    test('aynı message ve code ile eşit olmalı', () {
      const failure1 = NetworkFailure('test', code: 'TEST');
      const failure2 = NetworkFailure('test', code: 'TEST');

      expect(failure1, equals(failure2));
    });

    test('farklı message ile eşit olmamalı', () {
      const failure1 = NetworkFailure('test1', code: 'TEST');
      const failure2 = NetworkFailure('test2', code: 'TEST');

      expect(failure1, isNot(equals(failure2)));
    });

    test('farklı code ile eşit olmamalı', () {
      const failure1 = NetworkFailure('test', code: 'CODE1');
      const failure2 = NetworkFailure('test', code: 'CODE2');

      expect(failure1, isNot(equals(failure2)));
    });

    test('hashCode aynı değerlerde eşit olmalı', () {
      const failure1 = NetworkFailure('test', code: 'TEST');
      const failure2 = NetworkFailure('test', code: 'TEST');

      expect(failure1.hashCode, failure2.hashCode);
    });
  });

  group('AppFailure toString()', () {
    test('code varsa parantez içinde göstermeli', () {
      final failure = NetworkFailure.noInternet();

      expect(failure.toString(), contains('NetworkFailure'));
      expect(failure.toString(), contains('NO_INTERNET'));
    });

    test('code yoksa parantez olmamalı', () {
      const failure = NetworkFailure('Basit hata');

      expect(failure.toString(), 'NetworkFailure: Basit hata');
    });
  });
}