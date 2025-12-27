import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Performans izleme sayfası
/// RAM, Disk ve Network kullanımını gösterir
class PerformanceMonitorPage extends ConsumerStatefulWidget {
  const PerformanceMonitorPage({super.key});

  @override
  ConsumerState<PerformanceMonitorPage> createState() => _PerformanceMonitorPageState();
}

class _PerformanceMonitorPageState extends ConsumerState<PerformanceMonitorPage> {
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Performans İzleme'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Bilgi kartı
          Card(
            color: Colors.blue.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        'Kaynak Kullanım Bilgileri',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Flutter uygulamaları platform üzerinde çalıştığı için, '
                    'gerçek zamanlı kaynak kullanımı direkt olarak ölçülemez. '
                    'Aşağıdaki veriler tahmini değerlerdir.',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // RAM Kullanımı
          _buildResourceCard(
            context,
            icon: Icons.memory_rounded,
            title: 'RAM Kullanımı',
            color: Colors.purple,
            items: [
              _ResourceItem(
                label: 'Tahmini Kullanım',
                value: '50-150 MB',
                description: 'Ortalama bir Flutter uygulaması',
              ),
              _ResourceItem(
                label: 'Cache Boyutu',
                value: 'Değişken',
                description: 'Görsel önbelleği ve veri cache\'i',
              ),
              _ResourceItem(
                label: 'Optimizasyon',
                value: 'Aktif',
                description: 'Görsel cache limiti: 100MB',
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Disk Kullanımı
          _buildResourceCard(
            context,
            icon: Icons.storage_rounded,
            title: 'Disk Kullanımı',
            color: Colors.orange,
            items: [
              _ResourceItem(
                label: 'Uygulama Boyutu',
                value: '~25-40 MB',
                description: 'APK boyutu',
              ),
              _ResourceItem(
                label: 'Cache Boyutu',
                value: '10-50 MB',
                description: 'Görsel ve veri cache\'i',
              ),
              _ResourceItem(
                label: 'Veritabanı',
                value: '1-5 MB',
                description: 'Hive local database',
              ),
              _ResourceItem(
                label: 'Toplam Tahmini',
                value: '~50-100 MB',
                description: 'Kurulum sonrası toplam',
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Network Kullanımı
          _buildResourceCard(
            context,
            icon: Icons.network_check_rounded,
            title: 'Network Kullanımı',
            color: Colors.green,
            items: [
              _ResourceItem(
                label: 'RSS Feed Çekme',
                value: '~100-500 KB',
                description: 'Her güncelleme başına',
              ),
              _ResourceItem(
                label: 'Görsel İndirme',
                value: '~50-200 KB/görsel',
                description: 'Cache edilir, tekrar indirilmez',
              ),
              _ResourceItem(
                label: 'Günlük Ortalama',
                value: '~5-20 MB',
                description: 'Normal kullanımda',
              ),
              _ResourceItem(
                label: 'Optimizasyon',
                value: 'Aktif',
                description: 'WebP formatı, cache, compression',
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Optimizasyon İpuçları
          Card(
            color: Colors.green.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.tips_and_updates_rounded, color: Colors.green),
                      const SizedBox(width: 8),
                      Text(
                        'Optimizasyon İpuçları',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildTip('Önbelleği düzenli olarak temizleyin'),
                  _buildTip('WiFi üzerinden güncellemeleri tercih edin'),
                  _buildTip('Görsel kalitesi ayarlarını düşürün'),
                  _buildTip('Arka plan senkronizasyonunu sınırlayın'),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Temizleme Butonu
          ElevatedButton.icon(
            onPressed: () => _showClearCacheDialog(context),
            icon: const Icon(Icons.cleaning_services_rounded),
            label: const Text('Önbelleği Temizle'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildResourceCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required List<_ResourceItem> items,
  }) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            
            // İçerik öğeleri
            ...items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.label,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        item.value,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
  
  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Önbelleği Temizle'),
        content: const Text(
          'Tüm önbelleğe alınmış veriler temizlenecek. Bu işlem disk alanı açacak ancak tekrar yükleme gerektirebilir.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Önbellek temizleme özelliği ayarlar sayfasından erişilebilir'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Temizle'),
          ),
        ],
      ),
    );
  }
}

class _ResourceItem {
  final String label;
  final String value;
  final String description;

  _ResourceItem({
    required this.label,
    required this.value,
    required this.description,
  });
}