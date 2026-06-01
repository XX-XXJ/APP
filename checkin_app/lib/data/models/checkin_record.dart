import 'package:hive/hive.dart';

part 'checkin_record.g.dart';

@HiveType(typeId: 1)
class CheckInRecord extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String itemId;

  @HiveField(2)
  final DateTime dateTime;

  @HiveField(3)
  String? note;

  @HiveField(4)
  String? mood; // emoji or text

  CheckInRecord({
    required this.id,
    required this.itemId,
    required this.dateTime,
    this.note,
    this.mood,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'itemId': itemId,
        'dateTime': dateTime.toIso8601String(),
        'note': note,
        'mood': mood,
      };

  factory CheckInRecord.fromJson(Map<String, dynamic> json) => CheckInRecord(
        id: json['id'] as String,
        itemId: json['itemId'] as String,
        dateTime: DateTime.parse(json['dateTime'] as String),
        note: json['note'] as String?,
        mood: json['mood'] as String?,
      );
}
