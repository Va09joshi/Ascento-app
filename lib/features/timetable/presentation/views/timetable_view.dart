import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';
import 'package:ascento_abacus/core/widgets/app_card.dart';
import 'package:ascento_abacus/core/widgets/app_components.dart';
import 'package:ascento_abacus/core/widgets/app_shimmer.dart';
import 'package:ascento_abacus/core/widgets/responsive_builder.dart';
import 'package:ascento_abacus/shared/models/feature_models.dart';
import 'package:ascento_abacus/shared/providers/feature_providers.dart';

import '../../../../core/widgets/app_page_widgets.dart';

enum TimetableViewMode { daily, weekly }

class TimetableView extends ConsumerStatefulWidget {
  const TimetableView({super.key});

  @override
  ConsumerState<TimetableView> createState() => _TimetableViewState();
}

class _TimetableViewState extends ConsumerState<TimetableView> {
  static const _dayNames = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];

  static const _dayShortNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  static const _subjectPalette = [
    Color(0xFF4FB6FF),
    Color(0xFFFF7A59),
    Color(0xFF2FAE78),
    Color(0xFF8B5CF6),
    Color(0xFFFFC857),
    Color(0xFF14B8A6),
  ];

  static const _actionItems = [
    _TimetableAction(
      title: 'Upload Practice',
      subtitle: 'Send worksheet or homework',
      icon: Icons.upload_file_rounded,
      color: Color(0xFF4FB6FF),
    ),
    _TimetableAction(
      title: 'Upload Recording',
      subtitle: 'Share class video or audio',
      icon: Icons.video_file_rounded,
      color: Color(0xFFFF7A59),
    ),
    _TimetableAction(
      title: 'Pay Fees',
      subtitle: 'Open online payment flow',
      icon: Icons.payment_rounded,
      color: Color(0xFF2FAE78),
    ),
  ];

  int _selectedDay = _initialSelectedDay();
  TimetableViewMode _viewMode = TimetableViewMode.daily;

  static int _initialSelectedDay() {
    final weekday = DateTime.now().weekday;
    return weekday > 6 ? 1 : weekday;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final timetableAsync = ref.watch(weeklyTimetableProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: timetableAsync.when(
        loading: () => ListView(
          padding: EdgeInsets.all(20.w),
          children: List.generate(5, (_) => AppShimmer.card()),
        ),
        error: (error, _) => EmptyStateWidget(
          title: 'Timetable unavailable',
          subtitle: error.toString(),
          icon: Icons.error_outline_rounded,
        ),
        data: (slots) {
          final daySlots = slots
              .where((slot) => slot.dayOfWeek == _selectedDay)
              .toList()
            ..sort(
              (a, b) => _minutesFromClock(a.startTime).compareTo(
                _minutesFromClock(b.startTime),
              ),
            );

          final firstClass = daySlots.isNotEmpty ? daySlots.first.startTime : '--';
          final lastClass = daySlots.isNotEmpty ? daySlots.last.endTime : '--';
          final uniqueTeachers = daySlots.map((slot) => slot.teacherName).toSet();
          final totalMinutes = daySlots.fold<int>(
            0,
            (sum, slot) => sum + _slotDuration(slot),
          );

          return SingleChildScrollView(
            child: ResponsiveContent(
              padding: EdgeInsets.fromLTRB(
                ResponsiveBuilder.horizontalPadding(context),
                18.h,
                ResponsiveBuilder.horizontalPadding(context),
                28.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 46.w,
                        height: 46.w,
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: (isDark
                                  ? AppColors.darkSurface
                                  : AppColors.surface)
                              .withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.border,
                          ),
                        ),
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.schedule_rounded,
                            color: AppColors.primary,
                            size: 22.r,
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Timetable Grid',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'Responsive schedule cards with better media-query handling.',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 14.h),
                  Text(
                    'View the daily schedule as a clean responsive list with quick upload and payment options.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  SizedBox(height: 18.h),

                  // View Toggle Switcher (Daily Grid vs Weekly Matrix)
                  Container(
                    height: 46.h,
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : AppColors.surface,
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.border,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _viewMode = TimetableViewMode.daily),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: _viewMode == TimetableViewMode.daily
                                    ? (isDark ? AppColors.darkPrimary : AppColors.primary)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Daily Grid',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: _viewMode == TimetableViewMode.daily
                                      ? Colors.white
                                      : AppColors.textMuted,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _viewMode = TimetableViewMode.weekly),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: _viewMode == TimetableViewMode.weekly
                                    ? (isDark ? AppColors.darkPrimary : AppColors.primary)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Weekly Matrix',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: _viewMode == TimetableViewMode.weekly
                                      ? Colors.white
                                      : AppColors.textMuted,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 18.h),

                  // Show horizontal days selector only in Daily View
                  if (_viewMode == TimetableViewMode.daily) ...[
                    SizedBox(
                      height: 72.h,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _dayShortNames.length,
                        separatorBuilder: (_, _) => SizedBox(width: 10.w),
                        itemBuilder: (context, index) {
                          final day = index + 1;
                          final isSelected = _selectedDay == day;
                          final count = slots.where((slot) => slot.dayOfWeek == day).length;

                          return GestureDetector(
                            onTap: () => setState(() => _selectedDay = day),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: 90.w,
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 10.h,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? (isDark
                                          ? AppColors.darkPrimary
                                          : AppColors.primary)
                                    : (isDark
                                          ? AppColors.darkSurface
                                          : AppColors.surface),
                                borderRadius: BorderRadius.circular(16.r),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.transparent
                                      : (isDark
                                            ? AppColors.darkBorder
                                            : AppColors.border),
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _dayShortNames[index],
                                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: isSelected
                                          ? Colors.white
                                          : (isDark
                                                ? AppColors.darkTextPrimary
                                                : AppColors.textPrimary),
                                    ),
                                  ),
                                  SizedBox(height: 6.h),
                                  Text(
                                    '$count class',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: isSelected
                                          ? Colors.white.withValues(alpha: 0.85)
                                          : AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 18.h),
                  ],

                  _HorizontalSectionHeader(
                    title: 'Quick Actions',
                    subtitle: 'Upload files or open payment from one place.',
                  ),
                  SizedBox(height: 10.h),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final columns = _gridColumnsForWidth(
                        constraints.maxWidth,
                        mobile: 1,
                        tablet: 2,
                        desktop: 3,
                      );
                      final mainAxisExtent = columns == 1 ? 134.h : 128.h;

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _actionItems.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          crossAxisSpacing: 12.w,
                          mainAxisSpacing: 12.h,
                          mainAxisExtent: mainAxisExtent,
                        ),
                        itemBuilder: (context, index) {
                          final action = _actionItems[index];
                          return _ActionCard(
                            action: action,
                            onTap: () => _showActionMessage(context, action.title),
                          );
                        },
                      );
                    },
                  ),
                  SizedBox(height: 18.h),

                  // Render cross-fade between Daily and Weekly layouts
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 250),
                    crossFadeState: _viewMode == TimetableViewMode.daily
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    firstChild: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _HorizontalSectionHeader(
                          title: '${_dayNames[_selectedDay - 1]} Overview',
                          subtitle: 'Adaptive summary grid for today\'s classes.',
                        ),
                        SizedBox(height: 10.h),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final columns = _gridColumnsForWidth(
                              constraints.maxWidth,
                              mobile: 2,
                              tablet: 2,
                              desktop: 4,
                            );
                            const overviewItems = 4;
                            final rowCount = (overviewItems / columns).ceil();
                            final tileExtent = columns >= 4 ? 112.h : 124.h;
                            final gridHeight =
                                rowCount * tileExtent + ((rowCount - 1) * 12.h);

                            return SizedBox(
                              height: gridHeight,
                              child: GridView(
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: columns,
                                  crossAxisSpacing: 12.w,
                                  mainAxisSpacing: 12.h,
                                  mainAxisExtent: tileExtent,
                                ),
                                children: [
                                  _OverviewCard(
                                    label: 'First Class',
                                    value: firstClass,
                                    icon: Icons.alarm_rounded,
                                    color: const Color(0xFF4FB6FF),
                                  ),
                                  _OverviewCard(
                                    label: 'Last Class',
                                    value: lastClass,
                                    icon: Icons.access_time_filled_rounded,
                                    color: const Color(0xFFFF7A59),
                                  ),
                                  _OverviewCard(
                                    label: 'Teachers',
                                    value: '${uniqueTeachers.length}',
                                    icon: Icons.groups_rounded,
                                    color: const Color(0xFF2FAE78),
                                  ),
                                  _OverviewCard(
                                    label: 'Study Time',
                                    value: '${totalMinutes == 0 ? 0 : totalMinutes} min',
                                    icon: Icons.menu_book_rounded,
                                    color: const Color(0xFF8B5CF6),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 20.h),
                        _HorizontalSectionHeader(
                          title: '${_dayNames[_selectedDay - 1]} Session Grid',
                          subtitle: daySlots.isEmpty
                              ? 'No sessions are scheduled for this day.'
                              : 'Highly responsive grid layout for class timing, classroom, and teacher.',
                        ),
                        SizedBox(height: 10.h),
                        if (daySlots.isEmpty)
                          const EmptyStateWidget(
                            title: 'No Classes Planned',
                            subtitle: 'New sessions will appear here when the timetable is updated.',
                            icon: Icons.event_busy_rounded,
                          )
                        else
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final columns = _gridColumnsForWidth(
                                constraints.maxWidth,
                                mobile: 1,
                                tablet: 2,
                                desktop: 3,
                              );

                              return GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: daySlots.length,
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: columns,
                                  crossAxisSpacing: 12.w,
                                  mainAxisSpacing: 12.h,
                                  mainAxisExtent: columns == 1 ? 168.h : 176.h,
                                ),
                                itemBuilder: (context, index) {
                                  final slot = daySlots[index];
                                  return _TimetableListTile(
                                    slot: slot,
                                    accent: _subjectColor(slot.subject, slot.subjectColor),
                                    durationMinutes: _slotDuration(slot),
                                    onUpload: () => _showActionMessage(
                                      context,
                                      'Upload for ${slot.subject}',
                                    ),
                                    onPayment: () => _showActionMessage(
                                      context,
                                      'Payment for ${slot.subject}',
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                      ],
                    ),
                    secondChild: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _HorizontalSectionHeader(
                          title: 'Weekly Scheduler Board',
                          subtitle: 'View the complete week at a glance with color-coded period cells.',
                        ),
                        SizedBox(height: 12.h),
                        _WeeklyMatrixGrid(
                          slots: slots,
                          activeDay: DateTime.now().weekday > 6 ? 1 : DateTime.now().weekday,
                          onSlotTap: (slot) => _showSlotDetails(context, slot),
                          getSubjectColor: _subjectColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showActionMessage(BuildContext context, String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title action can be connected here.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSlotDetails(BuildContext context, TimetableSlot slot) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = _subjectColor(slot.subject, slot.subjectColor);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.surface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24.r),
              topRight: Radius.circular(24.r),
            ),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.border,
            ),
          ),
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Container(
                    width: 52.w,
                    height: 52.w,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Icon(
                      _subjectIcon(slot.subject),
                      color: accent,
                      size: 24.r,
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          slot.subject,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Weekly Schedule Slot',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              const Divider(),
              SizedBox(height: 16.h),
              _DetailRow(
                label: 'Instructor',
                value: slot.teacherName,
                icon: Icons.person_outline_rounded,
                accent: accent,
              ),
              SizedBox(height: 12.h),
              _DetailRow(
                label: 'Classroom / Location',
                value: slot.room,
                icon: Icons.room_outlined,
                accent: accent,
              ),
              SizedBox(height: 12.h),
              _DetailRow(
                label: 'Time Interval',
                value: '${slot.startTime} - ${slot.endTime} (${_dayNames[slot.dayOfWeek - 1]})',
                icon: Icons.access_time_rounded,
                accent: accent,
              ),
              SizedBox(height: 12.h),
              _DetailRow(
                label: 'Duration',
                value: '${_slotDuration(slot)} minutes',
                icon: Icons.timer_outlined,
                accent: accent,
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        side: BorderSide(color: accent.withValues(alpha: 0.5)),
                      ),
                      icon: Icon(Icons.upload_file_rounded, color: accent, size: 18.r),
                      label: Text(
                        'Upload Work',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: accent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _showActionMessage(
                          context,
                          'Upload practice for ${slot.subject}',
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      icon: const Icon(Icons.payment_rounded, size: 18),
                      label: const Text(
                        'Pay Fees',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _showActionMessage(
                          context,
                          'Payment flow for ${slot.subject}',
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _subjectIcon(String subject) {
    final name = subject.toLowerCase();
    if (name.contains('math')) return Icons.calculate_rounded;
    if (name.contains('sci')) return Icons.science_rounded;
    if (name.contains('eng')) return Icons.import_contacts_rounded;
    if (name.contains('hind')) return Icons.translate_rounded;
    if (name.contains('soc') || name.contains('geog') || name.contains('hist')) return Icons.public_rounded;
    if (name.contains('art') || name.contains('craft')) return Icons.palette_rounded;
    return Icons.menu_book_rounded;
  }

  int _gridColumnsForWidth(
    double width, {
    required int mobile,
    required int tablet,
    required int desktop,
  }) {
    if (width >= 1024) return desktop;
    if (width >= 600) return tablet;
    return mobile;
  }

  Color _subjectColor(String subject, Color? explicitColor) {
    if (explicitColor != null) return explicitColor;
    final seed = subject.codeUnits.fold<int>(0, (sum, unit) => sum + unit);
    return _subjectPalette[seed % _subjectPalette.length];
  }

  int _slotDuration(TimetableSlot slot) {
    final start = _minutesFromClock(slot.startTime);
    final end = _minutesFromClock(slot.endTime);
    if (end <= start) return 45;
    return end - start;
  }

  int _minutesFromClock(String value) {
    final normalized = value.trim().toUpperCase();
    final amPmMatch =
        RegExp(r'^(\d{1,2}):(\d{2})\s*(AM|PM)$').firstMatch(normalized);
    if (amPmMatch != null) {
      var hour = int.tryParse(amPmMatch.group(1)!) ?? 0;
      final minute = int.tryParse(amPmMatch.group(2)!) ?? 0;
      final meridiem = amPmMatch.group(3)!;

      if (meridiem == 'PM' && hour != 12) hour += 12;
      if (meridiem == 'AM' && hour == 12) hour = 0;
      return (hour * 60) + minute;
    }

    final parts = normalized.split(':');
    if (parts.length != 2) return 0;

    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    return (hour * 60) + minute;
  }
}

class _HorizontalSectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _HorizontalSectionHeader({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textMuted,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final _TimetableAction action;
  final VoidCallback onTap;

  const _ActionCard({
    required this.action,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      margin: EdgeInsets.zero,
      padding: EdgeInsets.all(12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: action.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(action.icon, color: action.color, size: 18.r),
          ),
          SizedBox(height: 6.h),
          Expanded(
            child: Text(
              action.subtitle, // displayed subtitle as the main text to perfectly match the high fidelity screenshot mockup
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                height: 1.25,
              ),
            ),
          ),
          SizedBox(height: 4.h),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Open',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: action.color,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(width: 4.w),
              Icon(Icons.arrow_forward_rounded, color: action.color, size: 14.r),
            ],
          ),
        ],
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _OverviewCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 38.w,
            height: 38.w,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: color, size: 18.r),
          ),
          SizedBox(height: 10.h),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimetableListTile extends StatelessWidget {
  final TimetableSlot slot;
  final Color accent;
  final int durationMinutes;
  final VoidCallback onUpload;
  final VoidCallback onPayment;

  const _TimetableListTile({
    required this.slot,
    required this.accent,
    required this.durationMinutes,
    required this.onUpload,
    required this.onPayment,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black12
                : const Color(0xFF1F2328).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Thicker solid left colored accent bar
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 6.w,
            child: Container(
              color: accent,
            ),
          ),
          // Content
          Padding(
            padding: EdgeInsets.fromLTRB(18.w, 14.w, 14.w, 14.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44.w,
                      height: 44.w,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        _subjectIcon(slot.subject),
                        color: accent,
                        size: 20.r,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            slot.subject,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            '${slot.startTime} - ${slot.endTime} ($durationMinutes mins)',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    AppInfoChip(
                      label: slot.teacherName,
                      icon: Icons.person_outline_rounded,
                      color: accent,
                    ),
                    SizedBox(width: 8.w),
                    AppInfoChip(
                      label: slot.room,
                      icon: Icons.room_outlined,
                      color: accent,
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: _SmallActionButton(
                        label: 'Upload',
                        icon: Icons.upload_file_rounded,
                        color: accent,
                        onTap: onUpload,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: _SmallActionButton(
                        label: 'Payment',
                        icon: Icons.payment_rounded,
                        color: accent,
                        onTap: onPayment,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _subjectIcon(String subject) {
    final name = subject.toLowerCase();
    if (name.contains('math')) return Icons.calculate_rounded;
    if (name.contains('sci')) return Icons.science_rounded;
    if (name.contains('eng')) return Icons.import_contacts_rounded;
    if (name.contains('hind')) return Icons.translate_rounded;
    if (name.contains('soc') || name.contains('geog') || name.contains('hist')) return Icons.public_rounded;
    if (name.contains('art') || name.contains('craft')) return Icons.palette_rounded;
    return Icons.menu_book_rounded;
  }
}

class _SmallActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SmallActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(999.r),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14.r, color: color),
            SizedBox(width: 4.w),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimetableAction {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _TimetableAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}

class _PeriodSlot {
  final String label;
  final String timeRange;
  final String startTime;
  final String endTime;
  final bool isBreak;
  final String breakTitle;

  const _PeriodSlot({
    required this.label,
    required this.timeRange,
    required this.startTime,
    required this.endTime,
    this.isBreak = false,
    this.breakTitle = '',
  });
}

const _periods = [
  _PeriodSlot(label: 'Period 1', timeRange: '08:00 AM - 08:45 AM', startTime: '08:00', endTime: '08:45'),
  _PeriodSlot(label: 'Period 2', timeRange: '08:50 AM - 09:35 AM', startTime: '08:50', endTime: '09:35'),
  _PeriodSlot(label: 'Period 3', timeRange: '09:40 AM - 10:25 AM', startTime: '09:40', endTime: '10:25'),
  _PeriodSlot(label: 'Recess', timeRange: '10:25 AM - 10:45 AM', startTime: '10:25', endTime: '10:45', isBreak: true, breakTitle: 'Short Recess (Refreshment Break) ☕'),
  _PeriodSlot(label: 'Period 4', timeRange: '10:45 AM - 11:30 AM', startTime: '10:45', endTime: '11:30'),
  _PeriodSlot(label: 'Period 5', timeRange: '11:35 AM - 12:20 PM', startTime: '11:35', endTime: '12:20'),
  _PeriodSlot(label: 'Lunch', timeRange: '12:20 PM - 01:00 PM', startTime: '12:20', endTime: '01:00', isBreak: true, breakTitle: 'Lunch Break (Rest & Refuel) 🍱'),
  _PeriodSlot(label: 'Period 6', timeRange: '01:00 PM - 01:45 PM', startTime: '01:00', endTime: '01:45'),
];

class _WeeklyMatrixGrid extends StatelessWidget {
  final List<TimetableSlot> slots;
  final int activeDay;
  final Function(TimetableSlot) onSlotTap;
  final Color Function(String, Color?) getSubjectColor;

  const _WeeklyMatrixGrid({
    required this.slots,
    required this.activeDay,
    required this.onSlotTap,
    required this.getSubjectColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cellWidth = 140.w;
    final timeColWidth = 104.w;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        width: timeColWidth + (6 * cellWidth) + 12.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.border,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            // --- HEADER ROW ---
            Container(
              color: isDark ? AppColors.darkSurface : AppColors.surface,
              child: Row(
                children: [
                  Container(
                    width: timeColWidth,
                    height: 48.h,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(
                          color: isDark ? AppColors.darkBorder : AppColors.border,
                        ),
                        bottom: BorderSide(
                          color: isDark ? AppColors.darkBorder : AppColors.border,
                        ),
                      ),
                    ),
                    child: Text(
                      'Time Slot',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                  ...List.generate(6, (index) {
                    final dayNum = index + 1;
                    final isCurrentDay = activeDay == dayNum;
                    final dayShort = _dayShortNames[index];

                    return Container(
                      width: cellWidth,
                      height: 48.h,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isCurrentDay
                            ? (isDark
                                ? AppColors.darkPrimary.withValues(alpha: 0.08)
                                : AppColors.primary.withValues(alpha: 0.06))
                            : null,
                        border: Border(
                          right: BorderSide(
                            color: index == 5
                                ? Colors.transparent
                                : (isDark ? AppColors.darkBorder : AppColors.border),
                          ),
                          bottom: BorderSide(
                            color: isDark ? AppColors.darkBorder : AppColors.border,
                          ),
                        ),
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                        decoration: isCurrentDay
                            ? BoxDecoration(
                                color: isDark ? AppColors.darkPrimary : AppColors.primary,
                                borderRadius: BorderRadius.circular(8.r),
                              )
                            : null,
                        child: Text(
                          dayShort,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: isCurrentDay
                                ? Colors.white
                                : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),

            // --- MATRIX ROWS ---
            ..._periods.map((period) {
              if (period.isBreak) {
                return Container(
                  height: 38.h,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E293B).withValues(alpha: 0.3)
                        : const Color(0xFFF1F5F9).withValues(alpha: 0.6),
                    border: Border(
                      bottom: BorderSide(
                        color: isDark ? AppColors.darkBorder : AppColors.border,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: timeColWidth,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border(
                            right: BorderSide(
                              color: isDark ? AppColors.darkBorder : AppColors.border,
                            ),
                          ),
                        ),
                        child: Text(
                          period.startTime,
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              Icon(
                                period.label == 'Lunch'
                                    ? Icons.restaurant_rounded
                                    : Icons.coffee_rounded,
                                size: 14.r,
                                color: period.label == 'Lunch'
                                    ? AppColors.info
                                    : AppColors.primary,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                period.breakTitle,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontStyle: FontStyle.italic,
                                  color: isDark ? Colors.white70 : AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Container(
                height: 82.h,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isDark ? AppColors.darkBorder : AppColors.border,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: timeColWidth,
                      padding: EdgeInsets.symmetric(horizontal: 6.w),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : AppColors.surface,
                        border: Border(
                          right: BorderSide(
                            color: isDark ? AppColors.darkBorder : AppColors.border,
                          ),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            period.label,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white70 : AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            period.startTime,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'to ${period.endTime}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.textMuted,
                              fontSize: 9.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...List.generate(6, (dayIndex) {
                      final dayNum = dayIndex + 1;
                      final slot = _findSlotForDayAndPeriod(slots, dayNum, period);
                      final isCurrentDay = activeDay == dayNum;

                      return Container(
                        width: cellWidth,
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(5.w),
                        decoration: BoxDecoration(
                          color: isCurrentDay
                              ? (isDark
                                  ? AppColors.darkPrimary.withValues(alpha: 0.04)
                                  : AppColors.primary.withValues(alpha: 0.02))
                              : null,
                          border: Border(
                            right: BorderSide(
                              color: dayIndex == 5
                                  ? Colors.transparent
                                  : (isDark ? AppColors.darkBorder : AppColors.border),
                            ),
                          ),
                        ),
                        child: slot != null
                            ? _WeeklyCellCard(
                                slot: slot,
                                color: getSubjectColor(slot.subject, slot.subjectColor),
                                onTap: () => onSlotTap(slot),
                              )
                            : _FreeCellPlaceholder(),
                      );
                    }),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  static const _dayShortNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  TimetableSlot? _findSlotForDayAndPeriod(List<TimetableSlot> slots, int dayOfWeek, _PeriodSlot period) {
    try {
      return slots.firstWhere(
        (slot) => slot.dayOfWeek == dayOfWeek && slot.startTime.trim() == period.startTime,
      );
    } catch (_) {
      return null;
    }
  }
}

class _WeeklyCellCard extends StatelessWidget {
  final TimetableSlot slot;
  final Color color;
  final VoidCallback onTap;

  const _WeeklyCellCard({
    required this.slot,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(10.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.r),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: color.withValues(alpha: 0.35),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                slot.subject,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                  fontSize: 11.sp,
                ),
              ),
              SizedBox(height: 2.h),
              Row(
                children: [
                  Icon(
                    Icons.person_outline_rounded,
                    size: 9.r,
                    color: color,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Text(
                      slot.teacherName.split(' ').last,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 9.sp,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(
                    Icons.room_outlined,
                    size: 9.r,
                    color: color,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Text(
                      slot.room,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 9.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FreeCellPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black12
            : const Color(0xFFF8FAFC).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: isDark
              ? Colors.white10
              : const Color(0xFFE2E8F0).withValues(alpha: 0.5),
          style: BorderStyle.solid,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        '--',
        style: theme.textTheme.labelSmall?.copyWith(
          color: isDark ? Colors.white24 : Colors.black26,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color accent;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32.w,
          height: 32.w,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, color: accent, size: 16.r),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
