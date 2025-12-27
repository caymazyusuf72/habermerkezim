import '../error/exceptions.dart';

/// Kullanıcıya anlamlı hata mesajları sağlar
class ErrorMessageHelper {
  /// Exception'dan kullanıcı dostu mesaj oluşturur
  static String getErrorMessage(Object error) {
    // Exception tipine göre mesaj döndür
    if (error is TimeoutException) {
      return '⏱️ İstek zaman aşımına uğradı. Lütfen internet bağlantınızı kontrol edin.';
    }
    
    if (error is NoInternetException) {
      return '📡 İnternet bağlantısı yok. Lütfen bağlantınızı kontrol edin.';
    }
    
    if (error is NotFoundException) {
      return '🔍 İçerik bulunamadı. Kaynak geçici olarak erişilemeyebilir.';
    }
    
    if (error is ServerException) {
      if (error.statusCode == 500) {
        return '🔧 Sunucu hatası oluştu. Lütfen daha sonra tekrar deneyin.';
      }
      if (error.statusCode == 503) {
        return '⚠️ Hizmet geçici olarak kullanılamıyor. Lütfen daha sonra tekrar deneyin.';
      }
      return '❌ Sunucu hatası: ${error.message}';
    }
    
    if (error is RssParseException) {
      return '📰 Haber kaynağı yüklenirken hata oluştu. Farklı bir kategori deneyin.';
    }
    
    if (error is EmptyRssFeedException) {
      return '📭 Bu kategoride şu anda haber bulunmuyor.';
    }
    
    if (error is InvalidRssFeedException) {
      return '⚠️ Haber kaynağı formatı geçersiz. Kaynak güncelleniyor olabilir.';
    }
    
    if (error is NetworkException) {
      return '🌐 Ağ hatası oluştu. Lütfen internet bağlantınızı kontrol edin.';
    }
    
    if (error is CacheException) {
      return '💾 Önbellek hatası oluştu. Uygulama verilerini temizlemeyi deneyin.';
    }
    
    // Genel hata mesajı
    final errorStr = error.toString();
    
    // Timeout anahtar kelimeleri
    if (errorStr.toLowerCase().contains('timeout')) {
      return '⏱️ İstek zaman aşımına uğradı. Lütfen tekrar deneyin.';
    }
    
    // Network anahtar kelimeleri
    if (errorStr.toLowerCase().contains('network') || 
        errorStr.toLowerCase().contains('connection')) {
      return '📡 Bağlantı hatası oluştu. İnternet bağlantınızı kontrol edin.';
    }
    
    // Parse anahtar kelimeleri
    if (errorStr.toLowerCase().contains('parse') || 
        errorStr.toLowerCase().contains('xml') ||
        errorStr.toLowerCase().contains('format')) {
      return '📰 Haber içeriği işlenirken hata oluştu. Farklı bir kaynak deneyin.';
    }
    
    // 404 hataları
    if (errorStr.contains('404')) {
      return '🔍 İçerik bulunamadı. Kaynak artık mevcut olmayabilir.';
    }
    
    // 500 hataları
    if (errorStr.contains('500') || errorStr.contains('503')) {
      return '🔧 Sunucu hatası. Lütfen daha sonra tekrar deneyin.';
    }
    
    // Varsayılan mesaj
    return '❌ Bir hata oluştu. Lütfen daha sonra tekrar deneyin.';
  }
  
  /// Kısa hata mesajı (snackbar için)
  static String getShortErrorMessage(Object error) {
    if (error is TimeoutException) {
      return 'Zaman aşımı';
    }
    
    if (error is NoInternetException) {
      return 'İnternet bağlantısı yok';
    }
    
    if (error is NotFoundException) {
      return 'İçerik bulunamadı';
    }
    
    if (error is ServerException) {
      return 'Sunucu hatası';
    }
    
    if (error is RssParseException || error is EmptyRssFeedException) {
      return 'Haber yüklenemedi';
    }
    
    if (error is NetworkException) {
      return 'Ağ hatası';
    }
    
    if (error is CacheException) {
      return 'Önbellek hatası';
    }
    
    return 'Bir hata oluştu';
  }
  
  /// Hatanın retry edilebilir olup olmadığını kontrol eder
  static bool isRetryable(Object error) {
    // Retry edilebilir hatalar
    if (error is TimeoutException ||
        error is NoInternetException ||
        error is NetworkException ||
        error is ServerException) {
      return true;
    }
    
    final errorStr = error.toString().toLowerCase();
    
    if (errorStr.contains('timeout') ||
        errorStr.contains('network') ||
        errorStr.contains('connection') ||
        errorStr.contains('500') ||
        errorStr.contains('503')) {
      return true;
    }
    
    return false;
  }
  
  /// Hata için önerilen aksiyon mesajı
  static String? getSuggestedAction(Object error) {
    if (error is NoInternetException || error is NetworkException) {
      return 'İnternet bağlantınızı kontrol edin ve tekrar deneyin.';
    }
    
    if (error is TimeoutException) {
      return 'İnternet bağlantınız yavaş olabilir. Tekrar deneyin.';
    }
    
    if (error is ServerException) {
      return 'Kaynak geçici olarak erişilemeyebilir. Birkaç dakika sonra tekrar deneyin.';
    }
    
    if (error is EmptyRssFeedException) {
      return 'Farklı bir kategori deneyin veya sayfayı yenileyin.';
    }
    
    if (error is CacheException) {
      return 'Ayarlar > Önbelleği Temizle seçeneğini deneyin.';
    }
    
    return null;
  }
  
  /// Detaylı hata raporu (loglama için)
  static String getDetailedError(Object error, StackTrace? stackTrace) {
    final buffer = StringBuffer();
    
    buffer.writeln('=== ERROR DETAILS ===');
    buffer.writeln('Type: ${error.runtimeType}');
    buffer.writeln('Message: ${error.toString()}');
    
    if (error is ServerException) {
      buffer.writeln('Status Code: ${error.statusCode}');
    }
    
    if (stackTrace != null) {
      buffer.writeln('Stack Trace:');
      buffer.writeln(stackTrace.toString());
    }
    
    buffer.writeln('==================');
    
    return buffer.toString();
  }
}