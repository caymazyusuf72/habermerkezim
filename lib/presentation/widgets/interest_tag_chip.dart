import 'package:flutter/material.dart';
import '../../domain/entities/interest_tag.dart';
import '../themes/app_theme.dart';

/// İlgi alanı hashtag chip widget'ı
/// Twitter benzeri, dokunulabilir etiket tasarımı
class InterestTagChip extends StatelessWidget {
  final InterestTag tag;
  final bool isSelected;
  final VoidCallback onTap;

  const InterestTagChip({
    super.key,
    required this.tag,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? _getColorFromHex(tag.color).withValues(alpha: 0.2)
              : isDark
              ? Colors.grey[800]
              : Colors.grey[200],
          border: Border.all(
            color: isSelected
                ? _getColorFromHex(tag.color)
                : isDark
                ? Colors.grey[700]!
                : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Icon(
              tag.icon,
              size: 20,
              color: isSelected
                  ? _getColorFromHex(tag.color)
                  : isDark
                  ? Colors.grey[400]
                  : Colors.grey[700],
            ),
            const SizedBox(width: 8),
            // Hashtag text
            Text(
              tag.displayName,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? _getColorFromHex(tag.color)
                    : isDark
                    ? Colors.grey[300]
                    : Colors.grey[800],
              ),
            ),
            // Seçili işareti
            if (isSelected) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.check_circle,
                size: 18,
                color: _getColorFromHex(tag.color),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Hex color string'den Color oluştur
  Color _getColorFromHex(String hexString) {
    try {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) {
        buffer.write('ff');
        buffer.write(hexString.replaceFirst('#', ''));
        return Color(int.parse(buffer.toString(), radix: 16));
      }
    } catch (e) {
      // Hata durumunda varsayılan renk
    }
    return AppTheme.primaryBlue;
  }
}
