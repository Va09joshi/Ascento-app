import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';
import 'package:ascento_abacus/core/widgets/app_card.dart';
import 'package:ascento_abacus/core/widgets/responsive_builder.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:shimmer/shimmer.dart';

// StateProvider tracking IDs of unlocked/purchased premium content in-memory
final unlockedNotesProvider = StateProvider<Set<String>>((ref) => <String>{});

class LessonsView extends ConsumerStatefulWidget {
  const LessonsView({super.key});

  @override
  ConsumerState<LessonsView> createState() => _LessonsViewState();
}

class _LessonsViewState extends ConsumerState<LessonsView> {
  String _selectedCategory = 'All';
  String _selectedFilter = 'All Notes';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lessonsAsync = ref.watch(lessonsListProvider);
    final unlockedNotes = ref.watch(unlockedNotesProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFFAF9F5), // Premium off-white background
      body: lessonsAsync.when(
        data: (lessons) {
          // Dynamic category counts
          final totalCount = lessons.length;
          final testPaperCount = lessons.where((item) => item.category == 'Test paper').length;
          final vedicMathsCount = lessons.where((item) => item.category == 'Vedic maths').length;
          final abacusCount = lessons.where((item) => item.category == 'Abacus').length;

          // Dynamic filter counts
          final freeCount = lessons.where((item) => item.isFree).length;
          final premiumCount = lessons.where((item) => !item.isFree).length;

          // Filtered list compilation
          final filteredLessons = lessons.where((item) {
            // Category filter
            if (_selectedCategory == 'Test paper' && item.category != 'Test paper') return false;
            if (_selectedCategory == 'Vedic maths' && item.category != 'Vedic maths') return false;
            if (_selectedCategory == 'Abacus' && item.category != 'Abacus') return false;

            // Pill filter
            if (_selectedFilter == 'Free' && !item.isFree) return false;
            if (_selectedFilter == 'Premium' && item.isFree) return false;

            // Search filter
            if (_searchQuery.isNotEmpty &&
                !item.title.toLowerCase().contains(_searchQuery.toLowerCase()) &&
                !item.tag.toLowerCase().contains(_searchQuery.toLowerCase())) {
              return false;
            }

            return true;
          }).toList();

          return Column(
            children: [
              // Scrollable screen body
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    ResponsiveBuilder.horizontalPadding(context),
                    18.h,
                    ResponsiveBuilder.horizontalPadding(context),
                    28.h,
                  ),
                  child: ResponsiveContent(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- 1. Title Block (Serif Styling & Stacked Book Icon) ---
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _buildStackedNotesIcon(),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Notes & Materials',
                                    style: GoogleFonts.playfairDisplay(
                                      textStyle: TextStyle(
                                        fontSize: 24.sp,
                                        fontWeight: FontWeight.w800,
                                        color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1F2328),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    'Study resources shared by your teacher',
                                    style: GoogleFonts.inter(
                                      textStyle: TextStyle(
                                        fontSize: 11.5.sp,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),

                        // --- 2. Horizontal Scrollable Category Chips ---
                        Text(
                          'BROWSE BY CATEGORY',
                          style: TextStyle(
                            fontSize: 8.5.sp,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                            color: AppColors.textMuted,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: [
                              _CategoryChip(
                                label: 'All',
                                icon: Icons.menu_book_rounded,
                                count: totalCount,
                                isSelected: _selectedCategory == 'All',
                                baseColor: const Color(0xFF7C4ED9),
                                onTap: () => setState(() => _selectedCategory = 'All'),
                              ),
                              _CategoryChip(
                                label: 'Test paper',
                                icon: Icons.folder_outlined,
                                count: testPaperCount,
                                isSelected: _selectedCategory == 'Test paper',
                                baseColor: const Color(0xFFFF8F3C),
                                onTap: () => setState(() => _selectedCategory = 'Test paper'),
                              ),
                              _CategoryChip(
                                label: 'Vedic maths',
                                icon: Icons.folder_outlined,
                                count: vedicMathsCount,
                                isSelected: _selectedCategory == 'Vedic maths',
                                baseColor: const Color(0xFFE85A9A),
                                onTap: () => setState(() => _selectedCategory = 'Vedic maths'),
                              ),
                              _CategoryChip(
                                label: 'Abacus Book',
                                icon: Icons.folder_outlined,
                                count: abacusCount,
                                isSelected: _selectedCategory == 'Abacus',
                                baseColor: const Color(0xFF2FAE78),
                                onTap: () => setState(() => _selectedCategory = 'Abacus'),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 14.h),

                        // --- 3. Filters Row & Search Field (Responsive Wrap) ---
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isWide = constraints.maxWidth > 550;
                            final filterRow = SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              child: Row(
                                children: [
                                  _FilterPill(
                                    label: 'All Notes',
                                    count: totalCount,
                                    isSelected: _selectedFilter == 'All Notes',
                                    onTap: () => setState(() => _selectedFilter = 'All Notes'),
                                  ),
                                  _FilterPill(
                                    label: 'Free',
                                    count: freeCount,
                                    icon: Icons.school_outlined,
                                    isSelected: _selectedFilter == 'Free',
                                    onTap: () => setState(() => _selectedFilter = 'Free'),
                                  ),
                                  _FilterPill(
                                    label: 'Premium',
                                    count: premiumCount,
                                    icon: Icons.lock_outline_rounded,
                                    isSelected: _selectedFilter == 'Premium',
                                    onTap: () => setState(() => _selectedFilter = 'Premium'),
                                  ),
                                ],
                              ),
                            );

                            final searchField = Container(
                              width: isWide ? 220.w : double.infinity,
                              height: 34.h,
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.darkSurface : const Color(0xFFF3F2EC),
                                borderRadius: BorderRadius.circular(18.r),
                                border: Border.all(
                                  color: isDark ? AppColors.darkBorder : const Color(0xFFE1DFD5),
                                  width: 1,
                                ),
                              ),
                              child: TextField(
                                controller: _searchController,
                                onChanged: (value) {
                                  setState(() {
                                    _searchQuery = value;
                                  });
                                },
                                style: TextStyle(
                                  fontSize: 11.5.sp,
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Search notes...',
                                  hintStyle: TextStyle(
                                    fontSize: 11.5.sp,
                                    color: AppColors.textMuted,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.search_rounded,
                                    size: 15.r,
                                    color: AppColors.textMuted,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(vertical: 8.h),
                                ),
                              ),
                            );

                            if (isWide) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(child: filterRow),
                                  searchField,
                                ],
                              );
                            } else {
                              return Column(
                                children: [
                                  filterRow,
                                  SizedBox(height: 10.h),
                                  searchField,
                                ],
                              );
                            }
                          },
                        ),
                        SizedBox(height: 10.h),

                        // --- 4. Information Banner Notice ---
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF2C2216) : const Color(0xFFFEFBF0),
                            borderRadius: BorderRadius.circular(6.r),
                            border: Border.all(
                              color: isDark ? const Color(0xFF5A4428) : const Color(0xFFF7EED5),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.school_rounded,
                                size: 12.r,
                                color: isDark ? const Color(0xFFEAA040) : const Color(0xFFB48520),
                              ),
                              SizedBox(width: 6.w),
                              Expanded(
                                child: Text(
                                  '$freeCount free notes available  •  $premiumCount premium notes (payment integrated)',
                                  style: TextStyle(
                                    fontSize: 9.8.sp,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? const Color(0xFFECC290) : const Color(0xFF8B6508),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 12.h),

                        // --- 5. Compact Study Notes List Cards ---
                        if (filteredLessons.isEmpty)
                          AppCard(
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 36.h),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.search_off_rounded,
                                      size: 40.r,
                                      color: AppColors.textMuted,
                                    ),
                                    SizedBox(height: 12.h),
                                    Text(
                                      'No materials matched your filters.',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        else
                          Column(
                            children: List.generate(filteredLessons.length, (index) {
                              final item = filteredLessons[index];
                              final isUnlocked = item.isFree || unlockedNotes.contains(item.id);
                              return _ContentCard(
                                item: item,
                                index: index + 1,
                                isUnlocked: isUnlocked,
                                onActionTap: () => _handleItemAction(context, item, isUnlocked),
                              );
                            }),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const _LessonsShimmerView(),
        error: (err, stack) => Center(child: Text('Error loading study materials: $err')),
      ),
    );
  }

  // Handle Free vs Premium Checkout Flow
  void _handleItemAction(BuildContext context, ContentItem item, bool isUnlocked) async {
    if (isUnlocked) {
      // Free or unlocked: immediately open the offline PDF worksheet
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MockPdfReaderView(title: item.title),
        ),
      );
    } else {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      // Premium: trigger gorgeous simulated Razorpay bottom-sheet payment overlay
      final paymentSuccess = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => _RazorpayBottomSheet(item: item),
      );

      if (paymentSuccess == true) {
        // Unlock note inside Riverpod in-memory state
        ref.read(unlockedNotesProvider.notifier).update((state) => {...state, item.id});

        // Show toast feedback
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    '🎉 Payment Successful! "${item.title}" is now unlocked.',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF2FAE78),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  // Elegant Overlapping Stacked Academic Book Logo Graphic
  Widget _buildStackedNotesIcon() {
    return Container(
      width: 42.w,
      height: 42.w,
      alignment: Alignment.center,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Background blue book
          Transform.translate(
            offset: Offset(-4.w, 4.h),
            child: Transform.rotate(
              angle: -0.15,
              child: Container(
                width: 22.w,
                height: 28.h,
                decoration: BoxDecoration(
                  color: const Color(0xFF4FB6FF),
                  borderRadius: BorderRadius.circular(4.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Middle orange book
          Transform.translate(
            offset: Offset(4.w, 2.h),
            child: Transform.rotate(
              angle: 0.15,
              child: Container(
                width: 22.w,
                height: 28.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF8F3C),
                  borderRadius: BorderRadius.circular(4.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Foreground violet book
          Container(
            width: 22.w,
            height: 28.h,
            decoration: BoxDecoration(
              color: const Color(0xFF7C4ED9),
              borderRadius: BorderRadius.circular(4.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              Icons.auto_stories_rounded,
              size: 12.r,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// SUB-WIDGET: DYNAMIC CATEGORY CHIP WITH COUNTER
// =============================================================================
class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final int count;
  final bool isSelected;
  final Color baseColor;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.count,
    required this.isSelected,
    required this.baseColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color bgColor = isSelected
        ? baseColor
        : (isDark ? AppColors.darkSurface : const Color(0xFFF4F2EB));
    final Color textColor = isSelected
        ? Colors.white
        : (isDark ? AppColors.darkTextPrimary : const Color(0xFF1F2328));
    final Color iconColor = isSelected
        ? Colors.white
        : baseColor;

    return Container(
      margin: EdgeInsets.only(right: 8.w),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: isSelected
                  ? baseColor
                  : (isDark ? AppColors.darkBorder : const Color(0xFFE2E0D5)),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14.r, color: iconColor),
              SizedBox(width: 6.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              SizedBox(width: 6.w),
              // Compact dark count circle
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.22)
                      : (isDark ? Colors.black26 : Colors.black.withValues(alpha: 0.05)),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w900,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// SUB-WIDGET: FILTER PILL BUTTON
// =============================================================================
class _FilterPill extends StatelessWidget {
  final String label;
  final int count;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    required this.count,
    this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color bgColor = isSelected
        ? (isDark ? const Color(0xFFF0EFEA) : const Color(0xFF1F2328))
        : (isDark ? AppColors.darkSurface : const Color(0xFFFAF9F5));
    final Color textColor = isSelected
        ? (isDark ? const Color(0xFF121215) : Colors.white)
        : (isDark ? AppColors.darkTextMuted : AppColors.textPrimary);

    return Container(
      margin: EdgeInsets.only(right: 6.w),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isSelected
                  ? (isDark ? const Color(0xFFF0EFEA) : const Color(0xFF1F2328))
                  : (isDark ? AppColors.darkBorder : const Color(0xFFE2E0D5)),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 12.r,
                  color: isSelected
                      ? (isDark ? const Color(0xFF121215) : Colors.white)
                      : (isDark ? AppColors.darkTextMuted : AppColors.textMuted),
                ),
                SizedBox(width: 4.w),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.5.sp,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              SizedBox(width: 6.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.5.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? Colors.black12 : Colors.white.withValues(alpha: 0.18))
                      : (isDark ? Colors.black26 : Colors.black.withValues(alpha: 0.04)),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 8.sp,
                    fontWeight: FontWeight.w900,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// SUB-WIDGET: HIGH-DENSITY STUDY NOTE CARD LIST ITEM
// =============================================================================
class _ContentCard extends StatelessWidget {
  final ContentItem item;
  final int index;
  final bool isUnlocked;
  final VoidCallback onActionTap;

  const _ContentCard({
    required this.item,
    required this.index,
    required this.isUnlocked,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : const Color(0xFFEAE7DC),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.r),
        child: InkWell(
          onTap: onActionTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            child: Row(
              children: [
                // 1. Index numbering tag
                Container(
                  width: 26.w,
                  height: 26.h,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF26262D) : const Color(0xFFF3F2EC),
                    borderRadius: BorderRadius.circular(5.r),
                  ),
                  child: Text(
                    '#$index',
                    style: TextStyle(
                      fontSize: 9.5.sp,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),

                // 2. Beautiful lock / document visual emblem
                Container(
                  width: 30.w,
                  height: 30.h,
                  decoration: BoxDecoration(
                    color: isUnlocked
                        ? const Color(0xFFFCE8E6) // Soft red container for PDF
                        : const Color(0xFFE8E7FA), // Soft purple container for Premium
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Icon(
                    isUnlocked
                        ? Icons.picture_as_pdf_rounded
                        : Icons.lock_outline_rounded,
                    size: 15.r,
                    color: isUnlocked
                        ? const Color(0xFFFF5B5B) // Orange/red
                        : const Color(0xFF6C4ED9), // Royal purple
                  ),
                ),
                SizedBox(width: 10.w),

                // 3. Middle descriptive details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Document Title
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      // Meta Chips Row
                      Wrap(
                        spacing: 4.w,
                        runSpacing: 3.h,
                        children: [
                          // Free vs Premium badge
                          _buildMiniBadge(
                            isUnlocked
                                ? (item.isFree ? 'FREE PREVIEW' : 'UNLOCKED')
                                : 'PREMIUM',
                            isUnlocked
                                ? (item.isFree ? const Color(0xFF3B82F6) : const Color(0xFF10B981))
                                : const Color(0xFF7C4ED9),
                            isDark,
                          ),
                          // Category Folder badge
                          _buildCategoryMiniBadge(item.category, isDark),
                          // Specific tag badge (Yellow chip)
                          _buildYellowTagBadge(item.tag, isDark),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 10.w),

                // 4. Date & Action button
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Date
                    Text(
                      item.duration, // Hold dates like '22 May 2026'
                      style: TextStyle(
                        fontSize: 8.5.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    // Compact button
                    ElevatedButton.icon(
                      onPressed: onActionTap,
                      icon: Icon(
                        isUnlocked ? Icons.visibility_rounded : Icons.lock_rounded,
                        size: 10.r,
                        color: isUnlocked
                            ? AppColors.textPrimary
                            : Colors.white,
                      ),
                      label: Text(
                        isUnlocked ? 'View PDF' : 'Unlock',
                        style: TextStyle(
                          fontSize: 9.5.sp,
                          fontWeight: FontWeight.w800,
                          color: isUnlocked
                              ? AppColors.textPrimary
                              : Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isUnlocked
                            ? const Color(0xFFEFEBE4) // Neutral tan/grey
                            : const Color(0xFF6C4ED9), // Solid royal purple
                        foregroundColor: isUnlocked
                            ? AppColors.textPrimary
                            : Colors.white,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        minimumSize: Size(68.w, 24.h),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.r),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniBadge(String text, Color color, bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(3.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 7.8.sp,
          fontWeight: FontWeight.w900,
          color: color,
        ),
      ),
    );
  }

  Widget _buildCategoryMiniBadge(String category, bool isDark) {
    final color = const Color(0xFF7C4ED9);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(3.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.folder_open_rounded, size: 8.r, color: color),
          SizedBox(width: 2.w),
          Text(
            category,
            style: TextStyle(
              fontSize: 7.8.sp,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYellowTagBadge(String tag, bool isDark) {
    final color = isDark ? const Color(0xFFECC290) : const Color(0xFFB48520);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(3.r),
        border: Border.all(
          color: color.withValues(alpha: 0.16),
          width: 0.5,
        ),
      ),
      child: Text(
        tag,
        style: TextStyle(
          fontSize: 7.8.sp,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

// =============================================================================
// SUB-WIDGET: HIGH-FIDELITY SIMULATED RAZORPAY PAYMENT SHEET OVERLAY
// =============================================================================
class _RazorpayBottomSheet extends StatefulWidget {
  final ContentItem item;
  const _RazorpayBottomSheet({required this.item});

  @override
  State<_RazorpayBottomSheet> createState() => _RazorpayBottomSheetState();
}

class _RazorpayBottomSheetState extends State<_RazorpayBottomSheet> {
  String _payState = 'options'; // 'options', 'card_details', 'processing', 'success'
  String _loadingMessage = 'Connecting to Razorpay secure servers...';
  double _successScale = 0.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A), // Dark Midnight Blue/Navy Razorpay Theme
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      child: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: _buildStateContent(isDark),
        ),
      ),
    );
  }

  Widget _buildStateContent(bool isDark) {
    switch (_payState) {
      case 'options':
        return _buildPaymentOptions();
      case 'card_details':
        return _buildCardForm();
      case 'processing':
        return _buildProcessingScreen();
      case 'success':
        return _buildSuccessScreen();
      default:
        return _buildPaymentOptions();
    }
  }

  // Header part of Razorpay sheet
  Widget _buildRazorpayHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo and company title
              Row(
                children: [
                  Container(
                    width: 28.w,
                    height: 28.w,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.school_rounded, size: 14, color: Colors.white),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ascento Abacus Academy',
                        style: TextStyle(
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'vaibhav@ascento.com',
                        style: TextStyle(
                          fontSize: 9.sp,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Secured indicator
              Row(
                children: [
                  const Icon(Icons.verified_user_rounded, size: 10, color: Color(0xFF10B981)),
                  SizedBox(width: 3.w),
                  Text(
                    'Razorpay Secured',
                    style: TextStyle(
                      fontSize: 8.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),
              ),
              Text(
                '₹${widget.item.price.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 1. Payment methods options list
  Widget _buildPaymentOptions() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildRazorpayHeader(),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PREFERRED PAYMENT METHODS',
                style: TextStyle(
                  fontSize: 8.5.sp,
                  fontWeight: FontWeight.w900,
                  color: Colors.white38,
                  letterSpacing: 0.8,
                ),
              ),
              SizedBox(height: 8.h),
              // GPay UPI option
              _buildPayTile(
                icon: Icons.flash_on_rounded,
                title: 'Google Pay / PhonePe (UPI)',
                subtitle: 'Pay instantly using UPI applications',
                onTap: () => _triggerSimulation('Google Pay UPI'),
              ),
              SizedBox(height: 8.h),
              _buildPayTile(
                icon: Icons.credit_card_rounded,
                title: 'Card',
                subtitle: 'Visa, MasterCard, RuPay, Maestro',
                onTap: () => setState(() => _payState = 'card_details'),
              ),
              SizedBox(height: 8.h),
              _buildPayTile(
                icon: Icons.account_balance_rounded,
                title: 'Netbanking',
                subtitle: 'All Indian banks available',
                onTap: () => _triggerSimulation('SBI Netbanking'),
              ),
              SizedBox(height: 8.h),
              _buildPayTile(
                icon: Icons.account_balance_wallet_rounded,
                title: 'Wallet',
                subtitle: 'PhonePe Wallet, Mobikwik',
                onTap: () => _triggerSimulation('PhonePe Wallet'),
              ),
              SizedBox(height: 18.h),
              Center(
                child: Text(
                  'Secured by Razorpay • Lifetime Access Authorized',
                  style: TextStyle(
                    fontSize: 8.5.sp,
                    color: Colors.white24,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 2. Card Details Form View
  Widget _buildCardForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildRazorpayHeader(),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => setState(() => _payState = 'options'),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 14, color: Colors.white70),
                  ),
                  Text(
                    'ENTER CARD DETAILS',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              // Card Number Input
              _buildFormInput(
                hint: 'Card Number',
                icon: Icons.credit_card_rounded,
                textType: TextInputType.number,
                valText: '4312 8764 9912 3456',
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Expanded(
                    child: _buildFormInput(
                      hint: 'Expiry (MM/YY)',
                      icon: Icons.calendar_today_rounded,
                      textType: TextInputType.datetime,
                      valText: '12/30',
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: _buildFormInput(
                      hint: 'CVV',
                      icon: Icons.lock_outline_rounded,
                      textType: TextInputType.number,
                      valText: '988',
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              _buildFormInput(
                hint: 'Card Holder Name',
                icon: Icons.person_outline_rounded,
                textType: TextInputType.name,
                valText: 'Vaibhav Kumar',
              ),
              SizedBox(height: 18.h),
              // Pay button
              SizedBox(
                width: double.infinity,
                height: 44.h,
                child: ElevatedButton(
                  onPressed: () => _triggerSimulation('Visa Card'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6), // Blue
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    'Pay ₹${widget.item.price.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 3. Processing Loader
  Widget _buildProcessingScreen() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Razorpay branding color circular spinner
          SizedBox(
            width: 52.w,
            height: 52.w,
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
              strokeWidth: 3,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'RAZORPAY GATEWAY SIMULATION',
            style: TextStyle(
              fontSize: 9.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
              color: Colors.white38,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            _loadingMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4.h),
          const Text(
            'Please do not close this modal or refresh the view.',
            style: TextStyle(fontSize: 9.5, color: Colors.white24),
          ),
        ],
      ),
    );
  }

  // 4. Successful checkout spring overlay screen
  Widget _buildSuccessScreen() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 36.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Spring animation container
          AnimatedScale(
            scale: _successScale,
            duration: const Duration(milliseconds: 400),
            curve: Curves.elasticOut,
            child: Container(
              width: 56.w,
              height: 56.w,
              decoration: const BoxDecoration(
                color: Color(0xFF10B981),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'PAYMENT SUCCESSFUL',
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
              color: const Color(0xFF10B981),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '₹${widget.item.price.toStringAsFixed(0)} Paid',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Transaction Ref ID: pay_sim_${DateTime.now().millisecondsSinceEpoch}',
            style: const TextStyle(fontSize: 8.5, color: Colors.white38),
          ),
          SizedBox(height: 8.h),
          const Text(
            'Note unlocked! Redirecting...',
            style: TextStyle(fontSize: 11, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildPayTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: const Color(0xFF1E293B),
      borderRadius: BorderRadius.circular(8.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          child: Row(
            children: [
              Container(
                width: 28.w,
                height: 28.h,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Icon(icon, size: 14.r, color: const Color(0xFF3B82F6)),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 9.sp,
                        color: Colors.white38,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 10, color: Colors.white24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormInput({
    required String hint,
    required IconData icon,
    required TextInputType textType,
    required String valText,
  }) {
    return Container(
      height: 38.h,
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: TextField(
        readOnly: true, //Prefilled high-density simulation
        keyboardType: textType,
        style: TextStyle(fontSize: 12.sp, color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(fontSize: 11.sp, color: Colors.white24),
          prefixIcon: Icon(icon, size: 14.r, color: Colors.white38),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 8.h),
        ),
        controller: TextEditingController(text: valText),
      ),
    );
  }

  // Triggers beautiful payment lifecycle animation
  void _triggerSimulation(String method) async {
    setState(() {
      _payState = 'processing';
      _loadingMessage = 'Initiating Secure $method Gateway...';
    });

    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() {
      _loadingMessage = 'Processing secure billing authorization...';
    });

    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() {
      _loadingMessage = 'Verifying transactions token with Razorpay...';
    });

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {
      _payState = 'success';
    });

    // Spring scale pop
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;
    setState(() {
      _successScale = 1.0;
    });

    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    Navigator.pop(context, true); // Returns success back to caller
  }
}

// =============================================================================
// SUB-WIDGET: HIGH-FIDELITY LESSONS SHIMMER SKELETON LOADER
// =============================================================================
class _LessonsShimmerView extends StatelessWidget {
  const _LessonsShimmerView();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF2A2A35) : const Color(0xFFE0DFD5);
    final highlightColor = isDark ? const Color(0xFF3F3F4C) : const Color(0xFFF3F2EC);

    Widget shimmerWrapper({required Widget child}) {
      return Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: child,
      );
    }

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        ResponsiveBuilder.horizontalPadding(context),
        18.h,
        ResponsiveBuilder.horizontalPadding(context),
        28.h,
      ),
      child: ResponsiveContent(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Title Block Shimmer
            shimmerWrapper(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 42.w,
                    height: 42.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 160.w,
                          height: 20.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Container(
                          width: 200.w,
                          height: 10.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(3.r),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // 2. Horizontal Scrollable Category Chips Shimmer
            shimmerWrapper(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 110.w,
                    height: 9.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const NeverScrollableScrollPhysics(),
                    child: Row(
                      children: List.generate(4, (index) {
                        final widths = [55.w, 90.w, 95.w, 80.w];
                        return Container(
                          margin: EdgeInsets.only(right: 8.w),
                          width: widths[index],
                          height: 30.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 14.h),

            // 3. Filters Row & Search Field Shimmer
            shimmerWrapper(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                child: Row(
                  children: [
                    Row(
                      children: List.generate(3, (index) {
                        final widths = [75.w, 55.w, 75.w];
                        return Container(
                          margin: EdgeInsets.only(right: 6.w),
                          width: widths[index],
                          height: 26.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                        );
                      }),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      width: 120.w,
                      height: 34.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18.r),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10.h),

            // 4. Information Banner Notice Shimmer
            shimmerWrapper(
              child: Container(
                width: double.infinity,
                height: 26.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6.r),
                ),
              ),
            ),
            SizedBox(height: 12.h),

            // 5. Compact Study Notes List Cards Shimmers (Unified Wave for inner contents)
            Column(
              children: List.generate(5, (index) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : const Color(0xFFEAE7DC),
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                      child: shimmerWrapper(
                    child: Row(
                      children: [
                        // Index numbering tag shimmer
                        Container(
                          width: 26.w,
                          height: 26.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5.r),
                          ),
                        ),
                        SizedBox(width: 8.w),

                        // Emblem shimmer
                        Container(
                          width: 30.w,
                          height: 30.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                        ),
                        SizedBox(width: 10.w),

                        // Details column shimmer
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 140.w,
                                height: 12.h,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(3.r),
                                ),
                              ),
                              SizedBox(height: 6.h),
                              Row(
                                children: [
                                  Container(
                                    width: 50.w,
                                    height: 9.h,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(3.r),
                                    ),
                                  ),
                                  SizedBox(width: 4.w),
                                  Container(
                                    width: 60.w,
                                    height: 9.h,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(3.r),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 10.w),

                        // Date & Button shimmer
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              width: 40.w,
                              height: 8.h,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(2.r),
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Container(
                              width: 68.w,
                              height: 24.h,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5.r),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// SUB-WIDGET: OFFLINE MOCK PDF VIEWPORT & SUM GRID
// =============================================================================
class MockPdfReaderView extends StatefulWidget {
  final String title;
  const MockPdfReaderView({super.key, required this.title});

  @override
  State<MockPdfReaderView> createState() => _MockPdfReaderViewState();
}

class _MockPdfReaderViewState extends State<MockPdfReaderView> {
  late PdfViewerController _pdfViewerController;

  @override
  void initState() {
    _pdfViewerController = PdfViewerController();
    super.initState();
  }

  @override
  void dispose() {
    _pdfViewerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFFAF9F5),
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14.5.sp,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        foregroundColor: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.zoom_in_rounded, size: 18.r),
            tooltip: 'Zoom In',
            onPressed: () {
              setState(() {
                _pdfViewerController.zoomLevel = (_pdfViewerController.zoomLevel + 0.25).clamp(1.0, 3.0);
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.zoom_out_rounded, size: 18.r),
            tooltip: 'Zoom Out',
            onPressed: () {
              setState(() {
                _pdfViewerController.zoomLevel = (_pdfViewerController.zoomLevel - 0.25).clamp(1.0, 3.0);
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.share_rounded, size: 18.r),
            tooltip: 'Share',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Digital sharing link copied to clipboard!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      body: SfPdfViewer.asset(
        'assets/images/free_abacus.pdf',
        controller: _pdfViewerController,
        canShowScrollHead: true,
        canShowScrollStatus: true,
        enableTextSelection: true,
        onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to load PDF worksheet: ${details.description}'),
              backgroundColor: const Color(0xFFFF5B5B),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }
}

// =============================================================================
// DATA SCHEMA
// =============================================================================
class ContentItem {
  final String id;
  final String title;
  final String description;
  final String level;
  final String duration;
  final String format;
  final String category;
  final Color color;
  final IconData icon;
  final double price;
  final bool isFree;
  final String tag;

  const ContentItem({
    required this.id,
    required this.title,
    required this.description,
    required this.level,
    required this.duration,
    required this.format,
    required this.category,
    required this.color,
    required this.icon,
    required this.price,
    required this.isFree,
    required this.tag,
  });

  factory ContentItem.fromJson(Map<String, dynamic> json) {
    return ContentItem(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      level: json['level'] as String,
      duration: json['duration'] as String,
      format: json['format'] as String,
      category: json['category'] as String,
      color: Color(int.parse(json['color'] as String)),
      icon: _getIconData(json['icon'] as int),
      price: (json['price'] as num).toDouble(),
      isFree: json['isFree'] as bool,
      tag: json['tag'] as String,
    );
  }

  static IconData _getIconData(int codePoint) {
    // Tree-shaking requires known IconData constants
    // A mapping can be built here, but to satisfy the compiler and fallback safely:
    if (codePoint == Icons.menu_book.codePoint) return Icons.menu_book;
    if (codePoint == Icons.play_circle_fill.codePoint) return Icons.play_circle_fill;
    if (codePoint == Icons.picture_as_pdf.codePoint) return Icons.picture_as_pdf;
    return Icons.insert_drive_file_rounded;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'level': level,
      'duration': duration,
      'format': format,
      'category': category,
      'color': '0x${color.toARGB32().toRadixString(16).toUpperCase()}',
      'icon': icon.codePoint,
      'price': price,
      'isFree': isFree,
      'tag': tag,
    };
  }
}

// =============================================================================
// SERVICE LAYER (MOCKS PRECISELY IN-LINE WITH USER SCREENSHOTS)
// =============================================================================
class LessonsRepository {
  Future<List<ContentItem>> fetchContentItems() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    return _mockContentItems;
  }
}

final lessonsRepositoryProvider = Provider((ref) => LessonsRepository());

final lessonsListProvider = FutureProvider<List<ContentItem>>((ref) async {
  final repository = ref.watch(lessonsRepositoryProvider);
  return repository.fetchContentItems();
});

// Vibrant HSL-harmonized mock content elements matching screenshot
const _mockContentItems = [
  ContentItem(
    id: '1',
    title: 'vedic',
    description: 'Learn Vedic mathematics shortcuts for rapid calculation grids.',
    level: 'Vedic maths',
    duration: '22 May 2026',
    format: 'Premium Notes',
    category: 'Vedic maths',
    color: Color(0xFF6C4ED9),
    icon: Icons.menu_book_rounded,
    price: 99.0,
    isFree: false,
    tag: 'vedic',
  ),
  ContentItem(
    id: '2',
    title: 'Olymapaid',
    description: 'National and international level olympiad preparation test papers.',
    level: 'Test paper',
    duration: '22 May 2026',
    format: 'Test Paper',
    category: 'Test paper',
    color: Color(0xFFE85A9A),
    icon: Icons.edit_note_rounded,
    price: 149.0,
    isFree: false,
    tag: 'olympaid',
  ),
  ContentItem(
    id: '3',
    title: 'ASCENTO ABACUS BOOK LEVEL - 9',
    description: 'Advanced level 9 worksheets and mental abacus arithmetic.',
    level: 'Ascento abacus level 9',
    duration: '22 May 2026',
    format: 'Premium Book',
    category: 'Abacus',
    color: Color(0xFF8B5CF6),
    icon: Icons.star_rounded,
    price: 199.0,
    isFree: false,
    tag: 'Ascento abacus level 9',
  ),
  ContentItem(
    id: '4',
    title: 'ASCENTO ABACUS BOOK LEVEL - 8',
    description: 'Mental calculation drills and double digit multiplication.',
    level: 'Ascento abacus level 8',
    duration: '22 May 2026',
    format: 'Premium Book',
    category: 'Abacus',
    color: Color(0xFF8B5CF6),
    icon: Icons.star_rounded,
    price: 199.0,
    isFree: false,
    tag: 'Ascento abacus level 8',
  ),
  ContentItem(
    id: '5',
    title: 'ASCENTO ABACUS BOOK LEVEL - 7',
    description: 'Speed subtraction and addition techniques for high speed rods.',
    level: 'Ascento abacus level 7',
    duration: '22 May 2026',
    format: 'Premium Book',
    category: 'Abacus',
    color: Color(0xFF8B5CF6),
    icon: Icons.star_rounded,
    price: 199.0,
    isFree: false,
    tag: 'Ascento abacus level 7',
  ),
  ContentItem(
    id: '6',
    title: 'ASCENTO ABACUS BOOK LEVEL - 1',
    description: 'Beginner abacus manual. Learn basic bead positions and hands alignment.',
    level: 'Ascento abacus level 5',
    duration: '13 May 2026',
    format: 'Premium Book',
    category: 'Abacus',
    color: Color(0xFF8B5CF6),
    icon: Icons.star_rounded,
    price: 199.0,
    isFree: false,
    tag: 'Ascento abacus level 5',
  ),
  ContentItem(
    id: '7',
    title: 'ASCENTO ABACUS BOOK LEVEL - 2',
    description: 'Intermediate addition formulas and small friends rules.',
    level: 'Ascento abacus level 2',
    duration: '14 May 2026',
    format: 'Premium Book',
    category: 'Abacus',
    color: Color(0xFF8B5CF6),
    icon: Icons.star_rounded,
    price: 199.0,
    isFree: false,
    tag: 'Ascento abacus level 2',
  ),
  ContentItem(
    id: '8',
    title: 'ASCENTO ABACUS BOOK LEVEL - 3',
    description: 'Intermediate subtraction formulas and big friends rules.',
    level: 'Ascento abacus level 3',
    duration: '14 May 2026',
    format: 'Premium Book',
    category: 'Abacus',
    color: Color(0xFF8B5CF6),
    icon: Icons.star_rounded,
    price: 199.0,
    isFree: false,
    tag: 'Ascento abacus level 3',
  ),
  ContentItem(
    id: '9',
    title: 'ASCENTO ABACUS BOOK LEVEL - 4',
    description: 'Advanced double-digit bead movement combinations.',
    level: 'Ascento abacus level 4',
    duration: '14 May 2026',
    format: 'Premium Book',
    category: 'Abacus',
    color: Color(0xFF8B5CF6),
    icon: Icons.star_rounded,
    price: 199.0,
    isFree: false,
    tag: 'Ascento abacus level 4',
  ),
  ContentItem(
    id: '10',
    title: 'ASCENTO ABACUS BOOK LEVEL - 5',
    description: 'Advanced multiplication rules and mental visualization exercises.',
    level: 'Ascento abacus level 5',
    duration: '14 May 2026',
    format: 'Premium Book',
    category: 'Abacus',
    color: Color(0xFF8B5CF6),
    icon: Icons.star_rounded,
    price: 199.0,
    isFree: false,
    tag: 'Ascento abacus level 5',
  ),
  ContentItem(
    id: '11',
    title: 'ASCENTO ABACUS BOOK LEVEL - 6',
    description: 'Division rules, decimals, and master visual rod speed drills.',
    level: 'Ascento abacus level 6',
    duration: '14 May 2026',
    format: 'Premium Book',
    category: 'Abacus',
    color: Color(0xFF8B5CF6),
    icon: Icons.star_rounded,
    price: 199.0,
    isFree: false,
    tag: 'Ascento abacus level 6',
  ),
  ContentItem(
    id: '12',
    title: 'ABACUS CLASS Demo Free trial',
    description: 'Free trial worksheets containing Level 1 final pages 8-14.',
    level: 'Level 1 Final 8-14 PAGES FOR FREE TRIAL CLASS',
    duration: '21 May 2026',
    format: 'Free Preview Notes',
    category: 'Abacus',
    color: Color(0xFFFF5B5B),
    icon: Icons.picture_as_pdf_rounded,
    price: 0.0,
    isFree: true,
    tag: 'Level 1 Final 8-14 PAGES FOR FREE TRIAL CLASS',
  ),
];
