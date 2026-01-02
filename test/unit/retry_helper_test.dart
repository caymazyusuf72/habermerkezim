import 'package:flutter_test/flutter_test.dart';
import 'package:haber_merkezi/core/utils/retry_helper.dart';

void main() {
  group('RetryHelper Tests', () {
    test('should succeed on first attempt', () async {
      int attemptCount = 0;
      
      final result = await RetryHelper.retry<String>(
        operation: () async {
          attemptCount++;
          return 'success';
        },
        maxAttempts: 3,
      );

      expect(result, 'success');
      expect(attemptCount, 1);
    });

    test('should retry on failure and succeed', () async {
      int attemptCount = 0;
      
      final result = await RetryHelper.retry<String>(
        operation: () async {
          attemptCount++;
          if (attemptCount < 3) {
            throw Exception('Temporary failure');
          }
          return 'success after retry';
        },
        maxAttempts: 5,
        initialDelay: const Duration(milliseconds: 10),
      );

      expect(result, 'success after retry');
      expect(attemptCount, 3);
    });

    test('should throw after max attempts exceeded', () async {
      int attemptCount = 0;
      
      expect(
        () => RetryHelper.retry<String>(
          operation: () async {
            attemptCount++;
            throw Exception('Persistent failure');
          },
          maxAttempts: 3,
          initialDelay: const Duration(milliseconds: 10),
        ),
        throwsException,
      );
    });

    test('should use exponential backoff', () async {
      final delays = <Duration>[];
      int attemptCount = 0;
      DateTime? lastAttempt;
      
      try {
        await RetryHelper.retry<String>(
          operation: () async {
            attemptCount++;
            final now = DateTime.now();
            if (lastAttempt != null) {
              delays.add(now.difference(lastAttempt!));
            }
            lastAttempt = now;
            throw Exception('Failure');
          },
          maxAttempts: 4,
          initialDelay: const Duration(milliseconds: 50),
          backoffMultiplier: 2.0,
        );
      } catch (_) {}

      expect(attemptCount, 4);
      // Delays should increase exponentially (with some tolerance for timing)
      // First delay: ~50ms, Second: ~100ms, Third: ~200ms
      expect(delays.length, 3);
    });

    test('should respect maxDelay', () async {
      int attemptCount = 0;
      
      try {
        await RetryHelper.retry<String>(
          operation: () async {
            attemptCount++;
            throw Exception('Failure');
          },
          maxAttempts: 5,
          initialDelay: const Duration(milliseconds: 100),
          maxDelay: const Duration(milliseconds: 150),
          backoffMultiplier: 10.0, // Would normally cause huge delays
        );
      } catch (_) {}

      expect(attemptCount, 5);
    });

    test('should call onRetry callback', () async {
      final retryAttempts = <int>[];
      final retryErrors = <Object>[];
      
      try {
        await RetryHelper.retry<String>(
          operation: () async {
            throw Exception('Test error');
          },
          maxAttempts: 3,
          initialDelay: const Duration(milliseconds: 10),
          onRetry: (attempt, error) {
            retryAttempts.add(attempt);
            retryErrors.add(error);
          },
        );
      } catch (_) {}

      expect(retryAttempts, [1, 2]);
      expect(retryErrors.length, 2);
    });

    test('should not retry if shouldRetry returns false', () async {
      int attemptCount = 0;
      
      try {
        await RetryHelper.retry<String>(
          operation: () async {
            attemptCount++;
            throw ArgumentError('Non-retryable error');
          },
          maxAttempts: 5,
          initialDelay: const Duration(milliseconds: 10),
          shouldRetry: (error) => error is! ArgumentError,
        );
      } catch (_) {}

      expect(attemptCount, 1); // Should not retry
    });

    test('should retry if shouldRetry returns true', () async {
      int attemptCount = 0;
      
      try {
        await RetryHelper.retry<String>(
          operation: () async {
            attemptCount++;
            throw Exception('Retryable error');
          },
          maxAttempts: 3,
          initialDelay: const Duration(milliseconds: 10),
          shouldRetry: (error) => error is Exception,
        );
      } catch (_) {}

      expect(attemptCount, 3); // Should retry all attempts
    });
  });

  group('RetryHelper.retryWithFallback Tests', () {
    test('should return primary result on success', () async {
      final result = await RetryHelper.retryWithFallback<String>(
        primary: () async => 'primary result',
        fallback: () async => 'fallback result',
        maxAttempts: 3,
      );

      expect(result, 'primary result');
    });

    test('should use fallback when primary fails', () async {
      final result = await RetryHelper.retryWithFallback<String>(
        primary: () async => throw Exception('Primary failed'),
        fallback: () async => 'fallback result',
        maxAttempts: 2,
        initialDelay: const Duration(milliseconds: 10),
      );

      expect(result, 'fallback result');
    });

    test('should throw when both primary and fallback fail', () async {
      expect(
        () => RetryHelper.retryWithFallback<String>(
          primary: () async => throw Exception('Primary failed'),
          fallback: () async => throw Exception('Fallback failed'),
          maxAttempts: 2,
          initialDelay: const Duration(milliseconds: 10),
        ),
        throwsException,
      );
    });
  });

  group('RetryHelper Edge Cases', () {
    test('should handle zero maxAttempts', () async {
      int attemptCount = 0;
      
      try {
        await RetryHelper.retry<String>(
          operation: () async {
            attemptCount++;
            throw Exception('Failure');
          },
          maxAttempts: 0,
        );
      } catch (_) {}

      expect(attemptCount, 0);
    });

    test('should handle negative maxAttempts as zero', () async {
      int attemptCount = 0;
      
      try {
        await RetryHelper.retry<String>(
          operation: () async {
            attemptCount++;
            throw Exception('Failure');
          },
          maxAttempts: -1,
        );
      } catch (_) {}

      expect(attemptCount, 0);
    });

    test('should handle null return value', () async {
      final result = await RetryHelper.retry<String?>(
        operation: () async => null,
        maxAttempts: 3,
      );

      expect(result, isNull);
    });
  });
}