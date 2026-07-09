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
  String? selectedAcademicYearId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Watch providers
    final classesAsync = ref.watch(classesListProvider);
    final sectionsAsync = ref.watch(sectionsListProvider);
    final yearsAsync = ref.watch(academicYearsListProvider);
    final timetableAsync = ref.watch(sectionTimetableProvider);
    
    final selectedClassId = ref.watch(selectedClassIdProvider);
    final selectedSectionId = ref.watch(selectedSectionIdProvider);
    
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('SCHEDULE STUDIO', style: TextStyle(color: Colors.white70, fontSize: 12.sp, letterSpacing: 1.5)),
                        SizedBox(height: 8.h),
                        Text('Timetable', style: TextStyle(color: Colors.white, fontSize: 28.sp, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8.h),
                        Text(
                          'A real timetable board for period planning with cleaner actions and better readability.', 
                          style: TextStyle(color: Colors.white70, fontSize: 14.sp),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Container(
                    width: 200.w,
                    height: 80.h,
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.white24)
                    ),
                    child: const Center(
                      child: Text('Weekly Timetable Layout', style: TextStyle(color: Colors.white), textAlign: TextAlign.center),
                    ),
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
                    child: Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 16.w,
                      runSpacing: 16.h,
                      children: [
                        Text('Filters', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                        Wrap(
                          spacing: 12.w,
                          runSpacing: 12.h,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () {
                                ref.invalidate(classesListProvider);
                                ref.invalidate(sectionsListProvider);
                                ref.invalidate(academicYearsListProvider);
                                ref.invalidate(sectionTimetableProvider);
                              },
                              icon: const Icon(Icons.refresh, size: 18),
                              label: const Text('Refresh'),
                            ),
                            ElevatedButton.icon(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlue.shade300, foregroundColor: Colors.white),
                              icon: const Icon(Icons.download, size: 18),
                              label: const Text('Download PDF'),
                            ),
                            OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.share, size: 18),
                              label: const Text('Share'),
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                if (selectedSectionId == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a section first')));
                                  return;
                                }
                                showDialog(
                                  context: context, 
                                  builder: (_) => const TimetableSlotFormDialog()
                                );
                              },
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
                    child: Wrap(
                      spacing: 16.w,
                      runSpacing: 16.h,
                      children: [
                        SizedBox(
                          width: 200.w,
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(labelText: 'Class', border: OutlineInputBorder()),
                            value: selectedClassId,
                            items: classesAsync.valueOrNull?.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList() ?? [],
                            onChanged: (v) {
                              ref.read(selectedClassIdProvider.notifier).state = v;
                              ref.read(selectedSectionIdProvider.notifier).state = null; // Reset section
                            },
                            hint: classesAsync.isLoading ? const Text('Loading...') : const Text('Select Class'),
                          ),
                        ),
                        SizedBox(
                          width: 200.w,
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(labelText: 'Section', border: OutlineInputBorder()),
                            value: selectedSectionId,
                            items: sectionsAsync.valueOrNull
                                ?.where((s) => s.classId == selectedClassId)
                                .map((s) => DropdownMenuItem(value: s.id, child: Text(s.name)))
                                .toList() ?? [],
                            onChanged: (v) => ref.read(selectedSectionIdProvider.notifier).state = v,
                            hint: sectionsAsync.isLoading ? const Text('Loading...') : const Text('All Sections'),
                            disabledHint: const Text('Select Class First'),
                          ),
                        ),
                        SizedBox(
                          width: 200.w,
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(labelText: 'Academic Year', border: OutlineInputBorder()),
                            value: selectedAcademicYearId,
                            items: yearsAsync.valueOrNull?.map((y) => DropdownMenuItem(value: y.id, child: Text(y.name))).toList() ?? [],
                            onChanged: (v) => setState(() => selectedAcademicYearId = v),
                            hint: yearsAsync.isLoading ? const Text('Loading...') : const Text('Select Year'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 24.h),

                  // Table
                  if (selectedSectionId == null)
                    Padding(
                      padding: EdgeInsets.all(48.w),
                      child: Center(
                        child: Text('Select a class and section to load timetable slots.', style: TextStyle(color: Colors.grey.shade600)),
                      ),
                    )
                  else if (timetableAsync.isLoading)
                    const Padding(
                      padding: EdgeInsets.all(48.0),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (timetableAsync.hasError)
                    Padding(
                      padding: EdgeInsets.all(48.0),
                      child: Center(child: Text('Error: ${timetableAsync.error}', style: const TextStyle(color: AppColors.error))),
                    )
                  else
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: DataTable(
                          headingRowColor: WidgetStateProperty.resolveWith((states) => Colors.grey.shade50),
                          border: TableBorder.all(color: Colors.grey.shade300),
                          dataRowMaxHeight: 80,
                          columns: [
                            const DataColumn(label: Text('Day', style: TextStyle(fontWeight: FontWeight.bold))),
                            ...periods.map((p) => DataColumn(label: Text(p, style: const TextStyle(fontWeight: FontWeight.bold)))),
                          ],
                          rows: List.generate(days.length, (dayIndex) {
                            final dayName = days[dayIndex];
                            // Day of week: 1=Mon, ..., 6=Sat
                            final daySlots = timetableAsync.valueOrNull?.where((s) => s.dayOfWeek == dayIndex + 1).toList() ?? [];
                            // Sort slots by start time
                            daySlots.sort((a, b) => a.startTime.compareTo(b.startTime));
                            
                            return DataRow(
                              cells: [
                                DataCell(Text(dayName, style: const TextStyle(fontWeight: FontWeight.bold))),
                                ...List.generate(periods.length, (pIndex) {
                                  if (pIndex < daySlots.length) {
                                    final slot = daySlots[pIndex];
                                    return DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                        decoration: BoxDecoration(
                                          color: (slot.subjectColor ?? Colors.blue).withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: (slot.subjectColor ?? Colors.blue).withValues(alpha: 0.3)),
                                        ),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(slot.subject, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                            Text('${slot.startTime} - ${slot.endTime}', style: const TextStyle(fontSize: 10)),
                                            Text(slot.teacherName, style: TextStyle(fontSize: 10, color: Colors.grey.shade700)),
                                          ],
                                        ),
                                      ),
                                    );
                                  } else {
                                    return DataCell(
                                      Center(
                                        child: TextButton.icon(
                                          onPressed: () {
                                            showDialog(
                                              context: context, 
                                              builder: (_) => const TimetableSlotFormDialog()
                                            );
                                          },
                                          icon: const Icon(Icons.add, size: 14, color: Colors.grey),
                                          label: const Text('Add', style: TextStyle(color: Colors.grey)),
                                        ),
                                      )
                                    );
                                  }
                                }),
                              ]
                            );
                          }),
                        ),
                      ),
                    ),
                  
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
