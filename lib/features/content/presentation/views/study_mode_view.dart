import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';
import 'package:ascento_abacus/shared/models/feature_models.dart';

class StudyModeView extends ConsumerStatefulWidget {
  final ContentItem item;

  const StudyModeView({super.key, required this.item});

  @override
  ConsumerState<StudyModeView> createState() => _StudyModeViewState();
}

class _StudyModeViewState extends ConsumerState<StudyModeView> {
  final PdfViewerController _pdfController = PdfViewerController();
  bool _isLoading = true;
  bool _hasError = false;
  int _currentPage = 1;
  int _totalPages = 0;

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isPdf = widget.item.type.toLowerCase() == 'pdf';
    final isImage = widget.item.type.toLowerCase() == 'image';

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(
            Icons.arrow_back_rounded,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.item.title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (isPdf && _totalPages > 0)
              Text(
                'Page $_currentPage of $_totalPages',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                ),
              ),
          ],
        ),
        actions: [
          if (widget.item.publicUrl.isNotEmpty)
            IconButton(
              onPressed: () => _openExternal(),
              icon: Icon(
                Icons.download_rounded,
                color: isDark ? Colors.white70 : AppColors.textMuted,
                size: 20.r,
              ),
              tooltip: 'Download Material',
            ),
          SizedBox(width: 8.w),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.06),
          ),
        ),
      ),
      body: _buildBody(isDark, isPdf, isImage),
    );
  }

  Widget _buildBody(bool isDark, bool isPdf, bool isImage) {
    if (widget.item.publicUrl.isEmpty) {
      return _buildEmptyState(isDark, 'No Content URL', 'This material does not have a file link attached.');
    }

    if (isPdf) {
      return _buildPdfViewer(isDark);
    }

    if (isImage) {
      return _buildImageViewer(isDark);
    }

    // For video/other types — show info card with open external button
    return _buildGenericViewer(isDark);
  }

  Widget _buildPdfViewer(bool isDark) {
    return Stack(
      children: [
        SfPdfViewer.network(
          widget.item.publicUrl,
          controller: _pdfController,
          canShowScrollHead: true,
          canShowPaginationDialog: true,
          canShowScrollStatus: true,
          pageSpacing: 8,
          onDocumentLoaded: (details) {
            setState(() {
              _isLoading = false;
              _totalPages = details.document.pages.count;
            });
          },
          onDocumentLoadFailed: (details) {
            setState(() {
              _isLoading = false;
              _hasError = true;
            });
          },
          onPageChanged: (details) {
            setState(() {
              _currentPage = details.newPageNumber;
            });
          },
        ),
        if (_isLoading && !_hasError)
          Center(
            child: Container(
              padding: EdgeInsets.all(32.w),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 40.r,
                    height: 40.r,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Loading PDF...',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Please wait while the document loads',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (_hasError)
          Center(
            child: _buildErrorCard(isDark),
          ),
      ],
    );
  }

  Widget _buildImageViewer(bool isDark) {
    return Center(
      child: InteractiveViewer(
        minScale: 0.5,
        maxScale: 4.0,
        child: Image.network(
          widget.item.publicUrl,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return _buildErrorCard(isDark);
          },
        ),
      ),
    );
  }

  Widget _buildGenericViewer(bool isDark) {
    final iconColor = _getColorForType(widget.item.type);
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(32.w),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480),
          padding: EdgeInsets.all(40.w),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.border,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80.r,
                height: 80.r,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getIconForType(widget.item.type),
                  size: 36.r,
                  color: iconColor,
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                widget.item.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
              if (widget.item.description.isNotEmpty) ...[
                SizedBox(height: 12.h),
                Text(
                  widget.item.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                    height: 1.5,
                  ),
                ),
              ],
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  widget.item.type.toUpperCase(),
                  style: TextStyle(
                    color: iconColor,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              SizedBox(height: 32.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _openExternal(),
                  icon: const Icon(Icons.open_in_new_rounded),
                  label: const Text('Open in Browser'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorCard(bool isDark) {
    return Container(
      margin: EdgeInsets.all(32.w),
      padding: EdgeInsets.all(32.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64.r,
            height: 64.r,
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.error_outline_rounded, size: 32.r, color: AppColors.error),
          ),
          SizedBox(height: 16.h),
          Text(
            'Failed to Load',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'The document could not be loaded. Try opening it externally.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
            ),
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: () => _openExternal(),
            icon: const Icon(Icons.open_in_new_rounded),
            label: const Text('Open in Browser'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_off_rounded, size: 64.r, color: AppColors.textMuted),
          SizedBox(height: 16.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 13.sp,
              color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openExternal() async {
    final uri = Uri.tryParse(widget.item.publicUrl);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

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
      case 'pdf': return const Color(0xFFEF4444);
      case 'video': return const Color(0xFF3B82F6);
      case 'image': return const Color(0xFF10B981);
      case 'quiz': return const Color(0xFFF59E0B);
      case 'worksheet': return const Color(0xFF8B5CF6);
      default: return AppColors.primary;
    }
  }
}
