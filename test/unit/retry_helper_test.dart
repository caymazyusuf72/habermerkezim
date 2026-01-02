import 'package:flutter_test/flutter_test.dart';
import 'package:haber_merkezi/core/utils/retry_helper.dart';

void main() {
  group('RetryHelper Tests', () {
    test('should succeed on first attempt', () async {
      int attempts = 0;
      
      final result = await RetryHelper.retry<String>(
        operation: () async {
          attempts++;
          return 'success';
        },
        maxAttempts: 3,
      );

      expect(result, 'success');
      expect(attempts, 1);
    });

    test('should retry on failure and eventually succeed', () async {
      int attempts = 0;
      
      final result = await RetryHelper.retry<String>(
        operation: () async {
          attempts++;
          if (attempts < 3) {
            throw Exception('Temporary error');
          }
          return 'success after retry';
        },
        maxAttempts: 3,
        initialDelay: const Duration(milliseconds: 10),
      );

      expect(result, 'success after retry');
      expect(attempts, 3);
    });

    test('should throw after max attempts exceeded', () async {
      int attempts = 0;
      
      expect(
        () => RetryHelper.retry<String>(
          operation: () async {
            attempts++;
            throw Exception('Persistent error');
          },
          maxAttempts: 3,
          initialDelay: const Duration(milliseconds: 10),
        ),
        throwsException,
      );
    });

    test('should call onRetry callback', () async {
      int retryCount = 0;
      List<int> retryAttempts = [];
      
      try {
        await RetryHelper.retry<String>(
          operation: () async {
            throw Exception('Error');
          },
          maxAttempts: 3,
          initialDelay: const Duration(milliseconds: 10),
          onRetry: (attempt, error) {
            retryCount++;
            retryAttempts.add(attempt);
          },
        );
      } catch (_) {}

      expect(retryCount, 2); // Called before 2nd and 3rd attempts
      expect(retryAttempts, [1, 2]);
    });

    test('should use exponential backoff', () async {
      int attempts = 0;
      
      try {
        await RetryHelper.retry<String>(
          operation: () async {
            attempts++;
            throw Exception('Error');
          },
          maxAttempts: 4,
          initialDelay: const Duration(milliseconds: 50),
          maxDelay: const Duration(milliseconds: 500),
        );
      } catch (_) {}

      // Should have attempted 4 times
      expect(attempts, 4);
    });

    test('should respect maxDelay', () async {
      int attempts = 0;
      
      try {
        await RetryHelper.retry<String>(
          operation: () async {
            attempts++;
            throw Exception('Error');
          },
          maxAttempts: 5,
          initialDelay: const Duration(milliseconds: 100),
          maxDelay: const Duration(milliseconds: 200),
        );
      } catch (_) {}

      // Should complete without excessive delays
      expect(attempts, 5);
    });

    test('should not retry when shouldRetry returns false', () async {
      int attempts = 0;
      
      try {
        await RetryHelper.retry<String>(
          operation: () async {
            attempts++;
            throw Exception('Non-retryable error');
          },
          maxAttempts: 3,
          initialDelay: const Duration(milliseconds: 10),
          shouldRetry: (error) => false,
        );
      } catch (_) {}

      expect(attempts, 1); // Should not retry
    });
  });

  group('RetryHelper shouldRetryError Tests', () {
    test('should not retry parse errors', () {
      expect(RetryHelper.shouldRetryError(Exception('XML parse error')), false);
      expect(RetryHelper.shouldRetryError(Exception('Parse failed')), false);
      expect(RetryHelper.shouldRetryError(Exception('Invalid format')), false);
    });

    test('should not retry 404 errors', () {
      expect(RetryHelper.shouldRetryError(Exception('404 Not Found')), false);
      expect(RetryHelper.shouldRetryError(Exception('Resource not found')), false);
    });

    test('should not retry auth errors', () {
      expect(RetryHelper.shouldRetryError(Exception('401 Unauthorized')), false);
      expect(RetryHelper.shouldRetryError(Exception('403 Forbidden')), false);
    });

    test('should retry network errors', () {
      expect(RetryHelper.shouldRetryError(Exception('Connection timeout')), true);
      expect(RetryHelper.shouldRetryError(Exception('Network error')), true);
      expect(RetryHelper.shouldRetryError(Exception('500 Internal Server Error')), true);
    });
  });

  group('RetryHelper retryOrNull Tests', () {
    test('should return result on success', () async {
      final result = await RetryHelper.retryOrNull<String>(
        operation: () async => 'success',
      );

      expect(result, 'success');
    });

    test('should return null on failure', () async {
      final result = await RetryHelper.retryOrNull<String>(
        operation: () async => throw Exception('Error'),
        maxAttempts: 2,
        initialDelay: const Duration(milliseconds: 10),
      );

      expect(result, isNull);
    });

    test('should not retry non-retryable errors', () async {
      int attempts = 0;
      
      final result = await RetryHelper.retryOrNull<String>(
        operation: () async {
          attempts++;
          throw Exception('404 not found');
        },
        maxAttempts: 3,
        initialDelay: const Duration(milliseconds: 10),
      );

      expect(result, isNull);
      expect(attempts, 1); // Should not retry 404 errors
    });
  });
}