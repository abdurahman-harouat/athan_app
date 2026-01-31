import 'package:athan_app_v2/models/prayer_times.dart';
import 'package:athan_app_v2/services/prayer_notitfication_service.dart';
import 'package:athan_app_v2/services/prayer_service.dart';
import 'package:athan_app_v2/theme.dart';
import 'package:athan_app_v2/utils/month_translations.dart';
import 'package:athan_app_v2/utils/prayer_icons.dart';
import 'package:athan_app_v2/widgets/prayer_countdown.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart' as intl;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PrayerService _prayerService = PrayerService();
  List<PrayerDay> _prayerDays = [];
  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now();
  String _currentNextPrayer = '';

  @override
  void initState() {
    super.initState();
    PrayerNotificationService.initialize().then((_) {
      _loadPrayerTimes();
    });
  }

  Future<void> _loadPrayerTimes() async {
    setState(() => _isLoading = true);
    try {
      final year = _selectedDate.year;
      final month = _selectedDate.month;
      final key = 'prayer_times_${year}_$month';

      var prayerDays = await _prayerService.loadPrayerTimes(key);

      if (prayerDays.isEmpty) {
        prayerDays = await _prayerService.fetchPrayerTimes(year, month);
        await _prayerService.savePrayerTimes(prayerDays, key);
      }

      await PrayerNotificationService.cancelAllNotifications();

      final now = DateTime.now();
      final todayPrayers = prayerDays.firstWhere(
        (day) => day.readableDate == intl.DateFormat('dd MMM yyyy').format(now),
        orElse: () => prayerDays.first,
      );

      if (_selectedDate.year == now.year &&
          _selectedDate.month == now.month &&
          _selectedDate.day == now.day) {
        await _scheduleTodaysPrayers(todayPrayers);
      }

      setState(() {
        _prayerDays = prayerDays;
        _isLoading = false;
        // Initialize current next prayer
        if (_selectedDate.year == now.year &&
            _selectedDate.month == now.month &&
            _selectedDate.day == now.day &&
            prayerDays.isNotEmpty) {
          _currentNextPrayer = _getNextPrayerName(todayPrayers.timings);
        }
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: Text('خطأ'),
            content: Text('فشل تحميل مواقيت الصلاة: $e'),
            actions: [
              CupertinoDialogAction(
                child: Text('حسناً'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _scheduleTodaysPrayers(PrayerDay prayerDay) async {
    final prayers = {
      'Fajr': (PrayerNames.arabic['Fajr']!, prayerDay.timings.fajr),
      'Dhuhr': (PrayerNames.arabic['Dhuhr']!, prayerDay.timings.dhuhr),
      'Asr': (PrayerNames.arabic['Asr']!, prayerDay.timings.asr),
      'Maghrib': (PrayerNames.arabic['Maghrib']!, prayerDay.timings.maghrib),
      'Isha': (PrayerNames.arabic['Isha']!, prayerDay.timings.isha),
    };

    // Cancel all existing notifications first
    await PrayerNotificationService.cancelAllNotifications();

    // Schedule notifications for each prayer
    for (var entry in prayers.entries) {
      final prayerName = entry.key;
      final arabicName = entry.value.$1;
      final timeString = entry.value.$2;

      final timeParts = timeString.split(':');
      final now = DateTime.now();
      final prayerTime = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
      );

      // Schedule notification 5 minutes before prayer time
      final notificationTime = prayerTime.subtract(Duration(minutes: 5));

      await PrayerNotificationService.schedulePrayerNotification(
        prayerName: prayerName,
        arabicName: arabicName,
        timeString: timeString,
        scheduledTime: notificationTime,
      );
    }

    // Log scheduled notifications count (no dialog to avoid annoyance)
    if (kDebugMode) {
      final scheduledNotifs =
          await PrayerNotificationService.getScheduledNotifications();
      print('✅ Scheduled ${scheduledNotifs.length} prayer notifications');
    }
  }

  void _goToToday() {
    setState(() {
      _selectedDate = DateTime.now();
      _loadPrayerTimes();
    });
  }

  String _getNextPrayerName(PrayerTimings timings) {
    final now = DateTime.now();
    final prayers = {
      'الفجر': _parseTime(timings.fajr),
      'الظهر': _parseTime(timings.dhuhr),
      'العصر': _parseTime(timings.asr),
      'المغرب': _parseTime(timings.maghrib),
      'العشاء': _parseTime(timings.isha),
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

    return nextPrayer;
  }

  DateTime _parseTime(String time) {
    final now = DateTime.now();
    final parts = time.split(':');
    return DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  Widget _buildPrayerTimeRow(String name, String time, bool isNext) {
    return Builder(
      builder: (context) {
        final colors = AppColors.of(context);
        final iconData = PrayerIcons.getIconData(name);

        return Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            decoration: isNext
                ? BoxDecoration(
                    color: colors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: colors.primary.withOpacity(0.3),
                      width: 2.0,
                    ),
                  )
                : null,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 28.0,
                      width: 28.0,
                      child: PrayerIcons.buildGradientIcon(
                        icon: iconData.icon,
                        gradient: iconData.gradient,
                        size: 28.0,
                      ),
                    ),
                    SizedBox(width: AppSpacing.md),
                    Text(
                      name,
                      style: AppTextStyles.headlineMedium(context).copyWith(
                        color: isNext ? colors.primary : colors.textPrimary,
                        fontWeight: isNext ? FontWeight.w700 : FontWeight.w600,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
                Text(
                  time,
                  style: AppTextStyles.headlineMedium(context).copyWith(
                    fontWeight: isNext ? FontWeight.bold : FontWeight.normal,
                    color: isNext ? colors.primary : colors.textPrimary,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDatePicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 300,
        color: CupertinoColors.systemBackground,
        child: Column(
          children: [
            Container(
              height: 50,
              color: CupertinoColors.systemGrey6,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: Text('إلغاء'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  CupertinoButton(
                    child: Text('تم'),
                    onPressed: () {
                      Navigator.pop(context);
                      _loadPrayerTimes();
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: _selectedDate,
                minimumDate: DateTime.now().subtract(Duration(days: 365)),
                maximumDate: DateTime.now().add(Duration(days: 3650)),
                onDateTimeChanged: (date) {
                  setState(() => _selectedDate = date);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateLocation() async {
    setState(() => _isLoading = true);
    try {
      final year = DateTime.now().year;
      final month = DateTime.now().month;
      final key = 'prayer_times_${year}_$month';

      await _prayerService.clearPrayerTimes(key);

      if (mounted) {
        setState(() {
          _selectedDate = DateTime.now();
        });
      }

      await _loadPrayerTimes();

      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: Text('تم التحديث'),
            content: Text('تم تحديث الموقع ومواقيت الصلاة'),
            actions: [
              CupertinoDialogAction(
                child: Text('حسناً'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: CupertinoPageScaffold(
        backgroundColor: colors.background,
        navigationBar: CupertinoNavigationBar(
          middle: Text(
            'مواقيت الصلاة',
            style: AppTextStyles.headlineSmall(context),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: Icon(CupertinoIcons.location_solid, size: AppIconSizes.lg),
                onPressed: _updateLocation,
              ),
              SizedBox(width: AppSpacing.xs),
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: Icon(CupertinoIcons.calendar, size: AppIconSizes.lg),
                onPressed: _showDatePicker,
              ),
              SizedBox(width: AppSpacing.xs),
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: Icon(CupertinoIcons.today, size: AppIconSizes.lg),
                onPressed: _goToToday,
              ),
            ],
          ),
        ),
        child: _isLoading
            ? Center(child: CupertinoActivityIndicator(radius: 20))
            : SafeArea(
                child: CustomScrollView(
                  slivers: [
                    if (_prayerDays.isNotEmpty) ...[
                      if (_selectedDate.year == DateTime.now().year &&
                          _selectedDate.month == DateTime.now().month &&
                          _selectedDate.day == DateTime.now().day)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                            ),
                            child: PrayerCountdown(
                              timings:
                                  _prayerDays[_selectedDate.day - 1].timings,
                              onNextPrayerChanged: (nextPrayer) {
                                setState(() {
                                  _currentNextPrayer = nextPrayer;
                                });
                              },
                            ),
                          ),
                        ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(AppSpacing.md),
                          child: Container(
                            decoration: AppDecorations.liquidGlass(context),
                            child: Padding(
                              padding: EdgeInsets.all(AppSpacing.md),
                              child: Column(
                                children: [
                                  Text(
                                    '${_prayerDays[_selectedDate.day - 1].hijri.day} ${MonthTranslations.getHijriMonth(_prayerDays[_selectedDate.day - 1].hijri.monthEn)} ${_prayerDays[_selectedDate.day - 1].hijri.year}',
                                    style: AppTextStyles.titleLarge(context)
                                        .copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textDirection: TextDirection.rtl,
                                  ),
                                  SizedBox(height: AppSpacing.sm),
                                  Container(
                                    width: 100,
                                    height: 1,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColors.of(context)
                                              .divider
                                              .withOpacity(0.0),
                                          AppColors.of(context).divider,
                                          AppColors.of(context)
                                              .divider
                                              .withOpacity(0.0),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: AppSpacing.sm),
                                  Text(
                                    '${_selectedDate.day} ${MonthTranslations.getGregorianMonth(intl.DateFormat('MMMM').format(_selectedDate))} ${_selectedDate.year}',
                                    style: AppTextStyles.titleMedium(context)
                                        .copyWith(
                                      color:
                                          AppColors.of(context).textSecondary,
                                    ),
                                    textAlign: TextAlign.center,
                                    textDirection: TextDirection.rtl,
                                  ),
                                  SizedBox(height: AppSpacing.md),
                                  Builder(builder: (context) {
                                    final isToday = _selectedDate.year ==
                                            DateTime.now().year &&
                                        _selectedDate.month ==
                                            DateTime.now().month &&
                                        _selectedDate.day == DateTime.now().day;
                                    final nextPrayer =
                                        isToday ? _currentNextPrayer : '';

                                    return Column(
                                      children: [
                                        _buildPrayerTimeRow(
                                          'الفجر',
                                          _prayerDays[_selectedDate.day - 1]
                                              .timings
                                              .fajr,
                                          isToday && nextPrayer == 'الفجر',
                                        ),
                                        _buildPrayerTimeRow(
                                          'الظهر',
                                          _prayerDays[_selectedDate.day - 1]
                                              .timings
                                              .dhuhr,
                                          isToday && nextPrayer == 'الظهر',
                                        ),
                                        _buildPrayerTimeRow(
                                          'العصر',
                                          _prayerDays[_selectedDate.day - 1]
                                              .timings
                                              .asr,
                                          isToday && nextPrayer == 'العصر',
                                        ),
                                        _buildPrayerTimeRow(
                                          'المغرب',
                                          _prayerDays[_selectedDate.day - 1]
                                              .timings
                                              .maghrib,
                                          isToday && nextPrayer == 'المغرب',
                                        ),
                                        _buildPrayerTimeRow(
                                          'العشاء',
                                          _prayerDays[_selectedDate.day - 1]
                                              .timings
                                              .isha,
                                          isToday && nextPrayer == 'العشاء',
                                        ),
                                      ],
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }
}
