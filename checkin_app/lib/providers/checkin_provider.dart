import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/checkin_item.dart';
import '../data/models/checkin_record.dart';
import '../data/models/achievement.dart';
import '../data/repositories/checkin_repository.dart';
import '../core/utils/date_utils.dart';

final checkInRepositoryProvider = Provider<CheckInRepository>((ref) {
  throw UnimplementedError('Must be overridden in main.dart');
});

// Items
final checkInItemsProvider =
    StateNotifierProvider<CheckInItemsNotifier, List<CheckInItem>>((ref) {
  final repo = ref.watch(checkInRepositoryProvider);
  return CheckInItemsNotifier(repo);
});

class CheckInItemsNotifier extends StateNotifier<List<CheckInItem>> {
  final CheckInRepository _repo;

  CheckInItemsNotifier(this._repo) : super(_repo.getActiveItems());

  void refresh() {
    state = _repo.getActiveItems();
  }

  Future<void> addItem({
    required String name,
    required int iconCodePoint,
    required int colorValue,
    String? description,
    int frequency = 0,
    List<int>? customDays,
  }) async {
    await _repo.createItem(
      name: name,
      iconCodePoint: iconCodePoint,
      colorValue: colorValue,
      description: description,
      frequency: frequency,
      customDays: customDays,
    );
    refresh();
  }

  Future<void> updateItem(CheckInItem item) async {
    await _repo.updateItem(item);
    refresh();
  }

  Future<void> deleteItem(String id) async {
    await _repo.deleteItem(id);
    refresh();
  }
}

// Today's records
final todayRecordsProvider =
    StateNotifierProvider<TodayRecordsNotifier, List<CheckInRecord>>((ref) {
  final repo = ref.watch(checkInRepositoryProvider);
  return TodayRecordsNotifier(repo);
});

class TodayRecordsNotifier extends StateNotifier<List<CheckInRecord>> {
  final CheckInRepository _repo;

  TodayRecordsNotifier(this._repo) : super(_repo.getRecordsByDate(AppDateUtils.today()));

  void refresh() {
    state = _repo.getRecordsByDate(AppDateUtils.today());
  }

  Future<void> checkIn(String itemId, {String? note, String? mood}) async {
    await _repo.checkIn(itemId: itemId, note: note, mood: mood);
    refresh();
  }

  Future<void> cancelCheckIn(String itemId) async {
    await _repo.cancelCheckIn(itemId);
    refresh();
  }
}

// Check-in status for an item
final isCheckedInProvider = Provider.family<bool, String>((ref, itemId) {
  final todayRecords = ref.watch(todayRecordsProvider);
  return todayRecords.any((r) => r.itemId == itemId);
});

// Selected date records
final selectedDateRecordsProvider =
    StateNotifierProvider.family<DateRecordsNotifier, List<CheckInRecord>, DateTime>(
        (ref, date) {
  final repo = ref.watch(checkInRepositoryProvider);
  return DateRecordsNotifier(repo, date);
});

class DateRecordsNotifier extends StateNotifier<List<CheckInRecord>> {
  final CheckInRepository _repo;
  final DateTime _date;

  DateRecordsNotifier(this._repo, this._date)
      : super(_repo.getRecordsByDate(_date));

  void refresh() {
    state = _repo.getRecordsByDate(_date);
  }

  Future<void> checkIn(String itemId, {String? note, String? mood}) async {
    await _repo.checkInForDate(itemId, _date, note: note, mood: mood);
    refresh();
  }

  Future<void> cancelCheckIn(String itemId) async {
    await _repo.cancelCheckInForDate(itemId, _date);
    refresh();
  }
}

// Check-in status for an item on a specific date
final isCheckedInOnDateProvider =
    Provider.family<bool, ({String itemId, DateTime date})>((ref, params) {
  final records = ref.watch(selectedDateRecordsProvider(params.date));
  return records.any((r) => r.itemId == params.itemId);
});

// Items filtered by date (frequency-aware)
final itemsForDateProvider =
    Provider.family<List<CheckInItem>, DateTime>((ref, date) {
  ref.watch(checkInItemsProvider);
  final repo = ref.watch(checkInRepositoryProvider);
  final allItems = repo.getItemsForDate(date);
  final deferred = ref.watch(deferredItemsProvider);
  // Exclude items deferred to a future date
  return allItems.where((item) {
    final deferredTo = deferred[item.id];
    if (deferredTo == null) return true;
    return !AppDateUtils.isSameDay(deferredTo, date) &&
        date.isAfter(deferredTo);
  }).toList();
});

// Deferred items: items delayed to a future date (in-memory only)
class DeferredItemsNotifier extends StateNotifier<Map<String, DateTime>> {
  DeferredItemsNotifier() : super({});

  void defer(String itemId, DateTime toDate) {
    state = {...state, itemId: toDate};
  }

  void remove(String itemId) {
    final newState = Map<String, DateTime>.from(state);
    newState.remove(itemId);
    state = newState;
  }
}

final deferredItemsProvider =
    StateNotifierProvider<DeferredItemsNotifier, Map<String, DateTime>>((ref) {
  return DeferredItemsNotifier();
});

// Records for calendar markers
final calendarRecordsProvider =
    StateNotifierProvider<CalendarRecordsNotifier, Map<String, int>>((ref) {
  final repo = ref.watch(checkInRepositoryProvider);
  return CalendarRecordsNotifier(repo);
});

class CalendarRecordsNotifier extends StateNotifier<Map<String, int>> {
  final CheckInRepository _repo;

  CalendarRecordsNotifier(this._repo) : super({}) {
    refresh();
  }

  void refresh() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month - 1, 1);
    final end = DateTime(now.year, now.month + 2, 0);
    state = _repo.getCheckinCountByDate(start, end);
  }
}

// Current streak
final currentStreakProvider = Provider<int>((ref) {
  final repo = ref.watch(checkInRepositoryProvider);
  final allRecords = repo.getAllRecords();
  final dates = allRecords
      .map((r) => DateTime(r.dateTime.year, r.dateTime.month, r.dateTime.day))
      .toSet();
  return AppDateUtils.getStreakDays(dates);
});

// Achievements
final achievementsProvider =
    StateNotifierProvider<AchievementsNotifier, List<Achievement>>((ref) {
  ref.watch(calendarRecordsProvider); // rebuild when records change
  final repo = ref.watch(checkInRepositoryProvider);
  return AchievementsNotifier(repo);
});

class AchievementsNotifier extends StateNotifier<List<Achievement>> {
  final CheckInRepository _repo;

  AchievementsNotifier(this._repo) : super(_repo.getAllAchievements());

  void refresh() {
    state = _repo.getAllAchievements();
  }

  Future<List<Achievement>> checkAchievements() async {
    final newlyUnlocked = await _repo.checkAndUnlockAchievements();
    refresh();
    return newlyUnlocked;
  }
}

// Total stats
final totalStatsProvider = Provider<Map<String, int>>((ref) {
  ref.watch(calendarRecordsProvider); // rebuild when records change
  final repo = ref.watch(checkInRepositoryProvider);
  return {
    'totalCheckins': repo.getTotalCheckins(),
    'totalDays': repo.getTotalCheckinDays(),
    'totalItems': repo.getActiveItems().length,
    'unlockedAchievements':
        repo.getUnlockedAchievements().length,
  };
});

// Stats data provider - rebuilds when check-in data changes
final statsDataProvider = Provider<StatsData>((ref) {
  ref.watch(calendarRecordsProvider);
  final repo = ref.watch(checkInRepositoryProvider);
  return StatsData(repo);
});

class StatsData {
  final CheckInRepository _repo;
  StatsData(this._repo);

  Map<String, int> getCountByDate(DateTime start, DateTime end) =>
      _repo.getCheckinCountByDate(start, end);

  Map<String, int> getCountByItem(DateTime start, DateTime end) =>
      _repo.getCheckinCountByItem(start, end);

  int getCurrentStreak(String itemId) => _repo.getCurrentStreak(itemId);
  int getLongestStreak(String itemId) => _repo.getLongestStreak(itemId);
  int getCheckinDays(String itemId) => _repo.getCheckinDays(itemId);
}
