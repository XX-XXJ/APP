import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/checkin_item.dart';
import '../../../providers/checkin_provider.dart';
import '../../widgets/glass_container.dart';

class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(checkInItemsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('打卡项目管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _showAddDialog(context, ref),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.homeGradient),
        child: items.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                  ],
                ),
              )
            : ReorderableListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: items.length,
                onReorderItem: (oldIndex, newIndex) {
                  _reorderItems(ref, items, oldIndex, newIndex);
                },
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Padding(
                    key: ValueKey(item.id),
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _buildItemCard(context, ref, item, index),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildItemCard(
      BuildContext context, WidgetRef ref, CheckInItem item, int index) {
    final color = Color(item.colorValue);
    final repo = ref.watch(checkInRepositoryProvider);
    final checkinDays = repo.getCheckinDays(item.id);
    final streak = repo.getCurrentStreak(item.id);

    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Drag handle
          Icon(
            Icons.drag_handle_rounded,
            color: AppColors.textHint,
            size: 20,
          ),
          const SizedBox(width: 12),
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              IconData(item.iconCodePoint, // ignore: non_const_argument_for_const_parameter
                  fontFamily: 'MaterialIcons'),
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '已打卡 $checkinDays 天 · 连续 $streak 天',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // More options
          PopupMenuButton(
            icon: Icon(
              Icons.more_vert_rounded,
              color: AppColors.textHint,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) {
              if (value == 'edit') {
                _showEditDialog(context, ref, item);
              } else if (value == 'delete') {
                _confirmDelete(context, ref, item);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_rounded, size: 18),
                    SizedBox(width: 8),
                    Text('编辑'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_rounded, size: 18, color: AppColors.error),
                    SizedBox(width: 8),
                    Text('删除', style: TextStyle(color: AppColors.error)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(
          delay: Duration(milliseconds: 80 * index),
          duration: 400.ms,
        );
  }

  void _reorderItems(
      WidgetRef ref, List<CheckInItem> items, int oldIndex, int newIndex) {
    final notifier = ref.read(checkInItemsProvider.notifier);
    final item = items[oldIndex];
    item.sortOrder = newIndex;
    notifier.updateItem(item);
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SizedBox(), // Handled by home screen
    );
  }

  void _showEditDialog(
      BuildContext context, WidgetRef ref, CheckInItem item) {
    final nameController = TextEditingController(text: item.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('编辑项目'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(hintText: '项目名称'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                item.name = name;
                ref.read(checkInItemsProvider.notifier).updateItem(item);
                Navigator.pop(context);
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, WidgetRef ref, CheckInItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除"${item.name}"吗？相关的打卡记录也会被删除。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              ref.read(checkInItemsProvider.notifier).deleteItem(item.id);
              Navigator.pop(context);
              HapticFeedback.heavyImpact();
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}
