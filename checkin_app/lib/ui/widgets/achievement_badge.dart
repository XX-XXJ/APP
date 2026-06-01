import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/achievement.dart';

class AchievementBadge extends StatelessWidget {
  final Achievement achievement;
  final bool showDetails;
  final VoidCallback? onTap;
  final double size;

  const AchievementBadge({
    super.key,
    required this.achievement,
    this.showDetails = false,
    this.onTap,
    this.size = 64,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: showDetails ? _buildDetailedCard() : _buildBadge(),
    );
  }

  Widget _buildBadge() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: achievement.isUnlocked
                ? LinearGradient(
                    colors: [
                      achievement.tierColor,
                      achievement.tierColor.withValues(alpha: 0.6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: achievement.isUnlocked ? null : AppColors.surfaceVariant,
            boxShadow: achievement.isUnlocked
                ? [
                    BoxShadow(
                      color: achievement.tierColor.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Icon(
            IconData(achievement.iconCodePoint, fontFamily: 'MaterialIcons'), // ignore: non_const_argument_for_const_parameter
            color: achievement.isUnlocked ? Colors.white : AppColors.textHint,
            size: size * 0.5,
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: size + 16,
          child: Text(
            achievement.title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: achievement.isUnlocked
                  ? AppColors.textPrimary
                  : AppColors.textHint,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailedCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: achievement.isUnlocked
            ? Border.all(color: achievement.tierColor.withValues(alpha: 0.3), width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: achievement.isUnlocked
                  ? LinearGradient(
                      colors: [
                        achievement.tierColor,
                        achievement.tierColor.withValues(alpha: 0.6),
                      ],
                    )
                  : null,
              color: achievement.isUnlocked ? null : AppColors.surfaceVariant,
            ),
            child: Icon(
              IconData(achievement.iconCodePoint, // ignore: non_const_argument_for_const_parameter
                  fontFamily: 'MaterialIcons'),
              color:
                  achievement.isUnlocked ? Colors.white : AppColors.textHint,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      achievement.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: achievement.isUnlocked
                            ? AppColors.textPrimary
                            : AppColors.textHint,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: achievement.tierColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        achievement.tierName,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: achievement.tierColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  achievement.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: achievement.isUnlocked
                        ? AppColors.textSecondary
                        : AppColors.textHint,
                  ),
                ),
                if (achievement.isUnlocked && achievement.unlockedAt != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '解锁于 ${_formatDate(achievement.unlockedAt!)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.success,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (!achievement.isUnlocked)
            Icon(
              Icons.lock_rounded,
              color: AppColors.textHint,
              size: 20,
            ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.05, end: 0);
  }

  String _formatDate(DateTime date) {
    return '${date.month}月${date.day}日';
  }
}
