import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';
import 'package:ascento_abacus/core/widgets/app_shimmer.dart';
import 'package:ascento_abacus/core/widgets/app_components.dart';
import 'package:ascento_abacus/shared/models/feature_models.dart';
import 'package:ascento_abacus/shared/models/user_model.dart';
import 'package:ascento_abacus/features/auth/presentation/controllers/auth_controller.dart';
import 'package:ascento_abacus/features/content/presentation/providers/content_provider.dart';
import 'package:ascento_abacus/features/content/data/repositories/content_repository.dart';
import 'package:go_router/go_router.dart';
import 'package:ascento_abacus/shared/router/route_names.dart';

class ContentView extends ConsumerStatefulWidget {
  const ContentView({super.key});

  @override
  ConsumerState<ContentView> createState() => _ContentViewState();
}

class _ContentViewState extends ConsumerState<ContentView> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final contentAsync = ref.watch(contentListProvider);
    final currentUser = ref.watch(authControllerProvider).currentUser;
    final canManage = currentUser?.role == UserRole.admin ||
        currentUser?.role == UserRole.superAdmin ||
        currentUser?.role == UserRole.teacher;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: canManage
          ? FloatingActionButton.extended(
              onPressed: () => context.pushNamed(RouteNames.uploadContent),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.upload_file_rounded),
              label: const Text('Upload', style: TextStyle(fontWeight: FontWeight.bold)),
            )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Study Materials',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 22.sp,
                            color: isDark ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Upload and manage resources.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: contentAsync.when(
        loading: () => ListView.separated(
          padding: EdgeInsets.all(24.w),
          itemCount: 4,
          separatorBuilder: (_, __) => SizedBox(height: 16.h),
          itemBuilder: (_, __) => AppShimmer.card(),
        ),
        error: (e, _) => EmptyStateWidget(
          title: 'Load failed',
          subtitle: e.toString(),
          icon: Icons.error_outline,
        ),
        data: (items) {
          if (items.isEmpty) {
            return const EmptyStateWidget(
              title: 'No Materials Found',
              subtitle: 'Study materials and resources will appear here.',
              icon: Icons.auto_stories_rounded,
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.refresh(contentListProvider),
            child: ListView.separated(
              padding: EdgeInsets.all(20.w),
              itemCount: items.length,
              separatorBuilder: (_, __) => SizedBox(height: 16.h),
              itemBuilder: (context, index) => _ContentTile(
                item: items[index],
                canManage: canManage,
                onEdit: () => context.pushNamed(RouteNames.uploadContent, extra: items[index]),
                onDelete: () => _confirmDelete(context, ref, items[index]),
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

  void _confirmDelete(BuildContext context, WidgetRef ref, ContentItem content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 24.r),
            SizedBox(width: 8.w),
            const Text('Delete Material'),
          ],
        ),
        content: Text('Are you sure you want to delete "${content.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref.read(contentRepositoryProvider).deleteContent(content.id);
                ref.invalidate(contentListProvider);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Material deleted successfully'), backgroundColor: AppColors.success),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete: $e'), backgroundColor: AppColors.error),
                  );
                }
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ── Content Tile ──
// ── Content Tile ──
class _ContentTile extends StatelessWidget {
  final ContentItem item;
  final bool canManage;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ContentTile({
    required this.item,
    required this.canManage,
    required this.onEdit,
    required this.onDelete,
  });

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'pdf': return Icons.picture_as_pdf_rounded;
      case 'video': return Icons.play_circle_filled_rounded;
      case 'image': return Icons.image_rounded;
      case 'quiz': return Icons.quiz_rounded;
      case 'worksheet': return Icons.assignment_rounded;
      default: return Icons.insert_drive_file_rounded;
    }
  }

  Color _getColorForType(String type) {
    switch (type.toLowerCase()) {
      case 'pdf': return const Color(0xFFEF4444); // Red
      case 'video': return const Color(0xFF3B82F6); // Blue
      case 'image': return const Color(0xFF10B981); // Emerald
      case 'quiz': return const Color(0xFFF59E0B); // Amber
      case 'worksheet': return const Color(0xFF8B5CF6); // Violet
      default: return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final iconColor = _getColorForType(item.type);

    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Image (Simulated blurred cover)
          Container(
            height: 80.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: item.type.toLowerCase() == 'pdf' 
                    ? [Colors.orange.shade400, Colors.orange.shade300]
                    : [AppColors.primary, AppColors.primary.withValues(alpha: 0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                if (item.type.toLowerCase() == 'image')
                  Positioned.fill(
                    child: Image.network(
                      item.publicUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(_getIconForType(item.type), color: Colors.white24, size: 80.r),
                    ),
                  )
                else if (item.type.toLowerCase() == 'pdf') ...[
                  // Simulated blurred logo on the right
                  Positioned(
                    right: 20.w,
                    top: 10.h,
                    child: Opacity(
                      opacity: 0.3,
                      child: Icon(Icons.calculate_rounded, size: 60.r, color: Colors.white),
                    ),
                  ),
                  // Simulated blurred document preview on the left
                  Positioned(
                    left: 24.w,
                    top: 16.h,
                    bottom: 16.h,
                    child: Container(
                      width: 40.w,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(2.r),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(2, 2)),
                        ],
                      ),
                      padding: EdgeInsets.all(4.r),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(height: 4.h, width: 20.w, color: Colors.grey.shade300),
                          SizedBox(height: 4.h),
                          Container(height: 2.h, width: 30.w, color: Colors.grey.shade200),
                          SizedBox(height: 2.h),
                          Container(height: 2.h, width: 25.w, color: Colors.grey.shade200),
                        ],
                      ),
                    ),
                  ),
                ] else
                  Positioned.fill(
                    child: Icon(
                      _getIconForType(item.type),
                      size: 80.r,
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                // Admin Actions Menu over the header
                if (canManage)
                  Positioned(
                    top: 8.h,
                    right: 8.w,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        shape: BoxShape.circle,
                      ),
                      child: PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert_rounded, color: Colors.white, size: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        onSelected: (value) {
                          if (value == 'edit') onEdit();
                          if (value == 'delete') onDelete();
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                const Icon(Icons.edit_rounded, color: AppColors.info, size: 20),
                                SizedBox(width: 12.w),
                                const Text('Edit'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                const Icon(Icons.delete_rounded, color: AppColors.error, size: 20),
                                SizedBox(width: 12.w),
                                const Text('Delete', style: TextStyle(color: AppColors.error)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // Middle Content area
          Container(
            color: isDark ? AppColors.darkSurface : Colors.white,
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // PDF Icon
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: iconColor,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    item.type.toUpperCase(),
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10.sp),
                  ),
                ),
                SizedBox(width: 16.w),
                
                // Content Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w500, 
                          fontSize: 15.sp, 
                          color: isDark ? Colors.white : AppColors.textPrimary
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '${item.type.toUpperCase()} • ${item.description.isNotEmpty ? item.description : 'Document'}',
                        style: TextStyle(
                          color: isDark ? AppColors.darkTextMuted : AppColors.textMuted, 
                          fontSize: 12.sp
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8.h),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '${item.createdAt.hour.toString().padLeft(2, '0')}:${item.createdAt.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            color: isDark ? AppColors.darkTextMuted : AppColors.textMuted, 
                            fontSize: 11.sp
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Divider
          Divider(height: 1, thickness: 1, color: isDark ? Colors.white10 : Colors.grey.shade200),
          
          // Action Area (View / Save As)
          Container(
            color: isDark ? AppColors.darkSurface : Colors.white,
            padding: EdgeInsets.symmetric(vertical: 4.h),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      context.pushNamed(RouteNames.studyMode, extra: item);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF10B981), // Green color matching screenshot
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                    child: Text(
                      'View',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp),
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () async {
                       final url = Uri.tryParse(item.publicUrl);
                       if (url != null && await canLaunchUrl(url)) {
                         await launchUrl(url, mode: LaunchMode.externalApplication);
                       }
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF10B981), // Green color matching screenshot
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                    child: Text(
                      'Save as...',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp),
                    ),
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
