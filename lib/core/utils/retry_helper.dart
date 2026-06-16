import 'dart:async';

import 'package:flutter/foundation.dart';
/// Retry helper - işlemleri otomatik olarak tekrar dener
class RetryHelper {
  /// Exponential backoff ile retry yapar
  /// 
  /// [operation]: Tekrar denenecek işlem
  /// [maxAttempts]: Maksimum deneme sayısı (default: 3)
  /// [initialDelay]: İlk bekleme süresi (default: 1 saniye)
  /// [maxDelay]: Maksimum bekleme süresi (default: 10 saniye)
  /// [onRetry]: Her retry'dan önce çağrılan callback (opsiyonel)
  static Future<T> retry<T>({
    required Future<T> Function() operation,
    int maxAttempts = 3,
    Duration initialDelay = const Duration(seconds: 1),
    Duration maxDelay = const Duration(seconds: 10),
    void Function(int attempt, Exception error)? onRetry,
    bool Function(Exception error)? shouldRetry,
  }) async {
    int attempt = 0;
    Duration delay = initialDelay;
    
    while (true) {
      attempt++;
      
      try {
        return await operation();
      } catch (e) {
        final exception = e is Exception ? e : Exception(e.toString());
        
        // Son deneme ise hata fırlat
        if (attempt >= maxAttempts) {
          debugPrint('❌ Retry başarısız ($attempt/$maxAttempts): $e');
          rethrow;
        }
        
        // Retry yapılıp yapılmayacağını kontrol et
        if (shouldRetry != null && !shouldRetry(exception)) {
          debugPrint('❌ Retry yapılmayacak hata: $e');
          rethrow;
        }
        
        // Callback çağır
        if (onRetry != null) {
          onRetry(attempt, exception);
        }
        
        debugPrint('⚠️ Retry deneniyor ($attempt/$maxAttempts) - $delay bekleniyor: $e');
        
        // Exponential backoff ile bekle
        await Future.delayed(delay);
        
        // Bir sonraki delay'i hesapla (2x artır ama maxDelay'i geçme)
        delay = Duration(
          milliseconds: (delay.inMilliseconds * 2).clamp(
            initialDelay.inMilliseconds,
            maxDelay.inMilliseconds,
          ),
        );
      }
    }
  }
  
  /// Belirli hata tiplerini retry etmemek için kontrol fonksiyonu
  static bool shouldRetryError(Exception error) {
    final errorMessage = error.toString().toLowerCase();
    
    // Parse hataları retry edilmemeli (zaten başarısız olacak)
    if (errorMessage.contains('parse') || 
        errorMessage.contains('xml') ||
        errorMessage.contains('format')) {
      return false;
    }
    
    // 404 hataları retry edilmemeli (kaynak yok)
    if (errorMessage.contains('404') || errorMessage.contains('not found')) {
      return false;
    }
    
    // 401/403 hataları retry edilmemeli (yetki hatası)
    if (errorMessage.contains('401') || 
        errorMessage.contains('403') ||
        errorMessage.contains('unauthorized') ||
        errorMessage.contains('forbidden')) {
      return false;
    }
    
    // Timeout, network, 500 hataları retry edilebilir
    return true;
  }
  
  /// Paralel işlemler için retry wrapper
  static Future<T?> retryOrNull<T>({
    required Future<T> Function() operation,
    int maxAttempts = 3,
    Duration initialDelay = const Duration(seconds: 1),
    Duration maxDelay = const Duration(seconds: 10),
  }) async {
    try {
      return await retry(
        operation: operation,
        maxAttempts: maxAttempts,
        initialDelay: initialDelay,
        maxDelay: maxDelay,
        shouldRetry: shouldRetryError,
      );
    } catch (e) {
      debugPrint('⚠️ İşlem başarısız, null döndürülüyor: $e');
      return null;
    }
  }
}