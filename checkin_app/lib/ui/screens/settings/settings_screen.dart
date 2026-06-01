import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/services/notification_service.dart';
import '../../../providers/settings_provider.dart';
import '../../widgets/glass_container.dart';
import '../../dialogs/export_dialog.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.homeGradient),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            children: [
              Text(
                '设置',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ).animate().fadeIn(),

              const SizedBox(height: 20),

              // Notification section
              _buildSectionTitle('通知提醒'),
              const SizedBox(height: 8),
              GlassContainer(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _buildSwitchTile(
                      icon: Icons.notifications_rounded,
                      title: '打卡提醒',
                      subtitle: '开启后将在设定时间提醒您打卡',
                      value: settings.notificationsEnabled,
                      onChanged: (v) {
                        ref.read(settingsProvider.notifier).setNotificationsEnabled(v);
                        if (v) {
                          _scheduleNotification(settings.dailyReminderTime ?? '08:00');
                        } else {
                          NotificationService().cancelAll();
                        }
                      },
                    ),
                    if (settings.notificationsEnabled) ...[
                      const Divider(height: 1, indent: 56),
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.access_time_rounded, color: AppColors.primary, size: 20),
                        ),
                        title: Text(
                          '提醒时间',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        trailing: Text(
                          settings.dailyReminderTime ?? '08:00',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        onTap: () => _pickTime(context, ref, settings.dailyReminderTime ?? '08:00'),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Display section
              _buildSectionTitle('显示设置'),
              const SizedBox(height: 8),
              GlassContainer(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _buildSwitchTile(
                      icon: Icons.dark_mode_rounded,
                      title: '深色模式',
                      subtitle: '切换深色/浅色主题',
                      value: settings.darkMode,
                      onChanged: (v) =>
                          ref.read(settingsProvider.notifier).setDarkMode(v),
                    ),
                    const Divider(height: 1, indent: 56),
                    _buildSwitchTile(
                      icon: Icons.show_chart_rounded,
                      title: '显示连续打卡',
                      subtitle: '在首页显示连续打卡天数',
                      value: settings.showStreakOnHome,
                      onChanged: (v) =>
                          ref.read(settingsProvider.notifier).setShowStreakOnHome(v),
                    ),
                    const Divider(height: 1, indent: 56),
                    _buildSwitchTile(
                      icon: Icons.vibration_rounded,
                      title: '触觉反馈',
                      subtitle: '打卡时震动反馈',
                      value: settings.enableHapticFeedback,
                      onChanged: (v) =>
                          ref.read(settingsProvider.notifier).setEnableHapticFeedback(v),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Data section
              _buildSectionTitle('数据管理'),
              const SizedBox(height: 8),
              GlassContainer(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _buildActionTile(
                      icon: Icons.file_download_rounded,
                      title: '导出数据',
                      subtitle: '将打卡记录导出为CSV或JSON文件',
                      onTap: () => _showExportDialog(context, ref),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // About section
              _buildSectionTitle('关于'),
              const SizedBox(height: 8),
              GlassContainer(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _buildInfoTile(
                      icon: Icons.info_outline_rounded,
                      title: '版本',
                      value: 'v1.0.0',
                    ),
                    const Divider(height: 1, indent: 56),
                    _buildInfoTile(
                      icon: Icons.storage_rounded,
                      title: '数据存储',
                      value: '本地存储',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: AppColors.textHint,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.primary,
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: AppColors.textHint,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textHint,
      ),
      onTap: onTap,
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      trailing: Text(
        value,
        style: TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  void _showExportDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ExportDialog(),
    );
  }

  void _pickTime(BuildContext context, WidgetRef ref, String currentTime) async {
    final parts = currentTime.split(':');
    final initialTime = TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (picked != null) {
      final timeStr =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      ref.read(settingsProvider.notifier).setDailyReminderTime(timeStr);
      _scheduleNotification(timeStr);
    }
  }

  void _scheduleNotification(String timeStr) {
    final parts = timeStr.split(':');
    NotificationService().scheduleDaily(
      id: 0,
      title: '打卡提醒',
      body: '别忘了今天的打卡哦！',
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }
}
