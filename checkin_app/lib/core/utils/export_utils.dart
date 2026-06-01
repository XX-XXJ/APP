import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../data/models/checkin_item.dart';
import '../../data/models/checkin_record.dart';
import 'date_utils.dart';

class ExportUtils {
  static Future<String> exportToCsv({
    required List<CheckInItem> items,
    required List<CheckInRecord> records,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final filtered = records.where((r) {
      if (startDate != null && r.dateTime.isBefore(startDate)) return false;
      if (endDate != null && r.dateTime.isAfter(endDate)) return false;
      return true;
    }).toList();

    final itemMap = {for (var item in items) item.id: item.name};

    final data = <List<dynamic>>[
      ['日期', '时间', '项目', '备注', '心情'],
    ];

    for (var record in filtered) {
      data.add([
        AppDateUtils.formatDate(record.dateTime),
        AppDateUtils.formatTime(record.dateTime),
        itemMap[record.itemId] ?? '未知',
        record.note ?? '',
        record.mood ?? '',
      ]);
    }

    return csv.encode(data);
  }

  static Future<String> exportToJson({
    required List<CheckInItem> items,
    required List<CheckInRecord> records,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final filtered = records.where((r) {
      if (startDate != null && r.dateTime.isBefore(startDate)) return false;
      if (endDate != null && r.dateTime.isAfter(endDate)) return false;
      return true;
    }).toList();

    final itemMap = {for (var item in items) item.id: item.name};

    final exportData = {
      'exportDate': DateTime.now().toIso8601String(),
      'items': items.map((i) => i.toJson()).toList(),
      'records': filtered.map((r) {
        final json = r.toJson();
        json['itemName'] = itemMap[r.itemId] ?? '未知';
        return json;
      }).toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(exportData);
  }

  static Future<File> saveToFile(String content, String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$filename');
    return file.writeAsString(content);
  }
}
