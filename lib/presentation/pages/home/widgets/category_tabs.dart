import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../domain/entities/category.dart';
import '../../../themes/app_theme.dart';
import '../../../providers/category_order_provider.dart';

/// Kategori sekmelerini gösteren widget
/// Ana sayfada AppBar'ın altında yer alır
/// Sürükle-bırak ile kategori sıralaması değiştirilebilir
class CategoryTabs extends ConsumerStatefulWidget implements PreferredSizeWidget {
  final TabController tabController;
  final List<Category> categories;
  final Function(int, int)? onReorder;

  const CategoryTabs({
    super.key,
    required this.tabController,
    required this.categories,
    this.onReorder,
  });

  @override
  Size get preferredSize => const Size.fromHeight(48);

  @override
  ConsumerState<CategoryTabs> createState() => _CategoryTabsState();
}

class _CategoryTabsState extends ConsumerState<CategoryTabs> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor,
            width: 0.5,
          ),
        ),
      ),
      child: _buildNormalTabs(theme),
    );
  }

  /// Normal tab görünümü - Sürükle-bırak ile sıralama
  Widget _buildNormalTabs(ThemeData theme) {
    final orderedCategories = ref.watch(orderedCategoriesProvider);
    
    if (orderedCategories.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: orderedCategories.asMap().entries.map((entry) {
          final index = entry.key;
          final category = entry.value;
          final color = AppTheme.getCategoryColor(category.id);
          final isSelected = widget.tabController.index == index;
          
          return LongPressDraggable<int>(
            key: ValueKey(category.id),
            data: index,
            feedback: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color, width: 2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      category.displayName,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            childWhenDragging: Opacity(
              opacity: 0.3,
              child: _buildCategoryChip(theme, category, color, false),
            ),
            child: DragTarget<int>(
              onAccept: (draggedIndex) {
                if (draggedIndex != index) {
                  final oldIndex = draggedIndex;
                  final newIndex = index;
                  widget.onReorder?.call(oldIndex, newIndex);
                  ref.read(categoryOrderProvider.notifier).reorderCategories(oldIndex, newIndex);
                }
              },
              builder: (context, candidateData, rejectedData) {
                final isDragTarget = candidateData.isNotEmpty;
                return GestureDetector(
                  onTap: () {
                    widget.tabController.animateTo(index);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: _buildCategoryChip(
                      theme,
                      category,
                      color,
                      isSelected,
                      isDragTarget: isDragTarget,
                    ),
                  ),
                );
              },
            ),
          );
        }).toList(),
      ),
    );
  }
  
  /// Kategori chip widget'ı
  Widget _buildCategoryChip(
    ThemeData theme,
    Category category,
    Color color,
    bool isSelected, {
    bool isDragTarget = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected
            ? color.withOpacity(0.1)
            : isDragTarget
                ? color.withOpacity(0.05)
                : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: isSelected
            ? Border.all(color: color, width: 1.5)
            : isDragTarget
                ? Border.all(color: color, width: 1)
                : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            category.displayName,
            style: TextStyle(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withOpacity(0.6),
              fontSize: 14,
              fontWeight: isSelected
                  ? FontWeight.w600
                  : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

}

/// Animated kategori tab'ı
class AnimatedCategoryTab extends StatefulWidget {
  final Category category;
  final bool isSelected;
  final VoidCallback onTap;

  const AnimatedCategoryTab({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<AnimatedCategoryTab> createState() => _AnimatedCategoryTabState();
}

class _AnimatedCategoryTabState extends State<AnimatedCategoryTab>
    with SingleTickerProviderStateMixin {
  
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    if (widget.isSelected) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(AnimatedCategoryTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryColor = AppTheme.getCategoryColor(widget.category.id);
    
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: widget.isSelected
                    ? categoryColor.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: widget.isSelected
                    ? Border.all(color: categoryColor, width: 1.5)
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Kategori ikonu
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: widget.isSelected
                          ? categoryColor
                          : categoryColor.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  
                  // Kategori adı
                  Text(
                    widget.category.displayName,
                    style: TextStyle(
                      color: widget.isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface.withOpacity(0.7),
                      fontSize: 14,
                      fontWeight: widget.isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Kategori sekmelerinin utils sınıfı
class CategoryTabsUtils {
  CategoryTabsUtils._();
  
  /// Tab scroll position'ını hesaplar
  static double calculateScrollOffset(int selectedIndex, int totalTabs) {
    const tabWidth = 120.0; // Approximate tab width
    const screenWidth = 360.0; // Approximate screen width
    
    final maxScroll = (totalTabs * tabWidth) - screenWidth;
    final targetScroll = (selectedIndex * tabWidth) - (screenWidth / 2);
    
    return targetScroll.clamp(0.0, maxScroll);
  }
  
  /// Kategori count'ları format eder
  static String formatArticleCount(int count) {
    if (count == 0) return '';
    if (count < 100) return count.toString();
    if (count < 1000) return '${(count / 100).floor()}yüz+';
    return '${(count / 1000).floor()}bin+';
  }
}