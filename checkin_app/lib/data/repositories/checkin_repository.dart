import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/checkin_item.dart';
import '../models/checkin_record.dart';
import '../models/achievement.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/date_utils.dart';

class CheckInRepository {
  static const _uuid = Uuid();

  late Box<CheckInItem> _itemsBox;
  late Box<CheckInRecord> _recordsBox;
  late Box<Achievement> _achievementsBox;

  Future<void> init() async {
    _itemsBox = await Hive.openBox<CheckInItem>(AppConstants.checkinItemBox);
    _recordsBox =
        await Hive.openBox<CheckInRecord>(AppConstants.checkinRecordBox);
    _achievementsBox =
        await Hive.openBox<Achievement>(AppConstants.achievementsBox);

    // Initialize default items if empty
    if (_itemsBox.isEmpty) {
      await _createDefaultItems();
    }
    if (_achievementsBox.isEmpty) {
      await _createDefaultAchievements();
    }
  }

  Future<void> _createDefaultItems() async {
    for (var i = 0; i < AppConstants.defaultItems.length; i++) {
      final def = AppConstants.defaultItems[i];
      final item = CheckInItem(
        id: _uuid.v4(),
        name: def['name'] as String,
        iconCodePoint: def['icon'] as int,
        colorValue: AppColorsCheckin.itemColors[def['colorIndex'] as int],
        sortOrder: i,
      );
      await _itemsBox.put(item.id, item);
    }
  }

  // Items CRUD
  List<CheckInItem> getAllItems() {
    return _itemsBox.values.toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  List<CheckInItem> getActiveItems() {
    return _itemsBox.values.where((i) => i.isActive).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  CheckInItem? getItem(String id) => _itemsBox.get(id);

  Future<void> addItem(CheckInItem item) async {
    await _itemsBox.put(item.id, item);
  }

  Future<void> updateItem(CheckInItem item) async {
    await _itemsBox.put(item.id, item);
  }

  Future<void> deleteItem(String id) async {
    await _itemsBox.delete(id);
    // Also delete related records
    final records =
        _recordsBox.values.where((r) => r.itemId == id).toList();
    for (var record in records) {
      await _recordsBox.delete(record.id);
    }
  }

  Future<CheckInItem> createItem({
    required String name,
    required int iconCodePoint,
    required int colorValue,
    String? description,
    int frequency = 0,
    List<int>? customDays,
  }) async {
    final item = CheckInItem(
      id: _uuid.v4(),
      name: name,
      iconCodePoint: iconCodePoint,
      colorValue: colorValue,
      sortOrder: _itemsBox.length,
      description: description,
      frequency: frequency,
      customDays: customDays,
    );
    await _itemsBox.put(item.id, item);
    return item;
  }

  // Records CRUD
  List<CheckInRecord> getAllRecords() {
    return _recordsBox.values.toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
  }

  List<CheckInRecord> getRecordsByDate(DateTime date) {
    return _recordsBox.values
        .where((r) => AppDateUtils.isSameDay(r.dateTime, date))
        .toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
  }

  List<CheckInRecord> getRecordsByItem(String itemId) {
    return _recordsBox.values
        .where((r) => r.itemId == itemId)
        .toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
  }

  List<CheckInRecord> getRecordsByDateRange(DateTime start, DateTime end) {
    return _recordsBox.values
        .where((r) =>
            r.dateTime.isAfter(start.subtract(const Duration(days: 1))) &&
            r.dateTime.isBefore(end.add(const Duration(days: 1))))
        .toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
  }

  bool isCheckedInToday(String itemId) {
    final today = AppDateUtils.today();
    return _recordsBox.values.any(
        (r) => r.itemId == itemId && AppDateUtils.isSameDay(r.dateTime, today));
  }

  CheckInRecord? getTodayRecord(String itemId) {
    final today = AppDateUtils.today();
    try {
      return _recordsBox.values.firstWhere(
          (r) => r.itemId == itemId && AppDateUtils.isSameDay(r.dateTime, today));
    } catch (_) {
      return null;
    }
  }

  Future<CheckInRecord> checkIn({
    required String itemId,
    String? note,
    String? mood,
  }) async {
    final record = CheckInRecord(
      id: _uuid.v4(),
      itemId: itemId,
      dateTime: DateTime.now(),
      note: note,
      mood: mood,
    );
    await _recordsBox.put(record.id, record);
    return record;
  }

  Future<void> cancelCheckIn(String itemId) async {
    final today = AppDateUtils.today();
    final records = _recordsBox.values
        .where(
            (r) => r.itemId == itemId && AppDateUtils.isSameDay(r.dateTime, today))
        .toList();
    for (var record in records) {
      await _recordsBox.delete(record.id);
    }
  }

  Future<CheckInRecord> checkInForDate(
    String itemId,
    DateTime date, {
    String? note,
    String? mood,
  }) async {
    final record = CheckInRecord(
      id: _uuid.v4(),
      itemId: itemId,
      dateTime: DateTime(date.year, date.month, date.day,
          DateTime.now().hour, DateTime.now().minute),
      note: note,
      mood: mood,
    );
    await _recordsBox.put(record.id, record);
    return record;
  }

  Future<void> cancelCheckInForDate(String itemId, DateTime date) async {
    final records = _recordsBox.values
        .where((r) =>
            r.itemId == itemId && AppDateUtils.isSameDay(r.dateTime, date))
        .toList();
    for (var record in records) {
      await _recordsBox.delete(record.id);
    }
  }

  List<CheckInItem> getItemsForDate(DateTime date) {
    final items = getActiveItems();
    return items.where((item) => _isItemVisibleOnDate(item, date)).toList();
  }

  bool _isItemVisibleOnDate(CheckInItem item, DateTime date) {
    switch (item.frequency) {
      case 0: // daily
        return true;
      case 1: // weekly
        final weekEnd = AppDateUtils.endOfWeek(date);
        return !item.createdAt.isAfter(weekEnd);
      case 2: // monthly
        final monthEnd = AppDateUtils.endOfMonth(date);
        return !item.createdAt.isAfter(monthEnd);
      case 3: // longTerm
        return true;
      case 4: // custom
        return item.customDays.contains(date.day);
      default:
        return true;
    }
  }

  // Statistics
  int getCheckinDays(String itemId) {
    final records = getRecordsByItem(itemId);
    return records.map((r) => AppDateUtils.formatDate(r.dateTime)).toSet().length;
  }

  int getCurrentStreak(String itemId) {
    final records = getRecordsByItem(itemId);
    final dates = records
        .map((r) => DateTime(r.dateTime.year, r.dateTime.month, r.dateTime.day))
        .toSet();
    return AppDateUtils.getStreakDays(dates);
  }

  int getLongestStreak(String itemId) {
    final records = getRecordsByItem(itemId);
    if (records.isEmpty) return 0;
    final dates = records
        .map((r) => DateTime(r.dateTime.year, r.dateTime.month, r.dateTime.day))
        .toList()
      ..sort();
    int maxStreak = 1;
    int currentStreak = 1;
    for (int i = 1; i < dates.length; i++) {
      final diff = AppDateUtils.daysBetween(dates[i - 1], dates[i]);
      if (diff == 1) {
        currentStreak++;
        maxStreak = maxStreak < currentStreak ? currentStreak : maxStreak;
      } else if (diff > 1) {
        currentStreak = 1;
      }
    }
    return maxStreak;
  }

  Map<String, int> getCheckinCountByDate(DateTime start, DateTime end) {
    final records = getRecordsByDateRange(start, end);
    final map = <String, int>{};
    for (var record in records) {
      final key = AppDateUtils.formatDate(record.dateTime);
      map[key] = (map[key] ?? 0) + 1;
    }
    return map;
  }

  Map<String, int> getCheckinCountByItem(DateTime start, DateTime end) {
    final records = getRecordsByDateRange(start, end);
    final map = <String, int>{};
    for (var record in records) {
      map[record.itemId] = (map[record.itemId] ?? 0) + 1;
    }
    return map;
  }

  int getTotalCheckins() => _recordsBox.length;

  int getTotalCheckinDays() {
    return _recordsBox.values
        .map((r) => AppDateUtils.formatDate(r.dateTime))
        .toSet()
        .length;
  }

  // Achievements
  List<Achievement> getAllAchievements() => _achievementsBox.values.toList();

  List<Achievement> getUnlockedAchievements() {
    return _achievementsBox.values.where((a) => a.isUnlocked).toList();
  }

  Future<void> unlockAchievement(String id) async {
    final achievement = _achievementsBox.get(id);
    if (achievement != null && !achievement.isUnlocked) {
      achievement.unlockedAt = DateTime.now();
      await _achievementsBox.put(id, achievement);
    }
  }

  Future<List<Achievement>> checkAndUnlockAchievements() async {
    final newlyUnlocked = <Achievement>[];

    // Check streak achievements for all items
    for (var item in getActiveItems()) {
      final streak = getCurrentStreak(item.id);
      _checkStreakAchievement(streak, 'item_${item.id}', newlyUnlocked);
    }

    // Global streak: any item checked in each day
    final globalStreak = _getGlobalStreak();
    _checkStreakAchievement(globalStreak, 'global', newlyUnlocked);

    // Total checkins
    final total = getTotalCheckins();
    _checkTotalAchievement(total, newlyUnlocked);

    // Multi-item in one day
    final todayRecords = getRecordsByDate(AppDateUtils.today());
    final todayItemCount = todayRecords.map((r) => r.itemId).toSet().length;
    _checkMultiAchievement(todayItemCount, newlyUnlocked);

    // Special: early bird (before 7am)
    final hasEarlyBird = _recordsBox.values
        .any((r) => r.dateTime.hour < 7);
    if (hasEarlyBird) {
      await _tryUnlock('special_earlybird', newlyUnlocked);
    }

    // Special: night owl (after 11pm)
    final hasNightOwl = _recordsBox.values
        .any((r) => r.dateTime.hour >= 23);
    if (hasNightOwl) {
      await _tryUnlock('special_nightowl', newlyUnlocked);
    }

    return newlyUnlocked;
  }

  int _getGlobalStreak() {
    final allDates = _recordsBox.values
        .map((r) => DateTime(r.dateTime.year, r.dateTime.month, r.dateTime.day))
        .toSet();
    return AppDateUtils.getStreakDays(allDates);
  }

  Future<void> _checkStreakAchievement(
      int streak, String prefix, List<Achievement> newlyUnlocked) async {
    final thresholds = [3, 7, 14, 30, 100, 365];
    for (var threshold in thresholds) {
      if (streak >= threshold) {
        await _tryUnlock('${prefix}_streak_$threshold', newlyUnlocked);
      }
    }
  }

  Future<void> _checkTotalAchievement(
      int total, List<Achievement> newlyUnlocked) async {
    final thresholds = [10, 50, 100, 500, 1000, 5000];
    for (var threshold in thresholds) {
      if (total >= threshold) {
        await _tryUnlock('total_$threshold', newlyUnlocked);
      }
    }
  }

  Future<void> _checkMultiAchievement(
      int count, List<Achievement> newlyUnlocked) async {
    final thresholds = [2, 3, 5];
    for (var threshold in thresholds) {
      if (count >= threshold) {
        await _tryUnlock('multi_$threshold', newlyUnlocked);
      }
    }
  }

  Future<void> _tryUnlock(
      String id, List<Achievement> newlyUnlocked) async {
    final achievement = _achievementsBox.get(id);
    if (achievement != null && !achievement.isUnlocked) {
      achievement.unlockedAt = DateTime.now();
      await _achievementsBox.put(id, achievement);
      newlyUnlocked.add(achievement);
    }
  }

  Future<void> _createDefaultAchievements() async {
    final achievements = [
      // Streak achievements
      Achievement(
        id: 'global_streak_3',
        title: '初心者',
        description: '连续打卡3天',
        iconCodePoint: 0xe838,
        category: 'streak',
        targetValue: 3,
        tier: 0,
      ),
      Achievement(
        id: 'global_streak_7',
        title: '坚持一周',
        description: '连续打卡7天',
        iconCodePoint: 0xea23,
        category: 'streak',
        targetValue: 7,
        tier: 0,
      ),
      Achievement(
        id: 'global_streak_14',
        title: '两周达人',
        description: '连续打卡14天',
        iconCodePoint: 0xe8e5,
        category: 'streak',
        targetValue: 14,
        tier: 1,
      ),
      Achievement(
        id: 'global_streak_30',
        title: '月度之星',
        description: '连续打卡30天',
        iconCodePoint: 0xe559,
        category: 'streak',
        targetValue: 30,
        tier: 1,
      ),
      Achievement(
        id: 'global_streak_100',
        title: '百日挑战',
        description: '连续打卡100天',
        iconCodePoint: 0xe8e8,
        category: 'streak',
        targetValue: 100,
        tier: 2,
      ),
      Achievement(
        id: 'global_streak_365',
        title: '年度坚持',
        description: '连续打卡365天',
        iconCodePoint: 0xe916,
        category: 'streak',
        targetValue: 365,
        tier: 3,
      ),
      // Total achievements
      Achievement(
        id: 'total_10',
        title: '起步',
        description: '累计打卡10次',
        iconCodePoint: 0xe040,
        category: 'total',
        targetValue: 10,
        tier: 0,
      ),
      Achievement(
        id: 'total_50',
        title: '半百',
        description: '累计打卡50次',
        iconCodePoint: 0xe040,
        category: 'total',
        targetValue: 50,
        tier: 0,
      ),
      Achievement(
        id: 'total_100',
        title: '百次打卡',
        description: '累计打卡100次',
        iconCodePoint: 0xe040,
        category: 'total',
        targetValue: 100,
        tier: 1,
      ),
      Achievement(
        id: 'total_500',
        title: '打卡狂人',
        description: '累计打卡500次',
        iconCodePoint: 0xe040,
        category: 'total',
        targetValue: 500,
        tier: 2,
      ),
      Achievement(
        id: 'total_1000',
        title: '千次里程碑',
        description: '累计打卡1000次',
        iconCodePoint: 0xe040,
        category: 'total',
        targetValue: 1000,
        tier: 3,
      ),
      // Multi achievements
      Achievement(
        id: 'multi_2',
        title: '双管齐下',
        description: '一天内完成2个打卡项目',
        iconCodePoint: 0xe3a1,
        category: 'multi',
        targetValue: 2,
        tier: 0,
      ),
      Achievement(
        id: 'multi_3',
        title: '三连击',
        description: '一天内完成3个打卡项目',
        iconCodePoint: 0xe3a1,
        category: 'multi',
        targetValue: 3,
        tier: 1,
      ),
      Achievement(
        id: 'multi_5',
        title: '全能战士',
        description: '一天内完成5个打卡项目',
        iconCodePoint: 0xe3a1,
        category: 'multi',
        targetValue: 5,
        tier: 2,
      ),
      // Special achievements
      Achievement(
        id: 'special_earlybird',
        title: '早起鸟儿',
        description: '在早上7点前完成打卡',
        iconCodePoint: 0xe559,
        category: 'special',
        targetValue: 1,
        tier: 1,
      ),
      Achievement(
        id: 'special_nightowl',
        title: '夜猫子',
        description: '在晚上11点后完成打卡',
        iconCodePoint: 0xe3a1,
        category: 'special',
        targetValue: 1,
        tier: 1,
      ),
    ];

    for (var achievement in achievements) {
      await _achievementsBox.put(achievement.id, achievement);
    }
  }
}

// Helper class for item colors
class AppColorsCheckin {
  static const List<int> itemColors = [
    0xFF4A90D9, // Blue
    0xFF6C63FF, // Purple
    0xFF34D399, // Green
    0xFFFBBF24, // Yellow
    0xFFF87171, // Red
    0xFFFF8A65, // Orange
    0xFF4DD0E1, // Cyan
    0xFFE879F9, // Pink
    0xFF81C784, // Light Green
    0xFFFFB74D, // Light Orange
  ];
}
