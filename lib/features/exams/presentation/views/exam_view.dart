import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';
import 'package:ascento_abacus/core/widgets/app_card.dart';
import 'package:ascento_abacus/core/widgets/app_shimmer.dart';
import 'package:ascento_abacus/core/widgets/app_components.dart';
import 'package:ascento_abacus/shared/providers/feature_providers.dart';

class ExamView extends ConsumerStatefulWidget {
  const ExamView({super.key});

  @override
  ConsumerState<ExamView> createState() => _ExamViewState();
}

class _ExamViewState extends ConsumerState<ExamView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 8.h),
            child: AppCard(
              margin: EdgeInsets.zero,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              child: TabBar(
                controller: _tabController,
                indicatorColor: isDark
                    ? AppColors.darkPrimary
                    : AppColors.primary,
                labelColor: isDark
                    ? AppColors.darkPrimary
                    : AppColors.primary,
                unselectedLabelColor: Colors.grey,
                tabs: const [
                  Tab(text: 'Schedule'),
                  Tab(text: 'Report Card'),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [_ExamScheduleTab(), _ReportCardTab()],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExamScheduleTab extends ConsumerWidget {
  const _ExamScheduleTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheduleAsync = ref.watch(examScheduleProvider);

    return scheduleAsync.when(
      loading: () => ListView(
        padding: EdgeInsets.all(24.w),
        children: List.generate(4, (_) => AppShimmer.card()),
      ),
      error: (e, _) => EmptyStateWidget(
        title: 'Failed',
        subtitle: e.toString(),
        icon: Icons.error_outline,
      ),
      data: (exams) {
        final now = DateTime.now();
        final upcoming = exams
            .where(
              (e) => !e.date.isBefore(DateTime(now.year, now.month, now.day)),
            )
            .toList();
        final nextExam = upcoming.isNotEmpty
            ? upcoming.first
            : (exams.isNotEmpty ? exams.first : null);

        return ListView(
          padding: EdgeInsets.all(20.w),
          children: [
            if (nextExam != null)
              Container(
                padding: EdgeInsets.all(18.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFFFF8A34), const Color(0xFFF05A3A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56.w,
                      height: 56.w,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${nextExam.date.day}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            _monthName(nextExam.date.month),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Next Exam',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                          Text(
                            nextExam.subject,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '${nextExam.time} • ${nextExam.room}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(height: 18.h),
            Text(
              'Upcoming Exams',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10.h),
            if (upcoming.isEmpty)
              AppCard(
                child: Text(
                  'No upcoming exams',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              )
            else
              ...upcoming.map(
                (exam) => AppCard(
                  child: Row(
                    children: [
                      Container(
                        width: 52.w,
                        height: 52.w,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${exam.date.day}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              _monthName(exam.date.month),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 14.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              exam.subject,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              '${exam.time} • ${exam.room}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(
                            alpha: 0.12,
                          ),
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Text(
                          '${exam.totalMarks}M',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  String _monthName(int month) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month];
  }
}

class _ReportCardTab extends ConsumerWidget {
  const _ReportCardTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final reportAsync = ref.watch(reportCardProvider('mid-term'));

    return reportAsync.when(
      loading: () => ListView(
        padding: EdgeInsets.all(24.w),
        children: List.generate(5, (_) => AppShimmer.card()),
      ),
      error: (e, _) => EmptyStateWidget(
        title: 'Failed',
        subtitle: e.toString(),
        icon: Icons.error_outline,
      ),
      data: (report) => SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(18.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF1F2D2D), const Color(0xFF1B3A2F)]
                      : [const Color(0xFFE6F7F1), const Color(0xFFF1FBF7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.border,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _GpaStat(label: 'GPA', value: report.gpa.toStringAsFixed(1)),
                  _GpaStat(
                    label: 'Percentage',
                    value: '${report.overallPercentage.toStringAsFixed(1)}%',
                  ),
                  _GpaStat(label: 'Grade', value: report.overallGrade),
                ],
              ),
            ),
            SizedBox(height: 18.h),
            Text(
              'Subject Results',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10.h),
            ...report.results.map(
              (r) => AppCard(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.subject,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: r.percentage / 100,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation(
                                _gradeColor(r.grade),
                              ),
                              minHeight: 6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Column(
                      children: [
                        Text(
                          '${r.marksObtained}/${r.totalMarks}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: _gradeColor(r.grade).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            r.grade,
                            style: TextStyle(
                              color: _gradeColor(r.grade),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _gradeColor(String grade) {
    switch (grade) {
      case 'A+':
        return AppColors.secondary;
      case 'A':
        return const Color(0xFF4CAF50);
      case 'B+':
        return AppColors.primary;
      case 'B':
        return AppColors.info;
      default:
        return AppColors.error;
    }
  }
}

class _GpaStat extends StatelessWidget {
  final String label;
  final String value;
  const _GpaStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey),
        ),
      ],
    );
  }
}
