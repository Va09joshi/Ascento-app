import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';
import 'package:ascento_abacus/features/academics/presentation/widgets/academic_years_tab.dart';
import 'package:ascento_abacus/features/academics/presentation/widgets/classes_tab.dart';
import 'package:ascento_abacus/features/academics/presentation/widgets/sections_tab.dart';
import 'package:ascento_abacus/features/academics/presentation/widgets/subjects_tab.dart';
import 'package:go_router/go_router.dart';
import 'package:ascento_abacus/shared/router/route_names.dart';

class AcademicsManagementView extends ConsumerStatefulWidget {
  const AcademicsManagementView({super.key});

  @override
  ConsumerState<AcademicsManagementView> createState() => _AcademicsManagementViewState();
}

class _AcademicsManagementViewState extends ConsumerState<AcademicsManagementView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['Years', 'Classes', 'Sections', 'Subjects'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
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
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Row(
                children: [
                  Text(
                    'Academics',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              height: 48.h,
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  color: AppColors.primary,
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: isDark ? Colors.white70 : Colors.black54,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                dividerColor: Colors.transparent,
                padding: EdgeInsets.all(4.r),
                tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  AcademicYearsTab(),
                  ClassesTab(),
                  SectionsTab(),
                  SubjectsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          switch (_tabController.index) {
            case 0:
              context.push(RoutePaths.addAcademicYear);
              break;
            case 1:
              context.push(RoutePaths.addClass);
              break;
            case 2:
              context.push(RoutePaths.addSection);
              break;
            case 3:
              context.push(RoutePaths.addSubject);
              break;
          }
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add New'),
      ),
    );
  }
}
