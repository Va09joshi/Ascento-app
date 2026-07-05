import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';
import 'package:ascento_abacus/core/widgets/app_dialogs.dart';

class ProgramsView extends StatelessWidget {
  const ProgramsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.creamBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Flagship Educational Offerings',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),

              // --- 1. Abacus Mastery Program Card ---
              _ProgramBanner(
                title: 'Abacus Mastery',
                badgeText: 'MOST POPULAR',
                badgeBg: const Color(0xFFFFEAEA),
                badgeTextCol: const Color(0xFFFF5252),
                agesText: 'Ages 4-14',
                durationText: '120 min, twice a week (Levels 1-10)',
                description:
                    'A structured 12-week per-level journey from foundational abacus basics through grand master mental mathematics mastery.',
                imagePath: 'assets/images/abacus_mastery_banner.png',
                imageOnLeft: true,
                themeColor: const Color(0xFFFF6B6B),
                keyBenefits: const [
                  '11 progressive levels (0 to 10)',
                  'Two-hand, four-finger methodology',
                  'Mental math mastery & visualization',
                  'Competition-ready skills',
                  'Boosted concentration & memory',
                ],
                levels: const [
                  '01 Junior (4-6 yrs)',
                  '02 Foundation (6-9 yrs)',
                  '03 Intermediate (9-11 yrs)',
                  '04 Advanced (11-13 yrs)',
                  '05 Grand Master',
                ],
                onEnrol: () {
                  AppDialog.show(
                    context,
                    title: 'Enrolment Initiated!',
                    message: 'Thank you for choosing Abacus Mastery! Your enrolment request has been successfully registered. Our academic coordinator will contact you within 24 hours to schedule the orientation batch and class levels.',
                    confirmText: 'Awesome',
                  );
                },
              ),

              SizedBox(height: 24.h),

              // --- 2. Vedic Maths Program Card ---
              _ProgramBanner(
                title: 'Vedic Maths',
                badgeText: 'MIND-BLOWING',
                badgeBg: const Color(0xFFF1EAFF),
                badgeTextCol: const Color(0xFF8B5CF6),
                agesText: 'Ages 10+',
                durationText: '60 min, 2 classes / week',
                description:
                    'Ancient Vedic sutras applied to modern speed mathematics — from rapid arithmetic through algebraic polynomials and cube roots.',
                imagePath: 'assets/images/vedic_maths_banner.png',
                imageOnLeft: false,
                themeColor: const Color(0xFF8B5CF6),
                keyBenefits: const [
                  '4 comprehensive levels',
                  '16 ancient Vedic sutras',
                  '10x faster calculations',
                  'Perfect for JEE / NEET prep',
                  'Reduces exam anxiety',
                ],
                levels: const [
                  '01 Foundation (10-12 yrs)',
                  '02 Intermediate (12-14 yrs)',
                  '03 Advanced / Competitive',
                  '04 Expert',
                ],
                onEnrol: () {
                  AppDialog.show(
                    context,
                    title: 'Enrolment Initiated!',
                    message: 'Thank you for choosing Vedic Maths! Your enrolment request has been successfully registered. Our academic coordinator will contact you within 24 hours to schedule the placement assessment and class batch.',
                    confirmText: 'Awesome',
                  );
                },
              ),

              SizedBox(height: 24.h),

              // --- 3. Pre-Abacus Program Card ---
              _ProgramBanner(
                title: 'Pre-Abacus',
                badgeText: 'FOR TINY MINDS',
                badgeBg: const Color(0xFFFFEAF2),
                badgeTextCol: const Color(0xFFEC4899),
                agesText: 'Ages 1.5-8',
                durationText: '30-45 min, 3 classes / week',
                description:
                    'A nurturing early-learning journey that blends language, numeracy, and life skills — from first words through fluent reading and writing.',
                imagePath: 'assets/images/pre_abacus_banner.png',
                imageOnLeft: true,
                themeColor: const Color(0xFFEC4899),
                keyBenefits: const [
                  'Toddler to Class 2 (7 stages)',
                  'English, Hindi, Maths & EVS',
                  'Communication & confidence',
                  'Fine motor skill development',
                  'School readiness programme',
                ],
                levels: const [
                  '01 Toddler (1.5-2.5 yrs)',
                  '02 Nursery (2.5-3.5 yrs)',
                  '03 Jr. KG (3.5-4.5 yrs)',
                  '04 Sr. KG (4.5-5.5 yrs)',
                  '05 Class 1-2 Bridge',
                ],
                onEnrol: () {
                  AppDialog.show(
                    context,
                    title: 'Enrolment Initiated!',
                    message: 'Thank you for choosing Pre-Abacus! Your enrolment request has been successfully registered. Our toddler specialist will contact you within 24 hours to schedule a complimentary trial session.',
                    confirmText: 'Awesome',
                  );
                },
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgramBanner extends StatelessWidget {
  final String title;
  final String badgeText;
  final Color badgeBg;
  final Color badgeTextCol;
  final String agesText;
  final String durationText;
  final String description;
  final String imagePath;
  final bool imageOnLeft;
  final Color themeColor;
  final List<String> keyBenefits;
  final List<String> levels;
  final VoidCallback onEnrol;

  const _ProgramBanner({
    required this.title,
    required this.badgeText,
    required this.badgeBg,
    required this.badgeTextCol,
    required this.agesText,
    required this.durationText,
    required this.description,
    required this.imagePath,
    required this.imageOnLeft,
    required this.themeColor,
    required this.keyBenefits,
    required this.levels,
    required this.onEnrol,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkSurface : Colors.white;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        Widget buildBadgeAndTitle(bool compact) {
          return Row(
            children: [
              if (badgeText.isNotEmpty) ...[
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: isDark ? badgeTextCol.withValues(alpha: 0.15) : badgeBg,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      color: isDark ? badgeTextCol.withValues(alpha: 0.9) : badgeTextCol,
                      fontSize: compact ? 8.sp : 9.sp,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
              ],
              Icon(
                title.contains('Vedic')
                    ? Icons.architecture_rounded
                    : title.contains('Pre')
                        ? Icons.star_rounded
                        : Icons.grid_on_rounded,
                color: themeColor,
                size: compact ? 18.sp : 20.sp,
              ),
            ],
          );
        }

        Widget buildAgeAndTimeCapsules(bool compact) {
          return Wrap(
            spacing: 6.w,
            runSpacing: 4.h,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: themeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  agesText,
                  style: TextStyle(
                    color: themeColor,
                    fontSize: compact ? 9.sp : 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : Colors.black54.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: compact ? 9.sp : 10.sp,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                    SizedBox(width: 4.w),
                    Flexible(
                      child: Text(
                        durationText,
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black54,
                          fontSize: compact ? 9.sp : 10.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }

        Widget buildKeyBenefits(bool compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    color: themeColor,
                    size: compact ? 11.sp : 12.sp,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    'KEY BENEFITS',
                    style: TextStyle(
                      color: themeColor,
                      fontWeight: FontWeight.bold,
                      fontSize: compact ? 9.sp : 10.sp,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              ...keyBenefits.map(
                (benefit) => Padding(
                  padding: EdgeInsets.only(bottom: 2.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: compact ? 1.h : 2.h),
                        child: Icon(
                          Icons.check_circle_rounded,
                          color: themeColor,
                          size: compact ? 11.sp : 12.sp,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          benefit,
                          style: TextStyle(
                            fontSize: compact ? 10.sp : 11.sp,
                            color: isDark ? Colors.white70 : AppColors.textCharcoal,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }

        Widget buildLevelsOffered(bool compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.gps_fixed_rounded,
                    color: themeColor,
                    size: compact ? 11.sp : 12.sp,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    'LEVELS OFFERED',
                    style: TextStyle(
                      color: themeColor,
                      fontWeight: FontWeight.bold,
                      fontSize: compact ? 9.sp : 10.sp,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6.h),
              Wrap(
                spacing: 6.w,
                runSpacing: 6.h,
                children: levels
                    .map(
                      (level) => Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white,
                          borderRadius: BorderRadius.circular(30.r),
                          border: Border.all(
                            color: themeColor.withValues(alpha: isDark ? 0.3 : 0.25),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          level,
                          style: TextStyle(
                            color: isDark ? Colors.white70 : AppColors.textCharcoal,
                            fontSize: compact ? 8.sp : 9.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          );
        }

        Widget buildActionButtons(bool compact) {
          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 42.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.r),
                    boxShadow: [
                      BoxShadow(
                        color: themeColor.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    onPressed: onEnrol,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.auto_fix_high_rounded, size: 14.sp),
                        SizedBox(width: 6.w),
                        Text(
                          'Enrol in ${title.split(' ')[0]}',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  height: 42.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.r),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? Colors.black26 : Colors.black12,
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: isDark ? Colors.white10 : Colors.white,
                      foregroundColor: isDark
                          ? Colors.white.withValues(alpha: 0.8)
                          : AppColors.textCharcoal,
                      side: BorderSide(
                        color: isDark ? Colors.white24 : AppColors.creamBorder,
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Free Trial Registered Successfully'),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.phone_in_talk_rounded, size: 14),
                        SizedBox(width: 6.w),
                        Text(
                          'Book Free Trial',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else {
            return Row(
              children: [
                Expanded(
                  child: Container(
                    height: 38.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.r),
                      boxShadow: [
                        BoxShadow(
                          color: themeColor.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      onPressed: onEnrol,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.auto_fix_high_rounded, size: 14.sp),
                          SizedBox(width: 6.w),
                          Text(
                            'Enrol in ${title.split(' ')[0]}',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Container(
                  height: 38.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.r),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? Colors.black26 : Colors.black12,
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: isDark ? Colors.white10 : Colors.white,
                      foregroundColor: isDark
                          ? Colors.white.withValues(alpha: 0.8)
                          : AppColors.textCharcoal,
                      side: BorderSide(
                        color: isDark ? Colors.white24 : AppColors.creamBorder,
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Free Trial Registered Successfully'),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.phone_in_talk_rounded,
                          size: 14,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'Book Free Trial',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
        }

        if (isMobile) {
          return Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.creamBorder,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.45)
                      : const Color(0xFF1F2328).withValues(alpha: 0.08),
                  offset: const Offset(0, 10),
                  blurRadius: 24,
                ),
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.2)
                      : const Color(0xFF1F2328).withValues(alpha: 0.04),
                  offset: const Offset(0, 2),
                  blurRadius: 8,
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 160.h,
                  width: double.infinity,
                  child: ShaderMask(
                    shaderCallback: (rect) {
                      return const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black, Colors.transparent],
                        stops: [0.75, 1.0],
                      ).createShader(rect);
                    },
                    blendMode: BlendMode.dstIn,
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: themeColor.withValues(alpha: 0.15),
                        child: Icon(Icons.school_rounded, color: themeColor, size: 40.sp),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 14.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      buildBadgeAndTitle(true),
                      SizedBox(height: 8.h),
                      Text(
                        title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : AppColors.textCharcoal,
                          fontSize: 21.sp,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      buildAgeAndTimeCapsules(true),
                      SizedBox(height: 10.h),
                      Text(
                        description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                          height: 1.3,
                          fontSize: 12.sp,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      buildKeyBenefits(true),
                      SizedBox(height: 12.h),
                      buildLevelsOffered(true),
                      SizedBox(height: 16.h),
                      buildActionButtons(true),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else {
          final imageWidget = SizedBox(
            width: 140.w,
            height: double.infinity,
            child: ShaderMask(
              shaderCallback: (rect) {
                return LinearGradient(
                  begin: imageOnLeft ? Alignment.centerLeft : Alignment.centerRight,
                  end: imageOnLeft ? Alignment.centerRight : Alignment.centerLeft,
                  colors: const [Colors.black, Colors.transparent],
                  stops: const [0.65, 1.0],
                ).createShader(rect);
              },
              blendMode: BlendMode.dstIn,
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: themeColor.withValues(alpha: 0.15),
                  child: Icon(Icons.school_rounded, color: themeColor, size: 36),
                ),
              ),
            ),
          );

          final contentWidget = Expanded(
            child: Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  buildBadgeAndTitle(false),
                  SizedBox(height: 6.h),
                  Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppColors.textCharcoal,
                      fontSize: 20.sp,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  buildAgeAndTimeCapsules(false),
                  SizedBox(height: 8.h),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  buildKeyBenefits(false),
                  SizedBox(height: 10.h),
                  buildLevelsOffered(false),
                  SizedBox(height: 14.h),
                  buildActionButtons(false),
                ],
              ),
            ),
          );

          return Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.creamBorder,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.45)
                      : const Color(0xFF1F2328).withValues(alpha: 0.08),
                  offset: const Offset(0, 10),
                  blurRadius: 24,
                ),
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.2)
                      : const Color(0xFF1F2328).withValues(alpha: 0.04),
                  offset: const Offset(0, 2),
                  blurRadius: 8,
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: imageOnLeft
                    ? [imageWidget, contentWidget]
                    : [contentWidget, imageWidget],
              ),
            ),
          );
        }
      },
    );
  }
}
