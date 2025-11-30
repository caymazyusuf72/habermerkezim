import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

import '../../../domain/entities/article.dart';
import '../../providers/providers.dart';
import '../../providers/analytics_provider.dart';
import '../../providers/reading_list_provider.dart';
import '../../themes/app_theme.dart';
import 'widgets/image_gallery.dart';
import 'widgets/related_articles_section.dart';
import 'widgets/tts_controls.dart';
import '../../reading_mode/reading_mode_page.dart';

/// Haber detay sayfası - tek bir haberin ayrıntılı görünümü
/// Görsel, başlık, içerik, tarih, paylaşma ve kaynak görme özellikleri
class ArticleDetailPage extends ConsumerStatefulWidget {
  final Article article;

  const ArticleDetailPage({
    super.key,
    required this.article,
  });

  @override
  ConsumerState<ArticleDetailPage> createState() => _ArticleDetailPageState();
}

class _ArticleDetailPageState extends ConsumerState<ArticleDetailPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isImageExpanded = false;

  @override
  void initState() {
    super.initState();
    
    // Makaleyi okundu olarak işaretle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(newsProvider.notifier).markAsRead(widget.article.id);
      
      // Analytics kaydı - makale okundu
      ref.read(analyticsProvider.notifier).recordArticleRead(
        widget.article.category,
        widget.article.sourceName,
        timeSpent: 0, // Başlangıçta 0, gerçek süre daha sonra hesaplanabilir
      );
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryColor = AppTheme.getCategoryColor(widget.article.category);

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // App Bar (Collapsible)
          _buildSliverAppBar(context, categoryColor),
          
          // İçerik
          SliverToBoxAdapter(
            child: _buildContent(context, theme, categoryColor),
          ),
        ],
      ),
      
    );
  }

  /// Collapsible app bar
  Widget _buildSliverAppBar(BuildContext context, Color categoryColor) {
    return SliverAppBar(
      expandedHeight: widget.article.imageUrl != null ? 300 : 120,
      pinned: true,
      stretch: true,
      flexibleSpace: FlexibleSpaceBar(
        background: widget.article.imageUrl != null
            ? _buildHeaderImage(context)
            : _buildHeaderGradient(context, categoryColor),
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
        ],
      ),
      actions: [
        // Okuma listesi butonu
        Consumer(
          builder: (context, ref, child) {
            final isInReadingList = ref.watch(isInReadingListProvider(widget.article.id));
            return IconButton(
              onPressed: () {
                ref.read(readingListProvider.notifier).toggleReadingList(widget.article);
              },
              icon: Icon(
                isInReadingList ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              ),
              tooltip: isInReadingList ? 'Okuma listesinden çıkar' : 'Okuma listesine ekle',
            );
          },
        ),
        // Paylaş butonu
        IconButton(
          onPressed: () => _shareArticle(),
          icon: const Icon(Icons.share),
          tooltip: 'Paylaş',
        ),
        
        // Favori butonu
        Consumer(
          builder: (context, ref, child) {
            final newsState = ref.watch(newsProvider);
            final article = newsState.articles
                .where((a) => a.id == widget.article.id)
                .firstOrNull ?? widget.article;
            
            return IconButton(
              onPressed: () => _toggleFavorite(),
              icon: Icon(
                article.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: article.isFavorite ? Colors.red : null,
              ),
              tooltip: article.isFavorite ? 'Favorilerden Çıkar' : 'Favorilere Ekle',
            );
          },
        ),
        
        // Menü
        PopupMenuButton<String>(
          onSelected: _handleMenuSelection,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'copy_link',
              child: Row(
                children: [
                  Icon(Icons.copy),
                  SizedBox(width: 12),
                  Text('Bağlantıyı Kopyala'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'open_browser',
              child: Row(
                children: [
                  Icon(Icons.open_in_browser),
                  SizedBox(width: 12),
                  Text('Tarayıcıda Aç'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Header image
  Widget _buildHeaderImage(BuildContext context) {
    // Görselleri topla (ana görsel + content'ten çıkarılan görseller)
    final imageUrls = _extractImageUrls();
    
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            if (imageUrls.length > 1) {
              // Birden fazla görsel varsa galeri göster
              showDialog(
                context: context,
                barrierColor: Colors.black,
                builder: (context) => ImageGallery(
                  imageUrls: imageUrls,
                  initialIndex: 0,
                ),
              );
            } else {
              // Tek görsel varsa eski davranış
              _toggleImageExpansion();
            }
          },
          child: Hero(
            tag: 'article_image_${widget.article.id}',
            child: CachedNetworkImage(
              imageUrl: widget.article.imageUrl!,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Theme.of(context).colorScheme.surfaceVariant,
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                color: Theme.of(context).colorScheme.surfaceVariant,
                child: const Icon(Icons.image_not_supported, size: 48),
              ),
            ),
          ),
        ),
        
        // Galeri butonu (birden fazla görsel varsa)
        if (imageUrls.length > 1)
          Positioned(
            top: 16,
            right: 16,
            child: ImageGalleryButton(
              imageUrls: imageUrls,
              imageCount: imageUrls.length,
            ),
          ),
      ],
    );
  }
  
  /// Content'ten görsel URL'lerini çıkarır
  List<String> _extractImageUrls() {
    final imageUrls = <String>[];
    
    // Ana görseli ekle
    if (widget.article.imageUrl != null && widget.article.imageUrl!.isNotEmpty) {
      imageUrls.add(widget.article.imageUrl!);
    }
    
    // Content'ten img tag'lerini çıkar
    if (widget.article.content != null) {
      final content = widget.article.content!;
      final imgRegex = RegExp(r'<img[^>]+src=["\']([^"\']+)["\']', caseSensitive: false);
      final matches = imgRegex.allMatches(content);
      
      for (final match in matches) {
        final url = match.group(1);
        if (url != null && url.isNotEmpty && !imageUrls.contains(url)) {
          imageUrls.add(url);
        }
      }
    }
    
    return imageUrls;
  }

  /// Header gradient (görsel yoksa)
  Widget _buildHeaderGradient(BuildContext context, Color categoryColor) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            categoryColor.withOpacity(0.8),
            categoryColor.withOpacity(0.4),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.article,
          size: 48,
          color: Colors.white,
        ),
      ),
    );
  }

  /// Ana içerik
  Widget _buildContent(BuildContext context, ThemeData theme, Color categoryColor) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kategori badge
          _buildCategoryBadge(context, categoryColor),
          
          const SizedBox(height: 16),
          
          // Başlık
          Text(
            widget.article.title,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Meta bilgiler
          _buildMetaInfo(context, theme),
          
          const SizedBox(height: 24),
          
          // İçerik
          _buildArticleContent(context, theme),
          
          const SizedBox(height: 32),
          
          // Kaynak butonu
          _buildSourceButton(context, theme),
          
          const SizedBox(height: 24),
          
          // Alt eylem butonları (yukarı taşındı)
          _buildActionButtons(context, theme),
          
          const SizedBox(height: 32),
          
          // TTS Kontrolleri
          TtsControls(article: widget.article),
          
          const SizedBox(height: 32),
          
          // İlgili haberler bölümü
          RelatedArticlesSection(currentArticle: widget.article),
          
          const SizedBox(height: 32), // Alt padding
        ],
      ),
    );
  }

  /// Kategori badge
  Widget _buildCategoryBadge(BuildContext context, Color categoryColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: categoryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: categoryColor, width: 1.5),
      ),
      child: Text(
        widget.article.sourceName,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: categoryColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Meta bilgiler
  Widget _buildMetaInfo(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.access_time,
              size: 16,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                widget.article.formattedDateTime,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.visibility,
              size: 16,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            const SizedBox(width: 6),
            Text(
              'Okundu',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(width: 16),
            Icon(
              Icons.schedule,
              size: 16,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            const SizedBox(width: 6),
            Text(
              widget.article.timeAgo,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Makale içeriği
  Widget _buildArticleContent(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Açıklama/Özet
        if (widget.article.description.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Text(
              widget.article.description,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
                height: 1.6,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        
        const SizedBox(height: 20),
        
        // Ana içerik
        if (widget.article.content != null && widget.article.content!.isNotEmpty)
          Text(
            widget.article.content!,
            style: theme.textTheme.bodyLarge?.copyWith(
              height: 1.7,
              fontSize: 16,
            ),
          ),
      ],
    );
  }

  /// Kaynak butonu
  Widget _buildSourceButton(BuildContext context, ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _openInBrowser(),
        icon: const Icon(Icons.open_in_browser),
        label: const Text('Kaynağı Görüntüle'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(
            color: theme.colorScheme.primary,
            width: 2,
          ),
        ),
      ),
    );
  }

  /// Alt eylem butonları (içerik içinde, yukarı taşındı)
  Widget _buildActionButtons(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          // Okuma listesi butonu
          Consumer(
            builder: (context, ref, child) {
              final isInReadingList = ref.watch(isInReadingListProvider(widget.article.id));
              return Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ref.read(readingListProvider.notifier).toggleReadingList(widget.article);
                  },
                  icon: Icon(
                    isInReadingList ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                  ),
                  label: Text(isInReadingList ? 'Listeden Çıkar' : 'Listeye Ekle'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(width: 12),
          
          // Paylaş butonu
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _shareArticle(),
              icon: const Icon(Icons.share),
              label: const Text('Paylaş'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Tarayıcıda aç butonu
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _openInBrowser(),
              icon: const Icon(Icons.open_in_browser),
              label: const Text('Kaynağı Gör'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Okuma modu butonu (ayrı bir yerde gösterilebilir)
  Widget _buildReadingModeButton(BuildContext context, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ReadingModePage(article: widget.article),
            ),
          );
        },
        icon: const Icon(Icons.menu_book_rounded),
        label: const Text('Okuma Modu'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: AppTheme.primaryBlue,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  /// Makaleyi paylaş
  void _shareArticle() {
    final text = '${widget.article.title}\n\n${widget.article.link}';
    Share.share(text, subject: widget.article.title);
    
    // Analytics kaydı - paylaşım yapıldı
    ref.read(analyticsProvider.notifier).recordSharePerformed();
  }

  /// Favori durumunu toggle et
  void _toggleFavorite() {
    final wasAlreadyFavorite = ref.read(newsProvider).articles
        .where((a) => a.id == widget.article.id)
        .firstOrNull?.isFavorite ?? false;
        
    ref.read(newsProvider.notifier).toggleFavorite(widget.article.id);
    
    // Haptic feedback
    HapticFeedback.lightImpact();
    
    // Snackbar göster
    final isFavorite = ref.read(newsProvider).articles
        .where((a) => a.id == widget.article.id)
        .firstOrNull?.isFavorite ?? false;
    
    // Analytics kaydı - sadece favori eklendiğinde
    if (!wasAlreadyFavorite && isFavorite) {
      ref.read(analyticsProvider.notifier).recordFavoriteAdded();
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isFavorite
              ? 'Favorilere eklendi'
              : 'Favorilerden çıkarıldı',
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Tarayıcıda aç
  Future<void> _openInBrowser() async {
    try {
      // URL'yi temizle ve validate et
      String url = widget.article.link.trim();
      
      // Eğer URL http:// veya https:// ile başlamıyorsa ekle
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        url = 'https://$url';
      }
      
      final uri = Uri.parse(url);
      
      // Önce externalApplication modunu dene
      bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      
      // Eğer açılamadıysa, platformDefault modunu dene
      if (!launched) {
        launched = await launchUrl(
          uri,
          mode: LaunchMode.platformDefault,
        );
      }
      
      // Hala açılamadıysa, inAppWebView modunu dene
      if (!launched) {
        launched = await launchUrl(
          uri,
          mode: LaunchMode.inAppWebView,
        );
      }
      
      if (!launched) {
        throw 'URL açılamadı: $url';
      }
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bağlantı açılamadı: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Kopyala',
              textColor: Colors.white,
              onPressed: () {
                Clipboard.setData(ClipboardData(text: widget.article.link));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Bağlantı panoya kopyalandı'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ),
        );
      }
    }
  }

  /// Görsel genişletme toggle
  void _toggleImageExpansion() {
    setState(() {
      _isImageExpanded = !_isImageExpanded;
    });
    
    if (_isImageExpanded) {
      // Full screen image dialog
      showDialog(
        context: context,
        barrierColor: Colors.black,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  child: CachedNetworkImage(
                    imageUrl: widget.article.imageUrl!,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Positioned(
                top: 40,
                right: 20,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  /// Menü seçimlerini handle et
  void _handleMenuSelection(String value) {
    switch (value) {
      case 'copy_link':
        Clipboard.setData(ClipboardData(text: widget.article.link));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bağlantı panoya kopyalandı'),
            duration: Duration(seconds: 2),
          ),
        );
        break;
        
      case 'open_browser':
        _openInBrowser();
        break;
    }
  }
}