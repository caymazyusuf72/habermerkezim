import 'package:dio/dio.dart';
import 'package:xml/xml.dart';

/// RSS feed validasyon servisi
/// Kullanıcıların custom RSS feed eklerken feed'in geçerli olup olmadığını kontrol eder
class RssFeedValidator {
  final Dio _dio;
  
  RssFeedValidator(this._dio);
  
  /// RSS feed URL'sinin geçerli olup olmadığını kontrol et
  Future<RssFeedValidationResult> validateFeedUrl(String url) async {
    try {
      // URL format kontrolü
      final uri = Uri.tryParse(url);
      if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
        return RssFeedValidationResult.invalid('Geçersiz URL formatı');
      }
      
      // Sadece http ve https protokollerini kabul et
      if (uri.scheme != 'http' && uri.scheme != 'https') {
        return RssFeedValidationResult.invalid('Sadece HTTP ve HTTPS protokolleri desteklenir');
      }
      
      // Feed'i indir (timeout ile)
      final response = await _dio.get(
        url,
        options: Options(
          responseType: ResponseType.plain,
          followRedirects: true,
          validateStatus: (status) => status != null && status < 500,
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 10),
        ),
      );
      
      // HTTP status kontrolü
      if (response.statusCode != 200) {
        return RssFeedValidationResult.invalid(
          'HTTP hatası: ${response.statusCode} ${response.statusMessage}',
        );
      }
      
      // Boş içerik kontrolü
      if (response.data == null || response.data.toString().isEmpty) {
        return RssFeedValidationResult.invalid('Feed içeriği boş');
      }
      
      // XML parse kontrolü
      final XmlDocument document;
      try {
        document = XmlDocument.parse(response.data.toString());
      } catch (e) {
        return RssFeedValidationResult.invalid('Geçersiz XML formatı: $e');
      }
      
      // RSS veya Atom feed mi kontrol et
      final isRss = document.findElements('rss').isNotEmpty;
      final isAtom = document.findElements('feed').isNotEmpty;
      
      if (!isRss && !isAtom) {
        return RssFeedValidationResult.invalid('Geçerli bir RSS/Atom feed değil');
      }
      
      // Feed bilgilerini çıkar
      String? title;
      String? description;
      int itemCount = 0;
      
      if (isRss) {
        final channel = document.findAllElements('channel').firstOrNull;
        if (channel == null) {
          return RssFeedValidationResult.invalid('RSS feed channel bilgisi bulunamadı');
        }
        
        title = channel.findElements('title').firstOrNull?.innerText;
        description = channel.findElements('description').firstOrNull?.innerText;
        itemCount = channel.findElements('item').length;
      } else {
        // Atom feed
        title = document.findAllElements('title').firstOrNull?.innerText;
        description = document.findAllElements('subtitle').firstOrNull?.innerText;
        itemCount = document.findAllElements('entry').length;
      }
      
      // Başlık zorunlu
      if (title == null || title.trim().isEmpty) {
        return RssFeedValidationResult.invalid('Feed başlığı bulunamadı');
      }
      
      // En az bir makale olmalı
      if (itemCount == 0) {
        return RssFeedValidationResult.invalid('Feed\'de hiç makale bulunamadı');
      }
      
      return RssFeedValidationResult.valid(
        title: title.trim(),
        description: description?.trim(),
        feedType: isRss ? 'RSS' : 'Atom',
        itemCount: itemCount,
      );
      
    } on DioException catch (e) {
      String errorMessage;
      if (e.type == DioExceptionType.connectionTimeout || 
          e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Bağlantı zaman aşımı';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'Bağlantı hatası: İnternet bağlantınızı kontrol edin';
      } else if (e.type == DioExceptionType.badResponse) {
        errorMessage = 'Sunucu hatası: ${e.response?.statusCode}';
      } else {
        errorMessage = 'Bağlantı hatası: ${e.message}';
      }
      return RssFeedValidationResult.invalid(errorMessage);
    } catch (e) {
      return RssFeedValidationResult.invalid('Beklenmeyen hata: $e');
    }
  }
}

/// RSS feed validasyon sonucu
class RssFeedValidationResult {
  final bool isValid;
  final String? errorMessage;
  final String? title;
  final String? description;
  final String? feedType;
  final int? itemCount;
  
  RssFeedValidationResult.valid({
    required this.title,
    this.description,
    this.feedType,
    this.itemCount,
  })  : isValid = true,
        errorMessage = null;
        
  RssFeedValidationResult.invalid(this.errorMessage)
      : isValid = false,
        title = null,
        description = null,
        feedType = null,
        itemCount = null;
}