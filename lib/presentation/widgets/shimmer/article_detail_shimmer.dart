import 'package:flutter/material.dart';
import 'shimmer_widget.dart';

/// Haber detay sayfası skeleton loading widget'ı
class ArticleDetailShimmer extends StatelessWidget {
  const ArticleDetailShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surfaceColor = theme.colorScheme.surfaceContainerHighest;

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: ShimmerWidget(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero resim placeholder
            Container(
              width: double.infinity,
              height: 250,
              color: surfaceColor,
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kategori + Tarih satırı
                  Row(
                    children: [
                      Container(
                        width: 80,
                        height: 24,
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 100,
                        height: 14,
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Başlık satırları
                  Container(
                    width: double.infinity,
                    height: 24,
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    height: 24,
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 200,
                    height: 24,
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Kaynak bilgisi
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 120,
                            height: 14,
                            decoration: BoxDecoration(
                              color: surfaceColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 80,
                            height: 12,
                            decoration: BoxDecoration(
                              color: surfaceColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Ayırıcı
                  Container(
                    width: double.infinity,
                    height: 1,
                    color: surfaceColor,
                  ),

                  const SizedBox(height: 24),

                  // İçerik paragrafları
                  ...List.generate(4, (index) => Padding(
                    padding: EdgeInsets.only(bottom: index < 3 ? 16 : 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 14,
                          decoration: BoxDecoration(
                            color: surfaceColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: double.infinity,
                          height: 14,
                          decoration: BoxDecoration(
                            color: surfaceColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: double.infinity,
                          height: 14,
                          decoration: BoxDecoration(
                            color: surfaceColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: index.isEven ? 250.0 : 180.0,
                          height: 14,
                          decoration: BoxDecoration(
                            color: surfaceColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  )),

                  const SizedBox(height: 24),

                  // Aksiyon butonları
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(4, (index) => Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        shape: BoxShape.circle,
                      ),
                    )),
                  ),

                  const SizedBox(height: 32),

                  // İlgili haberler bölümü
                  Container(
                    width: 150,
                    height: 20,
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 3,
                      itemBuilder: (context, index) => Container(
                        width: 200,
                        height: 120,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}