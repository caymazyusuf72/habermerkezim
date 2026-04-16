import 'package:flutter_test/flutter_test.dart';
import 'package:haber_merkezi/core/services/logger_service.dart';

void main() {
  late LoggerService logger;

  setUp(() {
    logger = LoggerService();
    // Test başlangıcında geçmişi temizle
    logger.clearHistory();
    // Debug modda tüm logları görelim
    logger.setMinLevel(LogLevel.debug);
  });

  tearDown(() {
    logger.clearHistory();
  });

  group('LoggerService - Log Seviyeleri', () {
    test('debug log kaydedilmeli', () {
      // Act
      logger.debug('Test debug mesajı', tag: 'TEST');

      // Assert
      final history = logger.getHistory();
      expect(history, isNotEmpty);
      expect(history.last.level, LogLevel.debug);
      expect(history.last.message, 'Test debug mesajı');
      expect(history.last.tag, 'TEST');
    });

    test('info log kaydedilmeli', () {
      // Act
      logger.info('Test info mesajı');

      // Assert
      final history = logger.getHistory();
      expect(history, isNotEmpty);
      expect(history.last.level, LogLevel.info);
      expect(history.last.message, 'Test info mesajı');
    });

    test('warning log kaydedilmeli', () {
      // Act
      logger.warning('Test uyarı mesajı', tag: 'WARN');

      // Assert
      final history = logger.getHistory();
      expect(history, isNotEmpty);
      expect(history.last.level, LogLevel.warning);
    });

    test('error log hata bilgisi ile kaydedilmeli', () {
      // Arrange
      final error = Exception('test hatası');

      // Act
      logger.error('Test error mesajı', error: error, tag: 'ERR');

      // Assert
      final history = logger.getHistory();
      expect(history, isNotEmpty);
      expect(history.last.level, LogLevel.error);
      expect(history.last.error, error);
    });

    test('critical log kaydedilmeli', () {
      // Act
      logger.critical('Kritik hata', tag: 'CRITICAL');

      // Assert
      final history = logger.getHistory();
      expect(history, isNotEmpty);
      expect(history.last.level, LogLevel.critical);
    });

    test('network log kaydedilmeli', () {
      // Act
      logger.network('API çağrısı yapıldı');

      // Assert
      final history = logger.getHistory();
      expect(history, isNotEmpty);
      expect(history.last.level, LogLevel.info);
    });

    test('performance log kaydedilmeli', () {
      // Act
      logger.performance('Sayfa 200ms yüklendi');

      // Assert
      final history = logger.getHistory();
      expect(history, isNotEmpty);
      expect(history.last.level, LogLevel.info);
    });

    test('success log kaydedilmeli', () {
      // Act
      logger.success('İşlem başarılı');

      // Assert
      final history = logger.getHistory();
      expect(history, isNotEmpty);
      expect(history.last.level, LogLevel.info);
    });
  });

  group('LoggerService - Log Geçmişi', () {
    test('log geçmişi kaydedilmeli', () {
      // Act
      logger.info('Mesaj 1');
      logger.info('Mesaj 2');
      logger.info('Mesaj 3');

      // Assert
      final history = logger.getHistory();
      expect(history, hasLength(3));
    });

    test('log geçmişi temizlenebilmeli', () {
      // Arrange
      logger.info('Mesaj 1');
      logger.info('Mesaj 2');

      // Act
      logger.clearHistory();

      // Assert
      final history = logger.getHistory();
      expect(history, isEmpty);
    });

    test('log geçmişi unmodifiable olmalı', () {
      // Arrange
      logger.info('Mesaj');

      // Act & Assert
      final history = logger.getHistory();
      expect(() => (history as List).add('test'), throwsUnsupportedError);
    });
  });

  group('LoggerService - Minimum Seviye', () {
    test('minimum seviye altındaki loglar kaydedilmemeli', () {
      // Arrange
      logger.setMinLevel(LogLevel.warning);
      logger.clearHistory();

      // Act
      logger.debug('Bu gösterilmemeli');
      logger.info('Bu da gösterilmemeli');
      logger.warning('Bu gösterilmeli');

      // Assert
      final history = logger.getHistory();
      expect(history, hasLength(1));
      expect(history.first.level, LogLevel.warning);
    });

    test('minimum seviye değiştirilebilmeli', () {
      // Arrange
      logger.setMinLevel(LogLevel.error);
      logger.clearHistory();

      // Act
      logger.warning('Uyarı - gösterilmemeli');
      logger.error('Hata - gösterilmeli');

      // Assert
      final history = logger.getHistory();
      expect(history, hasLength(1));
      expect(history.first.level, LogLevel.error);
    });
  });

  group('LogLevel', () {
    test('her seviyenin ikonu olmalı', () {
      expect(LogLevel.debug.icon, '🔍');
      expect(LogLevel.info.icon, 'ℹ️');
      expect(LogLevel.warning.icon, '⚠️');
      expect(LogLevel.error.icon, '❌');
      expect(LogLevel.critical.icon, '🔥');
    });

    test('her seviyenin etiketi olmalı', () {
      expect(LogLevel.debug.label, 'DEBUG');
      expect(LogLevel.info.label, 'INFO');
      expect(LogLevel.warning.label, 'WARNING');
      expect(LogLevel.error.label, 'ERROR');
      expect(LogLevel.critical.label, 'CRITICAL');
    });

    test('seviye sıralaması doğru olmalı', () {
      expect(LogLevel.debug.index, lessThan(LogLevel.info.index));
      expect(LogLevel.info.index, lessThan(LogLevel.warning.index));
      expect(LogLevel.warning.index, lessThan(LogLevel.error.index));
      expect(LogLevel.error.index, lessThan(LogLevel.critical.index));
    });
  });

  group('LogEntry', () {
    test('toString doğru format döndürmeli', () {
      // Arrange
      final entry = LogEntry(
        level: LogLevel.info,
        message: 'Test mesajı',
        tag: 'TEST',
        timestamp: DateTime(2026, 1, 15, 10, 30),
      );

      // Act
      final result = entry.toString();

      // Assert
      expect(result, contains('ℹ️'));
      expect(result, contains('Test mesajı'));
      expect(result, contains('[TEST]'));
    });

    test('tag olmadan toString çalışmalı', () {
      // Arrange
      final entry = LogEntry(
        level: LogLevel.debug,
        message: 'Tagsız mesaj',
        timestamp: DateTime(2026, 1, 15),
      );

      // Act
      final result = entry.toString();

      // Assert
      expect(result, contains('Tagsız mesaj'));
      expect(result, isNot(contains('[')));
    });
  });
}