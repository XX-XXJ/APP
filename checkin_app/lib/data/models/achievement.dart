import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'achievement.g.dart';

@HiveType(typeId: 2)
class Achievement extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final int iconCodePoint;

  @HiveField(4)
  final String category; // streak, total, multi, special

  @HiveField(5)
  final int targetValue;

  @HiveField(6)
  DateTime? unlockedAt;

  @HiveField(7)
  final int tier; // 0=bronze, 1=silver, 2=gold, 3=diamond

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconCodePoint,
    required this.category,
    required this.targetValue,
    this.unlockedAt,
    this.tier = 0,
  });

  bool get isUnlocked => unlockedAt != null;

  Color get tierColor {
    switch (tier) {
      case 0:
        return const Color(0xFFCD7F32); // Bronze
      case 1:
        return const Color(0xFFC0C0C0); // Silver
      case 2:
        return const Color(0xFFFFD700); // Gold
      case 3:
        return const Color(0xFFB9F2FF); // Diamond
      default:
        return const Color(0xFFCD7F32);
    }
  }

  String get tierName {
    switch (tier) {
      case 0:
        return '铜';
      case 1:
        return '银';
      case 2:
        return '金';
      case 3:
        return '钻石';
      default:
        return '铜';
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'iconCodePoint': iconCodePoint,
        'category': category,
        'targetValue': targetValue,
        'unlockedAt': unlockedAt?.toIso8601String(),
        'tier': tier,
      };
}
