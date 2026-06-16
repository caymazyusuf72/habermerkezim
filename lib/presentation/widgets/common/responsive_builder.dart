import 'package:flutter/material.dart';

/// Breakpoint sabitleri
class Breakpoints {
  Breakpoints._();

  /// Mobil cihazlar için maksimum genişlik
  static const double mobile = 600;

  /// Tablet cihazlar için maksimum genişlik
  static const double tablet = 900;

  /// Desktop için maksimum genişlik
  static const double desktop = 1200;

  /// Büyük desktop için maksimum genişlik
  static const double largeDesktop = 1800;

  /// Mobil mi kontrol et
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobile;
  }

  /// Tablet mi kontrol et
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobile && width < tablet;
  }

  /// Desktop mi kontrol et
  static bool isDesktop(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= tablet && width < largeDesktop;
  }

  /// Büyük desktop mi kontrol et
  static bool isLargeDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= largeDesktop;
  }

  /// Tablet veya daha büyük mü kontrol et
  static bool isTabletOrLarger(BuildContext context) {
    return MediaQuery.of(context).size.width >= mobile;
  }

  /// Desktop veya daha büyük mü kontrol et
  static bool isDesktopOrLarger(BuildContext context) {
    return MediaQuery.of(context).size.width >= tablet;
  }
}

/// Cihaz türü enum
enum DeviceType { mobile, tablet, desktop, largeDesktop }

/// Responsive builder widget
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(
    BuildContext context,
    DeviceType deviceType,
    BoxConstraints constraints,
  )
  builder;

  const ResponsiveBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final deviceType = _getDeviceType(constraints.maxWidth);
        return builder(context, deviceType, constraints);
      },
    );
  }

  DeviceType _getDeviceType(double width) {
    if (width < Breakpoints.mobile) {
      return DeviceType.mobile;
    } else if (width < Breakpoints.tablet) {
      return DeviceType.tablet;
    } else if (width < Breakpoints.largeDesktop) {
      return DeviceType.desktop;
    } else {
      return DeviceType.largeDesktop;
    }
  }
}

/// Responsive layout widget - farklı cihazlar için farklı widget'lar
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? largeDesktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.largeDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType, constraints) {
        switch (deviceType) {
          case DeviceType.mobile:
            return mobile;
          case DeviceType.tablet:
            return tablet ?? mobile;
          case DeviceType.desktop:
            return desktop ?? tablet ?? mobile;
          case DeviceType.largeDesktop:
            return largeDesktop ?? desktop ?? tablet ?? mobile;
        }
      },
    );
  }
}

/// Responsive değer seçici
class ResponsiveValue<T> {
  final T mobile;
  final T? tablet;
  final T? desktop;
  final T? largeDesktop;

  const ResponsiveValue({
    required this.mobile,
    this.tablet,
    this.desktop,
    this.largeDesktop,
  });

  T getValue(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width >= Breakpoints.largeDesktop && largeDesktop != null) {
      return largeDesktop!;
    } else if (width >= Breakpoints.tablet && desktop != null) {
      return desktop!;
    } else if (width >= Breakpoints.mobile && tablet != null) {
      return tablet!;
    }
    return mobile;
  }

  T getValueFromType(DeviceType type) {
    switch (type) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
      case DeviceType.largeDesktop:
        return largeDesktop ?? desktop ?? tablet ?? mobile;
    }
  }
}

/// Responsive padding widget
class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final EdgeInsets mobile;
  final EdgeInsets? tablet;
  final EdgeInsets? desktop;
  final EdgeInsets? largeDesktop;

  const ResponsivePadding({
    super.key,
    required this.child,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.largeDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType, constraints) {
        EdgeInsets padding;
        switch (deviceType) {
          case DeviceType.mobile:
            padding = mobile;
            break;
          case DeviceType.tablet:
            padding = tablet ?? mobile;
            break;
          case DeviceType.desktop:
            padding = desktop ?? tablet ?? mobile;
            break;
          case DeviceType.largeDesktop:
            padding = largeDesktop ?? desktop ?? tablet ?? mobile;
            break;
        }
        return Padding(padding: padding, child: child);
      },
    );
  }
}

/// Responsive grid widget
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int mobileColumns;
  final int? tabletColumns;
  final int? desktopColumns;
  final int? largeDesktopColumns;
  final double spacing;
  final double runSpacing;
  final double? childAspectRatio;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.mobileColumns = 1,
    this.tabletColumns,
    this.desktopColumns,
    this.largeDesktopColumns,
    this.spacing = 16,
    this.runSpacing = 16,
    this.childAspectRatio,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType, constraints) {
        int columns;
        switch (deviceType) {
          case DeviceType.mobile:
            columns = mobileColumns;
            break;
          case DeviceType.tablet:
            columns = tabletColumns ?? mobileColumns;
            break;
          case DeviceType.desktop:
            columns = desktopColumns ?? tabletColumns ?? mobileColumns;
            break;
          case DeviceType.largeDesktop:
            columns =
                largeDesktopColumns ??
                desktopColumns ??
                tabletColumns ??
                mobileColumns;
            break;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: spacing,
            mainAxisSpacing: runSpacing,
            childAspectRatio: childAspectRatio ?? 1,
          ),
          itemCount: children.length,
          itemBuilder: (context, index) => children[index],
        );
      },
    );
  }
}

/// Responsive container - maksimum genişlik sınırlı
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsets? padding;
  final Alignment alignment;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
    this.alignment = Alignment.topCenter,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth ?? Breakpoints.desktop),
        padding: padding,
        child: child,
      ),
    );
  }
}

/// Responsive visibility widget
class ResponsiveVisibility extends StatelessWidget {
  final Widget child;
  final bool visibleOnMobile;
  final bool visibleOnTablet;
  final bool visibleOnDesktop;
  final bool visibleOnLargeDesktop;
  final Widget? replacement;

  const ResponsiveVisibility({
    super.key,
    required this.child,
    this.visibleOnMobile = true,
    this.visibleOnTablet = true,
    this.visibleOnDesktop = true,
    this.visibleOnLargeDesktop = true,
    this.replacement,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType, constraints) {
        bool isVisible;
        switch (deviceType) {
          case DeviceType.mobile:
            isVisible = visibleOnMobile;
            break;
          case DeviceType.tablet:
            isVisible = visibleOnTablet;
            break;
          case DeviceType.desktop:
            isVisible = visibleOnDesktop;
            break;
          case DeviceType.largeDesktop:
            isVisible = visibleOnLargeDesktop;
            break;
        }

        if (isVisible) {
          return child;
        }
        return replacement ?? const SizedBox.shrink();
      },
    );
  }
}

/// Responsive row/column widget
class ResponsiveRowColumn extends StatelessWidget {
  final List<Widget> children;
  final bool rowOnTablet;
  final bool rowOnDesktop;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;
  final double spacing;

  const ResponsiveRowColumn({
    super.key,
    required this.children,
    this.rowOnTablet = true,
    this.rowOnDesktop = true,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
    this.spacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType, constraints) {
        final isRow =
            (deviceType == DeviceType.tablet && rowOnTablet) ||
            (deviceType == DeviceType.desktop && rowOnDesktop) ||
            (deviceType == DeviceType.largeDesktop && rowOnDesktop);

        final spacedChildren = <Widget>[];
        for (int i = 0; i < children.length; i++) {
          spacedChildren.add(children[i]);
          if (i < children.length - 1) {
            spacedChildren.add(
              SizedBox(width: isRow ? spacing : 0, height: isRow ? 0 : spacing),
            );
          }
        }

        if (isRow) {
          return Row(
            mainAxisAlignment: mainAxisAlignment,
            crossAxisAlignment: crossAxisAlignment,
            mainAxisSize: mainAxisSize,
            children: spacedChildren,
          );
        }

        return Column(
          mainAxisAlignment: mainAxisAlignment,
          crossAxisAlignment: crossAxisAlignment,
          mainAxisSize: mainAxisSize,
          children: spacedChildren,
        );
      },
    );
  }
}

/// Responsive text widget
class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final double mobileFontSize;
  final double? tabletFontSize;
  final double? desktopFontSize;
  final double? largeDesktopFontSize;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const ResponsiveText({
    super.key,
    required this.text,
    this.style,
    required this.mobileFontSize,
    this.tabletFontSize,
    this.desktopFontSize,
    this.largeDesktopFontSize,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType, constraints) {
        double fontSize;
        switch (deviceType) {
          case DeviceType.mobile:
            fontSize = mobileFontSize;
            break;
          case DeviceType.tablet:
            fontSize = tabletFontSize ?? mobileFontSize;
            break;
          case DeviceType.desktop:
            fontSize = desktopFontSize ?? tabletFontSize ?? mobileFontSize;
            break;
          case DeviceType.largeDesktop:
            fontSize =
                largeDesktopFontSize ??
                desktopFontSize ??
                tabletFontSize ??
                mobileFontSize;
            break;
        }

        return Text(
          text,
          style: (style ?? const TextStyle()).copyWith(fontSize: fontSize),
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
        );
      },
    );
  }
}

/// Responsive sized box
class ResponsiveSizedBox extends StatelessWidget {
  final double? mobileWidth;
  final double? mobileHeight;
  final double? tabletWidth;
  final double? tabletHeight;
  final double? desktopWidth;
  final double? desktopHeight;
  final Widget? child;

  const ResponsiveSizedBox({
    super.key,
    this.mobileWidth,
    this.mobileHeight,
    this.tabletWidth,
    this.tabletHeight,
    this.desktopWidth,
    this.desktopHeight,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType, constraints) {
        double? width;
        double? height;

        switch (deviceType) {
          case DeviceType.mobile:
            width = mobileWidth;
            height = mobileHeight;
            break;
          case DeviceType.tablet:
            width = tabletWidth ?? mobileWidth;
            height = tabletHeight ?? mobileHeight;
            break;
          case DeviceType.desktop:
          case DeviceType.largeDesktop:
            width = desktopWidth ?? tabletWidth ?? mobileWidth;
            height = desktopHeight ?? tabletHeight ?? mobileHeight;
            break;
        }

        return SizedBox(width: width, height: height, child: child);
      },
    );
  }
}
