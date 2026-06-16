import 'package:flutter/material.dart';

/// Tutarlı spacing sabitleri
/// Material Design 3 spacing scale'ine uygun
class AppSpacing {
  AppSpacing._();

  /// 4px - Extra small
  static const double xs = 4;

  /// 8px - Small
  static const double sm = 8;

  /// 12px - Small-Medium arası
  static const double smMd = 12;

  /// 16px - Medium
  static const double md = 16;

  /// 20px - Medium-Large arası
  static const double mdLg = 20;

  /// 24px - Large
  static const double lg = 24;

  /// 32px - Extra Large
  static const double xl = 32;

  /// 48px - Extra Extra Large
  static const double xxl = 48;

  /// 64px - Triple Extra Large
  static const double xxxl = 64;

  // === EdgeInsets Helpers ===

  /// Tüm yönlere eşit padding
  static const EdgeInsets allXs = EdgeInsets.all(xs);
  static const EdgeInsets allSm = EdgeInsets.all(sm);
  static const EdgeInsets allMd = EdgeInsets.all(md);
  static const EdgeInsets allLg = EdgeInsets.all(lg);
  static const EdgeInsets allXl = EdgeInsets.all(xl);

  /// Yatay padding
  static const EdgeInsets horizontalXs = EdgeInsets.symmetric(horizontal: xs);
  static const EdgeInsets horizontalSm = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets horizontalMd = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets horizontalLg = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets horizontalXl = EdgeInsets.symmetric(horizontal: xl);

  /// Dikey padding
  static const EdgeInsets verticalXs = EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets verticalSm = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets verticalMd = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets verticalLg = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets verticalXl = EdgeInsets.symmetric(vertical: xl);

  // === Yaygın Kullanılan Kombinasyonlar ===

  /// Sayfa padding (yatay: 16, dikey: 8)
  static const EdgeInsets page = EdgeInsets.symmetric(
    horizontal: md,
    vertical: sm,
  );

  /// Kart padding
  static const EdgeInsets card = EdgeInsets.all(md);

  /// Kart margin
  static const EdgeInsets cardMargin = EdgeInsets.symmetric(
    horizontal: md,
    vertical: sm,
  );

  /// Liste item padding
  static const EdgeInsets listItem = EdgeInsets.symmetric(
    horizontal: md,
    vertical: smMd,
  );

  /// Bölüm başlığı padding
  static const EdgeInsets sectionHeader = EdgeInsets.symmetric(
    horizontal: md,
    vertical: sm,
  );

  /// Dialog padding
  static const EdgeInsets dialog = EdgeInsets.all(lg);

  /// Bottom sheet padding
  static const EdgeInsets bottomSheet = EdgeInsets.fromLTRB(md, sm, md, lg);

  // === SizedBox Helpers ===

  /// Yatay boşluk
  static const SizedBox gapXs = SizedBox(width: xs);
  static const SizedBox gapSm = SizedBox(width: sm);
  static const SizedBox gapMd = SizedBox(width: md);
  static const SizedBox gapLg = SizedBox(width: lg);
  static const SizedBox gapXl = SizedBox(width: xl);

  /// Dikey boşluk
  static const SizedBox vGapXs = SizedBox(height: xs);
  static const SizedBox vGapSm = SizedBox(height: sm);
  static const SizedBox vGapMd = SizedBox(height: md);
  static const SizedBox vGapLg = SizedBox(height: lg);
  static const SizedBox vGapXl = SizedBox(height: xl);
  static const SizedBox vGapXxl = SizedBox(height: xxl);

  // === Border Radius ===

  /// Küçük border radius
  static const BorderRadius radiusSm = BorderRadius.all(Radius.circular(4));

  /// Orta border radius
  static const BorderRadius radiusMd = BorderRadius.all(Radius.circular(8));

  /// Büyük border radius
  static const BorderRadius radiusLg = BorderRadius.all(Radius.circular(12));

  /// Extra büyük border radius
  static const BorderRadius radiusXl = BorderRadius.all(Radius.circular(16));

  /// Tam yuvarlak
  static const BorderRadius radiusFull = BorderRadius.all(Radius.circular(999));
}

/// Widget Extension'ları - kolay padding/margin ekleme
extension SpacingExtension on Widget {
  /// Tüm yönlere padding ekle
  Widget padAll(double value) =>
      Padding(padding: EdgeInsets.all(value), child: this);

  /// Yatay padding ekle
  Widget padHorizontal(double value) => Padding(
    padding: EdgeInsets.symmetric(horizontal: value),
    child: this,
  );

  /// Dikey padding ekle
  Widget padVertical(double value) => Padding(
    padding: EdgeInsets.symmetric(vertical: value),
    child: this,
  );

  /// Sol padding ekle
  Widget padLeft(double value) => Padding(
    padding: EdgeInsets.only(left: value),
    child: this,
  );

  /// Sağ padding ekle
  Widget padRight(double value) => Padding(
    padding: EdgeInsets.only(right: value),
    child: this,
  );

  /// Üst padding ekle
  Widget padTop(double value) => Padding(
    padding: EdgeInsets.only(top: value),
    child: this,
  );

  /// Alt padding ekle
  Widget padBottom(double value) => Padding(
    padding: EdgeInsets.only(bottom: value),
    child: this,
  );

  /// EdgeInsets ile padding ekle
  Widget withPadding(EdgeInsetsGeometry padding) =>
      Padding(padding: padding, child: this);
}
