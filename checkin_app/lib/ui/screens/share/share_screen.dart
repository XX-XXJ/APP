import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../providers/checkin_provider.dart';
import '../../widgets/glass_container.dart';

class ShareScreen extends ConsumerWidget {
  const ShareScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(totalStatsProvider);
    final streak = ref.watch(currentStreakProvider);
    final achievements = ref.watch(achievementsProvider);
    final unlockedAchievements =
        achievements.where((a) => a.isUnlocked).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('分享打卡'),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.homeGradient),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Share card preview
            GlassContainer(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // App name
                  const Text(
                    '打卡记录',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Stats row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildShareStat('连续打卡', '$streak天',
                          Icons.local_fire_department_rounded),
                      _buildShareStat(
                          '总打卡', '${stats['totalCheckins'] ?? 0}次',
                          Icons.check_circle_rounded),
                      _buildShareStat(
                          '打卡天数', '${stats['totalDays'] ?? 0}天',
                          Icons.calendar_today_rounded),
                    ],
                  ),

                  if (unlockedAchievements.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 12),
                    Text(
                      '已解锁成就',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: unlockedAchievements.take(6).map((a) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: a.tierColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                IconData(a.iconCodePoint, // ignore: non_const_argument_for_const_parameter
                                    fontFamily: 'MaterialIcons'),
                                size: 14,
                                color: a.tierColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                a.title,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: a.tierColor,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],

                  const SizedBox(height: 20),
                  Text(
                    AppDateUtils.formatDate(DateTime.now()),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Share buttons
            ElevatedButton.icon(
              onPressed: () {
                final text = _buildShareText(stats, streak, unlockedAchievements.length);
                SharePlus.instance.share(ShareParams(text: text));
              },
              icon: const Icon(Icons.share_rounded),
              label: const Text('分享文字'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),

            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(
                  text: _buildShareText(stats, streak, unlockedAchievements.length),
                ));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('已复制到剪贴板')),
                );
              },
              icon: const Icon(Icons.copy_rounded),
              label: const Text('复制文字'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: AppColors.primary),
                foregroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  String _buildShareText(
      Map<String, int> stats, int streak, int achievementCount) {
    return '''📊 我的打卡记录

🔥 连续打卡: $streak天
✅ 总打卡次数: ${stats['totalCheckins'] ?? 0}次
📅 打卡天数: ${stats['totalDays'] ?? 0}天
🏆 已解锁成就: $achievementCount个

坚持打卡，遇见更好的自己！
#打卡记录 #自律生活''';
  }
}
