import 'package:athan_app_v2/models/prayer_times.dart';
import 'package:athan_app_v2/theme.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';

class PrayerCountdown extends StatefulWidget {
  final PrayerTimings timings;
  final Function(String)? onNextPrayerChanged;

  const PrayerCountdown({
    super.key,
    required this.timings,
    this.onNextPrayerChanged,
  });

  @override
  State<PrayerCountdown> createState() => _PrayerCountdownState();
}

class _PrayerCountdownState extends State<PrayerCountdown> {
  late Timer _timer;
  String _nextPrayer = '';
  String _remainingTime = '';
  String _previousNextPrayer = '';

  @override
  void initState() {
    super.initState();
    _updateCountdown();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _updateCountdown();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateCountdown() {
    final now = DateTime.now();
    final prayers = {
      'الفجر': _parseTime(widget.timings.fajr),
      'الظهر': _parseTime(widget.timings.dhuhr),
      'العصر': _parseTime(widget.timings.asr),
      'المغرب': _parseTime(widget.timings.maghrib),
      'العشاء': _parseTime(widget.timings.isha),
    };

    String nextPrayer = '';
    DateTime? nextTime;

    for (var entry in prayers.entries) {
      if (entry.value.isAfter(now)) {
        if (nextTime == null || entry.value.isBefore(nextTime)) {
          nextPrayer = entry.key;
          nextTime = entry.value;
        }
      }
    }

    if (nextTime != null) {
      final difference = nextTime.difference(now);
      final hours = difference.inHours;
      final minutes = (difference.inMinutes % 60);
      final seconds = (difference.inSeconds % 60);

      if (mounted) {
        setState(() {
          if (_nextPrayer != nextPrayer && _previousNextPrayer.isNotEmpty) {
            // Next prayer changed, notify parent
            widget.onNextPrayerChanged?.call(nextPrayer);
          }
          _previousNextPrayer = _nextPrayer;
          _nextPrayer = nextPrayer;
          _remainingTime =
              '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
        });
      }
    } else {
      final tomorrow = DateTime.now().add(Duration(days: 1));
      final tomorrowFajr = _parseTime(widget.timings.fajr, tomorrow);
      final difference = tomorrowFajr.difference(now);

      if (mounted) {
        setState(() {
          if (_nextPrayer != 'الفجر' && _previousNextPrayer.isNotEmpty) {
            // Next prayer changed, notify parent
            widget.onNextPrayerChanged?.call('الفجر');
          }
          _previousNextPrayer = _nextPrayer;
          _nextPrayer = 'الفجر';
          _remainingTime =
              '${difference.inHours}:${(difference.inMinutes % 60).toString().padLeft(2, '0')}:${(difference.inSeconds % 60).toString().padLeft(2, '0')}';
        });
      }
    }
  }

  DateTime _parseTime(String time, [DateTime? date]) {
    final now = date ?? DateTime.now();
    final parts = time.split(':');
    return DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: AppDecorations.liquidGlass(
        context,
        backgroundColor: colors.primary.withValues(alpha: 0.1),
      ),
      child: Column(
        children: [
          Text(
            'الوقت المتبقي حتى $_nextPrayer',
            style: AppTextStyles.titleMedium(context).copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            _remainingTime,
            style: AppTextStyles.code(context).copyWith(
              color: colors.primary,
              fontFamily: 'Qahiri',
              fontSize: 45.0,
            ),
          ),
        ],
      ),
    );
  }
}
