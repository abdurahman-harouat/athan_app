import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:athan_app_v2/models/settings.dart';
import 'package:athan_app_v2/screens/migration_screen.dart';
import 'package:athan_app_v2/services/location_service.dart';
import 'package:athan_app_v2/services/prayer_notitfication_service.dart';
import 'package:athan_app_v2/services/prayer_service.dart';
import 'package:athan_app_v2/services/storage_service.dart';
import 'package:athan_app_v2/theme.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Divider, LinearProgressIndicator;

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final StorageService _storageService = StorageService();
  final PrayerService _prayerService = PrayerService();
  final LocationService _locationService = LocationService();
  AppSettings _settings = AppSettings();
  bool _isLoading = true;
  Map<String, dynamic>? _cacheStatus;
  String? _currentLocationName;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadCacheStatus();
  }

  Future<void> _loadCacheStatus() async {
    final location = await _locationService.getCurrentSavedLocation();
    if (location != null) {
      final lat = location['latitude'] as double;
      final lng = location['longitude'] as double;
      final name = location['name'] as String?;
      final status = await _prayerService.getCacheStatus(lat, lng);
      if (mounted) {
        setState(() {
          _cacheStatus = status;
          _currentLocationName = name;
        });
      }
    }
  }

  Future<void> _loadSettings() async {
    final settings = await _storageService.getSettings();
    setState(() {
      _settings = settings;
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    await _storageService.saveSettings(_settings);
    await _updateNotifications();
  }

  Future<void> _updateNotifications() async {
    // Re-schedule notifications with new settings
    await PrayerNotificationService.cancelAllNotifications();
    // The notifications will be re-scheduled when the home screen loads
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    if (_isLoading) {
      return const CupertinoPageScaffold(
        child: Center(child: CupertinoActivityIndicator()),
      );
    }

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: CupertinoPageScaffold(
        backgroundColor: colors.background,
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _buildHeader(),
              ),
              SliverToBoxAdapter(
                child: _buildOfflineDataSection(),
              ),
              SliverToBoxAdapter(
                child: _buildNotificationSettingsSection(),
              ),
              SliverToBoxAdapter(
                child: _buildDataManagementSection(),
              ),
              const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الإعدادات',
            style: AppTextStyles.headlineLarge(context).copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'تخصيص إشعارات الصلاة',
            style: AppTextStyles.bodyMedium(context).copyWith(
              color: AppColors.of(context).textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineDataSection() {
    final colors = AppColors.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Row(
              children: [
                Icon(
                  CupertinoIcons.cloud_download,
                  color: colors.primary,
                  size: 22,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'بيانات أوقات الصلاة المحفوظة',
                  style: AppTextStyles.titleMedium(context).copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: AppDecorations.liquidGlass(context),
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_cacheStatus == null) ...[
                  Row(
                    children: [
                      Icon(
                        CupertinoIcons.exclamationmark_circle,
                        color: colors.warning,
                        size: 20,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'لم يتم حفظ بيانات أوقات الصلاة بعد',
                          style: AppTextStyles.bodyMedium(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'اضغط على أيقونة الموقع في الشاشة الرئيسية ثم اختر "تحميل بيانات 7 سنوات" للعمل بدون إنترنت',
                    style: AppTextStyles.caption(context).copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ] else ...[
                  // Location name
                  if (_currentLocationName != null) ...[
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.location_solid,
                          color: colors.primary,
                          size: 18,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          _currentLocationName!,
                          style: AppTextStyles.bodyLarge(context).copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],

                  // Cache status
                  Row(
                    children: [
                      Icon(
                        _cacheStatus!['isCached'] == true
                            ? CupertinoIcons.checkmark_circle_fill
                            : CupertinoIcons.clock,
                        color: _cacheStatus!['isCached'] == true
                            ? colors.success
                            : colors.warning,
                        size: 20,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          _cacheStatus!['isCached'] == true
                              ? 'تم حفظ بيانات 7 سنوات كاملة ✓'
                              : 'تم حفظ ${_cacheStatus!['cachedMonths']} من ${_cacheStatus!['totalMonths']} شهر',
                          style: AppTextStyles.bodyMedium(context).copyWith(
                            color: _cacheStatus!['isCached'] == true
                                ? colors.success
                                : colors.textPrimary,
                            fontWeight: _cacheStatus!['isCached'] == true
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  // Years range
                  Text(
                    'الفترة: ${_cacheStatus!['yearsRange']}',
                    style: AppTextStyles.caption(context).copyWith(
                      color: colors.textSecondary,
                    ),
                  ),

                  // Progress bar if not complete
                  if (_cacheStatus!['isCached'] != true) ...[
                    const SizedBox(height: AppSpacing.md),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (_cacheStatus!['cachedMonths'] as int) /
                            (_cacheStatus!['totalMonths'] as int),
                        backgroundColor: colors.divider,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(colors.primary),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSettingsSection() {
    final colors = AppColors.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Row(
              children: [
                Icon(
                  CupertinoIcons.bell,
                  color: colors.primary,
                  size: 22,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'إعدادات الإشعارات',
                  style: AppTextStyles.titleMedium(context).copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: AppDecorations.liquidGlass(context),
            child: Column(
              children: [
                _buildPrayerNotificationTile(
                  prayerName: 'Fajr',
                  title: 'صلاة الفجر',
                  settings: _settings.fajrSettings,
                  onChanged: (newSettings) {
                    setState(() {
                      _settings = _settings.copyWith(fajrSettings: newSettings);
                    });
                    _saveSettings();
                  },
                ),
                Divider(
                  height: 1,
                  indent: AppSpacing.md,
                  color: colors.divider,
                ),
                _buildPrayerNotificationTile(
                  prayerName: 'Dhuhr',
                  title: 'صلاة الظهر',
                  settings: _settings.dhuhrSettings,
                  onChanged: (newSettings) {
                    setState(() {
                      _settings =
                          _settings.copyWith(dhuhrSettings: newSettings);
                    });
                    _saveSettings();
                  },
                ),
                Divider(
                  height: 1,
                  indent: AppSpacing.md,
                  color: colors.divider,
                ),
                _buildPrayerNotificationTile(
                  prayerName: 'Asr',
                  title: 'صلاة العصر',
                  settings: _settings.asrSettings,
                  onChanged: (newSettings) {
                    setState(() {
                      _settings = _settings.copyWith(asrSettings: newSettings);
                    });
                    _saveSettings();
                  },
                ),
                Divider(
                  height: 1,
                  indent: AppSpacing.md,
                  color: colors.divider,
                ),
                _buildPrayerNotificationTile(
                  prayerName: 'Maghrib',
                  title: 'صلاة المغرب',
                  settings: _settings.maghribSettings,
                  onChanged: (newSettings) {
                    setState(() {
                      _settings =
                          _settings.copyWith(maghribSettings: newSettings);
                    });
                    _saveSettings();
                  },
                ),
                Divider(
                  height: 1,
                  indent: AppSpacing.md,
                  color: colors.divider,
                ),
                _buildPrayerNotificationTile(
                  prayerName: 'Isha',
                  title: 'صلاة العشاء',
                  settings: _settings.ishaSettings,
                  onChanged: (newSettings) {
                    setState(() {
                      _settings = _settings.copyWith(ishaSettings: newSettings);
                    });
                    _saveSettings();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerNotificationTile({
    required String prayerName,
    required String title,
    required PrayerNotificationSettings settings,
    required Function(PrayerNotificationSettings) onChanged,
  }) {
    final colors = AppColors.of(context);

    return CupertinoButton(
      padding: const EdgeInsets.all(AppSpacing.md),
      onPressed: () => _showNotificationSettingsDialog(
          prayerName, title, settings, onChanged),
      child: Row(
        children: [
          CupertinoSwitch(
            value: settings.enabled,
            onChanged: (value) {
              onChanged(settings.copyWith(enabled: value));
            },
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyLarge(context),
                ),
                if (settings.enabled)
                  Text(
                    'تنبيه قبل ${settings.prePrayerReminderMinutes} دقيقة',
                    style: AppTextStyles.caption(context),
                  ),
              ],
            ),
          ),
          Icon(
            CupertinoIcons.chevron_left,
            size: 16,
            color: colors.textTertiary,
          ),
        ],
      ),
    );
  }

  void _showNotificationSettingsDialog(
    String prayerName,
    String title,
    PrayerNotificationSettings settings,
    Function(PrayerNotificationSettings) onChanged,
  ) {
    int prePrayerReminder = settings.prePrayerReminderMinutes;
    bool enabled = settings.enabled;

    showCupertinoModalPopup(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: 350,
          color: AppColors.of(context).background,
          child: SafeArea(
            child: Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: AppColors.of(context).divider),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CupertinoButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('إلغاء'),
                      ),
                      Text(
                        title,
                        style: AppTextStyles.titleMedium(context).copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      CupertinoButton(
                        onPressed: () {
                          onChanged(PrayerNotificationSettings(
                            enabled: enabled,
                            prePrayerReminderMinutes: prePrayerReminder,
                          ));
                          Navigator.pop(context);
                        },
                        child: Text(
                          'حفظ',
                          style: TextStyle(
                            color: AppColors.of(context).primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: AppDecorations.cleanCard(context),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'تفعيل الإشعارات',
                              style: AppTextStyles.bodyLarge(context),
                            ),
                            CupertinoSwitch(
                              value: enabled,
                              onChanged: (value) {
                                setModalState(() => enabled = value);
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      if (enabled) ...[
                        Text(
                          'وقت التنبيه قبل الصلاة',
                          style: AppTextStyles.titleSmall(context).copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: AppDecorations.cleanCard(context),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'سيتم إرسال إشعار قبل $prePrayerReminder دقيقة من وقت الصلاة',
                                style: AppTextStyles.bodyMedium(context),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              CupertinoSlider(
                                value: prePrayerReminder.toDouble(),
                                min: 0,
                                max: 60,
                                divisions: 12,
                                onChanged: (value) {
                                  setModalState(() {
                                    prePrayerReminder = value.round();
                                  });
                                },
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('0 د',
                                      style: AppTextStyles.caption(context)),
                                  Text(
                                    '$prePrayerReminder دقيقة',
                                    style: AppTextStyles.bodyMedium(context)
                                        .copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.of(context).primary,
                                    ),
                                  ),
                                  Text('60 د',
                                      style: AppTextStyles.caption(context)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleExport() async {
    try {
      final jsonString = await _storageService.exportData();
      final timestamp = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '-')
          .split('.')
          .first;
      final fileName = 'athan_app_backup_$timestamp.json';

      // Use file_picker's saveFile to let user choose location (works on Android 13+)
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'اختر مكان حفظ النسخة الاحتياطية',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: ['json'],
        bytes: utf8.encode(jsonString),
      );

      if (result != null) {
        // On some platforms, saveFile returns the path but doesn't write bytes
        // So we need to write the file manually
        if (Platform.isAndroid || Platform.isIOS) {
          // bytes parameter handles the writing on mobile
          _showSuccess('تم حفظ النسخة الاحتياطية بنجاح');
        } else {
          // For desktop platforms, write the file
          final file = File(result);
          await file.writeAsString(jsonString);
          _showSuccess('تم حفظ النسخة الاحتياطية بنجاح');
        }
      }
    } catch (e) {
      _showError('فشل التصدير: $e');
    }
  }

  Future<void> _handleImport() async {
    try {
      // Use withReadStream for Android 13+ compatibility with scoped storage
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true, // Important for Android 13+ scoped storage
      );

      if (result != null && result.files.single.bytes != null) {
        // Use bytes directly for Android 13+ compatibility
        final jsonString = utf8.decode(result.files.single.bytes!);

        await _storageService.importData(jsonString);
        await _loadSettings();

        if (mounted) {
          _showSuccess('تم استيراد البيانات بنجاح');
        }
      } else if (result != null && result.files.single.path != null) {
        // Fallback for platforms that provide path
        final file = File(result.files.single.path!);
        final jsonString = await file.readAsString();

        await _storageService.importData(jsonString);
        await _loadSettings();

        if (mounted) {
          _showSuccess('تم استيراد البيانات بنجاح');
        }
      }
    } catch (e) {
      _showError('فشل الاستيراد: $e');
    }
  }

  void _showError(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('خطأ'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('حسناً'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showSuccess(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('نجاح'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('حسناً'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildDataManagementSection() {
    final colors = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'إدارة البيانات',
            style: AppTextStyles.headlineSmall(context),
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            decoration: AppDecorations.cleanCard(context),
            child: Column(
              children: [
                CupertinoButton(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  onPressed: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (context) => const MigrationScreen(),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colors.cardBackground,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Icon(
                          CupertinoIcons.arrow_up_arrow_down_circle,
                          color: colors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          'استيراد البيانات من الويب',
                          style: AppTextStyles.bodyLarge(context),
                        ),
                      ),
                      Icon(
                        CupertinoIcons.chevron_left,
                        size: 16,
                        color: colors.textSecondary,
                      ),
                    ],
                  ),
                ),
                Divider(
                  height: 1,
                  indent: AppSpacing.md,
                  color: colors.divider,
                ),
                CupertinoButton(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  onPressed: _handleExport,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colors.cardBackground,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Icon(
                          CupertinoIcons.share,
                          color: colors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          'تصدير البيانات (نسخة احتياطية)',
                          style: AppTextStyles.bodyLarge(context),
                        ),
                      ),
                      Icon(
                        CupertinoIcons.chevron_left,
                        size: 16,
                        color: colors.textSecondary,
                      ),
                    ],
                  ),
                ),
                Divider(
                  height: 1,
                  indent: AppSpacing.md,
                  color: colors.divider,
                ),
                CupertinoButton(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  onPressed: _handleImport,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colors.cardBackground,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Icon(
                          CupertinoIcons.arrow_down_doc,
                          color: colors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          'استيراد نسخة احتياطية',
                          style: AppTextStyles.bodyLarge(context),
                        ),
                      ),
                      Icon(
                        CupertinoIcons.chevron_left,
                        size: 16,
                        color: colors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
