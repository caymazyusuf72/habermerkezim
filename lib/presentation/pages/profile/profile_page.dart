import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../domain/entities/user_profile.dart';
import '../../providers/providers.dart';
import '../../themes/app_theme.dart';
import '../../widgets/loading/shimmer_loading.dart';

/// Profil sayfası - kullanıcı profili, istatistikler ve tercihler
class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  @override
  void initState() {
    super.initState();
    // Sayfa açıldığında profili yükle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userProfileProvider.notifier).loadProfile();
      ref.read(userProfileProvider.notifier).refreshStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(userProfileProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.person_rounded,
                color: AppTheme.primaryBlue,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Profil',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              ref.read(userProfileProvider.notifier).refreshStats();
            },
            tooltip: 'Yenile',
          ),
        ],
      ),
      body: profileState.isLoading
          ? const NewsListShimmer()
          : profileState.isError
              ? _buildErrorWidget(profileState.errorMessage ?? 'Bilinmeyen hata')
              : profileState.hasData && profileState.profile != null
                  ? _buildProfileContent(context, profileState.profile!, theme)
                  : _buildEmptyState(context),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Hata',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref.read(userProfileProvider.notifier).loadProfile();
            },
            child: const Text('Tekrar Dene'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_outline_rounded,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Profil bulunamadı',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Profil oluşturuluyor...',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent(
    BuildContext context,
    UserProfile profile,
    ThemeData theme,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profil Header
          _buildProfileHeader(context, profile, theme),
          
          const SizedBox(height: 24),
          
          // İstatistik Kartları
          _buildStatsSection(context, profile.stats, theme),
          
          const SizedBox(height: 24),
          
          // Tercihler Bölümü
          _buildPreferencesSection(context, profile.preferences, theme),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    UserProfile profile,
    ThemeData theme,
  ) {
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  theme.colorScheme.surface,
                  theme.colorScheme.surfaceVariant,
                ]
              : [
                  Colors.white,
                  AppTheme.primaryBlue.withOpacity(0.05),
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Avatar - daha büyük ve modern
            GestureDetector(
              onTap: () => _showAvatarEditDialog(context, profile),
              child: Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.primaryBlue,
                          AppTheme.primaryBlue.withOpacity(0.7),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryBlue.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty
                        ? ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: profile.avatarUrl!,
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) => Icon(
                                Icons.person_rounded,
                                size: 50,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : Icon(
                            Icons.person_rounded,
                            size: 50,
                            color: Colors.white,
                          ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // İsim - daha büyük ve vurgulu
            Text(
              profile.name ?? 'Kullanıcı',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
            
            if (profile.email != null && profile.email!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.email_rounded,
                    size: 14,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    profile.email!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ],
            
            const SizedBox(height: 20),
            
            // Düzenle Butonu - daha modern
            ElevatedButton.icon(
              onPressed: () => _showEditProfileDialog(context, profile),
              icon: const Icon(Icons.edit_rounded, size: 18),
              label: const Text('Profili Düzenle'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(
    BuildContext context,
    UserStats stats,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.analytics_rounded,
                color: AppTheme.primaryBlue,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'İstatistikler',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.3, // Daha yüksek kartlar için
          children: [
            _buildStatCard(
              context,
              'Okunan Makale',
              '${stats.totalArticlesRead}',
              Icons.article_rounded,
              Colors.blue,
            ),
            _buildStatCard(
              context,
              'Favoriler',
              '${stats.totalFavorites}',
              Icons.favorite_rounded,
              Colors.red,
            ),
            _buildStatCard(
              context,
              'Okuma Listesi',
              '${stats.totalReadingList}',
              Icons.bookmark_rounded,
              Colors.orange,
            ),
            _buildStatCard(
              context,
              'Okuma Serisi',
              '${stats.streakDays} gün',
              Icons.local_fire_department_rounded,
              Colors.deepOrange,
            ),
            if (stats.lastReadDate != null)
              _buildStatCard(
                context,
                'Son Okuma',
                _formatDate(stats.lastReadDate!),
                Icons.access_time_rounded,
                Colors.purple,
              ),
          ],
        ),
        
        if (stats.categoryReadCount.isNotEmpty) ...[
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kategori Dağılımı',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...stats.categoryReadCount.entries.take(5).map((entry) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              entry.key,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${entry.value}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryBlue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 10),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: color,
                  height: 1.2,
                ),
                maxLines: 1,
              ),
            ),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesSection(
    BuildContext context,
    UserPreferences preferences,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.settings_rounded,
                color: AppTheme.primaryBlue,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Tercihler',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Bildirimler'),
                subtitle: const Text('Push bildirimlerini etkinleştir'),
                value: preferences.enableNotifications,
                onChanged: (value) {
                  ref.read(userProfileProvider.notifier).updatePreferences(
                    preferences.copyWith(enableNotifications: value),
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                title: const Text('Favori Kategoriler'),
                subtitle: Text(
                  preferences.favoriteCategories.isEmpty
                      ? 'Henüz favori kategori yok'
                      : preferences.favoriteCategories.join(', '),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // TODO: Favori kategoriler sayfası
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Yakında eklenecek')),
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                title: const Text('Engellenen Kaynaklar'),
                subtitle: Text(
                  preferences.blockedSources.isEmpty
                      ? 'Engellenen kaynak yok'
                      : '${preferences.blockedSources.length} kaynak engellendi',
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // TODO: Engellenen kaynaklar sayfası
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Yakında eklenecek')),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showEditProfileDialog(BuildContext context, UserProfile profile) {
    final nameController = TextEditingController(text: profile.name ?? '');
    final emailController = TextEditingController(text: profile.email ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Profili Düzenle'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'İsim',
                  hintText: 'Adınızı girin',
                  prefixIcon: Icon(Icons.person_rounded),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'E-posta',
                  hintText: 'E-posta adresinizi girin',
                  prefixIcon: Icon(Icons.email_rounded),
                ),
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final email = emailController.text.trim();
              
              final updatedProfile = profile.copyWith(
                name: name.isEmpty ? null : name,
                email: email.isEmpty ? null : email,
              );
              ref.read(userProfileProvider.notifier).updateProfile(updatedProfile);
              
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profil güncellendi')),
              );
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  void _showAvatarEditDialog(BuildContext context, UserProfile profile) {
    final urlController = TextEditingController(text: profile.avatarUrl ?? '');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Avatar Değiştir'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Avatar URL\'si girin:'),
            const SizedBox(height: 16),
            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                labelText: 'Avatar URL',
                hintText: 'https://example.com/avatar.jpg',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              ref.read(userProfileProvider.notifier).updateAvatar(null);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Avatar kaldırıldı')),
              );
            },
            child: const Text('Kaldır'),
          ),
          ElevatedButton(
            onPressed: () {
              final url = urlController.text.trim();
              ref.read(userProfileProvider.notifier).updateAvatar(url.isEmpty ? null : url);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Avatar güncellendi')),
              );
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Bugün';
    } else if (difference.inDays == 1) {
      return 'Dün';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} gün önce';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks hafta önce';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

