import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/notification_banner_provider.dart';
import '../../../providers/news_provider.dart' show newsProvider, NewsState;
import '../../../providers/theme_provider.dart';
import '../../../themes/app_theme.dart';
import '../../article_detail/article_detail_page.dart';

/// Üst çubuk bildirim banner'ı
/// RSS haberlerinden son haberler ve uygulama içi bildirimleri gösterir
class NotificationBanner extends ConsumerStatefulWidget {
  const NotificationBanner({super.key});

  @override
  ConsumerState<NotificationBanner> createState() => _NotificationBannerState();
}

class _NotificationBannerState extends ConsumerState<NotificationBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _marqueeController;
  int _currentIndex = 0;
  bool _isPaused = false;
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    _marqueeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }
  
  void _startAutoScroll(int itemsLength) {
    _autoScrollTimer?.cancel();
    if (itemsLength > 1 && !_isPaused) {
      _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
        if (mounted && !_isPaused) {
          _nextItem(itemsLength);
        } else {
          timer.cancel();
        }
      });
    }
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // News provider'dan haberler yüklendiğinde banner'ı güncelle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final newsState = ref.read(newsProvider);
      if (newsState.allArticles.isNotEmpty) {
        ref.read(notificationBannerProvider.notifier).updateFromNewsProvider(newsState.allArticles);
      }
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _marqueeController.dispose();
    super.dispose();
  }
  
  void _nextItem(int itemsLength) {
    if (itemsLength == 0) return;
    setState(() {
      _currentIndex = (_currentIndex + 1) % itemsLength;
    });
    _marqueeController.reset();
    _marqueeController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final bannerState = ref.watch(notificationBannerProvider);
    final items = bannerState.allItems;
    
    // News provider'dan haberler yüklendiğinde banner'ı otomatik güncelle
    // ref.listen ile değişiklikleri yakala
    ref.listen<NewsState>(newsProvider, (previous, next) {
      // Haberler yüklendiğinde veya güncellendiğinde banner'ı güncelle
      if (next.allArticles.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(notificationBannerProvider.notifier).updateFromNewsProvider(next.allArticles);
        });
      }
    });

    // Loading durumunda veya boşsa banner'ı göster ama loading indicator ile
    if (bannerState.isLoading && items.isEmpty) {
      final colorTheme = ref.watch(colorThemeProvider);
      final primaryColor = AppTheme.getPrimaryColor(colorTheme);
      
      return Container(
        height: 48,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark 
              ? AppTheme.matBlackSurfaceVariant 
              : primaryColor.withValues(alpha: 0.1),
          border: Border(
            bottom: BorderSide(
              color: primaryColor.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  'Haberler yükleniyor...',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: primaryColor.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorTheme = ref.watch(colorThemeProvider);
    final primaryColor = AppTheme.getPrimaryColor(colorTheme);

    // Otomatik geçiş timer'ını başlat
    if (items.length > 1) {
      _startAutoScroll(items.length);
    }

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [
                      AppTheme.matBlackSurface.withValues(alpha: 0.85),
                      AppTheme.matBlackSurfaceVariant.withValues(alpha: 0.85),
                      AppTheme.matBlackSurface.withValues(alpha: 0.85),
                    ]
                  : [
                      primaryColor.withValues(alpha: 0.20),
                      primaryColor.withValues(alpha: 0.12),
                      primaryColor.withValues(alpha: 0.20),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border(
              top: BorderSide(
                color: primaryColor.withValues(alpha: 0.3),
                width: 2,
              ),
              bottom: BorderSide(
                color: primaryColor.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Bildirim ikonu - Animasyonlu
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Pulse efekti
                    AnimatedBuilder(
                      animation: _marqueeController,
                      builder: (context, child) {
                        return Container(
                          width: 32 + (_marqueeController.value * 8),
                          height: 32 + (_marqueeController.value * 8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: primaryColor.withValues(alpha: 0.2 - (_marqueeController.value * 0.2)),
                          ),
                        );
                      },
                    ),
                    // Icon
                    Icon(
                      Icons.article_rounded,
                      size: 22,
                      color: primaryColor,
                    ),
                  ],
                ),
              ),
              
              // Ana içerik - Marquee efekti
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (items.isNotEmpty && items[_currentIndex].isArticle && items[_currentIndex].article != null) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ArticleDetailPage(article: items[_currentIndex].article!),
                        ),
                      );
                    }
                  },
                  onLongPress: () {
                    setState(() {
                      _isPaused = !_isPaused;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        // Haber başlığı - Marquee animasyonu
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 500),
                            transitionBuilder: (child, animation) {
                              return SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(1.0, 0.0),
                                  end: Offset.zero,
                                ).animate(CurvedAnimation(
                                  parent: animation,
                                  curve: Curves.easeInOut,
                                )),
                                child: FadeTransition(
                                  opacity: animation,
                                  child: child,
                                ),
                              );
                            },
                            child: Text(
                              items.isNotEmpty ? items[_currentIndex].title : '',
                              key: ValueKey(_currentIndex),
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w800, // Daha bold için okunabilirlik
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.95)
                                    : AppTheme.getPrimaryDarkColor(colorTheme).withValues(alpha: 0.9),
                                letterSpacing: 0.3,
                                height: 1.3,
                                shadows: isDark
                                    ? null
                                    : [
                                        Shadow(
                                          offset: const Offset(0.5, 0.5),
                                          blurRadius: 1.0,
                                          color: Colors.white.withValues(alpha: 0.5),
                                        ),
                                      ],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        
                        // Ok ikonu
                        if (items.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(left: 12),
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color: primaryColor,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Duraklat/Devam butonu
              if (items.length > 1)
                IconButton(
                  icon: Icon(
                    _isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                    size: 18,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPaused = !_isPaused;
                      if (!_isPaused) {
                        _startAutoScroll(items.length);
                      } else {
                        _autoScrollTimer?.cancel();
                      }
                    });
                  },
                  color: primaryColor.withValues(alpha: 0.8),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: _isPaused ? 'Devam Et' : 'Duraklat',
                ),
            ],
          ),
        ),
      ),
    );
  }

}

