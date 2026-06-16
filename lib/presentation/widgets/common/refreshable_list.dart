import 'package:flutter/material.dart';

/// RefreshIndicator + lazy loading birleşik widget
/// Pull-to-refresh ve infinite scroll desteği sağlar
class RefreshableList<T> extends StatefulWidget {
  /// Gösterilecek veri listesi
  final List<T> items;

  /// Veri ile widget oluşturan builder
  final Widget Function(BuildContext context, T item, int index) itemBuilder;

  /// Pull-to-refresh callback
  final Future<void> Function() onRefresh;

  /// Infinite scroll - daha fazla veri yükle callback
  final Future<void> Function()? onLoadMore;

  /// Yükleme durumu (ilk yükleme)
  final bool isLoading;

  /// Daha fazla veri yüklenirken
  final bool isLoadingMore;

  /// Daha fazla veri var mı
  final bool hasMore;

  /// Boş durum widget'ı
  final Widget? emptyWidget;

  /// Hata durumu widget'ı
  final Widget? errorWidget;

  /// Hata var mı
  final bool hasError;

  /// Loading widget (ilk yükleme)
  final Widget? loadingWidget;

  /// Separator widget
  final Widget? separator;

  /// Padding
  final EdgeInsetsGeometry? padding;

  /// Scroll controller (dışarıdan)
  final ScrollController? scrollController;

  /// Header widget (listenin başında)
  final Widget? header;

  /// Scroll sonu tetikleme eşiği (piksel cinsinden)
  final double loadMoreThreshold;

  /// Physics
  final ScrollPhysics? physics;

  const RefreshableList({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.onRefresh,
    this.onLoadMore,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.emptyWidget,
    this.errorWidget,
    this.hasError = false,
    this.loadingWidget,
    this.separator,
    this.padding,
    this.scrollController,
    this.header,
    this.loadMoreThreshold = 200,
    this.physics,
  });

  @override
  State<RefreshableList<T>> createState() => _RefreshableListState<T>();
}

class _RefreshableListState<T> extends State<RefreshableList<T>> {
  late ScrollController _scrollController;
  bool _isInternalController = false;

  @override
  void initState() {
    super.initState();
    if (widget.scrollController != null) {
      _scrollController = widget.scrollController!;
    } else {
      _scrollController = ScrollController();
      _isInternalController = true;
    }
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    if (_isInternalController) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  void _onScroll() {
    if (widget.onLoadMore == null) return;
    if (widget.isLoadingMore || !widget.hasMore) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (maxScroll - currentScroll <= widget.loadMoreThreshold) {
      widget.onLoadMore!();
    }
  }

  @override
  Widget build(BuildContext context) {
    // İlk yükleme durumu
    if (widget.isLoading) {
      return widget.loadingWidget ?? const _DefaultLoadingWidget();
    }

    // Hata durumu
    if (widget.hasError && widget.errorWidget != null) {
      return RefreshIndicator(
        onRefresh: widget.onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: widget.errorWidget!,
          ),
        ),
      );
    }

    // Boş durum
    if (widget.items.isEmpty && !widget.isLoading) {
      return RefreshIndicator(
        onRefresh: widget.onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: widget.emptyWidget ?? const _DefaultEmptyWidget(),
          ),
        ),
      );
    }

    // Normal liste
    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: ListView.builder(
        controller: _scrollController,
        padding: widget.padding ?? const EdgeInsets.symmetric(vertical: 8),
        physics: widget.physics ?? const AlwaysScrollableScrollPhysics(),
        itemCount: _calculateItemCount(),
        itemBuilder: (context, index) {
          // Header
          if (widget.header != null && index == 0) {
            return widget.header!;
          }

          final itemIndex = widget.header != null ? index - 1 : index;

          // Loading more indicator
          if (itemIndex >= widget.items.length) {
            return _buildLoadMoreIndicator();
          }

          // Separator support
          if (widget.separator != null) {
            final actualIndex = itemIndex ~/ 2;
            if (itemIndex.isOdd) {
              return widget.separator!;
            }
            if (actualIndex < widget.items.length) {
              return widget.itemBuilder(
                context,
                widget.items[actualIndex],
                actualIndex,
              );
            }
            return const SizedBox.shrink();
          }

          return widget.itemBuilder(
            context,
            widget.items[itemIndex],
            itemIndex,
          );
        },
      ),
    );
  }

  int _calculateItemCount() {
    int count = widget.items.length;

    // Separator ekle
    if (widget.separator != null && count > 0) {
      count = count * 2 - 1;
    }

    // Header ekle
    if (widget.header != null) {
      count += 1;
    }

    // Loading more indicator ekle
    if (widget.isLoadingMore || (widget.hasMore && widget.onLoadMore != null)) {
      count += 1;
    }

    return count;
  }

  Widget _buildLoadMoreIndicator() {
    if (widget.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (!widget.hasMore) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            'Tüm haberler yüklendi',
            style: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
              fontSize: 12,
            ),
          ),
        ),
      );
    }

    return const SizedBox(height: 16);
  }
}

/// Varsayılan yükleme widget'ı
class _DefaultLoadingWidget extends StatelessWidget {
  const _DefaultLoadingWidget();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

/// Varsayılan boş durum widget'ı
class _DefaultEmptyWidget extends StatelessWidget {
  const _DefaultEmptyWidget();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Henüz içerik yok',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Yenilemek için aşağı çekin',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}
