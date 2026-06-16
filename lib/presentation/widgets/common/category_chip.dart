import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../themes/app_theme.dart';

/// Animasyonlu kategori seçici chip widget'ı
class CategoryChip extends StatefulWidget {
  final String label;
  final String? categoryId;
  final bool isSelected;
  final VoidCallback? onTap;
  final IconData? icon;
  final Color? color;
  final bool showCheckmark;
  final bool animated;

  const CategoryChip({
    super.key,
    required this.label,
    this.categoryId,
    this.isSelected = false,
    this.onTap,
    this.icon,
    this.color,
    this.showCheckmark = true,
    this.animated = true,
  });

  @override
  State<CategoryChip> createState() => _CategoryChipState();
}

class _CategoryChipState extends State<CategoryChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _checkAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    if (widget.isSelected) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(CategoryChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getChipColor() {
    if (widget.color != null) return widget.color!;
    if (widget.categoryId != null) {
      return AppTheme.getCategoryColor(widget.categoryId!);
    }
    return AppTheme.sageGreen;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final chipColor = _getChipColor();

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) {
          if (widget.animated) {
            _controller.forward();
          }
        },
        onTapUp: (_) {
          if (widget.animated && !widget.isSelected) {
            _controller.reverse();
          }
        },
        onTapCancel: () {
          if (widget.animated && !widget.isSelected) {
            _controller.reverse();
          }
        },
        onTap: () {
          HapticFeedback.selectionClick();
          widget.onTap?.call();
        },
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: widget.animated ? _scaleAnimation.value : 1.0,
              child: child,
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.symmetric(
              horizontal: widget.isSelected ? 16 : 14,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? chipColor.withValues(alpha: isDark ? 0.25 : 0.15)
                  : _isHovered
                  ? theme.colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.8,
                    )
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: widget.isSelected
                    ? chipColor
                    : _isHovered
                    ? theme.colorScheme.outline.withValues(alpha: 0.5)
                    : theme.colorScheme.outline.withValues(alpha: 0.3),
                width: widget.isSelected ? 2 : 1.5,
              ),
              boxShadow: widget.isSelected
                  ? [
                      BoxShadow(
                        color: chipColor.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // İkon
                if (widget.icon != null) ...[
                  Icon(
                    widget.icon,
                    size: 16,
                    color: widget.isSelected
                        ? chipColor
                        : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 6),
                ],

                // Label
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: widget.isSelected
                        ? FontWeight.w600
                        : FontWeight.w500,
                    color: widget.isSelected
                        ? chipColor
                        : theme.colorScheme.onSurface.withValues(alpha: 0.8),
                    letterSpacing: 0.2,
                  ),
                ),

                // Checkmark
                if (widget.showCheckmark && widget.isSelected) ...[
                  const SizedBox(width: 6),
                  AnimatedBuilder(
                    animation: _checkAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _checkAnimation.value,
                        child: child,
                      );
                    },
                    child: Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: chipColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Kategori chip listesi
class CategoryChipList extends StatelessWidget {
  final List<CategoryChipData> categories;
  final String? selectedCategoryId;
  final Function(String) onCategorySelected;
  final bool scrollable;
  final EdgeInsets padding;

  const CategoryChipList({
    super.key,
    required this.categories,
    this.selectedCategoryId,
    required this.onCategorySelected,
    this.scrollable = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  @override
  Widget build(BuildContext context) {
    if (scrollable) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: padding,
        child: Row(
          children: categories.map((category) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: CategoryChip(
                label: category.label,
                categoryId: category.id,
                icon: category.icon,
                color: category.color,
                isSelected: selectedCategoryId == category.id,
                onTap: () => onCategorySelected(category.id),
              ),
            );
          }).toList(),
        ),
      );
    }

    return Padding(
      padding: padding,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: categories.map((category) {
          return CategoryChip(
            label: category.label,
            categoryId: category.id,
            icon: category.icon,
            color: category.color,
            isSelected: selectedCategoryId == category.id,
            onTap: () => onCategorySelected(category.id),
          );
        }).toList(),
      ),
    );
  }
}

/// Kategori chip verisi
class CategoryChipData {
  final String id;
  final String label;
  final IconData? icon;
  final Color? color;

  const CategoryChipData({
    required this.id,
    required this.label,
    this.icon,
    this.color,
  });
}

/// Filter chip - filtreleme için
class FilterChip extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final IconData? icon;
  final Color? selectedColor;
  final bool showRemoveButton;
  final VoidCallback? onRemove;

  const FilterChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.icon,
    this.selectedColor,
    this.showRemoveButton = false,
    this.onRemove,
  });

  @override
  State<FilterChip> createState() => _FilterChipState();
}

class _FilterChipState extends State<FilterChip> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedColor = widget.selectedColor ?? theme.colorScheme.primary;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          widget.onTap?.call();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? selectedColor.withValues(alpha: 0.15)
                : _isHovered
                ? theme.colorScheme.surfaceContainerHighest
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.isSelected
                  ? selectedColor
                  : theme.colorScheme.outline.withValues(alpha: 0.3),
              width: widget.isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(
                  widget.icon,
                  size: 16,
                  color: widget.isSelected
                      ? selectedColor
                      : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: widget.isSelected
                      ? FontWeight.w600
                      : FontWeight.w500,
                  color: widget.isSelected
                      ? selectedColor
                      : theme.colorScheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
              if (widget.showRemoveButton && widget.isSelected) ...[
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: widget.onRemove,
                  child: Icon(
                    Icons.close_rounded,
                    size: 16,
                    color: selectedColor,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Tag chip - etiketler için
class TagChip extends StatelessWidget {
  final String label;
  final Color? color;
  final VoidCallback? onTap;
  final bool removable;
  final VoidCallback? onRemove;

  const TagChip({
    super.key,
    required this.label,
    this.color,
    this.onTap,
    this.removable = false,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tagColor = color ?? theme.colorScheme.secondary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: tagColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: tagColor.withValues(alpha: 0.3), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '#$label',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: tagColor,
              ),
            ),
            if (removable) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onRemove,
                child: Icon(Icons.close_rounded, size: 14, color: tagColor),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
