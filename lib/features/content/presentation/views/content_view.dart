import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';
import 'package:ascento_abacus/core/widgets/app_card.dart';
import 'package:ascento_abacus/core/widgets/app_shimmer.dart';
import 'package:ascento_abacus/core/widgets/app_components.dart';
import 'package:ascento_abacus/core/widgets/custom_button.dart';
import 'package:ascento_abacus/shared/models/feature_models.dart';
import 'package:ascento_abacus/features/content/presentation/providers/content_provider.dart';

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

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Study Materials'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: contentAsync.when(
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
              title: 'No Materials Found',
              subtitle: 'Your teachers haven\'t uploaded any notes yet.',
              icon: Icons.menu_book_rounded,
            );
          }
          return ListView.separated(
            padding: EdgeInsets.all(20.w),
            itemCount: items.length,
            separatorBuilder: (_, __) => SizedBox(height: 16.h),
            itemBuilder: (context, index) => _ContentTile(item: items[index]),
          );
        },
      ),
    );
  }
}

class _ContentTile extends StatelessWidget {
  final ContentItem item;
  const _ContentTile({required this.item});

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'video':
        return Icons.video_library_rounded;
      case 'image':
        return Icons.image_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }

  Color _getColorForType(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return const Color(0xFFE74C3C); // Red for PDF
      case 'video':
        return const Color(0xFF3498DB); // Blue for Video
      case 'image':
        return const Color(0xFF2ECC71); // Green for Image
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = _getColorForType(item.type);

    return AppCard(
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              _getIconForType(item.type),
              color: iconColor,
              size: 28.r,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
                SizedBox(height: 4.h),
                Text(item.description, style: TextStyle(color: AppColors.textMuted, fontSize: 13.sp), maxLines: 2, overflow: TextOverflow.ellipsis),
                SizedBox(height: 8.h),
                Text('Added: ${item.createdAt.toIso8601String().split('T')[0]}', style: TextStyle(color: AppColors.textMuted, fontSize: 11.sp)),
              ],
            ),
          ),
          SizedBox(width: 16.w),
          IconButton(
            icon: Icon(Icons.download_rounded, color: AppColors.primary),
            onPressed: () {
              // Handle download / open URL
            },
          ),
        ],
      ),
    );
  }
}
