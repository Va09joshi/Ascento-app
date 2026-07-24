import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';
import 'package:ascento_abacus/core/widgets/app_shimmer.dart';
import 'package:ascento_abacus/shared/models/feature_models.dart';

import 'package:ascento_abacus/features/timetable/presentation/providers/timetable_provider.dart';
import 'package:ascento_abacus/features/academics/presentation/providers/academics_provider.dart';
import 'package:ascento_abacus/features/timetable/presentation/widgets/timetable_slot_form_dialog.dart';
import 'package:ascento_abacus/features/timetable/data/repositories/timetable_repository.dart';
import 'package:ascento_abacus/features/academics/data/repositories/academics_repository.dart';
import 'package:ascento_abacus/features/timetable/utils/timetable_pdf_generator.dart';
import 'package:ascento_abacus/features/timetable/presentation/views/timetable_pdf_preview_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:ascento_abacus/core/network/dio_client.dart';

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
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 600;
                  
                  return Flex(
                    direction: isMobile ? Axis.vertical : Axis.horizontal,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: isMobile ? CrossAxisAlignment.stretch : CrossAxisAlignment.center,
                    children: [
                      Column(
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
                      if (isMobile) SizedBox(height: 16.h) else SizedBox(width: 16.w),
                      Container(
                        width: isMobile ? double.infinity : 200.w,
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
                  );
                }
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
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isDesktop = constraints.maxWidth > 800;
                        
                        final refreshButton = OutlinedButton.icon(
                          onPressed: () {
                            ref.invalidate(classesListProvider);
                            ref.invalidate(sectionsListProvider);
                            ref.invalidate(academicYearsListProvider);
                            ref.invalidate(sectionTimetableProvider);
                          },
                          icon: const Icon(Icons.refresh, size: 16),
                          label: const Text('Refresh'),
                        );

                        final pdfButton = ElevatedButton.icon(
                          onPressed: () async {
                            if (selectedSectionId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a Section first')));
                              return;
                            }
                            final currentSection = sectionsAsync.valueOrNull?.firstWhere((s) => s.id == selectedSectionId);
                            final currentClass = classesAsync.valueOrNull?.firstWhere((c) => c.id == selectedClassId);
                            
                            final slots = timetableAsync.valueOrNull;
                            if (slots == null || slots.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No timetable slots available to generate PDF')));
                              return;
                            }
                            
                            try {
                              final pdfBytes = await TimetablePdfGenerator.generatePdfBytes(
                                slots, 
                                currentClass?.name ?? 'Class', 
                                currentSection?.name ?? 'Section'
                              );
                              if (mounted) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => TimetablePdfPreviewScreen(
                                      pdfBytes: pdfBytes,
                                      title: 'Timetable ${currentClass?.name ?? ''} ${currentSection?.name ?? ''}',
                                    ),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to generate PDF: $e')));
                            }
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlue.shade300, foregroundColor: Colors.white),
                          icon: const Icon(Icons.print, size: 16),
                          label: const Text('View PDF'),
                        );

                        final uploadPdfButton = OutlinedButton.icon(
                          onPressed: () async {
                            if (selectedSectionId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a Section first')));
                              return;
                            }
                            
                            try {
                              final result = await FilePicker.platform.pickFiles(
                                type: FileType.custom,
                                allowedExtensions: ['pdf'],
                              );

                              if (result != null && result.files.single.path != null) {
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Uploading PDF...')));
                                
                                final dioClient = ref.read(dioClientProvider);
                                final formData = FormData.fromMap({
                                  'file': await MultipartFile.fromFile(result.files.single.path!),
                                });
                                
                                final response = await dioClient.post(
                                  '/uploads/document', 
                                  data: formData,
                                );
                                
                                if (response.data['success'] == true) {
                                  final pdfUrl = response.data['data']['url'];
                                  await ref.read(academicsRepositoryProvider).updateSection(selectedSectionId!, {
                                    'timetable_pdf_url': pdfUrl,
                                  });
                                  
                                  ref.invalidate(sectionsListProvider);
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Timetable PDF uploaded successfully!')));
                                  }
                                } else {
                                  throw Exception(response.data['message'] ?? 'Failed to upload PDF');
                                }
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                              }
                            }
                          },
                          icon: const Icon(Icons.picture_as_pdf, size: 16),
                          label: const Text('Upload PDF'),
                        );

                        final shareButton = OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.share, size: 16),
                          label: const Text('Share'),
                        );

                        final createSlotButton = ElevatedButton.icon(
                          onPressed: () {
                            if (selectedSectionId == null || selectedAcademicYearId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select an Academic Year and Section first')));
                              return;
                            }
                            showDialog(
                              context: context, 
                              builder: (_) => TimetableSlotFormDialog(
                                sectionId: selectedSectionId!,
                                academicYearId: selectedAcademicYearId!,
                              )
                            );
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Create Slot'),
                        );

                        final desktopActionButtons = Wrap(
                          spacing: 8.w,
                          runSpacing: 8.h,
                          alignment: WrapAlignment.end,
                          children: [refreshButton, shareButton, pdfButton, uploadPdfButton, createSlotButton],
                        );

                        final mobileActionButtons = Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Expanded(child: refreshButton),
                                SizedBox(width: 8.w),
                                Expanded(child: shareButton),
                              ],
                            ),
                            SizedBox(height: 8.h),
                            Row(
                              children: [
                                Expanded(child: pdfButton),
                                SizedBox(width: 8.w),
                                Expanded(child: uploadPdfButton),
                              ],
                            ),
                            SizedBox(height: 8.h),
                            createSlotButton,
                          ],
                        );

                        final classDropdown = DropdownButtonFormField<String>(
                          isExpanded: true,
                          decoration: const InputDecoration(labelText: 'Class', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                          value: selectedClassId,
                          items: classesAsync.valueOrNull?.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList() ?? [],
                          onChanged: (v) {
                            ref.read(selectedClassIdProvider.notifier).state = v;
                            ref.read(selectedSectionIdProvider.notifier).state = null; // Reset section
                          },
                          hint: classesAsync.isLoading ? const Text('Loading...') : const Text('Select Class'),
                        );

                        final sectionDropdown = DropdownButtonFormField<String>(
                          isExpanded: true,
                          decoration: const InputDecoration(labelText: 'Section', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                          value: selectedSectionId,
                          items: sectionsAsync.valueOrNull
                              ?.where((s) => s.classId == selectedClassId)
                              .map((s) => DropdownMenuItem(value: s.id, child: Text(s.name)))
                              .toList() ?? [],
                          onChanged: (v) => ref.read(selectedSectionIdProvider.notifier).state = v,
                          hint: sectionsAsync.isLoading ? const Text('Loading...') : const Text('Sections'),
                          disabledHint: const Text('Select Class First'),
                        );

                        final yearDropdown = DropdownButtonFormField<String>(
                          isExpanded: true,
                          decoration: const InputDecoration(labelText: 'Academic Year', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                          value: selectedAcademicYearId,
                          items: yearsAsync.valueOrNull?.map((y) => DropdownMenuItem(value: y.id, child: Text(y.name))).toList() ?? [],
                          onChanged: (v) => setState(() => selectedAcademicYearId = v),
                          hint: yearsAsync.isLoading ? const Text('Loading...') : const Text('Select Year'),
                        );

                        if (isDesktop) {
                          final dropdownsDesktop = Row(
                            children: [
                              Expanded(child: classDropdown),
                              SizedBox(width: 8.w),
                              Expanded(child: sectionDropdown),
                              SizedBox(width: 8.w),
                              Expanded(child: yearDropdown),
                            ],
                          );
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(flex: 3, child: dropdownsDesktop),
                              SizedBox(width: 24.w),
                              Expanded(flex: 2, child: desktopActionButtons),
                            ],
                          );
                        } else {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Expanded(child: classDropdown),
                                  SizedBox(width: 8.w),
                                  Expanded(child: sectionDropdown),
                                ],
                              ),
                              SizedBox(height: 12.h),
                              yearDropdown,
                              SizedBox(height: 16.h),
                              mobileActionButtons,
                            ],
                          );
                        }
                      },
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
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
                      child: Column(
                        children: [
                          AppShimmer(width: double.infinity, height: 40.h, borderRadius: 8.r),
                          SizedBox(height: 8.h),
                          ...List.generate(5, (_) => Padding(
                            padding: EdgeInsets.only(bottom: 8.h),
                            child: AppShimmer(width: double.infinity, height: 60.h, borderRadius: 8.r),
                          )),
                        ],
                      ),
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
                            const DataColumn(label: Text('Day', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black))),
                            ...periods.map((p) => DataColumn(label: Text(p, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)))),
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
                                      Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          Container(
                                            constraints: const BoxConstraints(minWidth: 100),
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
                                          Positioned(
                                            top: -8,
                                            right: -8,
                                            child: IconButton(
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(),
                                              icon: const Icon(Icons.cancel, size: 18, color: Colors.redAccent),
                                              onPressed: () async {
                                                final confirm = await showDialog<bool>(
                                                  context: context,
                                                  builder: (ctx) => AlertDialog(
                                                    title: const Text('Remove Slot'),
                                                    content: const Text('Are you sure you want to remove this timetable slot?'),
                                                    actions: [
                                                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                                      TextButton(
                                                        onPressed: () => Navigator.pop(ctx, true), 
                                                        child: const Text('Remove', style: TextStyle(color: Colors.red))
                                                      ),
                                                    ],
                                                  )
                                                );
                                                
                                                if (confirm == true) {
                                                  try {
                                                    await ref.read(timetableRepositoryProvider).deleteTimetableSlot(slot.id);
                                                    ref.invalidate(sectionTimetableProvider);
                                                    if (context.mounted) {
                                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Slot removed successfully')));
                                                    }
                                                  } catch (e) {
                                                    if (context.mounted) {
                                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                                                    }
                                                  }
                                                }
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  } else {
                                    return DataCell(
                                      Center(
                                        child: TextButton.icon(
                                          onPressed: () {
                                            showDialog(
                                              context: context, 
                                              builder: (_) => TimetableSlotFormDialog(
                                                sectionId: selectedSectionId!,
                                                academicYearId: selectedAcademicYearId!,
                                              )
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
