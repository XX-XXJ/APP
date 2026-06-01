import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import 'glass_container.dart';

class StreakWidget extends StatelessWidget {
  final int streakDays;
  final int totalDays;

  const StreakWidget({
    super.key,
    required this.streakDays,
    required this.totalDays,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStat(
            context,
            icon: Icons.local_fire_department_rounded,
            value: streakDays.toString(),
            label: '连续打卡',
            color: const Color(0xFFFF6B35),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.surfaceVariant,
          ),
          _buildStat(
            context,
            icon: Icons.calendar_today_rounded,
            value: totalDays.toString(),
            label: '打卡天数',
            color: AppColors.primary,
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.surfaceVariant,
          ),
          _buildStat(
            context,
            icon: Icons.emoji_events_rounded,
            value: _getMotivationText(),
            label: '当前状态',
            color: AppColors.accent,
            isText: true,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildStat(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    bool isText = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 6),
        isText
            ? Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              )
            : Text(
                value,
                style: TextStyle(
                  fontSize: 22,
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

  String _getMotivationText() {
    if (streakDays >= 100) return '传奇';
    if (streakDays >= 30) return '坚持';
    if (streakDays >= 7) return '加油';
    if (streakDays >= 3) return '起步';
    return '开始';
  }
}
