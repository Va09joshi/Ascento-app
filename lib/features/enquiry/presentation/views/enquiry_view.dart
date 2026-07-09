import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';

class EnquiryView extends ConsumerStatefulWidget {
  const EnquiryView({super.key});

  @override
  ConsumerState<EnquiryView> createState() => _EnquiryViewState();
}

class _EnquiryViewState extends ConsumerState<EnquiryView> {
  String? selectedStatus;

  @override
  Widget build(BuildContext context) {
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
                _buildStatCard('Total Enquiries', '0'),
                SizedBox(width: 16.w),
                _buildStatCard('In Progress', '0'),
                SizedBox(width: 16.w),
                _buildStatCard('Visible Rows', '0'),
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
                          onPressed: () {},
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
                        rows: [],
                      ),
                    ),
                  ),
                  
                  Padding(
                    padding: EdgeInsets.all(48.w),
                    child: Center(child: Text('No enquiries found for current filters.', style: TextStyle(color: Colors.grey.shade600))),
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
