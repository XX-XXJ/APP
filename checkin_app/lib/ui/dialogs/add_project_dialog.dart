import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/checkin_provider.dart';

class AddProjectDialog extends ConsumerStatefulWidget {
  const AddProjectDialog({super.key});

  @override
  ConsumerState<AddProjectDialog> createState() => _AddProjectDialogState();
}

class _AddProjectDialogState extends ConsumerState<AddProjectDialog> {
  final _nameController = TextEditingController();
  int _selectedColorIndex = 0;
  int _selectedIconIndex = 0;
  int _selectedFrequency = 0; // 0=daily, 1=weekly, 2=monthly, 3=longTerm, 4=custom
  final Set<int> _selectedCustomDays = {};

  static const _availableIcons = [
    {'name': '日出', 'code': 0xe559},
    {'name': '水滴', 'code': 0xe1a1},
    {'name': '健身', 'code': 0xe566},
    {'name': '书本', 'code': 0xe865},
    {'name': '冥想', 'code': 0xe5a1},
    {'name': '学校', 'code': 0xe80c},
    {'name': '音乐', 'code': 0xe405},
    {'name': '画板', 'code': 0xe3a1},
    {'name': '代码', 'code': 0xe86f},
    {'name': '写作', 'code': 0xe249},
    {'name': '跑步', 'code': 0xe566},
    {'name': '咖啡', 'code': 0xe541},
    {'name': '星星', 'code': 0xe838},
    {'name': '目标', 'code': 0xe559},
    {'name': '购物', 'code': 0xe59c},
    {'name': '药', 'code': 0xe578},
    {'name': '睡觉', 'code': 0xe5a2},
    {'name': '清洁', 'code': 0xe1a1},
    {'name': '代码', 'code': 0xe86f},
    {'name': '游戏', 'code': 0xe021},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              '新建打卡项目',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                // Name input
                Text(
                  '项目名称',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameController,
                  maxLength: 20,
                  decoration: const InputDecoration(
                    hintText: '例如：早起、喝水、运动...',
                    counterText: '',
                  ),
                ),

                const SizedBox(height: 24),

                // Icon selection
                Text(
                  '选择图标',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: List.generate(_availableIcons.length, (index) {
                    final icon = _availableIcons[index];
                    final isSelected = _selectedIconIndex == index;
                    final color = AppColors.itemColors[_selectedColorIndex];
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() => _selectedIconIndex = index);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? color.withValues(alpha: 0.15)
                              : AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(14),
                          border: isSelected
                              ? Border.all(color: color, width: 2)
                              : null,
                        ),
                        child: Icon(
                          IconData(
                            icon['code'] as int, // ignore: non_const_argument_for_const_parameter
                            fontFamily: 'MaterialIcons',
                          ),
                          color: isSelected ? color : AppColors.textHint,
                          size: 22,
                        ),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 24),

                // Color selection
                Text(
                  '选择颜色',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: List.generate(AppColors.itemColors.length, (index) {
                    final color = AppColors.itemColors[index];
                    final isSelected = _selectedColorIndex == index;
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() => _selectedColorIndex = index);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: AppColors.textPrimary, width: 3)
                              : null,
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: color.withValues(alpha: 0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, color: Colors.white, size: 18)
                            : null,
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 24),

                // Frequency selection
                Text(
                  '打卡频率',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _buildFrequencyChip(0, '每天', Icons.today_rounded),
                    _buildFrequencyChip(1, '每周', Icons.date_range_rounded),
                    _buildFrequencyChip(2, '每月', Icons.calendar_month_rounded),
                    _buildFrequencyChip(3, '长期', Icons.all_inclusive_rounded),
                    _buildFrequencyChip(4, '自定义', Icons.tune_rounded),
                  ],
                ),

                // Custom days picker
                if (_selectedFrequency == 4) ...[
                  const SizedBox(height: 16),
                  Text(
                    '选择每月打卡日（已选 ${_selectedCustomDays.length} 天）',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(31, (index) {
                      final day = index + 1;
                      final isSelected = _selectedCustomDays.contains(day);
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            if (isSelected) {
                              _selectedCustomDays.remove(day);
                            } else {
                              _selectedCustomDays.add(day);
                            }
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(10),
                            border: isSelected
                                ? null
                                : Border.all(
                                    color: AppColors.surfaceVariant, width: 1),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '$day',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight:
                                  isSelected ? FontWeight.w600 : FontWeight.w400,
                              color:
                                  isSelected ? Colors.white : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],

                const SizedBox(height: 12),
              ],
            ),
          ),

          // Buttons
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('取消'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _save,
                    child: const Text('创建'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入项目名称')),
      );
      return;
    }

    if (_selectedFrequency == 4 && _selectedCustomDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请至少选择一天')),
      );
      return;
    }

    ref.read(checkInItemsProvider.notifier).addItem(
          name: name,
          iconCodePoint: _availableIcons[_selectedIconIndex]['code'] as int,
          colorValue: AppColors.itemColors[_selectedColorIndex].toARGB32(),
          frequency: _selectedFrequency,
          customDays: _selectedFrequency == 4
              ? (_selectedCustomDays.toList()..sort())
              : null,
        );

    Navigator.pop(context);
    HapticFeedback.heavyImpact();
  }

  Widget _buildFrequencyChip(int value, String label, IconData icon) {
    final isSelected = _selectedFrequency == value;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _selectedFrequency = value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.15)
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: AppColors.primary, width: 1.5)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 16,
                color: isSelected ? AppColors.primary : AppColors.textHint),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color:
                    isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
