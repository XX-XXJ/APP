class AppConstants {
  static const String appName = '打卡记录';
  static const String appVersion = '1.0.0';

  // Hive box names
  static const String checkinItemBox = 'checkin_items';
  static const String checkinRecordBox = 'checkin_records';
  static const String settingsBox = 'settings';
  static const String achievementsBox = 'achievements';

  // Default check-in items
  static const List<Map<String, dynamic>> defaultItems = [
    {'name': '早起', 'icon': 0xe559, 'colorIndex': 0}, // Icons.wb_sunny
    {'name': '喝水', 'icon': 0xe1a1, 'colorIndex': 3}, // Icons.water_drop
    {'name': '运动', 'icon': 0xe566, 'colorIndex': 4}, // Icons.fitness_center
    {'name': '阅读', 'icon': 0xe865, 'colorIndex': 1}, // Icons.menu_book
    {'name': '冥想', 'icon': 0xe5a1, 'colorIndex': 5}, // Icons.self_improvement
    {'name': '学习', 'icon': 0xe80c, 'colorIndex': 6}, // Icons.school
  ];

  // Achievement definitions
  static const String streakPrefix = 'streak_';
  static const String totalPrefix = 'total_';
  static const String multiPrefix = 'multi_';
  static const String specialPrefix = 'special_';

  // Notification
  static const String channelId = 'checkin_reminder';
  static const String channelName = '打卡提醒';
  static const String channelDescription = '提醒您按时完成打卡';

  // Task frequency types
  static const int frequencyDaily = 0;
  static const int frequencyWeekly = 1;
  static const int frequencyMonthly = 2;
  static const int frequencyLongTerm = 3;
  static const int frequencyCustom = 4;

  static const Map<int, String> frequencyLabels = {
    frequencyDaily: '每天',
    frequencyWeekly: '每周',
    frequencyMonthly: '每月',
    frequencyLongTerm: '长期',
    frequencyCustom: '自定义',
  };
}
