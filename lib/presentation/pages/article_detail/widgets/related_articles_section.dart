import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../domain/entities/article.dart';
import '../../../widgets/loading/shimmer_loading.dart';
import '../../home/widgets/article_card.dart';
import '../../../../core/services/related_articles_service.dart';
import '../article_detail_page.dart';

/// İlgili haberler bölümü - makale detay sayfasında gösterilir
class RelatedArticlesSection extends ConsumerStatefulWidget {
  final Article currentArticle;

  const RelatedArticlesSection({
    super.key,
    required this.currentArticle,
  });

  @override
  ConsumerState<RelatedArticlesSection> createState() => _RelatedArticlesSectionState();
}

class _RelatedArticlesSectionState extends ConsumerState<RelatedArticlesSection> {
  List<Article>? _relatedArticles;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRelatedArticles();
  }

  Future<void> _loadRelatedArticles() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final articles = await RelatedArticlesService.findRelatedArticles(
        widget.currentArticle,
        limit: 5,
      );
      
      setState(() {
        _relatedArticles = articles;
        _isLoading = false;
      });
    } catch (e) {
      print('💥 İlgili haberler yükleme hatası: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_relatedArticles == null || _relatedArticles!.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.article_rounded,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'İlgili Haberler',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
        
        SizedBox(
          height: 420,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _relatedArticles!.length,
            itemBuilder: (context, index) {
              final article = _relatedArticles![index];
              return SizedBox(
                width: 360,
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: ArticleCard(
                    article: article,
                    isCompact: false, // Tam boyutlu kart kullan
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => _getArticleDetailPage(article),
                        ),
                      );
                    },
                    onFavoriteToggle: () {
                      // Favorite toggle logic
                    },
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _getArticleDetailPage(Article article) {
    return ArticleDetailPage(article: article);
  }
}

