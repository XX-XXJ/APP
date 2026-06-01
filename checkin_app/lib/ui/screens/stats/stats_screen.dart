import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../providers/checkin_provider.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/stat_chart.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  int _selectedPeriod = 0; // 0=week, 1=month, 2=year
  String? _selectedItemId;

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(checkInItemsProvider);
    final statsData = ref.watch(statsDataProvider);
    final totalStats = ref.watch(totalStatsProvider);

    final now = DateTime.now();
    final range = _getDateRange(now);
    final startDate = range['start']!;
    final endDate = range['end']!;

    // Daily check-in counts
    final dailyCounts = statsData.getCountByDate(startDate, endDate);

    // Item distribution
    final itemCounts = statsData.getCountByItem(startDate, endDate);
    final itemDistribution = <String, Map<String, dynamic>>{};
    for (var entry in itemCounts.entries) {
      final item = items.where((i) => i.id == entry.key).firstOrNull;
      if (item != null) {
        itemDistribution[entry.key] = {
          'name': item.name,
          'count': entry.value,
          'color': Color(item.colorValue),
        };
      }
    }

    // Trend data
    final trendData = _buildTrendData(dailyCounts, startDate, endDate);

    // Selected item stats
    final selectedStreak = _selectedItemId != null
        ? statsData.getCurrentStreak(_selectedItemId!)
        : 0;
    final selectedLongest = _selectedItemId != null
        ? statsData.getLongestStreak(_selectedItemId!)
        : 0;
    final selectedTotal = _selectedItemId != null
        ? statsData.getCheckinDays(_selectedItemId!)
        : 0;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.homeGradient),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // Title
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Text(
                    '统计分析',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ).animate().fadeIn(),
              ),

              // Overview cards
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildOverviewCard(
                          '总打卡',
                          '${totalStats['totalCheckins'] ?? 0}',
                          Icons.check_circle_outline_rounded,
                          AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildOverviewCard(
                          '打卡天数',
                          '${totalStats['totalDays'] ?? 0}',
                          Icons.calendar_today_rounded,
                          const Color(0xFF34D399),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildOverviewCard(
                          '成就',
                          '${totalStats['unlockedAchievements'] ?? 0}',
                          Icons.emoji_events_rounded,
                          const Color(0xFFFFD700),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Period selector
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                  child: _buildPeriodSelector(),
                ),
              ),

              // Bar chart
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: GlassContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '打卡次数',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (_selectedPeriod == 0)
                          WeeklyBarChart(
                            data: dailyCounts,
                            weekStart: AppDateUtils.startOfWeek(now),
                          )
                        else
                          TrendLineChart(data: trendData),
                      ],
                    ),
                  ),
                ),
              ),

              // Item distribution
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: GlassContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '项目分布',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ItemPieChart(data: itemDistribution),
                      ],
                    ),
                  ),
                ),
              ),

              // Item selector for details
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildItemChip(null, '全部'),
                        ...items.map((item) => _buildItemChip(
                              item.id,
                              item.name,
                              color: Color(item.colorValue),
                            )),
                      ],
                    ),
                  ),
                ),
              ),

              // Item details
              if (_selectedItemId != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    child: GlassContainer(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildDetailStat('当前连续', '$selectedStreak天'),
                          Container(
                              width: 1,
                              height: 40,
                              color: AppColors.surfaceVariant),
                          _buildDetailStat('最长连续', '$selectedLongest天'),
                          Container(
                              width: 1,
                              height: 40,
                              color: AppColors.surfaceVariant),
                          _buildDetailStat('总打卡', '$selectedTotal天'),
                        ],
                      ),
                    ),
                  ),
                )
              else
                const SliverToBoxAdapter(
                    child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, DateTime> _getDateRange(DateTime now) {
    switch (_selectedPeriod) {
      case 0: // week
        return {
          'start': AppDateUtils.startOfWeek(now),
          'end': AppDateUtils.endOfWeek(now),
        };
      case 1: // month
        return {
          'start': DateTime(now.year, now.month, 1),
          'end': DateTime(now.year, now.month + 1, 0),
        };
      case 2: // year
        return {
          'start': DateTime(now.year, 1, 1),
          'end': DateTime(now.year, 12, 31),
        };
      default:
        return {'start': now, 'end': now};
    }
  }

  List<MapEntry<String, int>> _buildTrendData(
      Map<String, int> counts, DateTime start, DateTime end) {
    final result = <MapEntry<String, int>>[];
    var current = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day);

    while (!current.isAfter(endDate)) {
      final key = AppDateUtils.formatDate(current);
      result.add(MapEntry(key, counts[key] ?? 0));
      current = current.add(const Duration(days: 1));
    }

    // For year view, aggregate by week
    if (_selectedPeriod == 2 && result.length > 52) {
      final weekly = <MapEntry<String, int>>[];
      for (int i = 0; i < result.length; i += 7) {
        final end = (i + 7 < result.length) ? i + 7 : result.length;
        final weekData = result.sublist(i, end);
        final total = weekData.fold<int>(0, (a, b) => a + b.value);
        weekly.add(MapEntry(weekData.first.key, total));
      }
      return weekly;
    }

    // For month view, aggregate every 3 days if too many
    if (_selectedPeriod == 1 && result.length > 20) {
      final aggregated = <MapEntry<String, int>>[];
      for (int i = 0; i < result.length; i += 3) {
        final end = (i + 3 < result.length) ? i + 3 : result.length;
        final chunk = result.sublist(i, end);
        final total = chunk.fold<int>(0, (a, b) => a + b.value);
        aggregated.add(MapEntry(chunk.first.key, total));
      }
      return aggregated;
    }

    return result;
  }

  Widget _buildOverviewCard(
      String title, String value, IconData icon, Color color) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
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
            title,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms);
  }

  Widget _buildPeriodSelector() {
    final periods = ['本周', '本月', '本年'];
    return GlassContainer(
      padding: const EdgeInsets.all(4),
      child: Row(
        children: List.generate(periods.length, (index) {
          final isSelected = _selectedPeriod == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedPeriod = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  periods[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildItemChip(String? itemId, String label, {Color? color}) {
    final isSelected = _selectedItemId == itemId;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _selectedItemId = itemId),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? (color ?? AppColors.primary)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: (color ?? AppColors.primary).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
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
}
