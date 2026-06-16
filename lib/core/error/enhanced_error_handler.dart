import 'package:flutter/material.dart';
import 'package:retry/retry.dart';
import 'dart:async';

/// Gelişmiş error handling ve retry mekanizması
class EnhancedErrorHandler {
  /// Retry options - exponential backoff
  static const RetryOptions defaultRetryOptions = RetryOptions(
    maxAttempts: 3,
    delayFactor: Duration(seconds: 2),
    randomizationFactor: 0.25,
    maxDelay: Duration(seconds: 30),
  );

  /// Retry with custom options
  static Future<T> retryWithOptions<T>({
    required Future<T> Function() operation,
    RetryOptions? options,
    bool Function(Exception)? retryIf,
    void Function(Exception)? onRetry,
  }) async {
    final retryOptions = options ?? defaultRetryOptions;
    
    return retryOptions.retry(
      operation,
      retryIf: retryIf ?? (e) => _shouldRetry(e),
      onRetry: (e) {
        debugPrint('🔄 Retry attempt after error: $e');
        onRetry?.call(e);
      },
    );
  }

  /// Network operation with retry
  static Future<T> retryNetworkOperation<T>({
    required Future<T> Function() operation,
    int maxAttempts = 3,
    Duration initialDelay = const Duration(seconds: 1),
  }) async {
    return retryWithOptions(
      operation: operation,
      options: RetryOptions(
        maxAttempts: maxAttempts,
        delayFactor: initialDelay,
      ),
      retryIf: (e) => _isNetworkError(e),
    );
  }

  /// Parse operation with retry
  static Future<T> retryParseOperation<T>({
    required Future<T> Function() operation,
    int maxAttempts = 2,
  }) async {
    return retryWithOptions(
      operation: operation,
      options: RetryOptions(
        maxAttempts: maxAttempts,
        delayFactor: const Duration(milliseconds: 500),
      ),
      retryIf: (e) => _isParseError(e),
    );
  }

  /// Timeout operation with retry
  static Future<T> retryWithTimeout<T>({
    required Future<T> Function() operation,
    Duration timeout = const Duration(seconds: 30),
    int maxAttempts = 3,
  }) async {
    return retryWithOptions(
      operation: () => operation().timeout(timeout),
      options: RetryOptions(
        maxAttempts: maxAttempts,
        delayFactor: const Duration(seconds: 2),
      ),
    );
  }

  /// Error recovery strategies
  static Future<T> withFallback<T>({
    required Future<T> Function() primary,
    required Future<T> Function() fallback,
    bool Function(Exception)? shouldFallback,
  }) async {
    try {
      return await primary();
    } catch (e) {
      if (e is Exception && (shouldFallback?.call(e) ?? true)) {
        debugPrint('⚠️ Primary operation failed, using fallback: $e');
        return await fallback();
      }
      rethrow;
    }
  }

  /// Cache-first with network fallback
  static Future<T> cacheFirstWithNetworkFallback<T>({
    required Future<T?> Function() getFromCache,
    required Future<T> Function() getFromNetwork,
    required Future<void> Function(T data) saveToCache,
  }) async {
    try {
      // Try cache first
      final cachedData = await getFromCache();
      if (cachedData != null) {
        debugPrint('✅ Data loaded from cache');
        
        // Refresh in background
        getFromNetwork().then((networkData) {
          saveToCache(networkData);
          debugPrint('🔄 Cache updated in background');
        }).catchError((e) {
          debugPrint('⚠️ Background refresh failed: $e');
        });
        
        return cachedData;
      }
    } catch (e) {
      debugPrint('⚠️ Cache read failed: $e');
    }

    // Fallback to network
    debugPrint('📡 Loading from network');
    final networkData = await retryNetworkOperation(
      operation: getFromNetwork,
    );
    
    // Save to cache
    try {
      await saveToCache(networkData);
      debugPrint('💾 Data saved to cache');
    } catch (e) {
      debugPrint('⚠️ Cache save failed: $e');
    }
    
    return networkData;
  }

  /// User-friendly error messages (Turkish)
  static String getUserFriendlyMessage(dynamic error) {
    if (error is TimeoutException) {
      return 'İşlem zaman aşımına uğradı. Lütfen tekrar deneyin.';
    }
    
    if (_isNetworkError(error)) {
      return 'İnternet bağlantısı yok. Lütfen bağlantınızı kontrol edin.';
    }
    
    if (_isParseError(error)) {
      return 'Veri işlenirken bir hata oluştu. Lütfen daha sonra tekrar deneyin.';
    }
    
    if (_isServerError(error)) {
      return 'Sunucu hatası. Lütfen daha sonra tekrar deneyin.';
    }
    
    return 'Bir hata oluştu. Lütfen tekrar deneyin.';
  }

  /// Show error dialog
  static Future<void> showErrorDialog(
    BuildContext context, {
    required String title,
    required String message,
    VoidCallback? onRetry,
    VoidCallback? onDismiss,
  }) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.red, size: 28),
            const SizedBox(width: 12),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          if (onDismiss != null)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onDismiss();
              },
              child: const Text('Kapat'),
            ),
          if (onRetry != null)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                onRetry();
              },
              child: const Text('Tekrar Dene'),
            ),
        ],
      ),
    );
  }

  /// Show error snackbar
  static void showErrorSnackbar(
    BuildContext context, {
    required String message,
    VoidCallback? onRetry,
    Duration duration = const Duration(seconds: 4),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        duration: duration,
        action: onRetry != null
            ? SnackBarAction(
                label: 'Tekrar Dene',
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
      ),
    );
  }

  // Private helper methods
  
  static bool _shouldRetry(Exception e) {
    return _isNetworkError(e) || _isTimeoutError(e);
  }

  static bool _isNetworkError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('socket') ||
        errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('failed host lookup');
  }

  static bool _isParseError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('format') ||
        errorString.contains('parse') ||
        errorString.contains('json') ||
        errorString.contains('xml');
  }

  static bool _isTimeoutError(dynamic error) {
    return error is TimeoutException ||
        error.toString().toLowerCase().contains('timeout');
  }

  static bool _isServerError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('500') ||
        errorString.contains('502') ||
        errorString.contains('503') ||
        errorString.contains('server error');
  }
}

/// Error recovery widget
class ErrorRecoveryWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final IconData icon;
  final String? retryButtonText;

  const ErrorRecoveryWidget({
    super.key,
    required this.message,
    required this.onRetry,
    this.icon = Icons.error_outline_rounded,
    this.retryButtonText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 24),
            Text(
              'Bir Hata Oluştu',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(retryButtonText ?? 'Tekrar Dene'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
