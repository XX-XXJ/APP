import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/models/checkin_item.dart';
import '../../../data/models/checkin_record.dart';
import '../../../providers/checkin_provider.dart';
import '../../widgets/calendar_widget.dart';
import '../../widgets/checkin_card.dart';
import '../../widgets/streak_widget.dart';
import '../../dialogs/add_project_dialog.dart';

class CheckInItemWrapper {
  final CheckInItem item;
  final bool isCheckedIn;
  final CheckInRecord? record;
  CheckInItemWrapper(this.item, this.isCheckedIn, this.record);
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  DateTime _selectedDate = AppDateUtils.today();
  DateTime _focusedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(itemsForDateProvider(_selectedDate));
    final selectedDateRecords = ref.watch(selectedDateRecordsProvider(_selectedDate));
    final calendarData = ref.watch(calendarRecordsProvider);
    final streak = ref.watch(currentStreakProvider);
    final totalDays = ref.watch(totalStatsProvider)['totalDays'] ?? 0;

    // Split into unchecked and checked
    final uncheckedItems = <CheckInItemWrapper>[];
    final checkedItems = <CheckInItemWrapper>[];
    for (final item in items) {
      final isCheckedIn = ref.watch(
          isCheckedInOnDateProvider((itemId: item.id, date: _selectedDate)));
      final record = selectedDateRecords
          .where((r) => r.itemId == item.id)
          .firstOrNull;
      final wrapper = CheckInItemWrapper(item, isCheckedIn, record);
      if (isCheckedIn) {
        checkedItems.add(wrapper);
      } else {
        uncheckedItems.add(wrapper);
      }
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.homeGradient,
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getGreeting(),
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '打卡记录',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => _showAddProjectDialog(context),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.add_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 400.ms),
              ),

              // Streak Widget
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                  child: StreakWidget(
                    streakDays: streak,
                    totalDays: totalDays,
                  ),
                ),
              ),

              // Calendar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: CalendarWidget(
                    selectedDate: _selectedDate,
                    focusedDate: _focusedDate,
                    checkinData: calendarData,
                    onDaySelected: (selected, focused) {
                      setState(() {
                        _selectedDate = selected;
                        _focusedDate = focused;
                      });
                    },
                    onPageChanged: (focused) {
                      setState(() => _focusedDate = focused);
                    },
                  ),
                ),
              ),

              // Section title
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                  child: Row(
                    children: [
                      Text(
                        AppDateUtils.isToday(_selectedDate)
                            ? '今日打卡'
                            : '${_selectedDate.month}月${_selectedDate.day}日',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${checkedItems.length}/${items.length}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Empty state
              if (items.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Icon(
                          Icons.event_note_rounded,
                          size: 64,
                          color: AppColors.textHint.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '还没有打卡项目',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textHint,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => _showAddProjectDialog(context),
                          child: const Text('创建第一个打卡项目'),
                        ),
                      ],
                    ).animate().fadeIn(delay: 200.ms),
                  ),
                )
              else ...[
                // Unchecked items with swipe actions
                if (uncheckedItems.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final wrapper = uncheckedItems[index];
                          return _buildDismissibleCard(wrapper, index);
                        },
                        childCount: uncheckedItems.length,
                      ),
                    ),
                  ),

                // Checked items section
                if (checkedItems.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                      child: Text(
                        '已完成',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final wrapper = checkedItems[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: CheckInCard(
                              item: wrapper.item,
                              todayRecord: wrapper.record,
                              isCheckedIn: true,
                              onTap: () =>
                                  _handleCheckIn(wrapper.item.id, true),
                              onLongPress: () =>
                                  _showEditDialog(wrapper.item),
                            ),
                          )
                              .animate()
                              .fadeIn(
                                delay: Duration(milliseconds: 50 * index),
                                duration: 300.ms,
                              );
                        },
                        childCount: checkedItems.length,
                      ),
                    ),
                  ),
                ],
                if (uncheckedItems.isEmpty && checkedItems.isEmpty)
                  const SliverToBoxAdapter(
                      child: SizedBox(height: 100)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDismissibleCard(CheckInItemWrapper wrapper, int index) {
    return Dismissible(
      key: ValueKey(wrapper.item.id),
      // Right to left (swipe left) = delay to tomorrow
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFFF9800),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.schedule_rounded, color: Colors.white, size: 28),
            SizedBox(height: 4),
            Text('明天',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
      // Left to right (swipe right) = check in
      secondaryBackground: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF4CAF50),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_rounded, color: Colors.white, size: 28),
            SizedBox(height: 4),
            Text('打卡',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Swipe right = check in
          _handleCheckIn(wrapper.item.id, false);
          return true;
        } else if (direction == DismissDirection.endToStart) {
          // Swipe left = delay to tomorrow
          final tomorrow = DateTime.now().add(const Duration(days: 1));
          ref.read(deferredItemsProvider.notifier).defer(
              wrapper.item.id,
              DateTime(tomorrow.year, tomorrow.month, tomorrow.day));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('已延迟到明天: ${wrapper.item.name}'),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.all(16),
            ),
          );
          return true;
        }
        return false;
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: CheckInCard(
          item: wrapper.item,
          todayRecord: wrapper.record,
          isCheckedIn: false,
          onTap: () => _handleCheckIn(wrapper.item.id, false),
          onLongPress: () => _showEditDialog(wrapper.item),
        ),
      ),
    )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 80 * index),
          duration: 400.ms,
        )
        .slideX(begin: 0.05, end: 0);
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 6) return '夜深了';
    if (hour < 12) return '早上好';
    if (hour < 14) return '中午好';
    if (hour < 18) return '下午好';
    return '晚上好';
  }

  void _handleCheckIn(String itemId, bool isCheckedIn) async {
    HapticFeedback.mediumImpact();
    final notifier = ref.read(selectedDateRecordsProvider(_selectedDate).notifier);
    if (isCheckedIn) {
      await notifier.cancelCheckIn(itemId);
    } else {
      await notifier.checkIn(itemId);
      // Check achievements
      if (mounted) {
        final newAchievements = await ref
            .read(achievementsProvider.notifier)
            .checkAchievements();
        if (newAchievements.isNotEmpty && mounted) {
          _showAchievementUnlocked(newAchievements.first);
        }
      }
    }
    // Refresh calendar and today's records
    ref.read(calendarRecordsProvider.notifier).refresh();
    ref.read(todayRecordsProvider.notifier).refresh();
  }

  void _showAchievementUnlocked(dynamic achievement) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.emoji_events_rounded,
                color: Color(0xFFFFD700), size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '成就解锁: ${achievement.title}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.textPrimary.withValues(alpha: 0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showAddProjectDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddProjectDialog(),
    );
  }

  void _showEditDialog(CheckInItem item) {
    final nameController = TextEditingController(text: item.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('编辑项目'),
        content: TextField(
          controller: nameController,
          maxLength: 20,
          decoration: const InputDecoration(
            hintText: '项目名称',
            counterText: '',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              final newName = nameController.text.trim();
              if (newName.isNotEmpty) {
                item.name = newName;
                ref.read(checkInItemsProvider.notifier).updateItem(item);
              }
              Navigator.pop(context);
            },
            child: const Text('保存'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _confirmDelete(item);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(CheckInItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除「${item.name}」吗？相关的打卡记录也会被删除。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              ref.read(checkInItemsProvider.notifier).deleteItem(item.id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}
