import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/hive_service.dart';
import '../../themes/app_theme.dart';

/// Bildirim tercihleri sayfası - kategori bazlı, zaman bazlı bildirim ayarları
class NotificationPreferencesPage extends ConsumerStatefulWidget {
  const NotificationPreferencesPage({super.key});

  @override
  ConsumerState<NotificationPreferencesPage> createState() => _NotificationPreferencesPageState();
}

class _NotificationPreferencesPageState extends ConsumerState<NotificationPreferencesPage> {
  Map<String, bool> _categoryNotifications = {};
  String _frequency = 'daily';
  List<int> _notificationTimes = [];
  bool _enableBreakingNews = true;
  bool _enableWeeklyDigest = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  void _loadPreferences() {
    // Hive'dan tercihleri yükle
    final categoryBox = HiveService.categoryNotificationsBox;
    final frequencyBox = HiveService.notificationFrequencyBox;
    
    // Kategori bildirimleri
    final categories = ['genel', 'spor', 'teknoloji', 'ekonomi', 'saglik', 'egitim', 'magazin', 'bilim', 'otomobil'];
    for (final category in categories) {
      _categoryNotifications[category] = categoryBox.get(category, defaultValue: true) as bool;
    }
    
    // Bildirim sıklığı
    _frequency = frequencyBox.get('frequency', defaultValue: 'daily') as String;
    
    // Bildirim saatleri
    _notificationTimes = frequencyBox.get('times', defaultValue: [9, 18]) as List<int>;
    
    // Diğer ayarlar
    _enableBreakingNews = frequencyBox.get('breakingNews', defaultValue: true) as bool;
    _enableWeeklyDigest = frequencyBox.get('weeklyDigest', defaultValue: false) as bool;
    
    setState(() {});
  }

  void _savePreferences() {
    final categoryBox = HiveService.categoryNotificationsBox;
    final frequencyBox = HiveService.notificationFrequencyBox;
    
    // Kategori bildirimlerini kaydet
    for (final entry in _categoryNotifications.entries) {
      categoryBox.put(entry.key, entry.value);
    }
    
    // Bildirim sıklığı
    frequencyBox.put('frequency', _frequency);
    frequencyBox.put('times', _notificationTimes);
    frequencyBox.put('breakingNews', _enableBreakingNews);
    frequencyBox.put('weeklyDigest', _enableWeeklyDigest);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tercihler kaydedildi')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bildirim Tercihleri'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_rounded),
            onPressed: _savePreferences,
            tooltip: 'Kaydet',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Bildirim Sıklığı
          _buildFrequencySection(theme),
          const SizedBox(height: 24),
          
          // Kategori Bildirimleri
          _buildCategoryNotificationsSection(theme),
          const SizedBox(height: 24),
          
          // Bildirim Saatleri
          _buildNotificationTimesSection(theme),
          const SizedBox(height: 24),
          
          // Özel Bildirimler
          _buildSpecialNotificationsSection(theme),
        ],
      ),
    );
  }

  Widget _buildFrequencySection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bildirim Sıklığı',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'never',
                  label: Text('Asla'),
                ),
                ButtonSegment(
                  value: 'daily',
                  label: Text('Günlük'),
                ),
                ButtonSegment(
                  value: 'weekly',
                  label: Text('Haftalık'),
                ),
              ],
              selected: {_frequency},
              onSelectionChanged: (Set<String> selected) {
                setState(() {
                  _frequency = selected.first;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryNotificationsSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kategori Bildirimleri',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ..._categoryNotifications.entries.map((entry) {
              return SwitchListTile(
                title: Text(_getCategoryName(entry.key)),
                value: entry.value,
                onChanged: (value) {
                  setState(() {
                    _categoryNotifications[entry.key] = value;
                  });
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationTimesSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bildirim Saatleri',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ..._notificationTimes.asMap().entries.map((entry) {
              final index = entry.key;
              final hour = entry.value;
              return ListTile(
                title: Text('Bildirim ${index + 1}'),
                subtitle: Text('${hour.toString().padLeft(2, '0')}:00'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_rounded),
                  onPressed: () {
                    setState(() {
                      _notificationTimes.removeAt(index);
                    });
                  },
                ),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay(hour: hour, minute: 0),
                  );
                  if (time != null) {
                    setState(() {
                      _notificationTimes[index] = time.hour;
                    });
                  }
                },
              );
            }).toList(),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: const TimeOfDay(hour: 12, minute: 0),
                );
                if (time != null) {
                  setState(() {
                    _notificationTimes.add(time.hour);
                  });
                }
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text('Saat Ekle'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialNotificationsSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Özel Bildirimler',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Acil Haberler'),
              subtitle: const Text('Önemli haberler için anında bildirim'),
              value: _enableBreakingNews,
              onChanged: (value) {
                setState(() {
                  _enableBreakingNews = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Haftalık Özet'),
              subtitle: const Text('Haftalık okuma özeti bildirimi'),
              value: _enableWeeklyDigest,
              onChanged: (value) {
                setState(() {
                  _enableWeeklyDigest = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getCategoryName(String categoryId) {
    const categoryNames = {
      'genel': 'Genel',
      'spor': 'Spor',
      'teknoloji': 'Teknoloji',
      'ekonomi': 'Ekonomi',
      'saglik': 'Sağlık',
      'egitim': 'Eğitim',
      'magazin': 'Magazin',
      'bilim': 'Bilim',
      'otomobil': 'Otomobil',
    };
    return categoryNames[categoryId] ?? categoryId;
  }
}

