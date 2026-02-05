import 'dart:ui' as ui;
import 'package:athan_app_v2/models/task.dart';
import 'package:athan_app_v2/services/prayer_service.dart';
import 'package:athan_app_v2/services/storage_service.dart';
import 'package:athan_app_v2/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => CalendarScreenState();
}

class CalendarScreenState extends State<CalendarScreen> {
  final StorageService _storageService = StorageService();
  final PrayerService _prayerService = PrayerService();

  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  List<Task> _tasks = [];
  Map<DateTime, List<Task>> _events = {};
  DailyTasksSummary? _dailySummary;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// Public method to refresh calendar data - can be called externally via GlobalKey
  void refreshData() {
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await _loadAllTasks();
    await _loadTasks();
    await _loadSummary();
    setState(() => _isLoading = false);
  }

  Future<void> _loadAllTasks() async {
    final allTasks = await _storageService.getAllTasks();
    final Map<DateTime, List<Task>> events = {};

    for (final task in allTasks) {
      final date = DateTime(task.date.year, task.date.month, task.date.day);
      if (events[date] == null) {
        events[date] = [];
      }
      events[date]!.add(task);
    }

    // Sort events by time
    events.forEach((key, value) {
      value.sort((a, b) => a.startTime.compareTo(b.startTime));
    });

    setState(() => _events = events);
  }

  Future<void> _loadTasks() async {
    final tasks = await _storageService.getTasksForDate(_selectedDay);
    tasks.sort((a, b) => a.startTime.compareTo(b.startTime));
    setState(() => _tasks = tasks);
  }

  Future<void> _loadSummary() async {
    final summary = await _storageService.getDailySummary(
      _selectedDay,
      _prayerService,
    );
    setState(() => _dailySummary = summary);
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
    _loadTasks();
    _loadSummary();
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0) {
      return '$hoursس $minutesد';
    }
    return '$minutesد';
  }

  String _formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

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
                child: _buildCalendar(),
              ),
              SliverToBoxAdapter(
                child: _buildAnalyticsCard(),
              ),
              SliverToBoxAdapter(
                child: _buildTasksHeader(),
              ),
              if (_isLoading)
                const SliverFillRemaining(
                  child: Center(child: CupertinoActivityIndicator()),
                )
              else if (_tasks.isEmpty)
                SliverToBoxAdapter(
                  child: _buildEmptyState(),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildTaskCard(_tasks[index]),
                    childCount: _tasks.length,
                  ),
                ),
              // Increased padding to account for bottom navigation bar (~90px + safe area)
              const SliverPadding(padding: EdgeInsets.only(bottom: 140)),
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
            'التقويم',
            style: AppTextStyles.headlineLarge(context).copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'إدارة مهامك مع مواقيت الصلاة',
            style: AppTextStyles.bodyMedium(context).copyWith(
              color: AppColors.of(context).textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    final colors = AppColors.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: AppDecorations.liquidGlass(context),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: TableCalendar(
          firstDay: DateTime(2020, 1, 1),
          lastDay: DateTime(2030, 12, 31),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          eventLoader: (day) {
            return _events[DateTime(day.year, day.month, day.day)] ?? [];
          },
          calendarFormat: _calendarFormat,
          onDaySelected: _onDaySelected,
          onFormatChanged: (format) {
            setState(() => _calendarFormat = format);
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
          startingDayOfWeek: StartingDayOfWeek.saturday,
          locale: 'ar',
          calendarStyle: CalendarStyle(
            selectedDecoration: BoxDecoration(
              color: colors.primary,
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: colors.primary.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            defaultTextStyle: AppTextStyles.bodyMedium(context),
            weekendTextStyle: AppTextStyles.bodyMedium(context).copyWith(
              color: colors.error,
            ),
            outsideTextStyle: AppTextStyles.bodyMedium(context).copyWith(
              color: colors.textTertiary,
            ),
            selectedTextStyle: AppTextStyles.bodyMedium(context).copyWith(
              color: CupertinoColors.white,
              fontWeight: FontWeight.bold,
            ),
            todayTextStyle: AppTextStyles.bodyMedium(context).copyWith(
              fontWeight: FontWeight.bold,
            ),
            markersMaxCount: 3,
            markerDecoration: BoxDecoration(
              color: colors.primary,
              shape: BoxShape.circle,
            ),
          ),
          headerStyle: HeaderStyle(
            titleCentered: true,
            formatButtonVisible: true,
            formatButtonDecoration: BoxDecoration(
              color: colors.cardBackground,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            formatButtonTextStyle: AppTextStyles.labelMedium(context),
            titleTextStyle: AppTextStyles.titleMedium(context).copyWith(
              fontWeight: FontWeight.bold,
            ),
            leftChevronIcon: Icon(
              CupertinoIcons.chevron_right,
              color: colors.textPrimary,
            ),
            rightChevronIcon: Icon(
              CupertinoIcons.chevron_left,
              color: colors.textPrimary,
            ),
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: AppTextStyles.labelSmall(context).copyWith(
              fontWeight: FontWeight.bold,
            ),
            weekendStyle: AppTextStyles.labelSmall(context).copyWith(
              fontWeight: FontWeight.bold,
              color: colors.error,
            ),
          ),
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, date, events) {
              if (events.isNotEmpty) {
                final tasks = events.cast<Task>();
                return Positioned(
                  bottom: 5,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: tasks.take(3).map((task) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 1.5),
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: task.isCompleted
                              ? colors.success
                              : colors.primary,
                          shape: BoxShape.circle,
                        ),
                      );
                    }).toList(),
                  ),
                );
              }
              return null;
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyticsCard() {
    if (_dailySummary == null) return const SizedBox.shrink();

    final summary = _dailySummary!;

    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: AppDecorations.liquidGlass(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تحليل الوقت',
            style: AppTextStyles.titleMedium(context).copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildTimeBar(summary),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _buildTimeStat(
                'الصلاة',
                summary.totalPrayerTime,
                CupertinoColors.systemBlue,
              ),
              _buildTimeStat(
                'الذهاب والإياب',
                summary.totalTravelTime,
                CupertinoColors.systemOrange,
              ),
              _buildTimeStat(
                'المهام',
                summary.totalTasksDuration,
                CupertinoColors.systemGreen,
              ),
              _buildTimeStat(
                'المتبقي',
                summary.remainingDiscretionaryTime,
                CupertinoColors.systemPurple,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeBar(DailyTasksSummary summary) {
    final colors = AppColors.of(context);
    const dayMinutes = 24.0 * 60.0;

    final prayerWidth = (summary.totalPrayerTime.inMinutes / dayMinutes) * 100;
    final travelWidth = (summary.totalTravelTime.inMinutes / dayMinutes) * 100;
    final tasksWidth =
        (summary.totalTasksDuration.inMinutes / dayMinutes) * 100;

    return Container(
      height: 12,
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.xs),
      ),
      child: Row(
        children: [
          if (prayerWidth > 0)
            Flexible(
              flex: prayerWidth.round(),
              child: Container(
                decoration: const BoxDecoration(
                  color: CupertinoColors.systemBlue,
                  borderRadius: BorderRadius.horizontal(
                    right: Radius.circular(AppRadius.xs),
                  ),
                ),
              ),
            ),
          if (travelWidth > 0)
            Flexible(
              flex: travelWidth.round(),
              child: Container(color: CupertinoColors.systemOrange),
            ),
          if (tasksWidth > 0)
            Flexible(
              flex: tasksWidth.round(),
              child: Container(
                decoration: const BoxDecoration(
                  color: CupertinoColors.systemGreen,
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(AppRadius.xs),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTimeStat(String label, Duration duration, Color color) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.labelSmall(context),
          ),
          Text(
            _formatDuration(duration),
            style: AppTextStyles.labelMedium(context).copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'المهام (${_tasks.length})',
            style: AppTextStyles.titleMedium(context).copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: _showAddTaskDialog,
            child: Row(
              children: [
                Icon(
                  CupertinoIcons.add_circled_solid,
                  color: AppColors.of(context).primary,
                ),
                const SizedBox(width: 4),
                Text(
                  'إضافة',
                  style: AppTextStyles.labelMedium(context).copyWith(
                    color: AppColors.of(context).primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(Task task) {
    final colors = AppColors.of(context);

    Color priorityColor;
    switch (task.priority) {
      case TaskPriority.high:
        priorityColor = colors.error;
        break;
      case TaskPriority.medium:
        priorityColor = colors.warning;
        break;
      case TaskPriority.low:
        priorityColor = colors.success;
        break;
    }

    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: colors.error,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: AppSpacing.md),
        child: const Icon(
          CupertinoIcons.delete,
          color: CupertinoColors.white,
        ),
      ),
      onDismissed: (_) async {
        await _storageService.deleteTask(task.id);
        _loadData();
      },
      child: GestureDetector(
        onTap: () => _showEditTaskDialog(task),
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: AppDecorations.cleanCard(context),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 50,
                decoration: BoxDecoration(
                  color: priorityColor,
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: AppTextStyles.bodyLarge(context).copyWith(
                        fontWeight: FontWeight.w600,
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    if (task.description != null &&
                        task.description!.isNotEmpty)
                      Text(
                        task.description!,
                        style: AppTextStyles.bodySmall(context).copyWith(
                          color: colors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.clock,
                          size: 14,
                          color: colors.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${_formatTime(task.startTime)} - ${_formatTime(task.endTime)}',
                          style: AppTextStyles.labelSmall(context).copyWith(
                            color: colors.textTertiary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colors.cardBackground,
                            borderRadius: BorderRadius.circular(AppRadius.xs),
                          ),
                          child: Text(
                            task.category.displayName,
                            style: AppTextStyles.labelSmall(context).copyWith(
                              fontSize: 12,
                            ),
                          ),
                        ),
                        if (task.isRecurring) ...[
                          const SizedBox(width: 8),
                          Icon(
                            CupertinoIcons.repeat,
                            size: 14,
                            color: colors.primary,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () async {
                  await _storageService.saveTask(
                    task.copyWith(isCompleted: !task.isCompleted),
                  );
                  _loadData();
                },
                child: Icon(
                  task.isCompleted
                      ? CupertinoIcons.check_mark_circled_solid
                      : CupertinoIcons.circle,
                  color:
                      task.isCompleted ? colors.success : colors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.checkmark_circle,
            size: 64,
            color: AppColors.of(context).textTertiary,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'لا توجد مهام لهذا اليوم',
            style: AppTextStyles.bodyLarge(context).copyWith(
              color: AppColors.of(context).textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          CupertinoButton(
            onPressed: _showAddTaskDialog,
            child: Text(
              'إضافة مهمة جديدة',
              style: AppTextStyles.bodyMedium(context).copyWith(
                color: AppColors.of(context).primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddTaskDialog() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => TaskDialog(
        selectedDate: _selectedDay,
        onSave: (task) async {
          await _storageService.saveTask(task);
          _loadData();
        },
      ),
    );
  }

  void _showEditTaskDialog(Task task) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => TaskDialog(
        selectedDate: _selectedDay,
        existingTask: task,
        onSave: (updatedTask) async {
          await _storageService.saveTask(updatedTask);
          _loadData();
        },
      ),
    );
  }
}

class TaskDialog extends StatefulWidget {
  final DateTime selectedDate;
  final Task? existingTask;
  final Function(Task) onSave;

  const TaskDialog({
    super.key,
    required this.selectedDate,
    this.existingTask,
    required this.onSave,
  });

  @override
  State<TaskDialog> createState() => _TaskDialogState();
}

class _TaskDialogState extends State<TaskDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _startTime;
  late Duration _duration;
  late TaskCategory _category;
  late TaskPriority _priority;
  late bool _isRecurring;

  @override
  void initState() {
    super.initState();
    final task = widget.existingTask;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descriptionController =
        TextEditingController(text: task?.description ?? '');
    _startTime = task?.startTime ??
        DateTime(
          widget.selectedDate.year,
          widget.selectedDate.month,
          widget.selectedDate.day,
          9,
          0,
        );
    _duration = task?.duration ?? const Duration(hours: 1);
    _category = task?.category ?? TaskCategory.other;
    _priority = task?.priority ?? TaskPriority.medium;
    _isRecurring = task?.isRecurring ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.lg),
        ),
      ),
      child: Directionality(
        textDirection: ui.TextDirection.rtl,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  _buildTextField(
                    controller: _titleController,
                    placeholder: 'عنوان المهمة',
                    icon: CupertinoIcons.text_quote,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildTextField(
                    controller: _descriptionController,
                    placeholder: 'وصف المهمة (اختياري)',
                    icon: CupertinoIcons.text_alignright,
                    maxLines: 3,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildTimeSelector(),
                  const SizedBox(height: AppSpacing.md),
                  _buildDurationSelector(),
                  const SizedBox(height: AppSpacing.md),
                  _buildCategorySelector(),
                  const SizedBox(height: AppSpacing.md),
                  _buildPrioritySelector(),
                  const SizedBox(height: AppSpacing.md),
                  _buildRecurringSwitch(),
                ],
              ),
            ),
            _buildBottomButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.of(context).divider),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          Text(
            widget.existingTask == null ? 'مهمة جديدة' : 'تعديل المهمة',
            style: AppTextStyles.titleMedium(context).copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: _saveTask,
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
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String placeholder,
    required IconData icon,
    int maxLines = 1,
  }) {
    return CupertinoTextField(
      controller: controller,
      placeholder: placeholder,
      maxLines: maxLines,
      style: AppTextStyles.bodyMedium(context),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.of(context).cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      prefix: Padding(
        padding: const EdgeInsets.only(right: AppSpacing.md),
        child: Icon(
          icon,
          color: AppColors.of(context).textTertiary,
        ),
      ),
    );
  }

  Widget _buildTimeSelector() {
    return _buildSelectorCard(
      title: 'وقت البدء',
      value: DateFormat('HH:mm').format(_startTime),
      icon: CupertinoIcons.clock,
      onTap: _showTimePicker,
    );
  }

  Widget _buildDurationSelector() {
    final hours = _duration.inHours;
    final minutes = _duration.inMinutes % 60;
    String value;
    if (hours > 0 && minutes > 0) {
      value = '$hoursس $minutesد';
    } else if (hours > 0) {
      value = '$hours ساعة';
    } else {
      value = '$minutes دقيقة';
    }

    return _buildSelectorCard(
      title: 'المدة',
      value: value,
      icon: CupertinoIcons.hourglass,
      onTap: _showDurationPicker,
    );
  }

  Widget _buildCategorySelector() {
    return _buildSelectorCard(
      title: 'التصنيف',
      value: _category.displayName,
      icon: CupertinoIcons.tag,
      onTap: _showCategoryPicker,
    );
  }

  Widget _buildPrioritySelector() {
    final colors = AppColors.of(context);
    Color priorityColor;
    switch (_priority) {
      case TaskPriority.high:
        priorityColor = colors.error;
        break;
      case TaskPriority.medium:
        priorityColor = colors.warning;
        break;
      case TaskPriority.low:
        priorityColor = colors.success;
        break;
    }

    return _buildSelectorCard(
      title: 'الأولوية',
      value: _priority.displayName,
      valueColor: priorityColor,
      icon: CupertinoIcons.flag,
      onTap: _showPriorityPicker,
    );
  }

  Widget _buildRecurringSwitch() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.of(context).cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.repeat,
            color: AppColors.of(context).textTertiary,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'تكرار يومياً',
              style: AppTextStyles.bodyMedium(context),
            ),
          ),
          CupertinoSwitch(
            value: _isRecurring,
            onChanged: (value) => setState(() => _isRecurring = value),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectorCard({
    required String title,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
    Color? valueColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.of(context).cardBackground,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppColors.of(context).textTertiary,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.bodyMedium(context),
              ),
            ),
            Text(
              value,
              style: AppTextStyles.bodyMedium(context).copyWith(
                color: valueColor ?? AppColors.of(context).primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Icon(
              CupertinoIcons.chevron_left,
              size: 16,
              color: AppColors.of(context).textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButtons() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: SizedBox(
          width: double.infinity,
          child: CupertinoButton.filled(
            onPressed: _saveTask,
            child: Text(
              widget.existingTask == null ? 'إضافة المهمة' : 'حفظ التغييرات',
              style: AppTextStyles.button(context).copyWith(
                color: CupertinoColors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showTimePicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 250,
        color: AppColors.of(context).background,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
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
                    child: const Text('تم'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                initialDateTime: _startTime,
                onDateTimeChanged: (date) {
                  setState(() {
                    _startTime = DateTime(
                      widget.selectedDate.year,
                      widget.selectedDate.month,
                      widget.selectedDate.day,
                      date.hour,
                      date.minute,
                    );
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDurationPicker() {
    final hours = _duration.inHours;
    final minutes = _duration.inMinutes % 60;
    int selectedHours = hours;
    int selectedMinutes = minutes;

    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 250,
        color: AppColors.of(context).background,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.of(context).divider),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CupertinoButton(
                    onPressed: () {
                      setState(() {
                        _duration = Duration(
                          hours: selectedHours,
                          minutes: selectedMinutes,
                        );
                      });
                      Navigator.pop(context);
                    },
                    child: const Text('تم'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: CupertinoPicker(
                      itemExtent: 40,
                      scrollController: FixedExtentScrollController(
                        initialItem: selectedMinutes ~/ 5,
                      ),
                      onSelectedItemChanged: (index) {
                        selectedMinutes = index * 5;
                      },
                      children: List.generate(12, (index) {
                        return Center(
                          child: Text(
                            '${index * 5} د',
                            style: AppTextStyles.bodyMedium(context),
                          ),
                        );
                      }),
                    ),
                  ),
                  Expanded(
                    child: CupertinoPicker(
                      itemExtent: 40,
                      scrollController: FixedExtentScrollController(
                        initialItem: selectedHours,
                      ),
                      onSelectedItemChanged: (index) {
                        selectedHours = index;
                      },
                      children: List.generate(13, (index) {
                        return Center(
                          child: Text(
                            '$index س',
                            style: AppTextStyles.bodyMedium(context),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryPicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 300,
        color: AppColors.of(context).background,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.of(context).divider),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CupertinoButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('تم'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: TaskCategory.values.length,
                itemBuilder: (context, index) {
                  final category = TaskCategory.values[index];
                  return CupertinoButton(
                    onPressed: () {
                      setState(() => _category = category);
                      Navigator.pop(context);
                    },
                    child: Text(
                      category.displayName,
                      style: AppTextStyles.bodyLarge(context).copyWith(
                        color: _category == category
                            ? AppColors.of(context).primary
                            : AppColors.of(context).textPrimary,
                        fontWeight: _category == category
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPriorityPicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 250,
        color: AppColors.of(context).background,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.of(context).divider),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CupertinoButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('تم'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: TaskPriority.values.length,
                itemBuilder: (context, index) {
                  final priority = TaskPriority.values[index];
                  return CupertinoButton(
                    onPressed: () {
                      setState(() => _priority = priority);
                      Navigator.pop(context);
                    },
                    child: Text(
                      priority.displayName,
                      style: AppTextStyles.bodyLarge(context).copyWith(
                        color: _priority == priority
                            ? AppColors.of(context).primary
                            : AppColors.of(context).textPrimary,
                        fontWeight: _priority == priority
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveTask() {
    if (_titleController.text.trim().isEmpty) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('عنوان مطلوب'),
          content: const Text('يرجى إدخال عنوان للمهمة'),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(context),
              child: const Text('حسناً'),
            ),
          ],
        ),
      );
      return;
    }

    final task = Task(
      id: widget.existingTask?.id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      date: widget.selectedDate,
      startTime: _startTime,
      duration: _duration,
      category: _category,
      priority: _priority,
      isRecurring: _isRecurring,
      isCompleted: widget.existingTask?.isCompleted ?? false,
    );

    widget.onSave(task);
    Navigator.pop(context);
  }
}
