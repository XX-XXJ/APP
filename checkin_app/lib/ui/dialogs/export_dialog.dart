import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/export_utils.dart';
import '../../core/utils/date_utils.dart';
import '../../providers/checkin_provider.dart';

class ExportDialog extends ConsumerStatefulWidget {
  const ExportDialog({super.key});

  @override
  ConsumerState<ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends ConsumerState<ExportDialog> {
  int _format = 0; // 0=CSV, 1=JSON
  int _range = 0; // 0=all, 1=thisMonth, 2=thisYear, 3=custom

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '导出数据',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),

          // Format selection
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '导出格式',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildOptionChip('CSV', 0, _format, (v) => setState(() => _format = v)),
              const SizedBox(width: 8),
              _buildOptionChip('JSON', 1, _format, (v) => setState(() => _format = v)),
            ],
          ),

          const SizedBox(height: 16),

          // Range selection
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '时间范围',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildOptionChip('全部', 0, _range, (v) => setState(() => _range = v)),
              _buildOptionChip('本月', 1, _range, (v) => setState(() => _range = v)),
              _buildOptionChip('本年', 2, _range, (v) => setState(() => _range = v)),
            ],
          ),

          const SizedBox(height: 24),

          // Export button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _export,
              icon: const Icon(Icons.file_download_rounded),
              label: const Text('导出'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildOptionChip(
      String label, int value, int groupValue, ValueChanged<int> onChanged) {
    final isSelected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  DateTime? _getStartDate() {
    final now = DateTime.now();
    switch (_range) {
      case 1:
        return DateTime(now.year, now.month, 1);
      case 2:
        return DateTime(now.year, 1, 1);
      default:
        return null;
    }
  }

  DateTime? _getEndDate() {
    if (_range == 0) return null;
    return DateTime.now();
  }

  void _export() async {
    final repo = ref.read(checkInRepositoryProvider);
    final items = repo.getAllItems();
    final records = repo.getAllRecords();

    final startDate = _getStartDate();
    final endDate = _getEndDate();

    try {
      String content;
      String filename;

      if (_format == 0) {
        content = await ExportUtils.exportToCsv(
          items: items,
          records: records,
          startDate: startDate,
          endDate: endDate,
        );
        filename = 'checkin_export_${AppDateUtils.formatDate(DateTime.now())}.csv';
      } else {
        content = await ExportUtils.exportToJson(
          items: items,
          records: records,
          startDate: startDate,
          endDate: endDate,
        );
        filename = 'checkin_export_${AppDateUtils.formatDate(DateTime.now())}.json';
      }

      final file = await ExportUtils.saveToFile(content, filename);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('已导出到 ${file.path}'),
            action: SnackBarAction(
              label: '分享',
              onPressed: () => SharePlus.instance.share(ShareParams(files: [XFile(file.path)])),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导出失败: $e')),
        );
      }
    }
  }
}
