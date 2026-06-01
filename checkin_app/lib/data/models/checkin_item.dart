import 'package:hive/hive.dart';

part 'checkin_item.g.dart';

@HiveType(typeId: 0)
class CheckInItem extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int iconCodePoint;

  @HiveField(3)
  int colorValue;

  @HiveField(4)
  String? reminderTime; // HH:mm format

  @HiveField(5)
  List<int> reminderDays; // 1=Mon..7=Sun, empty=daily

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  int sortOrder;

  @HiveField(8)
  bool isActive;

  @HiveField(9)
  String? description;

  @HiveField(10)
  int frequency; // 0=daily, 1=weekly, 2=monthly, 3=longTerm, 4=custom

  @HiveField(11)
  List<int> customDays; // For frequency=4: days of month [1-31]

  CheckInItem({
    required this.id,
    required this.name,
    required this.iconCodePoint,
    required this.colorValue,
    this.reminderTime,
    List<int>? reminderDays,
    DateTime? createdAt,
    this.sortOrder = 0,
    this.isActive = true,
    this.description,
    this.frequency = 0,
    List<int>? customDays,
  })  : reminderDays = reminderDays ?? [],
        customDays = customDays ?? [],
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'iconCodePoint': iconCodePoint,
        'colorValue': colorValue,
        'reminderTime': reminderTime,
        'reminderDays': reminderDays,
        'createdAt': createdAt.toIso8601String(),
        'sortOrder': sortOrder,
        'isActive': isActive,
        'description': description,
        'frequency': frequency,
        'customDays': customDays,
      };

  factory CheckInItem.fromJson(Map<String, dynamic> json) => CheckInItem(
        id: json['id'] as String,
        name: json['name'] as String,
        iconCodePoint: json['iconCodePoint'] as int,
        colorValue: json['colorValue'] as int,
        reminderTime: json['reminderTime'] as String?,
        reminderDays: (json['reminderDays'] as List?)?.cast<int>(),
        createdAt: DateTime.parse(json['createdAt'] as String),
        sortOrder: json['sortOrder'] as int? ?? 0,
        isActive: json['isActive'] as bool? ?? true,
        description: json['description'] as String?,
        frequency: json['frequency'] as int? ?? 0,
        customDays: (json['customDays'] as List?)?.cast<int>(),
      );
}
