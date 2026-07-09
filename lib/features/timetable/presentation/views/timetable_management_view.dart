import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';
import 'package:ascento_abacus/shared/models/feature_models.dart';

import 'package:ascento_abacus/features/timetable/presentation/providers/timetable_provider.dart';
import 'package:ascento_abacus/features/academics/presentation/providers/academics_provider.dart';
import 'package:ascento_abacus/features/timetable/presentation/widgets/timetable_slot_form_dialog.dart';

class TimetableManagementView extends ConsumerStatefulWidget {
  const TimetableManagementView({super.key});

  @override
  ConsumerState<TimetableManagementView> createState() => _TimetableManagementViewState();
}

class _TimetableManagementViewState extends ConsumerState<TimetableManagementView> {
  String? selectedClassId;
  String? selectedSectionId;
  String? selectedAcademicYearId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // We mock these for the UI representation
    final classes = ['Class 1', 'Class 2'];
    final sections = ['Section A', 'Section B'];
    final years = ['2023-2024', '2024-2025'];
    
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    final periods = ['P1', 'P2', 'P3', 'P4', 'P5', 'P6', 'P7', 'P8'];

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF6A11CB), Color(0xFF2575FC)]),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('SCHEDULE STUDIO', style: TextStyle(color: Colors.white70, fontSize: 12.sp, letterSpacing: 1.5)),
                      SizedBox(height: 8.h),
                      Text('Timetable', style: TextStyle(color: Colors.white, fontSize: 28.sp, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8.h),
                      Text('A real timetable board for period planning with cleaner actions and better readability.', style: TextStyle(color: Colors.white70, fontSize: 14.sp)),
                    ],
                  ),
                  Container(
                    width: 300.w,
                    height: 80.h,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.white24)
                    ),
                    child: const Center(child: Text('Weekly Timetable Layout', style: TextStyle(color: Colors.white))),
                  )
                ],
              ),
            ),
            SizedBox(height: 24.h),

            // Content Card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Toolbar
                  Padding(
                    padding: EdgeInsets.all(24.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Filters', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                        Row(
                          children: [
                            OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.refresh, size: 18),
                              label: const Text('Refresh'),
                            ),
                            SizedBox(width: 12.w),
                            ElevatedButton.icon(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlue.shade300, foregroundColor: Colors.white),
                              icon: const Icon(Icons.download, size: 18),
                              label: const Text('Download PDF'),
                            ),
                            SizedBox(width: 12.w),
                            OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.share, size: 18),
                              label: const Text('Share'),
                            ),
                            SizedBox(width: 12.w),
                            ElevatedButton.icon(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('Create Slot'),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),

                  // Filters
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(labelText: 'Class', border: OutlineInputBorder()),
                            value: selectedClassId,
                            items: classes.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                            onChanged: (v) => setState(() => selectedClassId = v),
                            hint: const Text('Select Class'),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(labelText: 'Section', border: OutlineInputBorder()),
                            value: selectedSectionId,
                            items: sections.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                            onChanged: (v) => setState(() => selectedSectionId = v),
                            hint: const Text('All Sections'),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(labelText: 'Academic Year', border: OutlineInputBorder()),
                            value: selectedAcademicYearId,
                            items: years.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                            onChanged: (v) => setState(() => selectedAcademicYearId = v),
                            hint: const Text('Select Year'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 24.h),

                  // Table
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.resolveWith((states) => Colors.grey.shade50),
                        border: TableBorder.all(color: Colors.grey.shade300),
                        columns: [
                          const DataColumn(label: Text('Day', style: TextStyle(fontWeight: FontWeight.bold))),
                          ...periods.map((p) => DataColumn(label: Text(p, style: const TextStyle(fontWeight: FontWeight.bold)))),
                        ],
                        rows: days.map((day) => DataRow(
                          cells: [
                            DataCell(Text(day, style: const TextStyle(fontWeight: FontWeight.bold))),
                            ...periods.map((p) => DataCell(
                              Center(
                                child: TextButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.add, size: 14, color: Colors.grey),
                                  label: const Text('Add', style: TextStyle(color: Colors.grey)),
                                ),
                              )
                            ))
                          ]
                        )).toList(),
                      ),
                    ),
                  ),
                  
                  Padding(
                    padding: EdgeInsets.all(24.w),
                    child: Text('Select a class to load timetable slots.', style: TextStyle(color: Colors.grey.shade600)),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
