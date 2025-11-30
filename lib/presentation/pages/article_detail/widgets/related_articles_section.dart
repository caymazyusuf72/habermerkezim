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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Icon(
                Icons.article_rounded,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'İlgili Haberler',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _relatedArticles!.length,
            itemBuilder: (context, index) {
              final article = _relatedArticles![index];
              return SizedBox(
                width: 300,
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: ArticleCard(
                    article: article,
                    onTap: () {
                      // Makale detay sayfasına git
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => _getArticleDetailPage(article),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _getArticleDetailPage(Article article) {
    return ArticleDetailPage(article: article);
  }
}

