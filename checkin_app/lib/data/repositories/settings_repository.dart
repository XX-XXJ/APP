import 'package:hive/hive.dart';
import '../../core/constants/app_constants.dart';

class SettingsRepository {
  late Box _box;

  Future<void> init() async {
    _box = await Hive.openBox(AppConstants.settingsBox);
  }

  bool getDarkMode() => _box.get('darkMode', defaultValue: false);
  Future<void> setDarkMode(bool value) => _box.put('darkMode', value);

  bool getNotificationsEnabled() =>
      _box.get('notificationsEnabled', defaultValue: true);
  Future<void> setNotificationsEnabled(bool value) =>
      _box.put('notificationsEnabled', value);

  String? getDailyReminderTime() => _box.get('dailyReminderTime');
  Future<void> setDailyReminderTime(String? time) {
    if (time != null) return _box.put('dailyReminderTime', time);
    return _box.delete('dailyReminderTime');
  }

  bool getShowStreakOnHome() =>
      _box.get('showStreakOnHome', defaultValue: true);
  Future<void> setShowStreakOnHome(bool value) =>
      _box.put('showStreakOnHome', value);

  bool getHasCompletedOnboarding() =>
      _box.get('hasCompletedOnboarding', defaultValue: false);
  Future<void> setHasCompletedOnboarding(bool value) =>
      _box.put('hasCompletedOnboarding', value);
}
