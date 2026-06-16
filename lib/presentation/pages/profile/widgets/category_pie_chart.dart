import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../domain/entities/user_profile.dart';

/// Kategori dağılımı pasta grafiği widget'ı
class CategoryPieChart extends StatefulWidget {
  final UserPreferences preferences;
  final ThemeData theme;

  const CategoryPieChart({
    super.key,
    required this.preferences,
    required this.theme,
  });

  @override
  State<CategoryPieChart> createState() => _CategoryPieChartState();
}

class _CategoryPieChartState extends State<CategoryPieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: widget.theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: widget.theme.colorScheme.primary.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.pie_chart_rounded,
                  color: Colors.purple,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Favori Kategoriler',
                style: widget.theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (widget.preferences.favoriteCategories.isEmpty)
            _buildEmptyState()
          else
            SizedBox(
              height: 200,
              child: Row(
                children: [
                  Expanded(flex: 3, child: _buildPieChart()),
                  const SizedBox(width: 16),
                  Expanded(flex: 2, child: _buildLegend()),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(
              Icons.category_outlined,
              size: 48,
              color: widget.theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 12),
            Text(
              'Henüz favori kategori yok',
              style: widget.theme.textTheme.bodyMedium?.copyWith(
                color: widget.theme.colorScheme.onSurface.withValues(
                  alpha: 0.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart() {
    return PieChart(
      PieChartData(
        pieTouchData: PieTouchData(
          touchCallback: (FlTouchEvent event, pieTouchResponse) {
            setState(() {
              if (!event.isInterestedForInteractions ||
                  pieTouchResponse == null ||
                  pieTouchResponse.touchedSection == null) {
                touchedIndex = -1;
                return;
              }
              touchedIndex =
                  pieTouchResponse.touchedSection!.touchedSectionIndex;
            });
          },
        ),
        borderData: FlBorderData(show: false),
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: _getSections(),
      ),
    );
  }

  List<PieChartSectionData> _getSections() {
    final categories = _getCategoryData();
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
    ];

    return List.generate(categories.length, (index) {
      final isTouched = index == touchedIndex;
      final radius = isTouched ? 65.0 : 55.0;
      final fontSize = isTouched ? 16.0 : 12.0;

      return PieChartSectionData(
        color: colors[index % colors.length],
        value: categories[index]['value'],
        title: '${categories[index]['percentage']}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: const [Shadow(color: Colors.black26, blurRadius: 2)],
        ),
        badgeWidget: isTouched
            ? Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: widget.theme.colorScheme.surface,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Icon(
                  _getCategoryIcon(categories[index]['name']),
                  size: 20,
                  color: colors[index % colors.length],
                ),
              )
            : null,
        badgePositionPercentageOffset: 1.3,
      );
    });
  }

  Widget _buildLegend() {
    final categories = _getCategoryData();
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
    ];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        categories.length,
        (index) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: colors[index % colors.length],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  categories[index]['name'],
                  style: widget.theme.textTheme.bodySmall?.copyWith(
                    color: widget.theme.colorScheme.onSurface.withValues(
                      alpha: 0.8,
                    ),
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getCategoryData() {
    // Gerçek uygulamada bu veri backend'den gelecek
    // Şimdilik favoriteCategories'den simüle ediyoruz
    final categories = widget.preferences.favoriteCategories;
    if (categories.isEmpty) return [];

    final total = categories.length.toDouble();
    return categories.take(6).map((category) {
      final value = 100 / total;
      return {
        'name': _getCategoryDisplayName(category),
        'value': value,
        'percentage': value.toInt(),
      };
    }).toList();
  }

  String _getCategoryDisplayName(String category) {
    final displayNames = {
      'general': 'Genel',
      'technology': 'Teknoloji',
      'sports': 'Spor',
      'economy': 'Ekonomi',
      'health': 'Sağlık',
      'science': 'Bilim',
      'entertainment': 'Eğlence',
      'politics': 'Politika',
      'world': 'Dünya',
      'culture': 'Kültür',
    };
    return displayNames[category] ?? category;
  }

  IconData _getCategoryIcon(String category) {
    final icons = {
      'Genel': Icons.article_rounded,
      'Teknoloji': Icons.computer_rounded,
      'Spor': Icons.sports_soccer_rounded,
      'Ekonomi': Icons.trending_up_rounded,
      'Sağlık': Icons.health_and_safety_rounded,
      'Bilim': Icons.science_rounded,
      'Eğlence': Icons.movie_rounded,
      'Politika': Icons.account_balance_rounded,
      'Dünya': Icons.public_rounded,
      'Kültür': Icons.palette_rounded,
    };
    return icons[category] ?? Icons.category_rounded;
  }
}
