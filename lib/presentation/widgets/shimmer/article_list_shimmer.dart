import 'package:flutter/material.dart';
import 'article_card_shimmer.dart';

/// Haber listesi skeleton loading widget'ı
/// 5-6 adet article_card_shimmer gösterir
class ArticleListShimmerNew extends StatelessWidget {
  final int itemCount;
  final bool isCompact;
  final ScrollPhysics? physics;
  final bool shrinkWrap;

  const ArticleListShimmerNew({
    super.key,
    this.itemCount = 6,
    this.isCompact = false,
    this.physics,
    this.shrinkWrap = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: itemCount,
      shrinkWrap: shrinkWrap,
      physics: physics ?? const AlwaysScrollableScrollPhysics(),
      itemBuilder: (context, index) =>
          ArticleCardShimmerNew(isCompact: isCompact),
    );
  }
}

/// Sliver versiyonu - CustomScrollView içinde kullanım için
class SliverArticleListShimmer extends StatelessWidget {
  final int itemCount;
  final bool isCompact;

  const SliverArticleListShimmer({
    super.key,
    this.itemCount = 6,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => ArticleCardShimmerNew(isCompact: isCompact),
        childCount: itemCount,
      ),
    );
  }
}
