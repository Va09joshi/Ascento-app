import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';
import 'package:ascento_abacus/core/widgets/app_card.dart';
import 'package:ascento_abacus/core/widgets/app_shimmer.dart';
import 'package:ascento_abacus/core/widgets/app_components.dart';
import 'package:ascento_abacus/core/widgets/custom_button.dart';
import 'package:ascento_abacus/shared/models/feature_models.dart';
import 'package:ascento_abacus/shared/models/user_model.dart';
import 'package:ascento_abacus/features/auth/presentation/controllers/auth_controller.dart';
import 'package:ascento_abacus/features/meetings/presentation/providers/meetings_provider.dart';

class MeetingsView extends ConsumerStatefulWidget {
  const MeetingsView({super.key});

  @override
  ConsumerState<MeetingsView> createState() => _MeetingsViewState();
}

class _MeetingsViewState extends ConsumerState<MeetingsView> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final meetingsAsync = ref.watch(meetingsListProvider);
    final currentUser = ref.watch(authControllerProvider).currentUser;
    final canCreate = currentUser?.role == UserRole.admin || currentUser?.role == UserRole.teacher;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Live Meetings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (canCreate)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                // Open Meeting Creation Dialog
              },
            ),
        ],
      ),
      body: meetingsAsync.when(
        loading: () => ListView(
          padding: EdgeInsets.all(24.w),
          children: List.generate(4, (_) => AppShimmer.card()),
        ),
        error: (e, _) => EmptyStateWidget(
          title: 'Load failed',
          subtitle: e.toString(),
          icon: Icons.error_outline,
        ),
        data: (items) {
          if (items.isEmpty) {
            return const EmptyStateWidget(
              title: 'No Active Meetings',
              subtitle: 'There are no upcoming meetings for your classes.',
              icon: Icons.video_camera_front_outlined,
            );
          }
          return ListView.separated(
            padding: EdgeInsets.all(20.w),
            itemCount: items.length,
            separatorBuilder: (_, __) => SizedBox(height: 16.h),
            itemBuilder: (context, index) => _MeetingTile(item: items[index]),
          );
        },
      ),
    );
  }
}

class _MeetingTile extends StatelessWidget {
  final MeetingItem item;
  const _MeetingTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(item.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text('LIVE', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold, fontSize: 10.sp)),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14.sp, color: AppColors.textMuted),
              SizedBox(width: 6.w),
              Text('${item.meetDate.toIso8601String().split('T')[0]} • ${item.startTime} - ${item.endTime}', style: TextStyle(color: AppColors.textMuted, fontSize: 13.sp)),
            ],
          ),
          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: 'Join Meeting',
              onPressed: () {
                // Launch URL
              },
            ),
          )
        ],
      ),
    );
  }
}
