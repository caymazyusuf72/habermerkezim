import 'package:flutter/material.dart';

/// Otomatik sütun sayısı ayarlayan responsive grid widget
/// Ekran boyutuna göre sütun sayısını otomatik belirler
class ResponsiveAutoGrid extends StatelessWidget {
  final List<Widget> children;
  final double minItemWidth;
  final double spacing;
  final double runSpacing;
  final double? childAspectRatio;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final Widget? header;

  const ResponsiveAutoGrid({
    super.key,
    required this.children,
    this.minItemWidth = 160,
    this.spacing = 12,
    this.runSpacing = 12,
    this.childAspectRatio,
    this.padding,
    this.shrinkWrap = true,
    this.physics,
    this.header,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = (width / minItemWidth).floor().clamp(1, 6);
        final effectiveAspectRatio =
            childAspectRatio ?? _calculateAspectRatio(columns);

        if (header != null) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              header!,
              GridView.builder(
                shrinkWrap: shrinkWrap,
                physics: physics ?? const NeverScrollableScrollPhysics(),
                padding: padding ?? const EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: spacing,
                  mainAxisSpacing: runSpacing,
                  childAspectRatio: effectiveAspectRatio,
                ),
                itemCount: children.length,
                itemBuilder: (context, index) => children[index],
              ),
            ],
          );
        }

        return GridView.builder(
          shrinkWrap: shrinkWrap,
          physics: physics ?? const NeverScrollableScrollPhysics(),
          padding: padding ?? const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: spacing,
            mainAxisSpacing: runSpacing,
            childAspectRatio: effectiveAspectRatio,
          ),
          itemCount: children.length,
          itemBuilder: (context, index) => children[index],
        );
      },
    );
  }

  double _calculateAspectRatio(int columns) {
    // Daha fazla sütun = daha kare
    if (columns >= 3) return 1.0;
    if (columns == 2) return 1.2;
    return 1.5;
  }
}

/// Sliver versiyonu - CustomScrollView içinde kullanım için
class SliverResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double minItemWidth;
  final double spacing;
  final double runSpacing;
  final double? childAspectRatio;
  final EdgeInsetsGeometry? padding;

  const SliverResponsiveGrid({
    super.key,
    required this.children,
    this.minItemWidth = 160,
    this.spacing = 12,
    this.runSpacing = 12,
    this.childAspectRatio,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.crossAxisExtent;
        final columns = (width / minItemWidth).floor().clamp(1, 6);

        return SliverPadding(
          padding: padding ?? const EdgeInsets.all(16),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: spacing,
              mainAxisSpacing: runSpacing,
              childAspectRatio: childAspectRatio ?? 1.0,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => children[index],
              childCount: children.length,
            ),
          ),
        );
      },
    );
  }
}

/// Responsive news grid - haber kartları için özelleştirilmiş
class ResponsiveNewsGrid extends StatelessWidget {
  final List<Widget> children;
  final bool withSidebar;
  final Widget? sidebar;
  final EdgeInsetsGeometry? padding;

  const ResponsiveNewsGrid({
    super.key,
    required this.children,
    this.withSidebar = false,
    this.sidebar,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        // Mobile: tek sütun liste
        if (width < 600) {
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: padding,
            itemCount: children.length,
            itemBuilder: (context, index) => children[index],
          );
        }

        // Tablet: 2 sütun grid
        if (width < 900) {
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: padding ?? const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: children.length,
            itemBuilder: (context, index) => children[index],
          );
        }

        // Desktop: 3 sütun grid + opsiyonel sidebar
        if (withSidebar && sidebar != null) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ana içerik - 3 sütun grid
              Expanded(
                flex: 3,
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: padding ?? const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: children.length,
                  itemBuilder: (context, index) => children[index],
                ),
              ),
              // Sidebar
              SizedBox(width: 300, child: sidebar!),
            ],
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: padding ?? const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.8,
          ),
          itemCount: children.length,
          itemBuilder: (context, index) => children[index],
        );
      },
    );
  }
}
