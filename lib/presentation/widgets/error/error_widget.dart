import 'package:flutter/material.dart';

import '../../../core/error/failures.dart';
import '../../../core/utils/error_message_helper.dart';
import '../../themes/app_theme.dart';

/// Custom error widget - hataları kullanıcı dostu şekilde gösterir
/// Farklı hata tiplerini farklı görsellerle sunar
class CustomErrorWidget extends StatelessWidget {
  final dynamic error;  // Failure veya Exception kabul eder
  final VoidCallback? onRetry;
  final bool showOfflineMessage;
  final bool isCompact;
  final String? customMessage;

  const CustomErrorWidget({
    super.key,
    required this.error,
    this.onRetry,
    this.showOfflineMessage = false,
    this.isCompact = false,
    this.customMessage,
  });

  @override
  Widget build(BuildContext context) {
    return isCompact ? _buildCompactError(context) : _buildFullError(context);
  }

  /// Tam boyutlu hata gösterimi
  Widget _buildFullError(BuildContext context) {
    final theme = Theme.of(context);
    final errorInfo = _getErrorInfo();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Hata ikonu
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: errorInfo.color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                errorInfo.icon,
                size: 40,
                color: errorInfo.color,
              ),
            ),

            const SizedBox(height: 24),

            // Başlık
            Text(
              errorInfo.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // Açıklama
            Text(
              customMessage ?? _getErrorMessage(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            
            // Önerilen aksiyon
            if (_getSuggestedAction() != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _getSuggestedAction()!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Offline mesajı
            if (showOfflineMessage) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.wifi_off,
                      color: Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Offline moddasınız',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Yeniden dene butonu (sadece retry edilebilir hatalar için)
            if (onRetry != null && _isRetryable())
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: Icon(errorInfo.retryIcon),
                  label: Text(errorInfo.retryText),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: errorInfo.color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Kompakt hata gösterimi
  Widget _buildCompactError(BuildContext context) {
    final theme = Theme.of(context);
    final errorInfo = _getErrorInfo();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: errorInfo.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: errorInfo.color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            errorInfo.icon,
            color: errorInfo.color,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  errorInfo.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: errorInfo.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getErrorMessage(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: errorInfo.color.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              child: Text(
                'Yenile',
                style: TextStyle(color: errorInfo.color),
              ),
            ),
        ],
      ),
    );
  }

  /// Hata bilgilerini döner
  ErrorInfo _getErrorInfo() {
    if (error is NetworkFailure) {
      final networkError = error as NetworkFailure;
      
      if (networkError.code == 'NO_INTERNET') {
        return ErrorInfo(
          icon: Icons.wifi_off,
          color: Colors.orange,
          title: 'İnternet Bağlantısı Yok',
          retryIcon: Icons.wifi,
          retryText: 'Bağlantıyı Kontrol Et',
        );
      } else if (networkError.code == 'TIMEOUT') {
        return ErrorInfo(
          icon: Icons.timer_off,
          color: Colors.red,
          title: 'Zaman Aşımı',
          retryIcon: Icons.refresh,
          retryText: 'Yeniden Dene',
        );
      } else {
        return ErrorInfo(
          icon: Icons.cloud_off,
          color: Colors.red,
          title: 'Bağlantı Hatası',
          retryIcon: Icons.refresh,
          retryText: 'Yeniden Dene',
        );
      }
    } else if (error is RssParseFailure) {
      return ErrorInfo(
        icon: Icons.rss_feed,
        color: Colors.amber,
        title: 'RSS Hatası',
        retryIcon: Icons.sync,
        retryText: 'Yeniden Yükle',
      );
    } else if (error is CacheFailure) {
      return ErrorInfo(
        icon: Icons.storage,
        color: Colors.blue,
        title: 'Önbellek Hatası',
        retryIcon: Icons.cached,
        retryText: 'Önbelleği Yenile',
      );
    } else {
      return ErrorInfo(
        icon: Icons.error_outline,
        color: Colors.grey,
        title: 'Beklenmeyen Hata',
        retryIcon: Icons.refresh,
        retryText: 'Yeniden Dene',
      );
    }
  }

  /// Kullanıcı dostu hata mesajı
  String _getErrorMessage() {
    // Failure nesnesi ise
    if (error is Failure) {
      if (error is NetworkFailure) {
        final networkError = error as NetworkFailure;
        
        switch (networkError.code) {
          case 'NO_INTERNET':
            return 'Lütfen internet bağlantınızı kontrol edin ve tekrar deneyin.';
          case 'TIMEOUT':
            return 'İstek çok uzun sürdü. Bağlantınızı kontrol edip tekrar deneyin.';
          case 'SERVER_ERROR':
            return 'Sunucu şu anda yanıt vermiyor. Lütfen daha sonra tekrar deneyin.';
          default:
            return 'Haberler yüklenirken bir sorun oluştu. Lütfen tekrar deneyin.';
        }
      } else if (error is RssParseFailure) {
        return 'Haber kaynağından veri alınırken sorun oluştu. Kaynak geçici olarak erişilemez olabilir.';
      } else if (error is CacheFailure) {
        return 'Önbelleğe alınmış veriler okurken sorun oluştu. Önbellek temizlenebilir.';
      } else {
        return (error as Failure).message;
      }
    }
    
    // Exception veya string ise ErrorMessageHelper kullan
    return ErrorMessageHelper.getErrorMessage(error);
  }
  
  /// Önerilen aksiyon mesajı
  String? _getSuggestedAction() {
    if (error is Failure) {
      return null; // Failure için önceden tanımlı mesajlar var
    }
    return ErrorMessageHelper.getSuggestedAction(error);
  }
  
  /// Hatanın retry edilebilir olup olmadığını kontrol eder
  bool _isRetryable() {
    if (error is Failure) {
      return error is NetworkFailure || error is RssParseFailure;
    }
    return ErrorMessageHelper.isRetryable(error);
  }
}

/// Error info model
class ErrorInfo {
  final IconData icon;
  final Color color;
  final String title;
  final IconData retryIcon;
  final String retryText;

  ErrorInfo({
    required this.icon,
    required this.color,
    required this.title,
    this.retryIcon = Icons.refresh,
    this.retryText = 'Yeniden Dene',
  });
}

/// No internet connection widget
class NoInternetWidget extends StatelessWidget {
  final VoidCallback? onRetry;

  const NoInternetWidget({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return CustomErrorWidget(
      error: const NetworkFailure('İnternet bağlantısı yok', code: 'NO_INTERNET'),
      onRetry: onRetry,
      showOfflineMessage: true,
    );
  }
}

/// Empty state widget
class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final VoidCallback? onAction;
  final String? actionText;

  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.onAction,
    this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // İkon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 24),

            // Başlık
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // Mesaj
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),

            // Action button
            if (onAction != null && actionText != null) ...[
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.refresh),
                label: Text(actionText!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Error snackbar helper
class ErrorSnackbarHelper {
  ErrorSnackbarHelper._();

  /// Hata snackbar'ı gösterir
  static void showError(BuildContext context, Failure error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              _getErrorIcon(error),
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(_getShortErrorMessage(error)),
            ),
          ],
        ),
        backgroundColor: _getErrorColor(error),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Tamam',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  static IconData _getErrorIcon(Failure error) {
    if (error is NetworkFailure) {
      return Icons.wifi_off;
    } else if (error is RssParseFailure) {
      return Icons.rss_feed;
    } else if (error is CacheFailure) {
      return Icons.storage;
    } else {
      return Icons.error_outline;
    }
  }

  static Color _getErrorColor(Failure error) {
    if (error is NetworkFailure) {
      return Colors.orange;
    } else if (error is RssParseFailure) {
      return Colors.amber;
    } else if (error is CacheFailure) {
      return Colors.blue;
    } else {
      return Colors.red;
    }
  }

  static String _getShortErrorMessage(Failure error) {
    if (error is NetworkFailure) {
      final networkError = error as NetworkFailure;
      switch (networkError.code) {
        case 'NO_INTERNET':
          return 'İnternet bağlantısı yok';
        case 'TIMEOUT':
          return 'Bağlantı zaman aşımına uğradı';
        default:
          return 'Bağlantı hatası';
      }
    } else if (error is RssParseFailure) {
      return 'Haber kaynağı hatası';
    } else if (error is CacheFailure) {
      return 'Önbellek hatası';
    } else {
      return error.message;
    }
  }
}