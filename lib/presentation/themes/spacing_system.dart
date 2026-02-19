import 'package:flutter/material.dart';

/// Spacing sistemi - tutarlı boşluklar için
/// Material Design 3 spacing scale'i takip eder
class Spacing {
  // Base spacing values
  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;

  // Semantic spacing
  static const double cardPadding = md;
  static const double sectionPadding = lg;
  static const double screenPadding = md;
  static const double listItemSpacing = sm;
  static const double buttonPadding = md;
  
  // Vertical spacing
  static const double verticalXs = xs;
  static const double verticalSm = sm;
  static const double verticalMd = md;
  static const double verticalLg = lg;
  static const double verticalXl = xl;
  
  // Horizontal spacing
  static const double horizontalXs = xs;
  static const double horizontalSm = sm;
  static const double horizontalMd = md;
  static const double horizontalLg = lg;
  static const double horizontalXl = xl;

  // Border radius
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radiusXxl = 24.0;
  static const double radiusFull = 999.0;

  // Icon sizes
  static const double iconXs = 16.0;
  static const double iconSm = 20.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 48.0;
  static const double iconXxl = 64.0;

  // Elevation
  static const double elevationNone = 0.0;
  static const double elevationXs = 1.0;
  static const double elevationSm = 2.0;
  static const double elevationMd = 4.0;
  static const double elevationLg = 8.0;
  static const double elevationXl = 16.0;

  // Responsive spacing helper
  static double responsive(BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    final width = MediaQuery.of(context).size.width;
    
    if (width >= 1200 && desktop != null) {
      return desktop;
    } else if (width >= 600 && tablet != null) {
      return tablet;
    }
    return mobile;
  }

  // Safe area padding
  static EdgeInsets safeArea(BuildContext context, {
    bool top = true,
    bool bottom = true,
    bool left = true,
    bool right = true,
  }) {
    final padding = MediaQuery.of(context).padding;
    return EdgeInsets.only(
      top: top ? padding.top : 0,
      bottom: bottom ? padding.bottom : 0,
      left: left ? padding.left : 0,
      right: right ? padding.right : 0,
    );
  }
}

/// Spacing extension for easy usage
extension SpacingExtension on num {
  SizedBox get verticalSpace => SizedBox(height: toDouble());
  SizedBox get horizontalSpace => SizedBox(width: toDouble());
  
  EdgeInsets get allPadding => EdgeInsets.all(toDouble());
  EdgeInsets get horizontalPadding => EdgeInsets.symmetric(horizontal: toDouble());
  EdgeInsets get verticalPadding => EdgeInsets.symmetric(vertical: toDouble());
  
  BorderRadius get borderRadius => BorderRadius.circular(toDouble());
}

/// Spacing widgets for convenience
class VSpace extends StatelessWidget {
  final double height;
  
  const VSpace(this.height, {super.key});
  
  const VSpace.xs({super.key}) : height = Spacing.xs;
  const VSpace.sm({super.key}) : height = Spacing.sm;
  const VSpace.md({super.key}) : height = Spacing.md;
  const VSpace.lg({super.key}) : height = Spacing.lg;
  const VSpace.xl({super.key}) : height = Spacing.xl;
  const VSpace.xxl({super.key}) : height = Spacing.xxl;

  @override
  Widget build(BuildContext context) => SizedBox(height: height);
}

class HSpace extends StatelessWidget {
  final double width;
  
  const HSpace(this.width, {super.key});
  
  const HSpace.xs({super.key}) : width = Spacing.xs;
  const HSpace.sm({super.key}) : width = Spacing.sm;
  const HSpace.md({super.key}) : width = Spacing.md;
  const HSpace.lg({super.key}) : width = Spacing.lg;
  const HSpace.xl({super.key}) : width = Spacing.xl;
  const HSpace.xxl({super.key}) : width = Spacing.xxl;

  @override
  Widget build(BuildContext context) => SizedBox(width: width);
}

/// Grid system
class GridSystem {
  static const int columns = 12;
  static const double gutterWidth = Spacing.md;
  
  static double columnWidth(BuildContext context, int span) {
    final screenWidth = MediaQuery.of(context).size.width;
    final totalGutterWidth = gutterWidth * (columns - 1);
    final availableWidth = screenWidth - totalGutterWidth - (Spacing.screenPadding * 2);
    return (availableWidth / columns) * span + (gutterWidth * (span - 1));
  }
}

/// Responsive breakpoints
class Breakpoints {
  static const double mobile = 0;
  static const double tablet = 600;
  static const double desktop = 1200;
  static const double wide = 1600;
  
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < tablet;
  }
  
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= tablet && width < desktop;
  }
  
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktop;
  }
  
  static bool isWide(BuildContext context) {
    return MediaQuery.of(context).size.width >= wide;
  }
}
