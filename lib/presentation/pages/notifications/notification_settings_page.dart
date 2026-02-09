import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/notification_provider.dart';
import '../../themes/app_theme.dart';

class NotificationSettingsPage extends ConsumerStatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  ConsumerState<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState
    extends ConsumerState<NotificationSettingsPage> {
  @override
  Widget build(BuildContext context) {
    final notificationState = ref.watch(notificationProvider);
    final notificationNotifier = ref.read(notificationProvider.notifier);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bildirim Ayarları'),
        backgroundColor: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
        foregroundColor: isDark ? AppTheme.darkOnSurface : AppTheme.lightOnSurface,
        elevation: 0,
        actions: [
          if (notificationState.permissionsGranted)
            IconButton(
              icon: const Icon(Icons.bug_report_outlined),
              onPressed: () => notificationNotifier.showTestNotification(),
              tooltip: 'Test Bildirimi',
            ),
        ],
      ),
      body: notificationState.loading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Bildirim servisi başlatılıyor...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Permission Status
                  _buildPermissionCard(context, notificationState, notificationNotifier),
                  
                  const SizedBox(height: 24),
                  
                  // Daily News Settings
                  _buildDailyNewsCard(context, notificationState, notificationNotifier),
                  
                  const SizedBox(height: 16),
                  
                  // Reading Goal Settings
                  _buildReadingGoalCard(context, notificationState, notificationNotifier),
                  
                  const SizedBox(height: 16),
                  
                  // Breaking News Settings
                  _buildBreakingNewsCard(context, notificationState, notificationNotifier),
                  
                  const SizedBox(height: 16),
                  
                  // Quick Actions
                  _buildQuickActionsCard(context, notificationNotifier),
                  
                  if (notificationState.error != null) ...[
                    const SizedBox(height: 16),
                    _buildErrorCard(context, notificationState.error!, notificationNotifier),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildPermissionCard(
    BuildContext context,
    NotificationState state,
    NotificationNotifier notifier,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Card(
      elevation: 2,
      color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  state.permissionsGranted 
                      ? Icons.notifications_active 
                      : Icons.notifications_off,
                  color: state.permissionsGranted 
                      ? Colors.green 
                      : Colors.orange,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bildirim İzni',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppTheme.darkOnSurface : AppTheme.lightOnSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        state.permissionsGranted
                            ? 'Bildirimler aktif'
                            : 'Bildirimler için izin gerekli',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: (isDark ? AppTheme.darkOnSurface : AppTheme.lightOnSurface)
                              .withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!state.permissionsGranted)
                  ElevatedButton(
                    onPressed: () => notifier.requestPermissions(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('İzin Ver'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyNewsCard(
    BuildContext context,
    NotificationState state,
    NotificationNotifier notifier,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final settings = state.settings;
    
    return Card(
      elevation: 2,
      color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.schedule, color: AppTheme.primaryColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Günlük Haber Hatırlatması',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppTheme.darkOnSurface : AppTheme.lightOnSurface,
                    ),
                  ),
                ),
                Switch(
                  value: settings.dailyNewsEnabled,
                  onChanged: state.permissionsGranted
                      ? (value) => notifier.updateDailyNewsSettings(enabled: value)
                      : null,
                  thumbColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return AppTheme.primaryColor;
                    }
                    return null;
                  }),
                ),
              ],
            ),
            if (settings.dailyNewsEnabled) ...[
              const SizedBox(height: 16),
              Text(
                'Hatırlatma Zamanı',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppTheme.darkOnSurface : AppTheme.lightOnSurface,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: state.permissionsGranted ? () => _selectTime(
                  context,
                  TimeOfDay(hour: settings.dailyNewsHour, minute: settings.dailyNewsMinute),
                  (time) => notifier.updateDailyNewsSettings(
                    hour: time.hour,
                    minute: time.minute,
                  ),
                ) : null,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: (isDark ? AppTheme.darkOnSurface : AppTheme.lightOnSurface)
                          .withValues(alpha: 0.3),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '${settings.dailyNewsHour.toString().padLeft(2, '0')}:${settings.dailyNewsMinute.toString().padLeft(2, '0')}',
                        style: theme.textTheme.bodyLarge,
                      ),
                      const Spacer(),
                      const Icon(Icons.edit, size: 18),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReadingGoalCard(
    BuildContext context,
    NotificationState state,
    NotificationNotifier notifier,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final settings = state.settings;
    
    return Card(
      elevation: 2,
      color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.track_changes, color: AppTheme.accentColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Okuma Hedefi Hatırlatması',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppTheme.darkOnSurface : AppTheme.lightOnSurface,
                    ),
                  ),
                ),
                Switch(
                  value: settings.readingGoalEnabled,
                  onChanged: state.permissionsGranted
                      ? (value) => notifier.updateReadingGoalSettings(enabled: value)
                      : null,
                  thumbColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return AppTheme.accentColor;
                    }
                    return null;
                  }),
                ),
              ],
            ),
            if (settings.readingGoalEnabled) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Günlük Hedef',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            IconButton(
                              onPressed: state.permissionsGranted && settings.dailyReadingGoal > 1
                                  ? () => notifier.updateReadingGoalSettings(
                                        dailyGoal: settings.dailyReadingGoal - 1,
                                      )
                                  : null,
                              icon: const Icon(Icons.remove_circle_outline),
                            ),
                            Text(
                              '${settings.dailyReadingGoal} haber',
                              style: theme.textTheme.titleMedium,
                            ),
                            IconButton(
                              onPressed: state.permissionsGranted && settings.dailyReadingGoal < 50
                                  ? () => notifier.updateReadingGoalSettings(
                                        dailyGoal: settings.dailyReadingGoal + 1,
                                      )
                                  : null,
                              icon: const Icon(Icons.add_circle_outline),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hatırlatma Zamanı',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: state.permissionsGranted ? () => _selectTime(
                            context,
                            TimeOfDay(hour: settings.readingGoalHour, minute: settings.readingGoalMinute),
                            (time) => notifier.updateReadingGoalSettings(
                              hour: time.hour,
                              minute: time.minute,
                            ),
                          ) : null,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: (isDark ? AppTheme.darkOnSurface : AppTheme.lightOnSurface)
                                    .withValues(alpha: 0.3),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${settings.readingGoalHour.toString().padLeft(2, '0')}:${settings.readingGoalMinute.toString().padLeft(2, '0')}',
                              style: theme.textTheme.bodyLarge,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBreakingNewsCard(
    BuildContext context,
    NotificationState state,
    NotificationNotifier notifier,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final settings = state.settings;
    
    return Card(
      elevation: 2,
      color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.flash_on, color: Colors.red),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Son Dakika Haberleri',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppTheme.darkOnSurface : AppTheme.lightOnSurface,
                        ),
                      ),
                      Text(
                        'Önemli haberler için anında bildirim',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: (isDark ? AppTheme.darkOnSurface : AppTheme.lightOnSurface)
                              .withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: settings.breakingNewsEnabled,
                  onChanged: state.permissionsGranted
                      ? (value) => notifier.updateBreakingNewsEnabled(value)
                      : null,
                  thumbColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return Colors.red;
                    }
                    return null;
                  }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsCard(
    BuildContext context,
    NotificationNotifier notifier,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Card(
      elevation: 2,
      color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hızlı İşlemler',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? AppTheme.darkOnSurface : AppTheme.lightOnSurface,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => notifier.showTestNotification(),
                    icon: const Icon(Icons.bug_report),
                    label: const Text('Test Bildirimi'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => notifier.cancelAllNotifications(),
                    icon: const Icon(Icons.clear_all),
                    label: const Text('Tümünü İptal Et'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
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

  Widget _buildErrorCard(
    BuildContext context,
    String error,
    NotificationNotifier notifier,
  ) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 2,
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.error, color: Colors.red),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Hata',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => notifier.clearError(),
                  icon: const Icon(Icons.close, color: Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.red.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectTime(
    BuildContext context,
    TimeOfDay initialTime,
    Function(TimeOfDay) onTimeSelected,
  ) async {
    final time = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    
    if (time != null) {
      onTimeSelected(time);
    }
  }
}