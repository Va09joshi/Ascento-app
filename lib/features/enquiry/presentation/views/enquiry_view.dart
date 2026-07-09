import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';
import 'package:ascento_abacus/features/enquiry/data/models/enquiry_model.dart';
import 'package:ascento_abacus/features/enquiry/presentation/providers/enquiry_provider.dart';
import 'package:ascento_abacus/features/enquiry/data/repositories/enquiry_repository.dart';

class EnquiryView extends ConsumerStatefulWidget {
  const EnquiryView({super.key});

  @override
  ConsumerState<EnquiryView> createState() => _EnquiryViewState();
}

class _EnquiryViewState extends ConsumerState<EnquiryView> {
  String? selectedStatus;

  Future<void> _updateStatus(EnquiryModel enquiry, String newStatus) async {
    try {
      await ref.read(enquiryRepositoryProvider).updateEnquiry(enquiry.id, {'status': newStatus});
      ref.invalidate(enquiriesListProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Status updated')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update: $e')));
      }
    }
  }

  Future<void> _deleteEnquiry(EnquiryModel enquiry) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Enquiry'),
        content: const Text('Are you sure you want to delete this enquiry?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await ref.read(enquiryRepositoryProvider).deleteEnquiry(enquiry.id);
        ref.invalidate(enquiriesListProvider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enquiry deleted')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final enquiriesAsync = ref.watch(enquiriesListProvider);
    final allEnquiries = enquiriesAsync.valueOrNull ?? [];
    final filteredEnquiries = allEnquiries.where((e) {
      if (selectedStatus != null && selectedStatus != 'All Status') {
        return e.status?.toLowerCase() == selectedStatus?.toLowerCase();
      }
      return true;
    }).toList();
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
                gradient: const LinearGradient(colors: [Color(0xFFE91E63), Color(0xFFFF5252)]),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ADMISSIONS DESK', style: TextStyle(color: Colors.white70, fontSize: 12.sp, letterSpacing: 1.5)),
                      SizedBox(height: 8.h),
                      Text('Enquiries', style: TextStyle(color: Colors.white, fontSize: 28.sp, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8.h),
                      Text('Better enquiry pipeline view with clean updates, safe delete, and AI-style visual support.', style: TextStyle(color: Colors.white70, fontSize: 14.sp)),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(Icons.auto_awesome, color: Colors.white70, size: 14.sp),
                          SizedBox(width: 4.w),
                          Text('AI generated enquiry visual cards', style: TextStyle(color: Colors.white70, fontSize: 12.sp)),
                        ],
                      )
                    ],
                  ),
                  Container(
                    width: 350.w,
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.white24)
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48.w, height: 48.h,
                          decoration: BoxDecoration(
                            color: Colors.orangeAccent,
                            borderRadius: BorderRadius.circular(8.r)
                          ),
                          child: Icon(Icons.change_history, color: Colors.white, size: 24.sp),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('AI Enquiry Insight Card', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.sp)),
                              SizedBox(height: 4.h),
                              Text('Visual context for faster counselling follow-up in update form.', style: TextStyle(color: Colors.white70, fontSize: 12.sp)),
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: 24.h),

            // Stats
            Row(
              children: [
                _buildStatCard('Total Enquiries', allEnquiries.length.toString()),
                SizedBox(width: 16.w),
                _buildStatCard('In Progress', allEnquiries.where((e) => e.status == 'in_progress').length.toString()),
                SizedBox(width: 16.w),
                _buildStatCard('Visible Rows', filteredEnquiries.length.toString()),
              ],
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
                        Row(
                          children: [
                            Icon(Icons.email_outlined, color: Colors.pink),
                            SizedBox(width: 8.w),
                            Text('Enquiry List', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        OutlinedButton.icon(
                          onPressed: () => ref.invalidate(enquiriesListProvider),
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text('Refresh'),
                        ),
                      ],
                    ),
                  ),

                  // Filters
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search name, email, phone, course, message',
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                            ),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          flex: 1,
                          child: DropdownButtonFormField<String>(
                            decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r))),
                            value: selectedStatus,
                            items: ['All Status', 'New', 'In Progress', 'Converted', 'Closed'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                            onChanged: (v) => setState(() => selectedStatus = v),
                            hint: const Text('All Status'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 24.h),

                  // Table
                  if (enquiriesAsync.isLoading)
                    const Padding(
                      padding: EdgeInsets.all(48.0),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (enquiriesAsync.hasError)
                    Padding(
                      padding: const EdgeInsets.all(48.0),
                      child: Center(child: Text('Error: ${enquiriesAsync.error}', style: const TextStyle(color: Colors.red))),
                    )
                  else if (filteredEnquiries.isEmpty)
                    Padding(
                      padding: EdgeInsets.all(48.w),
                      child: Center(child: Text('No enquiries found for current filters.', style: TextStyle(color: Colors.grey.shade600))),
                    )
                  else
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: DataTable(
                          headingRowColor: WidgetStateProperty.resolveWith((states) => Colors.grey.shade50),
                          border: TableBorder(bottom: BorderSide(color: Colors.grey.shade200)),
                          columns: const [
                            DataColumn(label: Text('Contact', style: TextStyle(color: Colors.grey))),
                            DataColumn(label: Text('Interest', style: TextStyle(color: Colors.grey))),
                            DataColumn(label: Text('Message', style: TextStyle(color: Colors.grey))),
                            DataColumn(label: Text('Status', style: TextStyle(color: Colors.grey))),
                            DataColumn(label: Text('Created', style: TextStyle(color: Colors.grey))),
                            DataColumn(label: Text('Action', style: TextStyle(color: Colors.grey))),
                          ],
                          rows: filteredEnquiries.map((enquiry) {
                            return DataRow(cells: [
                              DataCell(Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(enquiry.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  if (enquiry.email != null) Text(enquiry.email!, style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
                                  if (enquiry.phone != null) Text(enquiry.phone!, style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
                                ],
                              )),
                              DataCell(Text(enquiry.domainName ?? 'General')),
                              DataCell(SizedBox(
                                width: 200,
                                child: Text(enquiry.message ?? '-', maxLines: 2, overflow: TextOverflow.ellipsis),
                              )),
                              DataCell(
                                DropdownButton<String>(
                                  value: ['new', 'in_progress', 'converted', 'closed'].contains(enquiry.status) ? enquiry.status : 'new',
                                  underline: const SizedBox(),
                                  items: ['new', 'in_progress', 'converted', 'closed']
                                      .map((s) => DropdownMenuItem(value: s, child: Text(s.toUpperCase(), style: TextStyle(fontSize: 12.sp))))
                                      .toList(),
                                  onChanged: (val) {
                                    if (val != null) _updateStatus(enquiry, val);
                                  },
                                )
                              ),
                              DataCell(Text(enquiry.createdAt.toIso8601String().split('T')[0])),
                              DataCell(IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: () => _deleteEnquiry(enquiry),
                              )),
                            ]);
                          }).toList(),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            Padding(
              padding: EdgeInsets.only(top: 16.h),
              child: Text('API coverage: GET /admin/enquiries, PUT /admin/enquiries/:id, DELETE /admin/enquiries/:id', style: TextStyle(color: Colors.grey, fontSize: 10.sp)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 12.sp)),
            SizedBox(height: 8.h),
            Text(value, style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
