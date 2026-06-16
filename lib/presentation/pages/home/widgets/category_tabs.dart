import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../domain/entities/category.dart';
import '../../../themes/app_theme.dart' show AppTheme, ColorTheme;
import '../../../providers/category_order_provider.dart';
import '../../../providers/theme_provider.dart';

/// Kategori sekmelerini gösteren widget
/// Ana sayfada AppBar'ın altında yer alır
/// Sürükle-bırak ile kategori sıralaması değiştirilebilir
class CategoryTabs extends ConsumerStatefulWidget implements PreferredSizeWidget {
  final TabController tabController;
  final List<Category> categories;

  const CategoryTabs({
    super.key,
    required this.tabController,
    required this.categories,
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
            color: AppTheme.getPrimaryColor(ref.watch(colorThemeProvider)).withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: _buildNormalTabs(theme),
    );
  }

  /// Normal tab görünümü
  Widget _buildNormalTabs(ThemeData theme) {
    final orderedCategories = ref.watch(orderedCategoriesProvider);
    final colorTheme = ref.watch(colorThemeProvider);
    final primaryColor = AppTheme.getPrimaryColor(colorTheme);
    
    return TabBar(
      controller: widget.tabController,
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      
      // Tab stilleri - Merriweather font
      labelStyle: theme.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
      unselectedLabelStyle: theme.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w400,
        letterSpacing: 0.2,
      ),
      
      // Renkler - Seçili renk teması
      labelColor: primaryColor,
      unselectedLabelColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
      
      // Indicator - Seçili renk teması
      indicatorColor: primaryColor,
      indicatorWeight: 2.5,
      indicatorSize: TabBarIndicatorSize.label,
      
      // Padding
      padding: const EdgeInsets.symmetric(horizontal: 8),
      labelPadding: const EdgeInsets.symmetric(horizontal: 16),
      
      // Tabs
      tabs: orderedCategories.asMap().entries.map((entry) {
        final category = entry.value;
        final color = AppTheme.getCategoryColor(category.id);
        
        return Tab(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Kategori ikonu
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              
              // Kategori adı
              Text(category.displayName),
            ],
          ),
        );
      }).toList(),
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
                    ? categoryColor.withValues(alpha: 0.1)
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
                          : categoryColor.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  
                  // Kategori adı
                  Text(
                    widget.category.displayName,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: widget.isSelected
                          ? AppTheme.getPrimaryColor(ColorTheme.defaultTheme)
                          : theme.colorScheme.onSurface.withValues(alpha: 0.7),
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