import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../core/constants/app_constants.dart';

class SettingsState {
  final bool darkMode;
  final bool notificationsEnabled;
  final String? dailyReminderTime; // HH:mm
  final bool showStreakOnHome;
  final bool enableHapticFeedback;
  final String language;
  final bool hasCompletedOnboarding;

  const SettingsState({
    this.darkMode = false,
    this.notificationsEnabled = true,
    this.dailyReminderTime,
    this.showStreakOnHome = true,
    this.enableHapticFeedback = true,
    this.language = 'zh',
    this.hasCompletedOnboarding = false,
  });

  SettingsState copyWith({
    bool? darkMode,
    bool? notificationsEnabled,
    String? dailyReminderTime,
    bool? showStreakOnHome,
    bool? enableHapticFeedback,
    String? language,
    bool? hasCompletedOnboarding,
  }) {
    return SettingsState(
      darkMode: darkMode ?? this.darkMode,
      notificationsEnabled:
          notificationsEnabled ?? this.notificationsEnabled,
      dailyReminderTime: dailyReminderTime ?? this.dailyReminderTime,
      showStreakOnHome: showStreakOnHome ?? this.showStreakOnHome,
      enableHapticFeedback:
          enableHapticFeedback ?? this.enableHapticFeedback,
      language: language ?? this.language,
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
    );
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});

class SettingsNotifier extends StateNotifier<SettingsState> {
  late Box _box;

  SettingsNotifier() : super(const SettingsState()) {
    _load();
  }

  Future<void> _load() async {
    _box = await Hive.openBox(AppConstants.settingsBox);
    state = SettingsState(
      darkMode: _box.get('darkMode', defaultValue: false),
      notificationsEnabled:
          _box.get('notificationsEnabled', defaultValue: true),
      dailyReminderTime: _box.get('dailyReminderTime'),
      showStreakOnHome: _box.get('showStreakOnHome', defaultValue: true),
      enableHapticFeedback:
          _box.get('enableHapticFeedback', defaultValue: true),
      language: _box.get('language', defaultValue: 'zh'),
      hasCompletedOnboarding:
          _box.get('hasCompletedOnboarding', defaultValue: false),
    );
  }

  Future<void> setDarkMode(bool value) async {
    await _box.put('darkMode', value);
    state = state.copyWith(darkMode: value);
  }

  Future<void> setNotificationsEnabled(bool value) async {
    await _box.put('notificationsEnabled', value);
    state = state.copyWith(notificationsEnabled: value);
  }

  Future<void> setDailyReminderTime(String? time) async {
    if (time != null) {
      await _box.put('dailyReminderTime', time);
    } else {
      await _box.delete('dailyReminderTime');
    }
    state = state.copyWith(dailyReminderTime: time);
  }

  Future<void> setShowStreakOnHome(bool value) async {
    await _box.put('showStreakOnHome', value);
    state = state.copyWith(showStreakOnHome: value);
  }

  Future<void> setEnableHapticFeedback(bool value) async {
    await _box.put('enableHapticFeedback', value);
    state = state.copyWith(enableHapticFeedback: value);
  }

  Future<void> setHasCompletedOnboarding(bool value) async {
    await _box.put('hasCompletedOnboarding', value);
    state = state.copyWith(hasCompletedOnboarding: value);
  }
}
