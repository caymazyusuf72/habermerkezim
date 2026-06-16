import 'package:flutter/material.dart';
import 'shimmer_widget.dart';

/// Kategori chip'leri skeleton loading widget'ı
class CategoryShimmer extends StatelessWidget {
  final int itemCount;
  final double chipWidth;
  final double chipHeight;

  const CategoryShimmer({
    super.key,
    this.itemCount = 6,
    this.chipWidth = 80,
    this.chipHeight = 32,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surfaceColor = theme.colorScheme.surfaceContainerHighest;

    return ShimmerWidget(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: List.generate(itemCount, (index) {
            // Farklı genişliklerde chip'ler
            final width = chipWidth + (index % 3) * 20.0;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Container(
                width: width,
                height: chipHeight,
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(chipHeight / 2),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

/// Kategori tab bar shimmer (PreferredSizeWidget)
class CategoryTabBarShimmer extends StatelessWidget
    implements PreferredSizeWidget {
  final int itemCount;

  const CategoryTabBarShimmer({super.key, this.itemCount = 5});

  @override
  Size get preferredSize => const Size.fromHeight(48);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surfaceColor = theme.colorScheme.surfaceContainerHighest;

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ShimmerWidget(
        child: Row(
          children: List.generate(itemCount, (index) {
            return Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Container(
                width: 70 + (index % 3) * 15.0,
                height: 32,
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

/// Kategori grid shimmer (keşfet sayfası için)
class CategoryGridShimmer extends StatelessWidget {
  final int itemCount;
  final int crossAxisCount;

  const CategoryGridShimmer({
    super.key,
    this.itemCount = 8,
    this.crossAxisCount = 2,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surfaceColor = theme.colorScheme.surfaceContainerHighest;

    return ShimmerWidget(
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.5,
        ),
        itemCount: itemCount,
        itemBuilder: (context, index) => Container(
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
