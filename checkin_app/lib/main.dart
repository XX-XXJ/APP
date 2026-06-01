import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'data/models/checkin_item.dart';
import 'data/models/checkin_record.dart';
import 'data/models/achievement.dart';
import 'data/repositories/checkin_repository.dart';
import 'data/services/notification_service.dart';
import 'providers/checkin_provider.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize locale data for date formatting
  await initializeDateFormatting('zh_CN');

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(CheckInItemAdapter());
  Hive.registerAdapter(CheckInRecordAdapter());
  Hive.registerAdapter(AchievementAdapter());

  // Initialize repository
  final repository = CheckInRepository();
  await repository.init();

  // Initialize notifications
  await NotificationService().init();

  runApp(
    ProviderScope(
      overrides: [
        checkInRepositoryProvider.overrideWithValue(repository),
      ],
      child: const CheckInApp(),
    ),
  );
}
