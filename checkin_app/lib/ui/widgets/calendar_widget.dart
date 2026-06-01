import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_utils.dart';
import '../widgets/glass_container.dart';

class CalendarWidget extends StatelessWidget {
  final DateTime selectedDate;
  final DateTime focusedDate;
  final Map<String, int> checkinData;
  final Function(DateTime, DateTime) onDaySelected;
  final Function(DateTime) onPageChanged;

  const CalendarWidget({
    super.key,
    required this.selectedDate,
    required this.focusedDate,
    required this.checkinData,
    required this.onDaySelected,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(2020, 1, 1);
    final lastDay = DateTime(2030, 12, 31);
    final safeFocusedDay = focusedDate.isBefore(firstDay)
        ? firstDay
        : focusedDate.isAfter(lastDay)
            ? lastDay
            : focusedDate;

    return GlassContainer(
      padding: const EdgeInsets.all(12),
      child: TableCalendar(
        locale: 'zh_CN',
        firstDay: firstDay,
        lastDay: lastDay,
        focusedDay: safeFocusedDay,
        selectedDayPredicate: (day) => isSameDay(selectedDate, day),
        onDaySelected: (selected, focused) {
          onDaySelected(selected, focused);
        },
        onPageChanged: onPageChanged,
        calendarFormat: CalendarFormat.month,
        startingDayOfWeek: StartingDayOfWeek.monday,
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          leftChevronIcon:
              Icon(Icons.chevron_left, color: AppColors.textSecondary),
          rightChevronIcon:
              Icon(Icons.chevron_right, color: AppColors.textSecondary),
          headerPadding: const EdgeInsets.symmetric(vertical: 8),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
          weekendStyle: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          todayDecoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          todayTextStyle: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
          selectedDecoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(10),
          ),
          selectedTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          defaultDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          defaultTextStyle: TextStyle(
            color: AppColors.textPrimary,
          ),
          weekendDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          weekendTextStyle: TextStyle(
            color: AppColors.textSecondary,
          ),
          markerDecoration: BoxDecoration(
            color: AppColors.textHint,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, day, events) {
            final key = AppDateUtils.formatDate(day);
            final count = checkinData[key] ?? 0;
            if (count == 0) return null;
            return Positioned(
              bottom: 2,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  count > 3 ? 3 : count,
                  (index) => Container(
                    width: 5,
                    height: 5,
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    decoration: BoxDecoration(
                      color: _getMarkerColor(count),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Color _getMarkerColor(int count) {
    if (count >= 5) return const Color(0xFF6C63FF);
    if (count >= 3) return AppColors.primary;
    if (count >= 2) return const Color(0xFF34D399);
    return const Color(0xFFFBBF24);
  }
}

bool isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
