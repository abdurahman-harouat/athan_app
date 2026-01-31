import 'package:athan_app_v2/theme.dart';
import 'package:athan_app_v2/utils/month_translations.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class CalendarStrip extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const CalendarStrip({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  State<CalendarStrip> createState() => _CalendarStripState();
}

class _CalendarStripState extends State<CalendarStrip> {
  late ScrollController _scrollController;
  final double _itemWidth = 70.0;
  final double _itemSpacing = 8.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedDate();
    });
  }

  @override
  void didUpdateWidget(CalendarStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate) {
      _scrollToSelectedDate();
    }
  }

  void _scrollToSelectedDate() {
    if (!_scrollController.hasClients) return;

    // We generate +/- 30 days. Index 30 is the selected date initially? 
    // No, that's confusing if selectedDate changes.
    // Let's just always generate +/- 15 days from the CURRENT selectedDate 
    // so the selected date is always in the middle physically?
    // Or better: Generate dates from Today +/- 365.
    // Find index of selectedDate.
    // Scroll to index.
    
    final today = DateTime.now();
    final start = today.subtract(const Duration(days: 365));
    final diff = widget.selectedDate.difference(start).inDays;
    
    if (diff >= 0 && diff < 365 * 2) {
      final screenWidth = MediaQuery.of(context).size.width;
      final offset = (diff * (_itemWidth + _itemSpacing)) - (screenWidth / 2) + (_itemWidth / 2);
      
      _scrollController.animateTo(
        offset,
        duration: AppConstants.normalAnimation,
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _getDayName(int weekday) {
    const days = {
      DateTime.monday: 'الاثنين',
      DateTime.tuesday: 'الثلاثاء',
      DateTime.wednesday: 'الأربعاء',
      DateTime.thursday: 'الخميس',
      DateTime.friday: 'الجمعة',
      DateTime.saturday: 'السبت',
      DateTime.sunday: 'الأحد',
    };
    return days[weekday] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final today = DateTime.now();
    final startDate = today.subtract(const Duration(days: 365));

    return SizedBox(
      height: 85,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: 365 * 2, // 2 years range
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemBuilder: (context, index) {
          final date = startDate.add(Duration(days: index));
          final isSelected = date.year == widget.selectedDate.year &&
              date.month == widget.selectedDate.month &&
              date.day == widget.selectedDate.day;
          final isToday = date.year == today.year &&
              date.month == today.month &&
              date.day == today.day;

          return GestureDetector(
            onTap: () => widget.onDateSelected(date),
            child: Container(
              width: _itemWidth,
              margin: EdgeInsets.only(right: _itemSpacing),
              decoration: BoxDecoration(
                color: isSelected
                    ? colors.primary
                    : isToday
                        ? colors.primary.withOpacity(0.1)
                        : colors.cardBackground,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: isToday && !isSelected
                    ? Border.all(color: colors.primary, width: 1)
                    : null,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: colors.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _getDayName(date.weekday), // Arabic Day Name
                    style: AppTextStyles.labelSmall(context).copyWith(
                      color: isSelected
                          ? CupertinoColors.white
                          : colors.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 11, // Smaller font for longer names
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    MonthTranslations.toArabicNumerals(date.day.toString()), // Arabic Numerals
                    style: AppTextStyles.titleMedium(context).copyWith(
                      color: isSelected
                          ? CupertinoColors.white
                          : colors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (isToday) ...[
                    SizedBox(height: 4),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? CupertinoColors.white
                            : colors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
