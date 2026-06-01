import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/checkin_item.dart';
import '../../data/models/checkin_record.dart';
import 'glass_container.dart';

class CheckInCard extends StatefulWidget {
  final CheckInItem item;
  final CheckInRecord? todayRecord;
  final bool isCheckedIn;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const CheckInCard({
    super.key,
    required this.item,
    this.todayRecord,
    required this.isCheckedIn,
    required this.onTap,
    this.onLongPress,
  });

  @override
  State<CheckInCard> createState() => _CheckInCardState();
}

class _CheckInCardState extends State<CheckInCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _animating = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.mediumImpact();
    if (!widget.isCheckedIn) {
      setState(() => _animating = true);
      _controller.forward(from: 0).then((_) {
        setState(() => _animating = false);
      });
    }
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final itemColor = Color(widget.item.colorValue);

    return GestureDetector(
      onTap: _handleTap,
      onLongPress: widget.onLongPress != null
          ? () {
              HapticFeedback.heavyImpact();
              widget.onLongPress!();
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        child: GlassContainer(
          opacity: widget.isCheckedIn ? 0.9 : 0.7,
          tintColor: widget.isCheckedIn
              ? itemColor.withValues(alpha: 0.1)
              : Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // Icon
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: widget.isCheckedIn
                      ? itemColor
                      : itemColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  IconData(widget.item.iconCodePoint, // ignore: non_const_argument_for_const_parameter
                      fontFamily: 'MaterialIcons'),
                  color: widget.isCheckedIn ? Colors.white : itemColor,
                  size: 24,
                ),
              )
                  .animate(target: _animating ? 1 : 0)
                  .scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.2, 1.2),
                    duration: 200.ms,
                    curve: Curves.easeOutBack,
                  )
                  .then()
                  .scale(
                    begin: const Offset(1.2, 1.2),
                    end: const Offset(1, 1),
                    duration: 300.ms,
                    curve: Curves.elasticOut,
                  ),
              const SizedBox(width: 14),
              // Name & time
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: widget.isCheckedIn
                            ? AppColors.textPrimary
                            : AppColors.textPrimary.withValues(alpha: 0.8),
                      ),
                    ),
                    if (widget.isCheckedIn && widget.todayRecord != null)
                      Text(
                        '已打卡 ${_formatTime(widget.todayRecord!.dateTime)}',
                        style: TextStyle(
                          fontSize: 13,
                          color: itemColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
              // Check button
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: widget.isCheckedIn
                      ? itemColor
                      : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  widget.isCheckedIn ? Icons.check_rounded : Icons.add_rounded,
                  color: widget.isCheckedIn
                      ? Colors.white
                      : AppColors.textSecondary,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
