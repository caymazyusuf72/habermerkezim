import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/notification_banner_provider.dart';
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
  late AnimationController _scrollController;
  late ScrollController _horizontalScrollController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    
    _horizontalScrollController = ScrollController();
    
    // Otomatik kaydırma
    _scrollController.addListener(_autoScroll);
  }

  void _autoScroll() {
    if (!_horizontalScrollController.hasClients) return;
    
    final maxScroll = _horizontalScrollController.position.maxScrollExtent;
    if (maxScroll > 0) {
      final offset = (_scrollController.value * maxScroll * 2) % maxScroll;
      _horizontalScrollController.jumpTo(offset);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bannerState = ref.watch(notificationBannerProvider);
    final items = bannerState.allItems;

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.matBlackSurfaceVariant : AppTheme.sageGreen.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.sageGreen.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Bildirim ikonu
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            child: Icon(
              Icons.notifications_active_rounded,
              size: 20,
              color: AppTheme.sageGreen,
            ),
          ),
          
          // Kaydırılabilir içerik
          Expanded(
            child: ListView.builder(
              controller: _horizontalScrollController,
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return _buildBannerItem(context, item, index == _currentIndex);
              },
            ),
          ),
          
          // Kapat butonu
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: () {
              // Banner'ı gizle (gelecekte state'e eklenebilir)
            },
            color: theme.colorScheme.onSurface.withOpacity(0.6),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerItem(BuildContext context, BannerItem item, bool isActive) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: () {
        if (item.isArticle && item.article != null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ArticleDetailPage(article: item.article!),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            // Başlık
            Flexible(
              child: Text(
                item.title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isActive 
                      ? AppTheme.sageGreen 
                      : theme.colorScheme.onSurface.withOpacity(0.8),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            
            const SizedBox(width: 8),
            
            // Alt başlık veya ikon
            if (item.isArticle)
              Icon(
                Icons.arrow_forward_ios,
                size: 12,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.sageGreen.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Yeni',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppTheme.sageGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

