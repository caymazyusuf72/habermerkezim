import 'package:flutter/material.dart';
import '../../themes/app_theme.dart';

/// Modern tasarımlı alert dialog widget'ı
class ModernAlertDialog extends StatelessWidget {
  final String title;
  final String content;
  final IconData? icon;
  final Color? iconColor;
  final String? confirmText;
  final String? cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool isDangerous;

  const ModernAlertDialog({
    super.key,
    required this.title,
    required this.content,
    this.icon,
    this.iconColor,
    this.confirmText,
    this.cancelText,
    this.onConfirm,
    this.onCancel,
    this.isDangerous = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon ve Title
            if (icon != null) ...[
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: (iconColor ?? AppTheme.primaryBlue).withValues(
                    alpha: 0.1,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: iconColor ?? AppTheme.primaryBlue,
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Title
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // Content
            Text(
              content,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                // Cancel button
                if (onCancel != null || cancelText != null)
                  Expanded(
                    child: TextButton(
                      onPressed: onCancel ?? () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        cancelText ?? 'İptal',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                    ),
                  ),

                if ((onCancel != null || cancelText != null) &&
                    (onConfirm != null || confirmText != null))
                  const SizedBox(width: 12),

                // Confirm button
                if (onConfirm != null || confirmText != null)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onConfirm ?? () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDangerous
                            ? Colors.red
                            : AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        confirmText ?? 'Tamam',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Hızlı kullanım için helper function'lar
class ModernDialogs {
  /// Onay dialog'u göster
  static Future<bool?> showConfirmDialog({
    required BuildContext context,
    required String title,
    required String content,
    IconData? icon,
    Color? iconColor,
    String? confirmText,
    String? cancelText,
    bool isDangerous = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ModernAlertDialog(
        title: title,
        content: content,
        icon: icon,
        iconColor: iconColor,
        confirmText: confirmText,
        cancelText: cancelText,
        isDangerous: isDangerous,
        onConfirm: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
      ),
    );
  }

  /// Bilgi dialog'u göster
  static Future<void> showInfoDialog({
    required BuildContext context,
    required String title,
    required String content,
    IconData? icon,
    Color? iconColor,
    String? buttonText,
  }) {
    return showDialog(
      context: context,
      builder: (context) => ModernAlertDialog(
        title: title,
        content: content,
        icon: icon ?? Icons.info_rounded,
        iconColor: iconColor ?? AppTheme.primaryBlue,
        confirmText: buttonText ?? 'Tamam',
        onConfirm: () => Navigator.of(context).pop(),
      ),
    );
  }

  /// Hata dialog'u göster
  static Future<void> showErrorDialog({
    required BuildContext context,
    required String title,
    required String content,
    String? buttonText,
  }) {
    return showDialog(
      context: context,
      builder: (context) => ModernAlertDialog(
        title: title,
        content: content,
        icon: Icons.error_rounded,
        iconColor: Colors.red,
        confirmText: buttonText ?? 'Tamam',
        onConfirm: () => Navigator.of(context).pop(),
      ),
    );
  }

  /// Başarı dialog'u göster
  static Future<void> showSuccessDialog({
    required BuildContext context,
    required String title,
    required String content,
    String? buttonText,
  }) {
    return showDialog(
      context: context,
      builder: (context) => ModernAlertDialog(
        title: title,
        content: content,
        icon: Icons.check_circle_rounded,
        iconColor: Colors.green,
        confirmText: buttonText ?? 'Tamam',
        onConfirm: () => Navigator.of(context).pop(),
      ),
    );
  }

  /// Tehlikeli işlem dialog'u
  static Future<bool?> showDangerDialog({
    required BuildContext context,
    required String title,
    required String content,
    IconData? icon,
    String? confirmText,
    String? cancelText,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ModernAlertDialog(
        title: title,
        content: content,
        icon: icon ?? Icons.warning_rounded,
        iconColor: Colors.red,
        confirmText: confirmText ?? 'Sil',
        cancelText: cancelText ?? 'İptal',
        isDangerous: true,
        onConfirm: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
      ),
    );
  }
}
