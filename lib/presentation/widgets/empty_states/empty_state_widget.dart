import 'package:flutter/material.dart';
import '../../themes/app_theme.dart';
import '../common/custom_buttons.dart';

/// Empty state türleri
enum EmptyStateType {
  noArticles,
  noFavorites,
  noBookmarks,
  noSearchResults,
  noNotifications,
  offline,
  error,
  custom,
}

/// Genel Empty State Widget - Tüm boş durumlar için kullanılabilir
class EmptyStateWidget extends StatefulWidget {
  final EmptyStateType type;
  final String? title;
  final String? description;
  final IconData? icon;
  final String? actionText;
  final VoidCallback? onAction;
  final String? secondaryActionText;
  final VoidCallback? onSecondaryAction;
  final Widget? customIllustration;
  final bool showAnimation;

  const EmptyStateWidget({
    super.key,
    this.type = EmptyStateType.custom,
    this.title,
    this.description,
    this.icon,
    this.actionText,
    this.onAction,
    this.secondaryActionText,
    this.onSecondaryAction,
    this.customIllustration,
    this.showAnimation = true,
  });

  @override
  State<EmptyStateWidget> createState() => _EmptyStateWidgetState();
}

class _EmptyStateWidgetState extends State<EmptyStateWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.6, curve: Curves.elasticOut),
      ),
    );

    if (widget.showAnimation) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _EmptyStateData _getDataForType() {
    switch (widget.type) {
      case EmptyStateType.noArticles:
        return _EmptyStateData(
          icon: Icons.article_outlined,
          title: 'Henüz haber yok',
          description: 'Haberler yüklenirken bir sorun oluştu veya henüz haber bulunmuyor.',
          actionText: 'Yenile',
        );
      case EmptyStateType.noFavorites:
        return _EmptyStateData(
          icon: Icons.favorite_border_rounded,
          title: 'Favori haberiniz yok',
          description: 'Beğendiğiniz haberleri favorilere ekleyerek daha sonra kolayca ulaşabilirsiniz.',
          actionText: 'Haberlere Göz At',
        );
      case EmptyStateType.noBookmarks:
        return _EmptyStateData(
          icon: Icons.bookmark_border_rounded,
          title: 'Okuma listeniz boş',
          description: 'Daha sonra okumak istediğiniz haberleri okuma listesine ekleyin.',
          actionText: 'Haberlere Göz At',
        );
      case EmptyStateType.noSearchResults:
        return _EmptyStateData(
          icon: Icons.search_off_rounded,
          title: 'Sonuç bulunamadı',
          description: 'Aramanızla eşleşen haber bulunamadı. Farklı anahtar kelimeler deneyin.',
          actionText: 'Aramayı Temizle',
        );
      case EmptyStateType.noNotifications:
        return _EmptyStateData(
          icon: Icons.notifications_off_outlined,
          title: 'Bildirim yok',
          description: 'Henüz bildiriminiz bulunmuyor. Yeni haberler geldiğinde burada göreceksiniz.',
        );
      case EmptyStateType.offline:
        return _EmptyStateData(
          icon: Icons.wifi_off_rounded,
          title: 'Çevrimdışısınız',
          description: 'İnternet bağlantınızı kontrol edin. Önbelleğe alınmış haberler gösteriliyor.',
          actionText: 'Tekrar Dene',
        );
      case EmptyStateType.error:
        return _EmptyStateData(
          icon: Icons.error_outline_rounded,
          title: 'Bir hata oluştu',
          description: 'Beklenmeyen bir hata oluştu. Lütfen tekrar deneyin.',
          actionText: 'Tekrar Dene',
        );
      case EmptyStateType.custom:
        return _EmptyStateData(
          icon: widget.icon ?? Icons.inbox_outlined,
          title: widget.title ?? 'Boş',
          description: widget.description,
          actionText: widget.actionText,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final data = _getDataForType();
    final effectiveTitle = widget.title ?? data.title;
    final effectiveDescription = widget.description ?? data.description;
    final effectiveIcon = widget.icon ?? data.icon;
    final effectiveActionText = widget.actionText ?? data.actionText;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: child,
          ),
        );
      },
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // İllüstrasyon veya ikon
              AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: child,
                  );
                },
                child: widget.customIllustration ??
                    _buildIconIllustration(context, effectiveIcon),
              ),

              const SizedBox(height: 32),

              // Başlık
              Text(
                effectiveTitle,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),

              if (effectiveDescription != null) ...[
                const SizedBox(height: 12),
                Text(
                  effectiveDescription,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],

              const SizedBox(height: 32),

              // Action butonları
              if (effectiveActionText != null && widget.onAction != null)
                PrimaryButton(
                  text: effectiveActionText,
                  onPressed: widget.onAction,
                  icon: _getActionIcon(),
                ),

              if (widget.secondaryActionText != null && widget.onSecondaryAction != null) ...[
                const SizedBox(height: 12),
                TertiaryButton(
                  text: widget.secondaryActionText!,
                  onPressed: widget.onSecondaryAction,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconIllustration(BuildContext context, IconData icon) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withOpacity(isDark ? 0.2 : 0.1),
            theme.colorScheme.primary.withOpacity(isDark ? 0.1 : 0.05),
          ],
        ),
        shape: BoxShape.circle,
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.2),
          width: 2,
        ),
      ),
      child: Icon(
        icon,
        size: 56,
        color: theme.colorScheme.primary.withOpacity(0.7),
      ),
    );
  }

  IconData? _getActionIcon() {
    switch (widget.type) {
      case EmptyStateType.noArticles:
      case EmptyStateType.offline:
      case EmptyStateType.error:
        return Icons.refresh_rounded;
      case EmptyStateType.noFavorites:
      case EmptyStateType.noBookmarks:
        return Icons.explore_rounded;
      case EmptyStateType.noSearchResults:
        return Icons.clear_rounded;
      default:
        return null;
    }
  }
}

class _EmptyStateData {
  final IconData icon;
  final String title;
  final String? description;
  final String? actionText;

  _EmptyStateData({
    required this.icon,
    required this.title,
    this.description,
    this.actionText,
  });
}

/// Haber yok durumu için özel widget
class NoArticlesEmptyState extends StatelessWidget {
  final VoidCallback? onRefresh;

  const NoArticlesEmptyState({super.key, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      type: EmptyStateType.noArticles,
      onAction: onRefresh,
    );
  }
}

/// Favori yok durumu için özel widget
class NoFavoritesEmptyState extends StatelessWidget {
  final VoidCallback? onExplore;

  const NoFavoritesEmptyState({super.key, this.onExplore});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      type: EmptyStateType.noFavorites,
      onAction: onExplore,
      customIllustration: _buildFavoriteIllustration(context),
    );
  }

  Widget _buildFavoriteIllustration(BuildContext context) {
    return SizedBox(
      width: 140,
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Arka plan dairesi
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.red.withOpacity(0.15),
                  Colors.pink.withOpacity(0.1),
                ],
              ),
              shape: BoxShape.circle,
            ),
          ),
          // Kalp ikonu
          Icon(
            Icons.favorite_rounded,
            size: 64,
            color: Colors.red.withOpacity(0.3),
          ),
          // Üst kalp
          Positioned(
            top: 20,
            right: 20,
            child: Icon(
              Icons.favorite_rounded,
              size: 24,
              color: Colors.red.withOpacity(0.5),
            ),
          ),
          // Alt kalp
          Positioned(
            bottom: 30,
            left: 15,
            child: Icon(
              Icons.favorite_rounded,
              size: 18,
              color: Colors.pink.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }
}

/// Arama sonucu yok durumu için özel widget
class NoSearchResultsEmptyState extends StatelessWidget {
  final String searchQuery;
  final VoidCallback? onClear;

  const NoSearchResultsEmptyState({
    super.key,
    required this.searchQuery,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      type: EmptyStateType.noSearchResults,
      description: '"$searchQuery" için sonuç bulunamadı. Farklı anahtar kelimeler deneyin.',
      onAction: onClear,
    );
  }
}

/// Çevrimdışı durumu için özel widget
class OfflineEmptyState extends StatelessWidget {
  final VoidCallback? onRetry;

  const OfflineEmptyState({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      type: EmptyStateType.offline,
      onAction: onRetry,
      customIllustration: _buildOfflineIllustration(context),
    );
  }

  Widget _buildOfflineIllustration(BuildContext context) {
    return SizedBox(
      width: 140,
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Arka plan
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.orange.withOpacity(0.15),
                  Colors.amber.withOpacity(0.1),
                ],
              ),
              shape: BoxShape.circle,
            ),
          ),
          // WiFi ikonu
          Icon(
            Icons.wifi_off_rounded,
            size: 56,
            color: Colors.orange.withOpacity(0.6),
          ),
          // Sinyal çizgileri
          Positioned(
            top: 25,
            child: Container(
              width: 40,
              height: 3,
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Hata durumu için özel widget
class ErrorEmptyState extends StatelessWidget {
  final String? errorMessage;
  final VoidCallback? onRetry;

  const ErrorEmptyState({
    super.key,
    this.errorMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      type: EmptyStateType.error,
      description: errorMessage ?? 'Beklenmeyen bir hata oluştu. Lütfen tekrar deneyin.',
      onAction: onRetry,
      customIllustration: _buildErrorIllustration(context),
    );
  }

  Widget _buildErrorIllustration(BuildContext context) {
    return SizedBox(
      width: 140,
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Arka plan
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.errorRed.withOpacity(0.15),
                  Colors.red.withOpacity(0.1),
                ],
              ),
              shape: BoxShape.circle,
            ),
          ),
          // Hata ikonu
          Icon(
            Icons.error_outline_rounded,
            size: 56,
            color: AppTheme.errorRed.withOpacity(0.7),
          ),
        ],
      ),
    );
  }
}

/// Okuma listesi boş durumu için özel widget
class NoBookmarksEmptyState extends StatelessWidget {
  final VoidCallback? onExplore;

  const NoBookmarksEmptyState({super.key, this.onExplore});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      type: EmptyStateType.noBookmarks,
      onAction: onExplore,
      customIllustration: _buildBookmarkIllustration(context),
    );
  }

  Widget _buildBookmarkIllustration(BuildContext context) {
    final theme = Theme.of(context);
    
    return SizedBox(
      width: 140,
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Arka plan
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary.withOpacity(0.15),
                  theme.colorScheme.secondary.withOpacity(0.1),
                ],
              ),
              shape: BoxShape.circle,
            ),
          ),
          // Bookmark ikonu
          Icon(
            Icons.bookmark_rounded,
            size: 56,
            color: theme.colorScheme.primary.withOpacity(0.5),
          ),
          // Küçük bookmark'lar
          Positioned(
            top: 25,
            right: 25,
            child: Icon(
              Icons.bookmark_rounded,
              size: 20,
              color: theme.colorScheme.primary.withOpacity(0.3),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 20,
            child: Icon(
              Icons.bookmark_border_rounded,
              size: 16,
              color: theme.colorScheme.primary.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bildirim yok durumu için özel widget
class NoNotificationsEmptyState extends StatelessWidget {
  const NoNotificationsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyStateWidget(
      type: EmptyStateType.noNotifications,
    );
  }
}